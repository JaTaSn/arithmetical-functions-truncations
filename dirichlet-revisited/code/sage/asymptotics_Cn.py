#!/usr/bin/env python3
# asymptotics_Cn.py -- large-scale numerics for C_n, the number of minimal
# generators of the truncation ideal I_n of Snellman (2000).
#
# The direct enumeration in recompute_truncations.sage is O(n * p_{pi(n)}) and
# dies well before n = 10^4.  A182843 (which this sequence turns out to be,
# shifted) carries an increment formula due to Fintan Costello:
#
#     C_n - C_{n-1} = [n is prime] + (pi(lpf(n)) - 1)
#
# That is verified here against the direct enumeration for n <= 200 before
# being used to sieve out to 10^7 -- the point being to see how C_n/n actually
# behaves, since the paper's own table stops at n = 30.
#
# Changelog (reverse chronological):
#   2026-08-25  Claude-Code-6d5c5b66 (jts-pc) -- initial version.

import sys
from sympy import factorint, primepi, prime

# ------------------------------------------------- direct (slow, trustworthy)
def C_direct(n):
    r = int(primepi(n)); pr = prime(r)
    c = 0
    for W in range(n + 1, n * pr + 1):
        ps = sorted(factorint(W))
        if ps[-1] <= n and W <= n * ps[0]:
            c += 1
    return c

# ------------------------------------------------------ sieve (fast)
def sieve_lpf(N):
    """lpf[i] = least prime factor of i, and a list of primes up to N."""
    lpf = [0] * (N + 1)
    for i in range(2, N + 1):
        if lpf[i] == 0:
            for j in range(i, N + 1, i):
                if lpf[j] == 0:
                    lpf[j] = i
    return lpf

def C_sieve(N):
    lpf = sieve_lpf(N)
    # pi_index[p] = index of prime p (p_1 = 2 -> 1)
    idx, k = {}, 0
    for i in range(2, N + 1):
        if lpf[i] == i:
            k += 1; idx[i] = k
    out = [0] * (N + 1)
    cur = 0
    for n in range(2, N + 1):
        cur += (1 if lpf[n] == n else 0) + (idx[lpf[n]] - 1)
        out[n] = cur
    return out

if __name__ == "__main__":
    print("[verify] sieve recurrence vs. direct enumeration, n = 2..200")
    S = C_sieve(200)
    bad = [n for n in range(2, 201) if S[n] != C_direct(n)]
    print("   mismatches:", bad if bad else "NONE -- recurrence confirmed")
    if bad:
        sys.exit(1)

    N = 10 ** 7
    print("\n[sieve] computing C_n up to n = %d ..." % N)
    S = C_sieve(N)
    print("\n   n        C_n            C_n/n     C_n/(n*loglog n)")
    from math import log
    for n in [10, 30, 100, 300, 1000, 3000, 10**4, 3*10**4, 10**5,
              3*10**5, 10**6, 3*10**6, 10**7]:
        ll = log(log(n)) if n > 3 else 1.0
        print("   %-9d %-14d %-9.4f %.4f" % (n, S[n], S[n] / n, S[n] / (n * ll)))
    print("\n   C_n for n = 2..30:", S[2:31])
