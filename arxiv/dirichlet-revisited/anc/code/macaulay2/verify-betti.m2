-- verify-betti.m2 -- an INDEPENDENT check of Section 4 of Snellman (2000).
--
-- The 2000 paper computes the Poincare-Betti series of Gamma_n from the
-- Eliahou-Kervaire formula: it never resolves anything.  This script instead
-- builds the ideal I_n directly and asks Macaulay2 for actual minimal free
-- resolutions, then compares.  So it tests the *input* to Section 4, not just
-- the arithmetic downstream of it.
--
-- Two things are checked, for each n in the range below:
--   (1) beta_q(I_n) from a genuine resolution  ==  sum_i C_{n,1+r-i} * binom(i-1,q)
--       which is equation (30) of the paper.
--   (2) dim_K A_n == n   (Proposition 2.4).
--
-- Usage:  M2 --script verify-betti.m2
--
-- Changelog (reverse chronological):
--   2026-08-25  Claude-Code-6d5c5b66 (jts-pc) -- initial version.

NMAX = 40;
kk = ZZ/32003;

primesUpTo = n -> select(2..n, p -> isPrime p);

-- the minimal generators of I_n, as exponent vectors:
--   a monomial of weight W is a minimal generator iff W > n and W/p <= n
--   for every prime p | W, the binding case being the least prime factor.
weightOf = (ps, e) -> product apply(#ps, i -> (ps#i)^(e#i));

-- Build I_n inside kk[x_1..x_r] with x_i <-> p_i, by listing every monomial of
-- weight > n that is minimal for divisibility.
truncationIdeal = n -> (
    ps := toList primesUpTo n;
    r := #ps;
    R := kk[vars(0..r-1)];
    -- all integers W in (n, n*p_r] whose prime factors are all <= n
    gensList := {};
    for W from n+1 to n*(ps#(r-1)) do (
        fac := factor W;
        pf := apply(toList fac, t -> (t#0));
        if max pf <= n and W <= n * (min pf) then (
            e := apply(ps, p -> (
                    c := 0; V := W;
                    while V % p == 0 do (V = V // p; c = c + 1);
                    c));
            gensList = append(gensList, product apply(r, i -> (R_i)^(e#i)));
            );
        );
    (R, ideal gensList, ps)
    );

-- C_{n,v} : number of minimal generators whose least variable is x_v
Cnv = (n, v) -> (
    ps := toList primesUpTo n;
    r := #ps;
    pv := ps#(v-1);
    count := 0;
    for x from (n // pv) + 1 to n do (
        if x == 1 then count = count + 1
        else ( pf := apply(toList factor x, t -> t#0);
               if min pf >= pv then count = count + 1 );
        );
    count
    );

print "=====================================================================";
print "Independent check of Snellman (2000), Section 4, via real resolutions";
print "=====================================================================";
print "";
print " n   r  dim A_n  betti(I_n) from resolution        from eqn (30)   ok?";

allOK = true;
for n from 2 to NMAX do (
    (R, In, ps) := truncationIdeal n;
    r := #ps;
    An := R/In;
    -- (2) dimension over kk
    dimAn := numgens source basis An;
    -- (1) Betti numbers of I_n from an honest minimal free resolution
    F := res(module In, LengthLimit => r + 1);
    betaRes := apply(toList(0..r-1), q -> rank F_q);
    -- equation (30):  beta_q = sum_{i=1}^{r} C_{n,1+r-i} * binomial(i-1, q)
    betaFormula := apply(toList(0..r-1), q ->
        sum apply(toList(1..r), i -> (Cnv(n, 1 + r - i)) * binomial(i-1, q)));
    ok := (betaRes == betaFormula) and (dimAn == n);
    if not ok then allOK = false;
    print(toString n | "  " | toString r | "   " | toString dimAn | "      " |
          toString betaRes | "   " | toString betaFormula | "   " |
          (if ok then "yes" else "NO  <<<<"));
    );
print "";
print(if allOK then "ALL CHECKS PASSED -- equation (30) and Prop 2.4 confirmed against"
                    | " genuine minimal free resolutions."
               else "SOME CHECK FAILED -- see the rows marked NO above.");
