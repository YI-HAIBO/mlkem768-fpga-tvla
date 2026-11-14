"""Update project_manifest.json: A1 SIGN-mode bit-exact verification landed."""
import io, json, os, sys

P = r"C:\Users\Yi\WorkBuddy\2026-10-05-09-29-14\调研FPGA大模型安全\研发\ipx_aoi_fpga_prototype\project_manifest.json"
d = json.load(io.open(P, encoding="utf-8"))

a1 = None
for it in d["algorithm_innovations"]["innovations"]:
    if it["id"] == "A1":
        a1 = it
        break
assert a1, "A1 entry not found"

a1["description"] = (
    "参数化统一 NTT 模块，共享蝶形/乘法器硬件，支持 Kyber(q=3329, 7 层, BW=16) "
    "和 Dilithium(q=8380417, 8 层, BW=27, W_WIDTH=54)；Zeta ROM 深度参数化 "
    "2^N_LAYERS（128/256），SCALE_K=R^2*C^-1 mod q（实测原始往返因子 C=256=N，"
    "即干净逆）"
)
a1["files"] = [
    "rtl/core/unified_ntt.v",
    "sim/tb_unified_ntt.v",
    "sim/tb_unified_ntt_sign.v",
    "verify/gen_sign_tb.py",
    "verify/ntt_model.py",
    "verify/gen_sign_params.py",
    "verify/verify_sign_model.py",
    "verify/run2.py",
    "verify/run_all_ntt.py",
    "verify/golden_sign_ntt.log",
    "verify/golden_kem_ntt.log",
    "verify/golden_sign_model.log",
    "docs/innovation_A1_unified_ntt.md",
]
a1["verification"] = (
    "PASS - 双模式位精确 (iverilog -g2012): KEM 回归 4/4；SIGN 6/6，含前向与"
    "黄金模型 256/256 位精确、往返 5 多项式 1280 系数、隔离逆变换、以及 "
    "poly_mul == 教科书负环卷积*R 黄金基准。独立 Python 黄金模型 4 类性质 x "
    "60 组随机向量 ALL PASS，零定点溢出、零 Barrett 越界，中间值峰值 "
    "30315562 << 2^26"
)
a1["sign_mode"] = {
    "status": "bit_exact_verified",
    "q": 8380417,
    "bw": 27,
    "w_width": 54,
    "n_layers": 8,
    "qinv": 58728449,
    "r_mod": 131056,
    "scale_k": 49145,
    "barrett_m": 33587228,
    "barrett_sh": 48,
    "zeta_entries": 256,
    "peak_intermediate_abs": 30315562,
    "signed_bw_max": 67108863,
    "raw_roundtrip_factor_C": 256,
    "note": (
        "SIGN 模式最初报 1275/1280 往返失败；定位为测试平台期望值算式的 32 位"
        "溢出（f*R 需 44 位，`reg [31:0]` 在取模前截断），RTL 本身正确。"
        "修正为 64 位中间量后全绿。"
    ),
}

d["version"] = "3.3.0"
d["last_updated"] = "2026-10-21"
d["algorithm_innovations"]["note"] = (
    "13/13 已落地创新方向全部完成；A1 现已补完 SIGN 模式（Dilithium）位精确"
    "验证，KEM+SIGN 双模式均达位精确级别。"
)

with io.open(P, "w", encoding="utf-8", newline="\n") as fh:
    json.dump(d, fh, ensure_ascii=False, indent=2)
    fh.write("\n")

print("version ->", d["version"])
print("last_updated ->", d["last_updated"])
print("A1 files:", len(a1["files"]))
print("A1 status:", a1["status"])
print("invasions:", len(d["algorithm_innovations"]["innovations"]))
print("all completed:", all(i["status"] == "completed"
                            for i in d["algorithm_innovations"]["innovations"]))
print("OK")
