#!/usr/bin/env python3
"""C2 golden model — security/accuracy Pareto operating-point selection.

Mirrors rtl/core/sec_acc_pareto.v exactly:
  1. feasible[k] = area<=max_area and acc>=min_acc and sec>=min_sec
  2. k is Pareto  <=> no other feasible j strictly dominates k on
                      (acc up, sec up, area down)
  3. pick MIN area among Pareto-feasible (tie-break: lowest index)

run_budget(name, max_area, min_acc, min_sec, exp) returns PASS/FAIL.
"""
import io
import sys

NCFG = 8

# index: (quant, order, acc, sec, area)
ROM = [
    (4, 1, 120, 40, 100),
    (5, 1, 150, 40, 130),
    (6, 1, 175, 40, 160),
    (4, 2, 125, 90, 180),
    (5, 2, 160, 90, 210),
    (6, 2, 185, 90, 240),
    (7, 3, 210, 140, 350),
    (5, 1, 140, 40, 135),   # dominated by index 1
]

def solve(max_area, min_acc, min_sec):
    """Return (sel_idx, feasible_cnt, pareto_cnt, no_solution, feas, pareto)."""
    feas = []
    for k in range(NCFG):
        q, o, a, s, ar = ROM[k]
        feas.append(ar <= max_area and a >= min_acc and s >= min_sec)
    fcnt = sum(feas)

    pareto = []
    for k in range(NCFG):
        if not feas[k]:
            pareto.append(False)
            continue
        _, _, ak, sk, ark = ROM[k]
        dominated = False
        for j in range(NCFG):
            if j == k or not feas[j]:
                continue
            _, _, aj, sj, arj = ROM[j]
            if (aj >= ak and sj >= sk and arj <= ark and
                    (aj > ak or sj > sk or arj < ark)):
                dominated = True
                break
        pareto.append(not dominated)
    pcnt = sum(pareto)

    sel = 15
    for k in range(NCFG):
        if pareto[k]:
            if sel == 15 or ROM[k][4] < ROM[sel][4]:
                sel = k
    return sel, fcnt, pcnt, (sel == 15), feas, pareto


def show_frontier(feas, pareto):
    lines = []
    for k in range(NCFG):
        q, o, a, s, ar = ROM[k]
        lines.append("  cfg%d q%do%d acc=%3d sec=%3d area=%4d  feas=%d pareto=%d"
                     % (k, q, o, a, s, ar, int(bool(feas[k])), int(bool(pareto[k]))))
    return "\n".join(lines)


def run_budget(name, max_area, min_acc, min_sec, exp):
    sel, fcnt, pcnt, nosol, feas, pareto = solve(max_area, min_acc, min_sec)
    print("== %s: budget area<=%d acc>=%d sec>=%d" % (name, max_area, min_acc, min_sec))
    print(show_frontier(feas, pareto))
    print("   -> sel=%d feas=%d pareto=%d nosol=%d   (exp sel=%d feas=%d pareto=%d nosol=%d)"
          % (sel, fcnt, pcnt, int(nosol), exp[0], exp[1], exp[2], exp[3]))
    ok = (sel == exp[0]) and (fcnt == exp[1]) and (pcnt == exp[2]) and (nosol == exp[3])
    print(("PASS " if ok else "FAIL ") + name)
    return ok


def main():
    ok = True
    ok &= run_budget("T2 wide",       200,    0,    0, (0,  5, 4, False))
    ok &= run_budget("T3 acc180",     300,  180,    0, (5,  1, 1, False))
    ok &= run_budget("T4 acc200sec100", 1000, 200, 100, (6,  1, 1, False))
    ok &= run_budget("T5 sec80",      500,  100,   80, (3,  4, 4, False))
    ok &= run_budget("T6 noarea",      50,    0,    0, (15, 0, 0, True))
    ok &= run_budget("T7 nosec",     1000,    0,  255, (15, 0, 0, True))
    ok &= run_budget("T8 dom",        135,    0,    0, (0,  3, 2, False))

    # ---- structural properties -------------------------------------------------
    # the frontier must be strictly cheaper than the dominated config 7 when 7 is feasible
    _, _, pcnt, _, feas, pareto = solve(135, 0, 0)
    ok &= check("T8 dominance: cfg7 feasible but removed", feas[7] and not pareto[7])
    # the unfiltered feasible set for the same budget is exactly 3
    ok &= check("T8 feasible set {0,1,7}", feas[0] and feas[1] and feas[7] and not (feas[2] or feas[3] or feas[4]))
    # dominance is transitive-safe: cfg7 dominated by cfg1, and cfg1 itself is on the frontier
    ok &= check("T8 cfg1 remains on the frontier", pareto[1])

    # no budget can ever select a config that violates any constraint
    worst = True
    for area in (60, 90, 130, 145, 200, 300, 500, 1000):
        for a in (0, 100, 150, 180, 200, 250):
            for s in (0, 45, 80, 100, 140, 200):
                sel, f, p, nosol, fe, pa = solve(area, a, s)
                if nosol:
                    if sel != 15 or f != 0 or p != 0:
                        worst = False
                else:
                    q, o, acc, sec, ar = ROM[sel]
                    if not (ar <= area and acc >= a and sec >= s):
                        worst = False
                    if pa.count(True) != p:
                        worst = False
                    if fe.count(True) != f:
                        worst = False
                    if f < p:
                        worst = False
    ok &= check("T10 sweep: 288 budgets, sel always feasible, no_solution consistent", worst)

    # selection must be deterministic and idempotent
    ok &= check("T11 determinism",
                solve(500, 100, 80)[:4] == solve(500, 100, 80)[:4])

    print("=== GOLDEN %s ===" % ("ALL PASS" if ok else "FAILURES"))
    return 0 if ok else 1


def check(name, cond):
    print(("PASS " if cond else "FAIL ") + name)
    return cond


if __name__ == "__main__":
    sys.exit(main())
