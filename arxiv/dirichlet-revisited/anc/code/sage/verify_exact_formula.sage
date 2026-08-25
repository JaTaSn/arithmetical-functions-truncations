# verify_exact_formula.sage -- the central claim of "Truncations Revisited":
#
#     C_{n,v} = (r(n) - v + 1) + E(n,v),
#     E(n,v) := #{ composite x <= n : every prime factor of x is >= p_{v+1} }
#
# from which Snellman's Conjecture 4.6 follows, since C_{n,v} != r(n)-v+1
# exactly when E(n,v) > 0, i.e. exactly when p_{v+1}^2 <= n.
#
# C_{n,v} is recomputed by direct enumeration of minimal generators of I_n --
# the formula is NOT used to produce the numbers it is being tested against.
#
# Changelog (reverse chronological):
#   2026-08-25  Claude-Code-6d5c5b66 (jts-pc) -- initial version.

from sage.all import *

def r_of(n): return prime_pi(n)

def Cv_from_generators(n):
    """C_{n,v} straight from G(I_n), independent of any formula below."""
    if n < 2: return {}
    r = r_of(n); pr = nth_prime(r); d = {}
    for W in range(n + 1, n * pr + 1):
        ps = ZZ(W).prime_divisors()
        if ps[-1] > n: continue
        if W <= n * ps[0]:
            v = prime_pi(ps[0]); d[v] = d.get(v, 0) + 1
    return d

def E(n, v):
    """#{composite x <= n : lpf(x) >= p_{v+1}}."""
    q = nth_prime(v + 1)
    return sum(1 for x in range(2, n + 1)
               if not ZZ(x).is_prime() and ZZ(x).prime_divisors()[0] >= q)

def ell1(n): return sum(1 for p in prime_range(3, n + 1) if p * p <= n)

print("=" * 74)
print("THE EXACT FORMULA   C_{n,v} = (r(n)-v+1) + E(n,v)")
print("=" * 74)

NMAX = 150
bad = []
for n in range(2, NMAX + 1):
    r = r_of(n); C = Cv_from_generators(n)
    for v in range(1, r + 1):
        if C.get(v, 0) != (r - v + 1) + E(n, v):
            bad.append((n, v, C.get(v, 0), (r - v + 1) + E(n, v)))
print("\n[1] tested every (n,v) with 2 <= n <= %d, 1 <= v <= r(n)" % NMAX)
print("    counterexamples: %s" % ("NONE -- formula confirmed" if not bad else bad[:6]))

print("\n[2] Corollary: C_{n,v} != r(n)-v+1  <=>  p_{v+1}^2 <= n")
bad = []
for n in range(2, NMAX + 1):
    r = r_of(n); C = Cv_from_generators(n)
    for v in range(1, r + 1):
        if (C.get(v, 0) != r - v + 1) != (nth_prime(v + 1)**2 <= n):
            bad.append((n, v))
print("    counterexamples: %s" % ("NONE" if not bad else bad[:6]))

print("\n[3] Hence V(n) = max{v : C_{n,v} != r-v+1} = pi(floor(sqrt n)) - 1 = ell_1(n)")
bad = []
for n in range(4, 400):
    r = r_of(n); C = Cv_from_generators(n) if n <= NMAX else None
    V_pred = prime_pi(isqrt(n)) - 1
    if V_pred != ell1(n): bad.append(("ell1", n, V_pred, ell1(n)))
    if C is not None:
        devs = [v for v in range(1, r + 1) if C.get(v, 0) != r - v + 1]
        V = max(devs) if devs else 0
        if V != V_pred: bad.append(("V", n, V, V_pred))
print("    counterexamples: %s" % ("NONE -- Conjecture 4.6(2) follows" if not bad else bad[:6]))

print("\n[4] Closed form for C_n:  binom(r+1,2) + sum over composites x<=n of (pi(lpf x) - 1)")
bad = []
for n in range(2, NMAX + 1):
    Cn = sum(Cv_from_generators(n).values())
    pred = binomial(r_of(n) + 1, 2) + sum(prime_pi(ZZ(x).prime_divisors()[0]) - 1
                                          for x in range(2, n + 1)
                                          if not ZZ(x).is_prime())
    if Cn != pred: bad.append((n, Cn, pred))
print("    counterexamples: %s" % ("NONE -- closed form confirmed" if not bad else bad[:6]))

print("\n[5] The error term  C_n - binom(r+1,2), and its size")
from math import log
print("      n      C_n - binom(r+1,2)     n^{3/2}/log^2 n     ratio")
for n in (50, 100, 150):
    Cn = sum(Cv_from_generators(n).values())
    err = Cn - binomial(r_of(n) + 1, 2)
    b = n**1.5 / log(n)**2
    print("    %4d   %14d      %14.1f     %.4f" % (n, err, b, err / b))
