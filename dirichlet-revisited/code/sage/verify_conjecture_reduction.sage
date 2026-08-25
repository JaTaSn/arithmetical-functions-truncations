# verify_conjecture_reduction.sage -- checks the reduction of Snellman's
# Conjecture 4.6 to a single arithmetic statement, plus the asymptotic results,
# before any of it goes into "Truncations Revisited".
#
# Nothing here is assumed from the 2000 paper: C_{n,v} is recomputed by direct
# enumeration of minimal generators (same route as recompute_truncations.sage).
#
# Changelog (reverse chronological):
#   2026-08-25  Claude-Code-6d5c5b66 (jts-pc) -- initial version.

from sage.all import *

def Omega(W): return sum(e for (_, e) in ZZ(W).factor())
def r_of(n):  return prime_pi(n)

def gens(n):
    """G(I_n) as (W, v, d): weight, min-support index, total degree."""
    if n < 2: return []
    r = r_of(n); pr = nth_prime(r); out = []
    for W in range(n + 1, n * pr + 1):
        ps = ZZ(W).prime_divisors()
        if ps[-1] > n: continue
        if W <= n * ps[0]:
            out.append((W, prime_pi(ps[0]), Omega(W)))
    return out

def Cv(n):
    d = {}
    for (_, v, _) in gens(n): d[v] = d.get(v, 0) + 1
    return d

def ell1(n):
    """#{odd primes p : p^2 <= n} -- the conjecture's l_1(n)."""
    return sum(1 for p in prime_range(3, n + 1) if p * p <= n)

R = PolynomialRing(QQ, 't,u'); t, u = R.gens()

print("=" * 76)
print("Reduction of Conjecture 4.6, and the asymptotics.  Verification run.")
print("=" * 76)

NMAX = 120

# ---- (0) c_0 = C_{n,r(n)} = 1 ----------------------------------------------
bad = [n for n in range(2, NMAX+1) if Cv(n).get(r_of(n), 0) != 1]
print("\n[0] C_{n,r(n)} = 1 for all n in 2..%d : %s" % (NMAX, "YES" if not bad else bad))

# ---- (1) the coefficient identity D = (1-c_0) - sum (Delta^2 c_k) u^k ------
print("\n[1] Coefficient identity: writing D(t) = 1 - t^2 sum_j (1+t)^{r-j} C_{n,j}")
print("    and u = 1+t, c_k = C_{n,r-k}, claim coeff of u^k in D is -(c_k - 2c_{k-1} + c_{k-2}).")
bad = []
for n in range(2, 61):
    r = r_of(n); C = Cv(n)
    D = 1 - t**2 * sum((1 + t)**(r - j) * C.get(j, 0) for j in range(1, r + 1))
    Du = R(D.subs({t: u - 1}))                 # rewrite in u
    c = [C.get(r - k, 0) for k in range(0, r)]
    def cc(i): return c[i] if 0 <= i < len(c) else 0
    pred = [1 - cc(0)] + [-(cc(k) - 2*cc(k-1) + cc(k-2)) for k in range(1, r + 2)]
    got  = [Du.coefficient({u: k, t: 0}) for k in range(0, r + 2)]
    if pred != got: bad.append((n, pred, got))
print("    mismatches over n = 2..60 : %s" % ("NONE -- identity confirmed" if not bad else bad))

# ---- (2) order of vanishing = first k with c_k != k+1 ----------------------
print("\n[2] mu(n) := ord_{u=0} D  equals  min{k >= 1 : c_k != k+1}")
bad = []
for n in range(2, 61):
    r = r_of(n); C = Cv(n)
    D = 1 - t**2 * sum((1 + t)**(r - j) * C.get(j, 0) for j in range(1, r + 1))
    Du = R(D.subs({t: u - 1}))
    ordu = min(k for k in range(0, r + 3) if Du.coefficient({u: k, t: 0}) != 0)
    first = min([k for k in range(1, r) if C.get(r - k, 0) != k + 1] or [r])
    if ordu != first: bad.append((n, ordu, first))
print("    mismatches over n = 2..60 : %s" % ("NONE -- confirmed" if not bad else bad))

# ---- (3) THE reduction: V(n) = max{v : C_{n,v} != r-v+1}  ==  ell_1(n) -----
print("\n[3] THE REDUCTION.  V(n) := max{v : C_{n,v} != r(n)-v+1}  (0 if none).")
print("    Conjecture 4.6(2) is equivalent to  V(n) = ell_1(n) = #{odd p : p^2 <= n}.")
bad = []
for n in range(2, NMAX + 1):
    r = r_of(n); C = Cv(n)
    devs = [v for v in range(1, r + 1) if C.get(v, 0) != r - v + 1]
    V = max(devs) if devs else 0
    if V != ell1(n): bad.append((n, V, ell1(n)))
print("    n = 2..%d, mismatches (n, V, ell_1) : %s"
      % (NMAX, "NONE -- reduction holds throughout" if not bad else bad))

# ---- (4) the lemma that gives the linear regime ---------------------------
print("\n[4] Lemma: p_v^2 >= n  ==>  C_{n,v} = r(n) - v + 1.")
bad = []
for n in range(2, NMAX + 1):
    r = r_of(n); C = Cv(n)
    for v in range(1, r + 1):
        if nth_prime(v)**2 >= n and C.get(v, 0) != r - v + 1:
            bad.append((n, v, C.get(v, 0), r - v + 1))
print("    counterexamples : %s" % ("NONE -- lemma holds" if not bad else bad[:5]))
print("    (sufficient, NOT sharp: the linear regime often starts earlier --")
sharp = []
for n in (24, 30, 48, 60, 90, 120):
    r = r_of(n); C = Cv(n)
    devs = [v for v in range(1, r+1) if C.get(v,0) != r-v+1]
    v_lemma = min(v for v in range(1, r+1) if nth_prime(v)**2 >= n)
    sharp.append((n, (max(devs)+1 if devs else 1), v_lemma))
print("     n, actual start of linear regime, what the lemma proves: %s)" % sharp)

# ---- (5) clauses (1),(3),(4),(5),(6) as unconditional consequences ---------
print("\n[5] With ell_1 REPLACED by V(n), clauses (1),(3),(4),(5),(6) should be theorems.")
fails = {k: [] for k in (1, 3, 4, 5, 6)}
for n in range(2, 61):
    r = r_of(n); C = Cv(n)
    D = 1 - t**2 * sum((1 + t)**(r - j) * C.get(j, 0) for j in range(1, r + 1))
    devs = [v for v in range(1, r + 1) if C.get(v, 0) != r - v + 1]
    V = max(devs) if devs else 0
    mu = r - V
    q = R(-D / (1 + t)**mu) if ((-D) % (1 + t)**mu == 0) else None
    if q is None:
        for k in fails: fails[k].append((n, "does not divide"))
        continue
    h = [q.coefficient({t: i, u: 0}) for i in range(q.degree(t) + 1)]
    if q.subs({t: -1}) == 0:              fails[1].append(n)
    if q.degree(t) != V + 1:              fails[3].append((n, q.degree(t), V + 1))
    if h[0] != -1:                        fails[4].append((n, h[0]))
    if len(h) < 2 or h[1] != r - V:       fails[5].append((n, h[1] if len(h)>1 else None, r - V))
    if h[-1] != ceil(n / 2):              fails[6].append((n, h[-1], ceil(n / 2)))
for k, lab in [(1,"q_n(-1) != 0"), (3,"deg q_n = V+1"), (4,"h_0 = -1"),
               (5,"h_1 = r - V"), (6,"h_top = ceil(n/2)")]:
    print("    clause (%d) %-18s : %s" % (k, lab, "holds" if not fails[k] else fails[k][:4]))

# ---- (6) the corrected Theorem 3.5(3) --------------------------------------
print("\n[6] Corrected Thm 3.5(3):  #{m in G(I_n) : |supp(m)| = 2}  >=  binom(r(n),2)")
bad, eq = [], []
for n in range(2, 81):
    k = sum(1 for (W, _, _) in gens(n) if len(ZZ(W).prime_divisors()) == 2)
    b = binomial(r_of(n), 2)
    if k < b: bad.append((n, k, b))
    if k == b: eq.append(n)
print("    violations : %s" % ("NONE -- inequality holds" if not bad else bad))
print("    equality exactly at n = %s" % eq)

# ---- (7) asymptotics -------------------------------------------------------
print("\n[7] Exact error formula:  C_n - binom(r+1,2) = sum_{v <= pi(sqrt n)} [C_{n,v} - (r-v+1)]")
bad = []
for n in range(4, NMAX + 1):
    r = r_of(n); C = Cv(n); Cn = sum(C.values())
    vstar = prime_pi(isqrt(n))
    rhs = sum(C.get(v, 0) - (r - v + 1) for v in range(1, vstar + 1))
    if Cn - binomial(r + 1, 2) != rhs: bad.append((n, Cn - binomial(r+1,2), rhs))
print("    mismatches : %s" % ("NONE -- exact identity confirmed" if not bad else bad[:5]))
print("\n[8] Thm 3.4(4) with the explicit bound N = 4^v:  n > 4^v ==> C_{n,1+r(n)-v} = v")
bad = []
for v in (1, 2, 3):
    for n in range(4**v + 1, min(4**v + 260, 400)):
        r = r_of(n)
        if r - v + 1 >= 1 and Cv(n).get(1 + r - v, 0) != v: bad.append((v, n))
print("    counterexamples : %s" % ("NONE" if not bad else bad[:6]))
