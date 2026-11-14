# -*- coding: utf-8 -*-
"""
ots_wrapper.py -- OpenTimestamps client launcher for Python 3.13 on Windows.

Problem (Task 90 / OTS receipts):
  python-bitcoinlib's bitcoin/core/key.py does:
      _ssl = ctypes.cdll.LoadLibrary(
          ctypes.util.find_library('ssl.35') or ctypes.util.find_library('ssl')
          or ctypes.util.find_library('libeay32'))
  On Python 3.13 (managed runtime) `ctypes.util.find_library('ssl')` returns
  None, so LoadLibrary(None) -> TypeError: LoadLibrary() argument 1 must be
  str, not None.

  Also, in OpenSSL 3.x the BN_*/EC_*/ECDSA_*/ERR_* symbols that key.py reads
  off the `_ssl` handle all live in **libcrypto** (libssl is TLS-protocol only
  and does not re-export them reliably). So mapping 'ssl' -> libcrypto dll is
  both necessary and correct for this package.

Fix:
  Patch ctypes.util.find_library BEFORE importing bitcoin/otsclient so that
  'ssl' / 'crypto' names resolve to the bundled libcrypto-3-x64.dll. secp256k1
  is left untouched (bitcoin.core.key guards it with is_libsec256k1_available()
  and falls back to OpenSSL).

Usage:
  python ots_wrapper.py <subcommand> [args...]
  e.g.  python ots_wrapper.py info <file.ots>
"""
import ctypes.util
import os
import sys

_CRYPTO_DLL = r"C:\Users\Yi\.workbuddy\binaries\python\versions\3.13.12\DLLs\libcrypto-3-x64.dll"
_SSL_DLL = r"C:\Users\Yi\.workbuddy\binaries\python\versions\3.13.12\DLLs\libssl-3-x64.dll"

_orig_find_library = ctypes.util.find_library


def _find(name):
    n = (name or "").lower()
    if n in ("ssl", "ssl.35", "libeay32", "libssl", "libssl-3-x64"):
        return _CRYPTO_DLL  # key.py reads BN_*/EC_*/ERR_* -> all in libcrypto
    if n in ("crypto", "libcrypto", "libcrypto-3-x64"):
        return _CRYPTO_DLL
    return _orig_find_library(name)


ctypes.util.find_library = _find


def main():
    from otsclient.ots import main as ots_main
    return ots_main()


if __name__ == "__main__":
    sys.exit(main())
