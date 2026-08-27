# Changelog (reverse-chronological)
# 2026-08-27 - created.  Checks the two claims behind Section 7 and the Acknowledgements'
#   remark on why commutative-algebra results do not transfer cheaply to number theory:
#   (a) the socle of Gamma_n is
#   {m : n/2 < m <= n}, so the Cohen-Macaulay type equals ceil(n/2) = C_{n,1} = Phi(n,2); and
#   (b) the Hilbert function d -> pi_d(n) = #{m<=n : Omega(m)=d} is an M-sequence, i.e. obeys
#   Macaulay's growth bound. (b) holds but is very slack, which is the point: extremal algebra
#   results are too weak to say anything new about these arithmetic counts.

from sympy import primerange, primefactors, factorint, binomial
from functools import lru_cache

def Omega(m):
    return sum(factorint(m).values())

def data(n):
    ps = list(primerange(2, n+1)); r = len(ps)
    # Gamma_n basis = {1..n}; grading by Omega
    H = {}
    for m in range(1, n+1):
        H[Omega(m)] = H.get(Omega(m), 0) + 1
    H = [H.get(d,0) for d in range(max(H)+1)]
    # socle: m<=n with m*p > n for every prime p<=n  <=> 2m > n
    socle = [m for m in range(1,n+1) if all(m*p > n for p in ps)]
    # Phi(n,p_v)
    C = []
    for v,pv in enumerate(ps, start=1):
        C.append(sum(1 for m in range(1,n+1) if all(q > pv for q in primefactors(m))))
    return ps, r, H, socle, C

def macaulay_bound(h, d):
    """Macaulay's h^<d>: bound on H(d+1) given H(d)=h in degree d."""
    if h == 0: return 0
    # d-th Macaulay representation of h
    reps = []; k = d; rem = h
    while k >= 1:
        a = k - 1
        while binomial(a+1, k) <= rem: a += 1
        reps.append((a, k)); rem -= binomial(a, k); k -= 1
        if rem == 0: break
    return sum(binomial(a+1, k+1) for a, k in reps)

print(f"{'n':>5} {'r':>4} {'socle':>6} {'ceil(n/2)':>9} {'C_n,1':>6}  Hilbert (by Omega)")
for n in [10, 25, 50, 100, 200]:
    ps, r, H, socle, C = data(n)
    print(f"{n:>5} {r:>4} {len(socle):>6} {-(-n//2):>9} {C[0]:>6}  {H}")

print("\nMacaulay test: is (pi_d(n))_d an M-sequence?  H(d+1) <= H(d)^<d> ?")
for n in [10, 25, 50, 100, 200, 500]:
    ps, r, H, socle, C = data(n)
    ok = all(H[d+1] <= macaulay_bound(H[d], d) for d in range(1, len(H)-1))
    slack = [(d+1, H[d+1], macaulay_bound(H[d], d)) for d in range(1, len(H)-1)]
    print(f"  n={n:>4}: {ok}   (d+1, actual, Macaulay bound) = {slack[:4]}")
