#!/usr/bin/env python3
"""
VCD to SAIF converter for Vivado report_power (hierarchy-aware, v4).

v4 fix (the critical one): iverilog reuses one VCD identifier for every
electrically-equivalent net (a design net AND all its connected cell pins
are the SAME electrical net, so iverilog merges them into one VCD id).
A naive id->name dict silently overwrites, dropping design nets and
attributing their activity to a cell pin name -> read_saif matches 0%.

Verified on the real 852MB VCD: 848,823 ids, of which 0 ids carry more than
one *design-net* name -> each design net has a unique id, shared only with
its own pins. So the fix is: map id -> SET of names, and emit the id's
stats under EVERY name. read_saif then matches whichever name style the
checkpoint uses (design-net '_n_0'/'_i_N' style, or cell-pin '/O' style).

v3 -> v4:
  - build_id_map returns {id: set(names)} (was {id: one name}).
  - write_saif emits each id's (T0,T1,TX,TC) under all of its names.
  - Everything else (streaming, ps->ns, scope tracking, escape stripping)
    unchanged.

Honors $scope/$upscope so net names carry full hierarchy (relative to the
<dut_scope> instance), which read_saif needs to map onto design nets.
Skips parameter/integer/time/event/real vars. Bus (vector) nets: one
toggle per distinct value change; T0 only when all-zeros, T1 only when
all-ones, else TX.

Usage: python vcd_to_saif.py <input.vcd> <output.saif> [top_name] [dut_scope]
"""
import sys
import re

SKIP_TYPES = {"parameter", "integer", "time", "event", "real", "realtime"}

# Primitive cell pins (from UNISIM funcsim models). Used only to decide
# whether to ALSO emit the cell-pin name; the design-net name is what
# read_saif really needs. Emitting both is harmless (read_saif ignores
# names that are not nets in the checkpoint).
PIN_LEAVES = {
    "O", "O_out", "CE", "CLR_in", "D", "I0", "I1", "I2", "I3", "I4", "I5",
    "Q", "Q_out", "glblGSR", "INIT_REG", "trig_attr",
    "IS_CLR_INVERTED_REG", "IS_C_INVERTED_REG", "IS_D_INVERTED_REG",
    "C", "R", "S", "T", "A", "B", "DI", "DO", "ADDR", "WE", "CLK",
    "GND", "VCC", "P", "G",
}


def build_id_map(vcd_path, dut_scope="dut"):
    """Parse header; return ({id: set(hier_names)}, header_end_offset).

    Names are relative to the <dut_scope> instance root and joined with '/'
    (the SAIF hierarchy divider), e.g. 'u_kem/acc_reg[116][3]'.

    VCD identifiers may be escaped with a leading '\\' (e.g. '\\wdog_reg[0]');
    the '\\' is an escape marker, not part of the real net name, so it is
    stripped. A trailing VCD bit-range '[msb:lsb]' (contains a colon) is
    removed; a bare '[N]' is part of the net name and is kept.

    Returns the byte offset where the value-change section starts.
    """
    id_to_names = {}  # id -> set of hierarchical names (one per $var)
    scope_stack = []
    in_dut = False
    dut_depth = 0
    header_end = 0

    with open(vcd_path, 'rb') as f:
        while True:
            line = f.readline()
            if not line:
                break
            line = line.strip()
            if not line:
                continue
            if line.startswith(b"$scope"):
                parts = line.split()
                if len(parts) >= 3:
                    sname = parts[2].decode("latin1").lstrip("\\")
                    scope_stack.append(sname)
                    if sname == dut_scope and not in_dut:
                        in_dut = True
                        dut_depth = len(scope_stack)
            elif line.startswith(b"$upscope"):
                if scope_stack:
                    scope_stack.pop()
                if in_dut and len(scope_stack) < dut_depth:
                    in_dut = False
            elif line.startswith(b"$var"):
                if not in_dut:
                    continue
                parts = line.split()
                if len(parts) < 5:
                    continue
                vtype = parts[1].decode("latin1")
                if vtype in SKIP_TYPES:
                    continue
                sig_id = parts[3].decode("latin1")
                name_parts = []
                for p in parts[4:]:
                    if p == b"$end":
                        break
                    name_parts.append(p.decode("latin1"))
                sig_name = " ".join(name_parts).strip()
                # strip ONLY a VCD bit-range [msb:lsb] (contains ':');
                # a bare [N] or [N][M] is part of the net name.
                sig_name = re.sub(r'\[\d+:\d+\]\s*$', '', sig_name).strip()
                # strip VCD escape marker (leading backslash)
                sig_name = sig_name.lstrip("\\")
                rel_scope = scope_stack[dut_depth:]
                full = "/".join(rel_scope + [sig_name]) if rel_scope \
                    else sig_name
                id_to_names.setdefault(sig_id, set()).add(full)
            elif line.startswith(b"$enddefinitions"):
                header_end = f.tell()  # exact byte position after this line
                break
    return id_to_names, header_end


def _classify(val):
    """Map a raw value token to '0'|'1'|'x'."""
    if val in ('0', '1', 'x', 'X'):
        return val.lower()
    if all(c == '0' for c in val):
        return '0'
    if all(c == '1' for c in val):
        return '1'
    return 'x'


def stream_stats(vcd_path, id_to_names, header_end):
    """Stream the value section once; return ({id: (t0ps,t1ps,txps,tc)}, last_ts).

    Per-signal tail time (last transition -> EOF timestamp) is added to the
    correct bucket so T0+T1+TX == DURATION for every signal.
    """
    state = {}  # id -> [prev_val, prev_time, t0, t1, tx, tc]
    cur_time = 0
    last_ts = 0
    with open(vcd_path, 'rb') as f:
        f.seek(header_end)
        while True:
            line = f.readline()
            if not line:
                break
            line = line.strip()
            if not line:
                continue
            c = line[:1]
            if c == b"#":
                digits = line[1:]
                if digits.isdigit():
                    cur_time = int(digits)
                    last_ts = cur_time
                continue
            if c == b"$":
                # $dumpvars/$end/$dumpall... skip whole directive line
                continue
            if c in (b"0", b"1", b"x", b"X", b"z", b"Z"):
                val = chr(c[0])
                sig_id = line[1:].decode("latin1")
                if sig_id not in id_to_names:
                    continue
                st = state.get(sig_id)
                if st is None:
                    state[sig_id] = [val, cur_time, 0, 0, 0, 0]
                    continue
                dt = cur_time - st[1]
                if dt < 0:
                    dt = 0
                if st[0] == '0':
                    st[2] += dt
                elif st[0] == '1':
                    st[3] += dt
                else:
                    st[4] += dt
                cv = _classify(val)
                if cv != st[0]:
                    st[5] += 1
                st[0] = cv
                st[1] = cur_time
            elif c in (b"b", b"B"):
                parts = line.split()
                if len(parts) == 2:
                    val_str = parts[0][1:].decode("latin1")
                    sig_id = parts[1].decode("latin1")
                    if sig_id not in id_to_names:
                        continue
                    st = state.get(sig_id)
                    if st is None:
                        state[sig_id] = [_classify(val_str), cur_time,
                                         0, 0, 0, 0]
                        continue
                    dt = cur_time - st[1]
                    if dt < 0:
                        dt = 0
                    if st[0] == '0':
                        st[2] += dt
                    elif st[0] == '1':
                        st[3] += dt
                    else:
                        st[4] += dt
                    cv = _classify(val_str)
                    if cv != st[0]:
                        st[5] += 1
                    st[0] = cv
                    st[1] = cur_time

    # finalize: add tail time (last transition -> last_ts)
    stats = {}
    for sig_id, st in state.items():
        tail = last_ts - st[1]
        if tail > 0:
            if st[0] == '0':
                st[2] += tail
            elif st[0] == '1':
                st[3] += tail
            else:
                st[4] += tail
        t0, t1, tx, tc = st[2], st[3], st[4], st[5]
        if tc > 0 or t0 > 0 or t1 > 0:
            stats[sig_id] = (t0, t1, tx, tc)
    return stats, last_ts


def _is_cell_pin(name):
    """True if the name's leaf looks like a UNISIM cell pin (cell/pin)."""
    leaf = name.rsplit('/', 1)[-1]
    return leaf in PIN_LEAVES


def write_saif(stats_by_id, id_to_names, total_time_ns, top_name, saif_path):
    """Write SAIF. stats (t0,t1,tx,tc) in ps -> divide by 1000 for ns.

    Emits each id's stats under EVERY hierarchical name that id was seen
    with (the id is the electrical net; all its names carry the same value).

    Uses EXACTLY the Vivado-documented xsim SAIF format (verified against
    docs.amd.com UG906 "Example SAIF File Dump"):
        (SAIFILE
          (SAIFVERSION "2.0")
          (DIRECTION "backward")
          (DESIGN "...")
          (DATE "...")
          (VENDOR "...")
          (PROGRAM_NAME "...")
          (VERSION "...")
          (DIVIDER /)
          (TIMESCALE 1 ns)
          (DURATION ...)
          (INSTANCE <top>
            (NET (name (T0 ...) (T1 ...) (TX ...) (TC ...)) ...)
          )
        )
    Critically: (1) header must start SAIFILE -> SAIFVERSION -> DIRECTION in
    that order (else Vivado Power 33-52 "expecting DIRECTION"); (2) NET name
    is UNQUOTED and grouped with its attributes as (NET (name (attrs)));
    (3) names containing '(' or ')' (iverilog '(null)' scopes, keccak
    theta_round flattened slices) break the S-expression and are SKIPPED --
    they have no mapped post-synthesis design net anyway.
    """
    # name -> (t0,t1,tx,tc), dedup so each name appears once
    name_stats = {}
    n_names = 0
    n_skipped = 0
    for sig_id, st in stats_by_id.items():
        names = id_to_names.get(sig_id)
        if not names:
            continue
        for nm in names:
            if '(' in nm or ')' in nm:
                # iverilog '(null)' scope -> breaks S-expr; no design net
                n_skipped += 1
                continue
            name_stats[nm] = st
            n_names += 1

    with open(saif_path, 'w') as f:
        f.write("(SAIFILE\n")
        f.write('  (SAIFVERSION "2.0")\n')
        f.write('  (DIRECTION "backward")\n')
        f.write('  (DESIGN "%s")\n' % top_name)
        f.write('  (DATE "Sun Nov  8 00:00:00 2026")\n')
        f.write('  (VENDOR "Icarus")\n')
        f.write('  (PROGRAM_NAME "iverilog")\n')
        f.write('  (VERSION "12.0")\n')
        f.write("  (DIVIDER /)\n")
        f.write("  (TIMESCALE 1 ns)\n")
        f.write("  (DURATION %d.0)\n" % total_time_ns)
        f.write('  (INSTANCE %s\n' % top_name)
        # One (NET ...) block containing every name as (name (attrs)).
        f.write('    (NET\n')
        for name, (t0, t1, tx, tc) in sorted(name_stats.items()):
            f.write('      (%s (T0 %d) (T1 %d) (TX %d) (TC %d))\n'
                    % (name, int(t0 / 1000), int(t1 / 1000),
                       int(tx / 1000), tc))
        f.write('    )\n')
        f.write('  )\n')
        f.write(')\n')
    return n_names, n_skipped


def convert_vcd_to_saif(vcd_path, saif_path, top_name=None, dut_scope="dut"):
    print("  Parsing VCD header (hierarchy-aware)...", flush=True)
    id_to_names, header_end = build_id_map(vcd_path, dut_scope=dut_scope)
    n_ids = len(id_to_names)
    n_vars = sum(len(v) for v in id_to_names.values())
    print("  DUT ids: %d  names: %d  header_end=%.1fMB"
          % (n_ids, n_vars, header_end / 1e6), flush=True)

    print("  Streaming value section...", flush=True)
    stats_by_id, max_time = stream_stats(vcd_path, id_to_names, header_end)

    total_time = max_time // 1000  # ps -> ns
    print("  Active ids: %d" % len(stats_by_id), flush=True)
    print("  Total time: %d ns (VCD end %d ps)" % (total_time, max_time),
          flush=True)

    if top_name is None:
        top_name = "top"

    print("  Writing SAIF (top=%s)..." % top_name, flush=True)
    n_names, n_skipped = write_saif(stats_by_id, id_to_names, total_time,
                                    top_name, saif_path)
    print("  SAIF net entries: %d  skipped_paren_names: %d"
          % (n_names, n_skipped), flush=True)
    return n_names, total_time


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python vcd_to_saif.py <input.vcd> <output.saif> "
              "[top_name] [dut_scope]")
        sys.exit(1)
    top = sys.argv[3] if len(sys.argv) > 3 else None
    dut = sys.argv[4] if len(sys.argv) > 4 else "dut"
    convert_vcd_to_saif(sys.argv[1], sys.argv[2], top, dut)
