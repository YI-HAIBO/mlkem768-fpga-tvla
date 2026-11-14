#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Verilog syntax verification (iverilog -p)
Handles Chinese project paths natively via Python subprocess.
Author: Dr. Haibo Yi (Shenzhen Tech University)
Date: 2026-10-07
"""

import os
import subprocess
import sys
from pathlib import Path

# Absolute base path to avoid cwd confusion
PROJECT_ROOT = Path(__file__).parent.parent
BASE = PROJECT_ROOT / "rtl"

def find_verilog_files(dir_path):
    files = []
    for root, _, fnames in os.walk(dir_path):
        for fname in fnames:
            if fname.endswith(".v"):
                files.append(os.path.join(root, fname))
    return files

def main():
    rtl_files = find_verilog_files(BASE)
    if not rtl_files:
        print("No .v files found.")
        sys.exit(1)

    # Use -p for preprocessor-only check (no output file)
    cmd = ["iverilog", "-g2012", "-p", "-f", "-"] + rtl_files

    p = subprocess.run(
        cmd,
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
        shell=False
    )

    if p.returncode == 0:
        print(f"VERILOG SYNTAX PASS ({len(rtl_files)} files)")
    else:
        print(f"VERILOG SYNTAX FAIL (returncode={p.returncode})")
        stdout = p.stdout[-1000:] if len(p.stdout) > 1000 else p.stdout
        stderr = p.stderr[-1000:] if len(p.stderr) > 1000 else p.stderr
        print("STDOUT:", stdout)
        print("STDERR:", stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
