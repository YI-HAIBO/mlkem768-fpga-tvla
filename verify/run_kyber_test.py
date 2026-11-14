import sys, os
# Add kyber-py to path
kyber_dir = r"C:\Users\Yi\.workbuddy\binaries\python\envs\default\kyber-py"
if os.path.isdir(kyber_dir):
    sys.path.insert(0, kyber_dir)
    print(f"Added kyber-py path: {kyber_dir}")
else:
    print(f"WARNING: kyber-py dir not found: {kyber_dir}")

# Now run the test
exec(open(r"C:\Users\Yi\WorkBuddy\2026-10-05-09-29-14\调研FPGA大模型安全\研发\ipx_aoi_fpga_prototype\verify\test_kyber_py3.py", encoding="utf-8").read())