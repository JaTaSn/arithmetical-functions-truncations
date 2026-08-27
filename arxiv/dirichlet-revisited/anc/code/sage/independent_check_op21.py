# Changelog (reverse-chronological)
# 2026-08-27 - added an explicit check of the manuscript's Lemma 21 (the exact splitting
#   S_2 = T - (P-1)P(2P-1)/6 with T = sum_j (j-1) pi(n/p_j)).  An adversarial review found
#   that the six-stage report verifies Lemma 20's closed form and NOT Lemma 21's -- the two
#   look alike but are different statements, and nothing in runs/ covered the second.  Note
#   also that the six-stage report uses the name T(n) for an unrelated quantity,
#   (9/8) pi(n^{1/3})^4, in its Omega >= 3 table.
# 2026-08-27 - Claude: created. An independent re-check of the subagent's Open Problem 21 result,
#   written without reference to code/openproblem21_asymptotics.py: a plain lpf sieve, S(n) and its
#   semiprime part S_2(n) summed directly, compared against A(n) = (2/3)pi(sqrt n)^3. Also
#   reproduces C_n for n = 10^6 and 10^7 as a check on the sieve itself, against Table 1 of the
#   manuscript. Needs numpy, so run under `sage` -- the system python here has neither numpy nor
#   matplotlib.

import numpy as np

def lpf_sieve(N):
    lpf = np.zeros(N + 1, dtype=np.int32)
    for i in range(2, int(N**0.5) + 1):
        if lpf[i] == 0:
            lpf[i*i::i] = np.where(lpf[i*i::i] == 0, i, lpf[i*i::i])
    rest = np.arange(N + 1, dtype=np.int32)
    lpf = np.where(lpf == 0, rest, lpf)
    return lpf

for N in [10**6, 10**7]:
    lpf = lpf_sieve(N)
    x = np.arange(N + 1)
    isprime = (lpf == x) & (x >= 2)
    # pi(m) for m <= N
    pi = np.cumsum(isprime.astype(np.int64))
    composite = (x >= 4) & ~isprime
    # S(n) = sum over composite x<=n of (pi(lpf x) - 1)
    S = int(np.sum(pi[lpf[composite]] - 1))
    # semiprime part: x = p*q with p = lpf x, q = x/p prime
    co = x[composite]
    cof = co // lpf[composite]
    semi = isprime[cof]
    S2 = int(np.sum(pi[lpf[composite]][semi] - 1))
    P = int(pi[int(N**0.5)])
    A = (2.0/3.0) * P**3
    Cn_minus = S  # this IS C_n - binom(pi(n)+1,2)
    print(f"n=10^{len(str(N))-1}: S={S:>14,}  S2={S2:>14,}  Omega>=3 part={S-S2:>12,}")
    print(f"          pi(sqrt n)={P},  A=(2/3)pi(sqrt n)^3={A:,.0f}")
    print(f"          S2/A = {S2/A:.4f}   S/A = {S/A:.4f}   S*log^3(n)/n^1.5 = {S*np.log(N)**3/N**1.5:.3f}")
    # cross-check against the manuscript's Table 1 where available
    from math import comb
    pin = int(pi[N])
    print(f"          C_n = binom(pi(n)+1,2)+S = {comb(pin+1,2)+S:,}   (pi(n)={pin})")
    # Lemma 21, the exact splitting, checked as its own statement rather than inferred
    # from Lemma 20: with p_1 < ... < p_P the primes <= sqrt n, pi(p_j) = j exactly, so
    #     S_2(n) = sum_j (j-1) pi(n/p_j)  -  (P-1)P(2P-1)//6.
    sq = list(x[isprime])
    P = int(pi[int(N**0.5)])
    primes_le_sqrt = [int(q) for q in sq if q * q <= N]
    T = sum((j + 1 - 1) * int(pi[N // p]) for j, p in enumerate(primes_le_sqrt))
    square_sum = (P - 1) * P * (2 * P - 1) // 6
    print(f"          Lemma 21:  T={T:,}  -  (P-1)P(2P-1)/6={square_sum:,}  =  {T-square_sum:,}")
    print(f"                     S_2 = {S2:,}   identity holds: {T - square_sum == S2}")
    print()
