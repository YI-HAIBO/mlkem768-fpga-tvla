import sys, importlib
print("python", sys.version)
for mod in ["Crypto.Hash.keccak", "Crypto.Hash.keccak", "sha3", "tinykeccak", "keccak"]:
    try:
        m = importlib.import_module(mod)
        print("OK", mod, "->", [a for a in dir(m) if not a.startswith('_')][:20])
    except Exception as e:
        print("NO", mod, "->", type(e).__name__, e)