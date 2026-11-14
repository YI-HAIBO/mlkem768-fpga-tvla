# Derive the correct rho rotation table from the Keccak traversal and compare to my RTL table.
# Traversal: (x,y)=(1,0); for t in 0..23: (x,y)=(y,(2x+3y)%5); the value consumed at step t
# (the lane that is the position at the START of step t) gets rotation (t+1)(t+2)//2 mod 64.
mine = [0,1,62,28,27, 36,44,6,55,20, 3,10,25,39,8, 41,45,15,21,14, 18,2,61,56,47]
x, y = 1, 0
correct = [0]*25
correct[0] = 0  # (0,0) fixed point
for t in range(24):
    lane = x + 5*y
    correct[lane] = ((t+1)*(t+2)//2) % 64
    x, y = y, (2*x+3*y) % 5
print("correct ROT (indexed by lane = x+5*y):")
print(correct)
print("mine:  ", mine)
print("diffs:")
ok = True
for i in range(25):
    if correct[i] != mine[i]:
        ok = False
        x_, y_ = i % 5, i // 5
        print("  lane %2d (x=%d y=%d): mine=%d correct=%d" % (i, x_, y_, mine[i], correct[i]))
print("ALL MATCH" if ok else "MISMATCH - need fix")