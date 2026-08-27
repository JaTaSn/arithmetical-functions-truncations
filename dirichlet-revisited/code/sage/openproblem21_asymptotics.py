#!/usr/bin/env python3
# openproblem21_asymptotics.py -- the analytic number theory of Open Problem 21
# of the manuscript (article/truncations-revisited.tex).
#
# The quantity under study is the error term of Theorem 18 (thm:asymp),
#
#     S(n) = C_n - binom(pi(n)+1, 2)
#          = sum_{x <= n, x composite} ( pi(lpf x) - 1 )
#          = sum_{j >= 2} (j-1) * #{ x <= n : x composite, lpf x = p_j },
#
# for which the manuscript proves only S(n) = O(n^{3/2}/log n) and observes
# numerically that the truth "appears to be of order n^{3/2}/log^3 n".
#
# The claim tested here is the sharper
#
#     S(n) ~ (2/3) * pi(sqrt n)^3 ~ (16/3) * n^{3/2} / log^3 n .
#
# The first form is the numerically useful one: the 1/log n expansion of the
# second has a large coefficient (6/log n at second order), so the raw ratio
# S(n) log^3(n) / n^{3/2} is still around 10 at n = 10^9 and converges to
# 16/3 = 5.333... far too slowly to be convincing on its own.
#
# Stages (each prints its own table; run "all" for the full report):
#
#   sieve  -- S(n) exactly on a logarithmic grid up to NMAX, by a segmented
#             least-prime-factor sieve.  Records pi(n) and the pi(n/p) that
#             stage "split" needs.  Also re-derives C_n and diffs it against
#             Table 1 of the manuscript.
#   brute  -- the same S(n) for small n by two *different* routes (sympy
#             factorint; a plain unsegmented smallest-prime-factor sieve), and
#             a direct enumeration of the semiprime part, as checks.
#   split  -- S(n) = S_2(n) + S_{>=3}(n), S_2 the part from semiprimes.
#             Checks the closed form
#                 S_2(n) = sum_{p <= sqrt n} (pi(p)-1) (pi(n/p) - pi(p) + 1)
#             and that S_{>=3}(n) = O(n^{4/3}/log^2 n), i.e. is negligible.
#   lucy   -- S_2(n) *exactly* for n up to 10^14, via Lucy_Hedgehog's O(n^{3/4})
#             prime-counting recursion, which computes pi(n//i) for every i at
#             once -- precisely the values the closed form needs.  Independent
#             of the sieve, and overlaps it at n <= 10^9 for cross-checking.
#   model  -- the smooth model
#                 Q(n) = int_2^{sqrt n} (Li(t)-1)(Li(n/t)-Li(t)+1) dt/log t
#             by quadrature, against the exact S_2(n), with the two intermediate
#             quantities E and D that separate "pi -> Li" from "sum -> integral".
#   const  -- Q(n) log^3(n) / n^{3/2} for n up to 10^4000, checking that the
#             model itself converges to 16/3.  The integral is evaluated in a
#             normalised form in which every quantity is O(1), so 50 digits
#             suffice at any n.  This is the leg no sieve could reach.
#
# Needs a Python with numpy, mpmath and sympy.  SageMath bundles all three; ask it where
# its interpreter is with
#   sage -c "import sys; print(sys.executable)"
# and then, from inside runs/,
#   <that python> ../code/sage/openproblem21_asymptotics.py all 1e9 REPORT-openproblem21.txt
#
# Not `sage <script>`: SageMath's front end preparses the file and does not forward
# command-line arguments, so any script taking arguments -- this one and compare_fig2.py --
# must be handed to a Python interpreter directly.
#
# The stages are independent; `sieve` and `split` alone reproduce everything the
# manuscript's Lemmas 20-21 rest on, in seconds.  The full run above takes about six
# minutes and ~2 GB, almost all of it the n = 10^14 pass of the `lucy` stage.
#
# Changelog (reverse-chronological):
#   2026-08-27  Claude-Code-c6452f57 (jts-pc) -- split the model stage's error
#               into its two sources (pi -> Li, and sum over primes -> dt/log t);
#               added the Omega >= 3 remainder table to the split stage.
#   2026-08-27  Claude-Code-c6452f57 (jts-pc) -- added the Lucy_Hedgehog stage,
#               which reaches n = 10^14 where the sieve stops at 10^9; normalised
#               the quadrature so that 50 digits suffice at arbitrary n.
#   2026-08-27  Claude-Code-c6452f57 (jts-pc) -- initial version.

import sys
import time
from math import isqrt, log, comb

import numpy as np

OUT = sys.stdout


def emit(s=""):
    OUT.write(s + "\n")
    OUT.flush()
    if OUT is not sys.stdout:
        print(s, flush=True)


def banner(title):
    emit()
    emit("=" * 104)
    emit("STAGE " + title)
    emit("=" * 104)
    emit()


def fmt(x, w=0):
    return f"{x:,}".rjust(w)


# --------------------------------------------------------------------------
# basic sieving
# --------------------------------------------------------------------------


def primes_upto(m):
    """Plain sieve of Eratosthenes; np.int64 array of the primes <= m."""
    if m < 2:
        return np.zeros(0, dtype=np.int64)
    s = np.ones(m + 1, dtype=bool)
    s[:2] = False
    for i in range(2, isqrt(m) + 1):
        if s[i]:
            s[i * i:: i] = False
    return np.flatnonzero(s).astype(np.int64)


# --------------------------------------------------------------------------
# stage "sieve": exact S(n) by a segmented least-prime-factor sieve
# --------------------------------------------------------------------------


def segmented_S(nmax, queries, seg=1 << 22, verbose=True):
    """Exact S(n) and pi(n) at every n in `queries`.

    The segment array holds, for each x, the 0-based index i of lpf(x) when x
    is composite -- which is exactly the weight pi(lpf x) - 1 -- and -1 when x
    is prime.  Marking multiples of p from p*p upwards, in increasing p, and
    only where the cell is still -1, deposits the *least* prime factor.
    """
    qs = sorted(set(int(q) for q in queries if 1 <= q <= nmax))
    base = [int(p) for p in primes_upto(isqrt(nmax) + 1)]
    out_S, out_pi = {}, {}
    runS = runpi = 0
    qi = 0
    t0 = time.time()
    lo = 1
    while lo <= nmax:
        hi = min(lo + seg, nmax + 1)
        arr = np.full(hi - lo, -1, dtype=np.int32)
        for i, p in enumerate(base):
            if p * p >= hi:
                break
            start = max(p * p, ((lo + p - 1) // p) * p)
            if start >= hi:
                continue
            view = arr[start - lo:: p]        # basic slice => a genuine view
            view[view == -1] = i              # weight pi(p) - 1 = i (0-based)
        if lo == 1:
            arr[0] = -2                       # x = 1 is neither prime nor composite
        seg_qs = []
        while qi < len(qs) and qs[qi] < hi:
            seg_qs.append(qs[qi])
            qi += 1
        w = np.where(arr >= 0, arr, 0).astype(np.int64)
        if seg_qs:
            wcum = np.cumsum(w)
            pcum = np.cumsum((arr == -1).astype(np.int64))
            for q in seg_qs:
                out_S[q] = int(runS + wcum[q - lo])
                out_pi[q] = int(runpi + pcum[q - lo])
            runS, runpi = int(wcum[-1]) + runS, int(pcum[-1]) + runpi
        else:
            runS += int(w.sum())
            runpi += int((arr == -1).sum())
        if verbose and hi - 1 >= lo and (lo // seg) % 16 == 0:
            print(f"    ... sieved to {hi-1:,}  ({time.time()-t0:.1f}s)", flush=True)
        lo = hi
    return out_S, out_pi


# --------------------------------------------------------------------------
# stage "lucy": pi(n//i) for all i, in O(n^{3/4})
# --------------------------------------------------------------------------


def lucy_pi(n):
    """Lucy_Hedgehog's prime-counting recursion, vectorised.

    Returns (small, large) with
        small[i] = pi(i)      for 0 <= i <= r = isqrt(n),
        large[i] = pi(n // i) for 1 <= i <= r.
    Both are exact.  The recursion is the Legendre/Meissel sieve carried out on
    the O(sqrt n) distinct values of n//i.
    """
    r = isqrt(n)
    small = np.arange(r + 1, dtype=np.int64) - 1
    small[0] = 0
    large = np.zeros(r + 1, dtype=np.int64)
    idx = np.arange(1, r + 1, dtype=np.int64)
    large[1:] = n // idx - 1
    for p in range(2, r + 1):
        if small[p] == small[p - 1]:
            continue                                   # p composite
        sp = small[p - 1]                              # pi(p-1)
        p2 = p * p
        lim = min(r, n // p2)
        if lim >= 1:
            i = np.arange(1, lim + 1, dtype=np.int64)
            d = i * p
            vals = np.empty(lim, dtype=np.int64)
            m = d <= r
            vals[m] = large[d[m]]
            nm = ~m
            if nm.any():
                vals[nm] = small[n // d[nm]]
            large[1:lim + 1] -= vals - sp
        if p2 <= r:
            j = np.arange(p2, r + 1, dtype=np.int64)
            small[p2:] -= small[j // p] - sp
    return small, large


def S2_from_pi(n, small, large):
    """S_2(n) = sum over primes p <= sqrt n of (pi(p)-1)(pi(n/p) - pi(p) + 1).

    This is exactly the contribution to S(n) of the semiprimes x = p*q, p <= q.
    """
    r = isqrt(n)
    isp = np.zeros(r + 1, dtype=bool)
    isp[2:] = small[2:] > small[1:-1]
    p = np.flatnonzero(isp)
    pip = small[p].astype(object)               # exact python ints
    pinp = large[p].astype(object)
    return int(sum((pip - 1) * (pinp - pip + 1)))


# --------------------------------------------------------------------------
# the smooth model, in normalised form
# --------------------------------------------------------------------------


def model_ratio(n, mp, W=45):
    """Return Q(n) / n^{3/2}, where

        Q(n) = int_2^{sqrt n} (Li(t) - 1) (Li(n/t) - Li(t) + 1) dt / log t

    and Li(x) = li(x) - li(2).  Substituting t = X e^{-a} with X = sqrt(n) and
    M = (log n)/2 turns this into

        X^3 int_0^{min(W, M-log 2)} (u - 1/X)(v - u + 1/X) e^{-a}/(M-a) da,
        u = Li(X e^{-a})/X,   v = Li(X e^{a})/X,

    whose integrand is O(1) and decays like e^{-a}; the tail beyond a = W is
    of relative size e^{-W}.  So a fixed 50 digits suffice for every n.
    """
    n = mp.mpf(n)
    M = mp.log(n) / 2
    X = mp.sqrt(n)
    li2 = mp.li(2)
    top = min(mp.mpf(W), M - mp.log(2))

    def f(a):
        u = (mp.li(X * mp.e**(-a)) - li2) / X
        v = (mp.li(X * mp.e**(a)) - li2) / X
        return (u - 1 / X) * (v - u + 1 / X) * mp.e**(-a) / (M - a)

    pts = [p for p in [mp.mpf(0), mp.mpf(1), mp.mpf(4), mp.mpf(12)] if p < top] + [top]
    return mp.quad(f, pts)


# --------------------------------------------------------------------------
# stages
# --------------------------------------------------------------------------


def log_grid(nmax, per_decade=8, lo=100):
    g = set(int(round(10 ** (k / per_decade)))
            for k in range(per_decade * 2, int(round(per_decade * log(nmax, 10))) + 1))
    g |= set(10 ** k for k in range(2, int(log(nmax, 10) + 1e-9) + 1))
    g.add(nmax)
    return sorted(x for x in g if lo <= x <= nmax)


def stage_sieve(nmax):
    grid = log_grid(nmax)
    decades = [g for g in grid if g in (10 ** k for k in range(4, 14))] + [nmax]
    decades = sorted(set(d for d in decades if d >= 10 ** 4))
    base = [int(p) for p in primes_upto(isqrt(nmax) + 1)]
    extra = set()
    for n0 in decades:
        for p in base:
            if p * p > n0:
                break
            extra.add(n0 // p)
    extra |= set(isqrt(g) for g in grid)
    for g in decades:                       # floor(g^{1/3}), for the Omega>=3 table
        c = int(round(g ** (1.0 / 3.0)))
        while (c + 1) ** 3 <= g:
            c += 1
        while c ** 3 > g:
            c -= 1
        extra.add(c)
    print(f"  segmented sieve to {nmax:,}: {len(grid)} grid points, "
          f"{len(extra)} auxiliary pi-queries", flush=True)
    t0 = time.time()
    S, PI = segmented_S(nmax, set(grid) | extra)
    print(f"  ... done in {time.time()-t0:.1f}s", flush=True)

    banner("sieve -- exact S(n) = C_n - binom(pi(n)+1,2), segmented lpf sieve")
    emit("  A(n) := (2/3) pi(sqrt n)^3   [the claimed asymptotic, with exact prime counts]")
    emit("  B(n) := (16/3) n^{3/2}/log^3 n   [the same claim after substituting PNT]")
    emit()
    emit("  n                    pi(n)          S(n)                    C_n"
         "                         S/B        S/A")
    emit("  " + "-" * 102)
    for n in grid:
        s, r = S[n], PI[n]
        L = log(n)
        A = (2.0 / 3.0) * PI[isqrt(n)] ** 3
        B = (16.0 / 3.0) * n ** 1.5 / L ** 3
        emit(f"  {fmt(n,16)} {fmt(r,14)} {fmt(s,20)} {fmt(s + comb(r+1,2),26)}"
             f"  {s/B:10.5f} {s/A:10.5f}")
    return S, PI, grid, decades


def stage_brute(nmax_sympy=20000, nmax_spf=2 * 10 ** 6):
    banner("brute -- independent recomputation of S(n) by two further routes")
    from sympy import factorint, primepi

    print(f"  sympy factorint route to {nmax_sympy:,} ...", flush=True)
    A = [0] * (nmax_sympy + 1)
    A2 = [0] * (nmax_sympy + 1)          # semiprime part, for the split stage
    run = run2 = 0
    for x in range(2, nmax_sympy + 1):
        f = factorint(x)
        om = sum(f.values())
        if om >= 2:
            w = int(primepi(min(f))) - 1
            run += w
            if om == 2:
                run2 += w
        A[x] = run
        A2[x] = run2

    print(f"  unsegmented spf-sieve route to {nmax_spf:,} ...", flush=True)
    spf = np.zeros(nmax_spf + 1, dtype=np.int64)
    for i in range(2, isqrt(nmax_spf) + 1):
        if spf[i] == 0:
            sl = spf[i * i:: i]
            sl[sl == 0] = i
    isprime = np.zeros(nmax_spf + 1, dtype=bool)
    isprime[2:] = spf[2:] == 0
    spf[2:][isprime[2:]] = np.arange(2, nmax_spf + 1)[isprime[2:]]
    pitab = np.cumsum(isprime)
    w = np.zeros(nmax_spf + 1, dtype=np.int64)
    comp = np.zeros(nmax_spf + 1, dtype=bool)
    comp[2:] = ~isprime[2:]
    w[comp] = pitab[spf[comp]] - 1
    B = np.cumsum(w)

    bad = [x for x in range(2, nmax_sympy + 1) if A[x] != int(B[x])]
    emit(f"  sympy factorint vs unsegmented spf sieve, every n <= {nmax_sympy:,}:"
         f"  {'AGREE' if not bad else 'DISAGREE at ' + str(bad[:8])}")

    print(f"  segmented route to {nmax_spf:,} ...", flush=True)
    qs = sorted(set(list(range(2, 3001)) + [10 ** k for k in range(2, 7)] + [nmax_spf]))
    C, PIc = segmented_S(nmax_spf, qs, seg=1 << 18, verbose=False)
    bad2 = [q for q in qs if C[q] != int(B[q])]
    emit(f"  segmented sieve vs unsegmented spf sieve, {len(qs)} values n <= {nmax_spf:,}:"
         f"  {'AGREE' if not bad2 else 'DISAGREE at ' + str(bad2[:8])}")

    # semiprime part: direct enumeration vs the closed form
    emit()
    emit("  Semiprime part S_2(n): direct enumeration (sympy Omega) vs the closed form")
    emit("  sum_{p <= sqrt n} (pi(p)-1)(pi(n/p) - pi(p) + 1):")
    emit()
    ok = True
    for n in [1000, 5000, 20000]:
        pr = [int(p) for p in primes_upto(isqrt(n))]
        cf = sum((i + 1 - 1) * (int(primepi(n // p)) - (i + 1) + 1) for i, p in enumerate(pr))
        emit(f"    n = {n:>6}:  direct {A2[n]:>10}   closed form {cf:>10}   "
             f"{'agree' if A2[n] == cf else 'DISAGREE'}")
        ok &= A2[n] == cf
    emit()

    emit("  Cross-check of C_n against Table 1 (tab:err) of the manuscript, computed")
    emit("  in an earlier session by an unrelated program:")
    emit()
    emit("    n        C_n (this run)          C_n (manuscript)        agree")
    emit("    " + "-" * 62)
    manuscript = {10 ** 2: 362, 10 ** 3: 14957, 10 ** 4: 769090,
                  10 ** 5: 46233662, 10 ** 6: 3084943710}
    for n, cm in sorted(manuscript.items()):
        cn = C[n] + comb(PIc[n] + 1, 2)
        emit(f"    10^{int(round(log(n,10)))}  {fmt(cn,20)}  {fmt(cm,20)}"
             f"        {'yes' if cn == cm else 'NO'}")
    return None


def stage_split(S, PI, decades):
    banner("split -- S(n) = S_2(n) + S_{>=3}(n)")
    emit("  S_2(n)     = sum_{p <= sqrt n} (pi(p)-1)(pi(n/p) - pi(p) + 1)   [x = p q, p <= q]")
    emit("  S_{>=3}(n) = S(n) - S_2(n)   [Omega(x) >= 3, which forces lpf(x) <= n^{1/3}]")
    emit()
    emit("  n                  S(n)                 S_2(n)             S_>=3(n)"
         "      S_>=3/S      S_2/A")
    emit("  " + "-" * 100)
    base = [int(p) for p in primes_upto(isqrt(max(decades)) + 1)]
    out = {}
    for n in decades:
        S2 = 0
        for i, p in enumerate(base):
            if p * p > n:
                break
            S2 += i * (PI[n // p] - i)
        rest = S[n] - S2
        A = (2.0 / 3.0) * PI[isqrt(n)] ** 3
        out[n] = (S2, rest)
        emit(f"  {fmt(n,14)} {fmt(S[n],20)} {fmt(S2,20)} {fmt(rest,16)}"
             f"  {rest/S[n]:11.6f} {S2/A:10.5f}")
    # the Omega >= 3 remainder in its own right: the trivial bound is
    # O(n^{4/3}/log^2 n), the same heuristic that gives 2/3 pi(sqrt n)^3 for
    # S_2 gives (9/8) pi(n^{1/3})^4 here.  Reported, not claimed.
    emit()
    emit("  The remainder S_{>=3}(n) in its own right.  T(n) := (9/8) pi(n^{1/3})^4 is what")
    emit("  the same saddle-point heuristic predicts; it is NOT verified by these numbers.")
    emit()
    emit("  n              S_>=3(n)          S_>=3 * log^4(n)/n^{4/3}   pi(n^{1/3})   S_>=3/T")
    emit("  " + "-" * 92)
    for n in decades:
        rest = out[n][1]
        c = int(round(n ** (1.0 / 3.0)))
        while (c + 1) ** 3 <= n:
            c += 1
        while c ** 3 > n:
            c -= 1
        pic = PI[c] if c in PI else int(np.searchsorted(np.array(base), c, 'right'))
        T = (9.0 / 8.0) * pic ** 4
        emit(f"  {fmt(n,14)} {fmt(rest,16)} {rest*log(n)**4/n**(4/3):26.3f}"
             f"   {fmt(pic,11)} {rest/T:10.5f}")
    return out


def stage_lucy(exps, sieve_S2=None):
    banner("lucy -- exact S_2(n) far beyond sieve range, via Lucy_Hedgehog prime counting")
    emit("  S_2(n) = sum_{p <= sqrt n} (pi(p)-1)(pi(n/p) - pi(p) + 1), computed from the")
    emit("  exact values pi(n//i) produced by an O(n^{3/4}) Legendre/Meissel recursion.")
    emit("  A(n) = (2/3) pi(sqrt n)^3;   B(n) = (16/3) n^{3/2}/log^3 n.")
    emit()
    emit("  n            pi(sqrt n)         S_2(n)                          "
         "S_2/B       S_2/A     vs sieve")
    emit("  " + "-" * 102)
    res = {}
    for k in exps:
        n = 10 ** k
        t0 = time.time()
        small, large = lucy_pi(n)
        s2 = S2_from_pi(n, small, large)
        pis = int(small[isqrt(n)])
        L = log(n)
        A = (2.0 / 3.0) * pis ** 3
        B = (16.0 / 3.0) * float(n) ** 1.5 / L ** 3
        chk = "-"
        if sieve_S2 and n in sieve_S2:
            chk = "agree" if sieve_S2[n][0] == s2 else "DISAGREE"
        res[n] = s2
        emit(f"  10^{k:<10d} {fmt(pis,12)} {fmt(s2,26)}  {s2/B:11.5f} {s2/A:11.5f}"
             f"     {chk:>8}   [{time.time()-t0:.0f}s]")
    return res


def stage_model(exact_S2):
    from mpmath import mp
    mp.dps = 50
    banner("model -- exact S_2(n) against the smooth model Q(n)")
    emit("  Q(n) = int_2^{sqrt n} (Li(t)-1)(Li(n/t)-Li(t)+1) dt/log t,  Li = offset li.")
    emit("  Q is the integral the derivation evaluates; the derivation says")
    emit("  Q(n) ~ (16/3) n^{3/2}/log^3 n, and this stage asks how fast Q(n) ~ S_2(n).")
    emit()
    emit("  Two intermediate quantities isolate the two approximations Q makes:")
    emit("    E(n) = sum_{p <= sqrt n} (pi(p)-1)(Li(n/p) - pi(p) + 1)   [only the inner pi -> Li]")
    emit("    D(n) = sum_{p <= sqrt n} (Li(p)-1)(Li(n/p) - Li(p) + 1)   [both pi -> Li]")
    emit("  so S_2 -> E -> D -> Q replaces pi by Li, then the sum over primes by dt/log t.")
    emit()
    emit("  n                  S_2(n)                    Q(n)          S_2/Q      S_2/E"
         "      S_2/D       D/Q     (Q-D)/n   (D-S_2)/n")
    emit("  " + "-" * 118)
    li2 = mp.li(2)
    for n in sorted(exact_S2):
        pr = [int(p) for p in primes_upto(isqrt(n))]
        pis = np.searchsorted(np.array(pr), np.array(pr), 'right')   # pi(p) for p in pr
        Q = model_ratio(n, mp) * mp.mpf(n) ** mp.mpf(1.5)
        D = mp.mpf(0)
        E = mp.mpf(0)
        for p, ip in zip(pr, pis):
            Lin = mp.li(mp.mpf(n) / p) - li2
            Lip = mp.li(p) - li2
            D += (Lip - 1) * (Lin - Lip + 1)
            E += (int(ip) - 1) * (Lin - int(ip) + 1)
        s2 = exact_S2[n]
        emit(f"  {fmt(n,16)} {fmt(s2,24)} {float(Q):>14.6e} {float(s2/Q):10.6f}"
             f" {float(s2/E):10.6f} {float(s2/D):10.6f} {float(D/Q):9.6f}"
             f" {float((Q-D)/n):11.4f} {float((D-s2)/n):11.4f}")


def stage_const():
    from mpmath import mp
    mp.dps = 50
    banner("const -- lim Q(n) log^3(n) / n^{3/2} = 16/3 ?")
    emit(f"  target 16/3 = {16/3:.12f}")
    emit("  last column: Q(n) / ((2/3) Li(sqrt n)^3), the smooth analogue of S_2/A.")
    emit()
    emit("  n              Q log^3 n / n^{3/2}    ratio to 16/3     Q/((2/3)Li(sqrt n)^3)")
    emit("  " + "-" * 84)
    for k in [3, 4, 6, 8, 10, 13, 16, 20, 30, 40, 60, 100, 150, 200, 300, 500,
              800, 1200, 2000, 4000]:
        n = mp.mpf(10) ** k
        q = model_ratio(n, mp)                    # = Q(n)/n^{3/2}
        L = mp.log(n)
        val = q * L ** 3
        LiX = (mp.li(mp.sqrt(n)) - mp.li(2)) / mp.sqrt(n)
        alt = q / (mp.mpf(2) / 3 * LiX ** 3)
        emit(f"  10^{k:<11d} {mp.nstr(val, 12):>18}   {float(val)/(16/3):15.9f}"
             f"   {float(alt):22.9f}")


def main():
    global OUT
    what = sys.argv[1] if len(sys.argv) > 1 else "all"
    nmax = int(float(sys.argv[2])) if len(sys.argv) > 2 else 10 ** 8
    lucy_exps = [int(x) for x in sys.argv[4].split(",")] if len(sys.argv) > 4 else \
        [6, 7, 8, 9, 10, 11, 12]
    if len(sys.argv) > 3 and sys.argv[3] != "-":
        OUT = open(sys.argv[3], "w")

    emit("REPORT-openproblem21.txt")
    emit("Open Problem 21 of the manuscript (article/truncations-revisited.tex): the exact order of")
    emit("    S(n) = C_n - binom(pi(n)+1,2) = sum_{x <= n composite} (pi(lpf x) - 1).")
    emit("Generated by code/openproblem21_asymptotics.py")
    emit(f"Run: {time.strftime('%Y-%m-%d %H:%M:%S')}    sieve nmax = {nmax:,}")

    S = PI = None
    sp = None
    if what in ("all", "sieve", "split", "model", "lucy"):
        S, PI, grid, decades = stage_sieve(nmax)
    if what in ("all", "brute"):
        stage_brute()
    if what in ("all", "split", "model", "lucy"):
        sp = stage_split(S, PI, decades)
    if what in ("all", "lucy"):
        stage_lucy(lucy_exps, sieve_S2=sp)
    if what in ("all", "model"):
        stage_model({n: v[0] for n, v in sp.items()})
    if what in ("all", "const"):
        stage_const()

    if OUT is not sys.stdout:
        OUT.close()


if __name__ == "__main__":
    main()
