# verify_legendre_phi.sage -- the headline identity of "Truncations Revisited":
#
#     C_{n,v} = Phi(n, p_v)
#
# where Phi(x,y) = #{ m <= x : every prime factor of m exceeds y } is Legendre's
# sifting function.  C_{n,v} is recomputed from the minimal generators of I_n,
# and Phi is computed by naive sieving -- two completely independent routes.
#
# Changelog (reverse chronological):
#   2026-08-25  Claude-Code-6d5c5b66 (jts-pc) -- initial version.

from sage.all import *

def r_of(n): return prime_pi(n)

def Cv_from_generators(n):
    if n < 2: return {}
    r = r_of(n); pr = nth_prime(r); d = {}
    for W in range(n + 1, n * pr + 1):
        ps = ZZ(W).prime_divisors()
        if ps[-1] > n: continue
        if W <= n * ps[0]:
            v = prime_pi(ps[0]); d[v] = d.get(v, 0) + 1
    return d

def Phi(x, y):
    """Legendre: #{m <= x : every prime factor of m > y}.  1 counts."""
    return sum(1 for m in range(1, x + 1)
               if m == 1 or ZZ(m).prime_divisors()[0] > y)

print("=" * 70)
print("HEADLINE:   C_{n,v} = Phi(n, p_v)   (Legendre's sifting function)")
print("=" * 70)

bad = []
for n in range(2, 161):
    C = Cv_from_generators(n)
    for v in range(1, r_of(n) + 1):
        if C.get(v, 0) != Phi(n, nth_prime(v)):
            bad.append((n, v, C.get(v, 0), Phi(n, nth_prime(v))))
print("\n[1] every (n,v), 2 <= n <= 160 :  %s"
      % ("NONE -- identity confirmed" if not bad else bad[:6]))

print("\n[2] worked instance, n = 25 (r = 9):")
C = Cv_from_generators(25)
for v in range(1, 10):
    pv = nth_prime(v)
    survivors = [m for m in range(1, 26) if m == 1 or ZZ(m).prime_divisors()[0] > pv]
    print("    v=%d  p_v=%2d   C_{25,v}=%2d   Phi(25,%2d)=%2d   %s"
          % (v, pv, C.get(v, 0), pv, len(survivors),
             survivors if len(survivors) <= 14 else ""))

print("\n[3] consequence:  C_n = sum_{v=1}^{r(n)} Phi(n, p_v)")
bad = [n for n in range(2, 161)
       if sum(Cv_from_generators(n).values())
          != sum(Phi(n, nth_prime(v)) for v in range(1, r_of(n) + 1))]
print("    counterexamples: %s" % ("NONE" if not bad else bad[:6]))

print("\n[4] and the paper's own Thm 3.2 set is a DIFFERENT set of the same size:")
for (n, v) in [(25, 1), (25, 2), (30, 2), (40, 3)]:
    pv = nth_prime(v)
    paper = [x for x in range(n // pv + 1, n + 1)
             if x == 1 or ZZ(x).prime_divisors()[0] >= pv]
    ours = [m for m in range(1, n + 1) if m == 1 or ZZ(m).prime_divisors()[0] > pv]
    print("    n=%d v=%d:  paper %s" % (n, v, paper))
    print("               ours  %s   (%d = %d)" % (ours, len(paper), len(ours)))

print("\n[5] Thm 3.4(4) with the sharper Bertrand bound N = 4^{v-1}:")
bad = [(v, n) for v in (1, 2, 3, 4)
       for n in range(4**(v-1) + 1, min(4**(v-1) + 300, 500))
       if r_of(n) - v + 1 >= 1
       and Cv_from_generators(n).get(1 + r_of(n) - v, 0) != v]
print("    counterexamples: %s" % ("NONE" if not bad else bad[:6]))
