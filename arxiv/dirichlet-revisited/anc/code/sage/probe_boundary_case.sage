# probe_boundary_case.sage -- the single case the "p_v^2 >= n" lemma does not
# reach, namely v = ell_1(n)+1, plus the lower boundary v = ell_1(n).
#
# Writing A(n,v) = #{composite x in (n/p_v, n] : lpf(x) >= p_v} and
#         B(n,v) = #{primes q : p_v <= q <= n/p_v},
# one has  C_{n,v} - (r(n)-v+1) = A(n,v) - B(n,v).
# The linear regime is exactly where A = B.  This prints both sides so the
# structure of the (conjecturally) exact cancellation is visible.
#
# Changelog (reverse chronological):
#   2026-08-25  Claude-Code-6d5c5b66 (jts-pc) -- initial version.

from sage.all import *

def r_of(n): return prime_pi(n)
def ell1(n): return sum(1 for p in prime_range(3, n+1) if p*p <= n)

def AB(n, v):
    pv = nth_prime(v)
    lo = n // pv
    A = [x for x in range(lo+1, n+1)
         if not ZZ(x).is_prime() and x > 1 and ZZ(x).prime_divisors()[0] >= pv]
    B = [q for q in prime_range(pv, lo+1)]
    return A, B

def C_direct(n, v):
    pv = nth_prime(v)
    return sum(1 for x in range(n//pv + 1, n+1)
               if x == 1 or ZZ(x).prime_divisors()[0] >= pv)

print("="*78)
print("A(n,v) vs B(n,v) at the two boundary indices v = ell_1(n)+1 and v = ell_1(n)")
print("="*78)
print("\nIdentity check  C_{n,v} - (r-v+1) == A - B :")
bad = [(n,v) for n in range(4,200) for v in range(1, r_of(n)+1)
       if C_direct(n,v) - (r_of(n)-v+1) != len(AB(n,v)[0]) - len(AB(n,v)[1])]
print("   mismatches:", "NONE -- identity confirmed" if not bad else bad[:5])

print("\n--- UPPER boundary v = ell_1(n)+1  (the case the lemma misses; want A == B) ---")
print("   n    p_v   |A|  |B|   A - B      A (composites)                B (primes)")
bad = []
for n in list(range(9, 60)) + [64, 81, 100, 121, 144, 169, 200, 250, 289, 361]:
    L = ell1(n); v = L + 1
    if v < 1 or v > r_of(n): continue
    A, B = AB(n, v)
    flag = "" if len(A) == len(B) else "   <<<< NOT EQUAL"
    if len(A) != len(B): bad.append(n)
    print("  %4d  %4d  %3d  %3d  %+4d      %-28s  %s%s"
          % (n, nth_prime(v), len(A), len(B), len(A)-len(B),
             str(A[:6]), str(B[:6]), flag))
print("   n where A != B at v = ell_1+1 :", bad if bad else "NONE")

print("\n--- LOWER boundary v = ell_1(n)  (want A != B, i.e. a genuine deviation) ---")
print("   n    p_v   |A|  |B|   A - B")
bad = []
for n in list(range(9, 60)) + [64, 81, 100, 121, 144, 169, 200, 250, 289, 361]:
    L = ell1(n)
    if L < 1: continue
    A, B = AB(n, L)
    if len(A) == len(B): bad.append(n)
    print("  %4d  %4d  %3d  %3d  %+4d%s"
          % (n, nth_prime(L), len(A), len(B), len(A)-len(B),
             "   <<<< EQUAL, deviation missing" if len(A)==len(B) else ""))
print("   n where A == B at v = ell_1 (would break the conjecture) :", bad if bad else "NONE")

print("\n--- how far below sqrt(n) does the linear regime actually reach? ---")
print("   n   ell_1  V(n)  first linear v   p_{ell_1+1}^2 <= n ?")
for n in [25, 30, 49, 60, 81, 100, 121, 150, 169, 200, 250, 289, 350, 361]:
    r = r_of(n); L = ell1(n)
    devs = [v for v in range(1, r+1) if C_direct(n,v) != r-v+1]
    V = max(devs) if devs else 0
    print("  %4d  %4d  %4d  %10d       %s"
          % (n, L, V, V+1, nth_prime(L+1)**2 <= n if L+1 <= r else "n/a"))
