# recompute_truncations.sage -- independent recomputation of every table and
# numbered claim in Jan Snellman, "Truncations of the ring of number-theoretic
# functions", Homology Homotopy Appl. 2 (2000) 17-27 (arXiv:math/9904143v2).
#
# Purpose: the paper's numbers came from `article/code/getsols.maple` in 1999.
# This is a from-scratch reimplementation along a *different* route (direct
# enumeration of minimal monomial generators as integers), so that agreement is
# evidence and disagreement is a finding.  Feeds working-notes/errata-*.md.
#
# Changelog (reverse chronological):
#   2026-08-25  Claude-Code-6d5c5b66 (jts-pc) -- initial version.

import sys, json
from sage.all import *

# ---------------------------------------------------------------- primitives
#
# Setting, in the paper's notation:
#   p_1 = 2 < p_2 = 3 < ... are the primes; r(n) = pi(n).
#   S = K[x_1,...,x_r], weight w(x_1^a1 ... x_r^ar) = prod p_i^{a_i}.
#   I_n = ( monomials of weight > n ),  A_n = S/I_n  ~=  Gamma_n.
# So monomials of S with weight <= n biject with the integers 1..n, and a
# monomial *is* just its weight.  A monomial W lies in I_n iff W > n, and is a
# minimal generator iff additionally W/p <= n for every prime p | W -- and the
# binding case is the *smallest* prime factor.  Hence:
#
#   G(I_n)  <->  { W : n < W <= n * lpf(W), every prime factor of W is <= n }
#
# with min(m) = index of lpf(W) and |m| = Omega(W).  That is the enumeration
# used below; the paper's own route (Theorem 3.2) is implemented separately in
# C_via_theorem_3_2() and the two are cross-checked.

def r_of(n):
    """r(n) = number of primes <= n."""
    return prime_pi(n)

def Omega(W):
    """Omega(W) = number of prime factors with multiplicity (the paper's lambda)."""
    return sum(e for (_, e) in ZZ(W).factor())

def sopfr(W):
    """sum of prime factors with multiplicity (the paper's lambda-tilde, A001414)."""
    return sum(p * e for (p, e) in ZZ(W).factor())

def lpf(W):
    """Least prime factor."""
    return ZZ(W).prime_divisors()[0]

def prime_index(p):
    """v with p_v = p (1-based, p_1 = 2)."""
    return prime_pi(p)

def minimal_generators(n):
    """G(I_n) as a list of (W, v, d): weight, min-support index, total degree."""
    if n < 2:
        return []
    r = r_of(n)
    pr = nth_prime(r)                      # largest variable p_r <= n
    out = []
    for W in range(n + 1, n * pr + 1):
        ps = ZZ(W).prime_divisors()
        if ps[-1] > n:                     # not a monomial of S = K[x_1..x_r]
            continue
        if W <= n * ps[0]:                 # minimal
            out.append((W, prime_index(ps[0]), Omega(W)))
    return out

def C_table(n):
    """(C_n, {v: C_{n,v}}, {(v,d): C_{n,v,d}})."""
    Cv, Cvd = {}, {}
    G = minimal_generators(n)
    for (W, v, d) in G:
        Cv[v] = Cv.get(v, 0) + 1
        Cvd[(v, d)] = Cvd.get((v, d), 0) + 1
    return len(G), Cv, Cvd

def C_via_theorem_3_2(n, v):
    """The paper's own formula: #{ x : n/p_v < x <= n, all prime factors >= p_v }."""
    pv = nth_prime(v)
    lo = n // pv                           # x > n/p_v  <=>  x >= floor(n/p_v)+1
    cnt = 0
    for x in range(lo + 1, n + 1):
        if x == 1 or lpf(x) >= pv:
            cnt += 1
    return cnt

# ------------------------------------------------------------- Hilbert series
def hilbert_bigraded(n):
    """c_{ij} = #{ m <= n : Omega(m) = i, sopfr(m) = j }."""
    c = {}
    for m in range(1, n + 1):
        i = Omega(m)    # lambda  = Omega
        j = sopfr(m)    # lambda~ = sopfr, A001414
        c[(i, j)] = c.get((i, j), 0) + 1
    return c

# ------------------------------------------------ Poincare-Betti series (sec 4)
R = PolynomialRing(QQ, 't,u')
t, u = R.gens()
F = FractionField(R)

def PBI(n):
    """P(Tor^S_*(I_n,K), t) = sum_{i=1}^r C_{n,1+r-i} (1+t)^{i-1}   -- eq (28)."""
    r = r_of(n); _, Cv, _ = C_table(n)
    return sum(Cv.get(1 + r - i, 0) * (1 + t) ** (i - 1) for i in range(1, r + 1))

def GPBI(n):
    """Bigraded version, eq (29)."""
    r = r_of(n); _, _, Cvd = C_table(n)
    tot = F(0)
    for i in range(1, r + 1):
        v = 1 + r - i
        inner = sum(c * u ** d for ((vv, d), c) in Cvd.items() if vv == v)
        tot += (1 + t * u) ** (i - 1) * inner
    return tot

def PBKK(n):
    """P(Tor^{A_n}_*(K,K), t) = (1+t)^r / (1 - t^2 PBI)   -- eq (35)."""
    return F((1 + t) ** r_of(n)) / F(1 - t ** 2 * PBI(n))

def GPBKK(n):
    """Eq (36)."""
    return F((1 + t * u) ** r_of(n)) / F(1 - t ** 2 * GPBI(n))

# =========================================================== CHECKS ==========
report = []
def say(s=""):
    print(s); report.append(str(s))

NMAX = 30

say("=" * 78)
say("Recomputation of Snellman, 'Truncations of the ring of number-theoretic")
say("functions' (arXiv:math/9904143v2).  n = 2..%d unless stated." % NMAX)
say("=" * 78)

# --- cross-check the two independent routes to C_{n,v} -----------------------
say("\n[1] Direct generator enumeration  vs  Theorem 3.2's counting formula")
bad = []
for n in range(2, NMAX + 1):
    _, Cv, _ = C_table(n)
    for v in range(1, r_of(n) + 1):
        a, b = Cv.get(v, 0), C_via_theorem_3_2(n, v)
        if a != b:
            bad.append((n, v, a, b))
say("    mismatches: %s" % ("NONE -- Theorem 3.2 confirmed" if not bad else bad))

# --- Figure 1: C_n and C_{n,i} ----------------------------------------------
PAPER_FIG1 = {
  2:[1],3:[2,1],4:[2,1],5:[3,2,1],6:[3,2,1],7:[4,3,2,1],8:[4,3,2,1],
  9:[5,3,2,1],10:[5,3,2,1],11:[6,4,3,2,1],12:[6,4,3,2,1],13:[7,5,4,3,2,1],
  14:[7,5,4,3,2,1],15:[8,5,4,3,2,1],16:[8,5,4,3,2,1],17:[9,6,5,4,3,2,1],
  18:[9,6,5,4,3,2,1],19:[10,7,6,5,4,3,2,1],20:[10,7,6,5,4,3,2,1],
  21:[11,7,6,5,4,3,2,1],22:[11,7,6,5,4,3,2,1],23:[12,8,7,6,5,4,3,2,1],
  24:[12,8,7,6,5,4,3,2,1],25:[13,9,7,6,5,4,3,2,1],26:[13,9,7,6,5,4,3,2,1],
  27:[14,9,7,6,5,4,3,2,1],28:[14,9,7,6,5,4,3,2,1],
  29:[15,10,8,7,6,5,4,3,2,1],30:[15,10,8,7,6,5,4,3,2,1]}
PAPER_SIGMA = {2:1,3:3,4:3,5:6,6:6,7:10,8:10,9:11,10:11,11:16,12:16,13:22,
  14:22,15:23,16:23,17:30,18:30,19:38,20:38,21:39,22:39,23:48,24:48,25:50,
  26:50,27:51,28:51,29:61,30:61}
say("\n[2] Figure 1 (tabC.tex): C_n and C_{n,i}, n = 2..30")
bad = []
for n in range(2, 31):
    Cn, Cv, _ = C_table(n)
    mine = [Cv.get(v, 0) for v in range(1, r_of(n) + 1)]
    if mine != PAPER_FIG1[n] or Cn != PAPER_SIGMA[n]:
        bad.append((n, Cn, mine, PAPER_SIGMA[n], PAPER_FIG1[n]))
say("    mismatches: %s" % ("NONE -- Figure 1 reproduced exactly" if not bad else bad))
say("    C_n, n=2..30: %s" % [C_table(n)[0] for n in range(2, 31)])

# --- Figure 2: C_{n,i,d}, printed as u^{-2} sum_d C u^d ----------------------
say("\n[3] Figure 2 (tabCg.tex): C_{n,i,d} as u^{-2} sum_d C_{n,i,d} u^d")
say("    (spot-check rows; full row dump written to runs/)")
fig2 = {}
for n in range(2, 31):
    _, _, Cvd = C_table(n)
    row = []
    for v in range(1, r_of(n) + 1):
        poly = sum(c * u ** (d - 2) for ((vv, d), c) in sorted(Cvd.items()) if vv == v)
        row.append(str(poly))
    fig2[n] = row
for n in (4, 5, 9, 10, 16, 30):
    say("    n=%-3d %s" % (n, " | ".join(fig2[n])))

# --- Theorem 1.2 (II): dim_K Gamma_n = n, Hilbert series ---------------------
say("\n[4] Prop 2.4 / Thm 1.2(II): dim_K A_n = n, and d_i = #{w<=n : Omega(w)=i}")
ok = all(sum(hilbert_bigraded(n).values()) == n for n in range(1, 61))
say("    dim_K A_n = n for n = 1..60: %s" % ok)
say("    Thm 2.7: t^1-coefficient of A_n(t,1) equals pi(n): %s" %
    all(sum(c for ((i, j), c) in hilbert_bigraded(n).items() if i == 1) == r_of(n)
        for n in range(2, 61)))

# --- Theorem 3.4 -------------------------------------------------------------
say("\n[5] Theorem 3.4, all six parts, n = 2..%d" % NMAX)
t34 = {}
t34[1] = all(C_table(n)[1].get(v, 0) == 0
             for n in range(2, NMAX + 1) for v in range(r_of(n) + 1, r_of(n) + 6))
t34[2] = all(C_table(n)[1].get(1 + r_of(n) - v, 0) >= v
             for n in range(2, NMAX + 1) for v in range(1, r_of(n) + 1))
t34[3] = all(C_table(n)[0] >= binomial(r_of(n) + 1, 2) for n in range(2, NMAX + 1))
t34[5] = all(C_table(n)[1] == C_table(n - 1)[1]
             for n in range(4, NMAX + 1) if n % 2 == 0)
t34_5_at_2 = (C_table(2)[1] == C_table(1)[1])
t34[6] = all(C_table(n)[1].get(1, 0) == ceil(n / 2) for n in range(2, NMAX + 1))
for k in (1, 2, 3, 5, 6):
    say("    (%d): %s%s" % (k, t34[k],
        "   [tested n >= 4; at n = 2 it fails, C_{2,1}=1 but Gamma_1 = K has no "
        "generators -- a degenerate edge case, not a substantive error]"
        if k == 5 else ""))
say("    (4) is a limit statement; C_{n,1+r(n)-v} for v=1,2,3 as n grows:")
for v in (1, 2, 3):
    say("        v=%d: %s" % (v, [C_table(n)[1].get(1 + r_of(n) - v, 0)
                                  for n in range(20, 61)]))

# --- Theorem 3.5 -------------------------------------------------------------
say("\n[6] Theorem 3.5")
say("    (1) C_{n,v,d} = 0 for d < 2 : %s" %
    all(d >= 2 for n in range(2, NMAX + 1) for (_, _, d) in minimal_generators(n)))
say("    (3) claims  binomial(r(n),2) == #{ m <= n : Omega(m) = 2 }.  Testing:")
bad35 = []
for n in range(2, 41):
    lhs = binomial(r_of(n), 2)
    rhs = sum(1 for m in range(1, n + 1) if Omega(m) == 2)
    if lhs != rhs:
        bad35.append((n, lhs, rhs))
say("        first 12 failures (n, LHS, RHS): %s" % bad35[:12])
say("        holds for: %s" % [n for n in range(2, 41)
                               if binomial(r_of(n), 2) ==
                               sum(1 for m in range(1, n + 1)
                                   if Omega(m) == 2)])
say("    -- candidate repairs, same test:")
for name, f in [
    ("#{minimal gens of degree 2}",
     lambda n: sum(1 for (_, _, d) in minimal_generators(n) if d == 2)),
    ("#{squarefree minimal gens of degree 2}",
     lambda n: sum(1 for (W, _, d) in minimal_generators(n)
                   if d == 2 and ZZ(W).is_squarefree())),
    ("#{minimal gens with |supp| = 2}",
     lambda n: sum(1 for (W, _, _) in minimal_generators(n)
                   if len(ZZ(W).prime_divisors()) == 2)),
    ("#{ m <= n : Omega(m) = 2 }",
     lambda n: sum(1 for m in range(1, n + 1)
                   if Omega(m) == 2)),
]:
    agree = [n for n in range(2, 41) if binomial(r_of(n), 2) == f(n)]
    geq   = all(f(n) >= binomial(r_of(n), 2) for n in range(2, 41))
    say("        %-38s  == at n in %-28s   always >= : %s"
        % (name, str(agree), geq))

# --- Poincare-Betti series, and Conjecture 4.6 -------------------------------
say("\n[7] Poincare-Betti series (non-graded), and Conjecture 4.6")
say("    Conj 4.6:  P = -(1+t)^{l1(n)} / q_n(t),  q_n = sum_{i=0}^{l2} h_i t^i,")
say("    l1(n) = #{odd p : p^2 <= n}; (1) q_n(-1) != 0; (2) l1 as above;")
say("    (3) l2 = l1+1; (4) h_0 = -1; (5) h_1 = r(n)-l1; (6) h_{l2} = ceil(n/2).")
say("    [The paper tabulates n <= 25 only; this runs to n = 60.]")
CONJ_MAX = 60
conj = {k: [] for k in range(1, 7)}
tt, uu = R.gens()
for n in range(2, CONJ_MAX + 1):
    P = PBKK(n)
    num, den = P.numerator(), P.denominator()
    g = gcd(num, den); num, den = num // g, den // g
    sc = QQ(-1) / QQ(den.constant_coefficient())   # normalise so q_n(0) = -1
    num, den = R(num * sc), R(den * sc)
    l1 = sum(1 for p in prime_range(3, n + 1) if p * p <= n)
    l2 = den.degree(tt)
    h = [den.coefficient({tt: i, uu: 0}) for i in range(l2 + 1)]
    if n <= 25:
        say("    n=%-3d  P = (%s) / (%s)" % (n, num, den))
    conj[1].append((n, den.subs({tt: -1}) != 0))
    conj[2].append((n, num == -(1 + t) ** l1))
    conj[3].append((n, l2 == l1 + 1))
    conj[4].append((n, h[0] == -1))
    conj[5].append((n, len(h) > 1 and h[1] == r_of(n) - l1))
    conj[6].append((n, h[l2] == ceil(n / 2)))
for k, label in [(1, "q_n(-1) != 0"), (2, "numerator = -(1+t)^{l1(n)}"),
                 (3, "deg q_n = l1(n)+1"), (4, "h_0 = -1"),
                 (5, "h_1 = r(n)-l1(n)"), (6, "h_{l2} = ceil(n/2)")]:
    fails = [n for (n, ok) in conj[k] if not ok]
    say("    Conj 4.6(%d) %-30s failures up to n=%d: %s"
        % (k, label, CONJ_MAX, fails if fails else "none"))

# --- Example 4.5 -------------------------------------------------------------
say("\n[8] Example 4.5 (n=5): paper says P^S_I = 6+8t+3t^2 and P^{S/I}_K = 1/(1-3t)")
say("    computed P^S_I  = %s" % expand(PBI(5)))
say("    computed P^{A_5}_K = %s" % PBKK(5).factor())

# --- sequences for OEIS ------------------------------------------------------
say("\n[9] Sequences worth an OEIS check")
say("    C_n            (n=2..60): %s" % [C_table(n)[0] for n in range(2, 61)])
say("    C_n odd n only (n=3,5,..): %s" % [C_table(n)[0] for n in range(3, 61, 2)])
say("    C_{n,2}        (n=3..60): %s" % [C_table(n)[1].get(2, 0) for n in range(3, 61)])

open("REPORT.txt", "w").write("\n".join(report) + "\n")
say("\nWrote REPORT.txt")
