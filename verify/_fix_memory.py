import re
p = r'C:/Users/Yi/.workbuddy/MEMORY.md'
txt = open(p, encoding='utf-8').read()
head = '## Vivado 2026.1 中文 CWD 必崩（2026-10-24 实证，17 轮 bisect）'
i = txt.find(head)
assert i >= 0, 'section not found'
txt = txt[:i].rstrip('\n') + '\n\n'

txt += '''## Vivado 2026.1 中文 CWD 必崩（2026-10-24 实证，17 轮 bisect）

**铁律：启动 Vivado 的进程 CWD 必须 100% ASCII**（项目/报告路径本来就在
C:/tmp_* 下，只有脚本的继承 CWD 常是中文项目目录）。

- 症状：cmd=synth_design 的 "Starting RTL Elaboration" 后立即
  rc=0xC0000374（STATUS_HEAP_CORRUPTION），log 停在
  "done synthesizing module 'xxx' (0#1)"。
- 机制：Vivado 把 .Xil/Vivado-<pid>-<user>/elab.rtd 写进 CWD，中文路径在
  MBCS 边界被破坏（Verific 流程直接 mojibake 报
  "Failed to open file .../璋冪爺FPGA..."，Rodin 流程则 heap corruption）。
- 与设计内容**无关**：16 位计数器也崩；maxThreads=1 /
  synth.enableParallelHelperSpawn=0 / read_verilog / 杀孤儿进程全部无效。
- 决定性证据：唯一成功的一次 log 里 "Current directory:
  c:/Users/Yi/WorkBuddy/2026-10-05-09-29-14"（ASCII），所有崩溃运行 CWD
  都是中文项目目录。
- 修复：subprocess.Popen(..., cwd=<ASCII 临时目录>)。已固化在
  ipx_aoi_fpga_prototype 的 scripts/impl_unified_ntt.py 与
  scripts/synth_unified_ntt.py 的 run_vivado()。
- 挖 Vivado 内部参数的方法：对 Vivado/lib/win64.o/xv_synth.dll 做正则
  re.finditer(rb'[ -~]{6,}', region) 扫可打印 ASCII 串（可找到
  synth.elab.tool / synth.enableParallelHelperSpawn 等未文档化参数名）。
'''
open(p, 'w', encoding='utf-8', newline='\n').write(txt)
print('rewrote, total', len(txt))
