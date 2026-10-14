# Verifies the graded sifting identity (v2 of "Truncations ... revisited"):
#   sum_d C_{n,v,d} u^(d-1) = Phi(n,p_v;u) - (1-u) sum_{a>=1} u^(a-1) Phi(n/p_v^a, p_v; u),
# where Phi(x,y;u) = sum over m <= x with no prime factor <= y of u^Omega(m).
# Two independent checks:
#   (1) against the minimal generators of I_n enumerated directly as integers m,
#       with d = Omega(m) the total degree, for n = 2..NMAX and every v;
#   (2) against the 2000 paper's own Figure 2 (article/tabCg.tex), whose cells are
#       u^(-2) sum_d C_{n,v,d} u^d, i.e. the left-hand side divided by u.
# Also checks the pinned-degree reading C_{n,v,d} = #{x : n/p_v < x <= n, p_v-rough,
# Omega(x) = d-1} (the talk's slide wrote Omega(x) = d, which is off by one).
import re, sys, os
NMAX = 200
# Path to the 2000 paper's Figure 2 source. In ai-workspace: article/tabCg.tex; in the
# arithmetical-functions-truncations repo: dirichlet-revisited/article/original-2000/tabCg.tex.
TABCG = sys.argv[1] if len(sys.argv) > 1 else 'article/tabCg.tex'
R.<u> = ZZ[]
def Om(m): return sum(e for _, e in factor(m)) if m > 1 else 0
def lpf(m): return min(p for p, _ in factor(m))
def PhiU(x, y):
    x = floor(x)
    return sum((u**Om(m) for m in range(1, x+1) if all(m % p for p in prime_range(y+1))), R(0))
def gens(n):                     # (v, d) for each minimal generator m = p_v * x
    P = prime_range(n+1); out = []
    for v, p in enumerate(P, 1):
        for x in range(n//p + 1, n+1):
            if x == 1 or lpf(x) >= p:
                out.append((v, 1 + Om(x)))
    return out
def gens_brute(n):               # straight from the definition, independent of Thm 3.2
    return sorted((prime_pi(lpf(m)), Om(m)) for m in range(n+1, n*n+1)
                  if max(p for p, _ in factor(m)) <= n and m // lpf(m) <= n)
pairs = 0
for n in range(2, NMAX+1):
    G = gens(n)
    if n <= 30: assert sorted(G) == gens_brute(n), n
    for v in range(1, prime_pi(n)+1):
        P = nth_prime(v)
        lhs = sum((u**(d-1) for (vv, d) in G if vv == v), R(0))
        rhs = PhiU(n, P) - (1-u)*sum((u**(a-1)*PhiU(n/P**a, P) for a in range(1, floor(log(n, P))+2)), R(0))
        assert lhs == rhs, (n, v, lhs, rhs)
        assert lhs(1) == PhiU(n, P)(1)          # ungraded: the main theorem
        pairs += 1
print('identity holds for n = 2..%d, all v: %d pairs (n,v)' % (NMAX, pairs))
# (2) the paper's Figure 2
if not os.path.exists(TABCG):
    print('check (2) SKIPPED: %s not found -- pass the path to tabCg.tex as the first argument' % TABCG)
    sys.exit(0)
txt = open(TABCG).read()
txt = txt[txt.index(r'\hline')+6:]; txt = txt[txt.index(r'\hline')+6:]
txt = txt.split(r'\end')[0].replace('\n', '').replace(r'\hline', '')
rows = 0
for raw in re.split(r'\\\\', txt):
    raw = raw.strip()
    if not raw: continue
    cells = [c.strip() for c in raw.split('&')]; n = int(cells[0])
    for v, c in enumerate(cells[1:], 1):
        c = c.replace(r'\,', '*').replace('{', '(').replace('}', ')').replace('^', '**')
        cell = R(sage_eval(c, locals={'u': u}))
        P = nth_prime(v)
        rhs = PhiU(n, P) - (1-u)*sum((u**(a-1)*PhiU(n/P**a, P) for a in range(1, floor(log(n, P))+2)), R(0))
        assert u*cell == rhs, (n, v, cell, rhs)
    rows += 1
print('agrees with every cell of the 2000 paper\'s Figure 2: %d rows' % rows)
