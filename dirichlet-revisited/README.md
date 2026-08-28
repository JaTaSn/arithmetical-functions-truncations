# dirichlet-revisited

## Truncations of the ring of number-theoretic functions, revisited

Supporting material for the note *Truncations of the ring of number-theoretic functions,
revisited*, a follow-up to

> Jan Snellman, *Truncations of the ring of number-theoretic functions*,
> Homology, Homotopy and Applications **2** (2000), 17–27; arXiv:math/9904143.

Everything needed to reproduce every numerical claim in **both** papers is here, together with a
Lean 4 formalization of the central algebraic step of the new one.

## The result

Let Γ be the ring of all functions ℕ⁺ → K under Dirichlet convolution and Γ_n its truncation to
functions supported on [1,n]. The 2000 paper shows Γ_n ≅ S/I_n for a monomial ideal I_n that is
stable after reversing the variable order, and computes its Poincaré–Betti series in terms of the
numbers C_{n,v} of minimal generators of I_n of least support v.

The new note proves

> **C_{n,v} = Φ(n, p_v)**,

Legendre's sifting function — the number of integers in [1,n] with no prime factor ≤ p_v. Hence the
generator counts governing a minimal free resolution are values of the classical sieve. Consequences:
a proof of Conjecture 4.6 of the 2000 paper, left open there; the average order C_n ~ π(n)²/2,
showing that Theorem 3.4(3)'s lower bound is asymptotically an equality; and the identification of
C_n with OEIS [A182843](https://oeis.org/A182843). The error term in that average order is then
determined exactly,

> **C_n − binom(π(n)+1, 2) ~ (2/3)·π(√n)³ ~ (16/3)·n^{3/2}/log³n**,

and a short section records the socle of Γ_n, its Cohen–Macaulay type ⌈n/2⌉, and that Γ_n is
Gorenstein only for n ≤ 2. Errata for the 2000 paper are also recorded — one stated result is
false and two proofs are incomplete.

## Layout

```
article/          the new manuscript (.tex, .pdf) and its two figures
  original-2000/  the 2000 paper's source and its three data tables, for reference
                  and so the scripts below have something to diff against
code/sage/        the 2026 recomputation -- SageMath + Python
code/maple/       the original 1999 Maple code, as it was
code/macaulay2/   an independent check of Section 4 via genuine free resolutions
runs/             raw output of all of the above
references/       certificate of existence for the references new to this note
LEAN/             Lean 4 + Mathlib formalization -- see LEAN/README.md
```

## Reproducing the results

**SageMath** (`sage 10.9` or later). Every script recomputes C_{n,v} by enumerating the minimal
generators of I_n *directly as integers*, never from the formula being tested, so agreement is
evidence rather than tautology.

```sh
cd runs
sage ../code/sage/recompute_truncations.sage      # Figures 1-3 of the 2000 paper, regenerated
sage ../code/sage/verify_legendre_phi.sage        # C_{n,v} = Phi(n,p_v), every (n,v) with n <= 160
sage ../code/sage/verify_exact_formula.sage       # the split, and the closed form for C_n
sage ../code/sage/verify_conjecture_reduction.sage # Conjecture 4.6's reduction, and clauses (1),(3)-(6)
python3 ../code/sage/compare_fig2.py ../article/original-2000/tabCg.tex   # cell-by-cell diff vs the paper
python3 ../code/sage/asymptotics_Cn.py            # C_n by sieve to 10^7
```

**The asymptotics.** The error term `S(n) = C_n − binom(π(n)+1, 2)` is the one place where the
note leaves exact arithmetic for analysis, so it is the one place where a numerical check has to
do real work. It is checked by five mutually independent routes, none of which fits a constant to
data — every quantity below is computed exactly, and the constant `16/3` is *predicted* and then
tested, never estimated.

- **Three implementations of `S(n)`, agreeing.** A segmented least-prime-factor sieve; an
  unsegmented smallest-prime-factor sieve written separately; and sympy's `factorint`. They agree
  at every `n ≤ 20,000` and at 3003 values of `n ≤ 2·10⁶`. `code/sage/independent_check_op21.py`
  is a fourth, written without reference to the others, and reproduces `C_n` at `10⁶` and `10⁷`.
- **Both closed forms are tested, not assumed, and they are different statements.** Lemma 20's
  form for `S₂` — the sum over `p ≤ √n` of `(π(p)−1)(π(n/p)−π(p)+1)` — is checked against direct
  enumeration by Ω at `n = 1000, 5000, 20000`. Lemma 21's *exact splitting*, which peels off
  `(P−1)P(2P−1)/6` and leaves `T(n) = Σ(j−1)π(n/p_j)`, is a different identity and is checked
  separately, in `independent_check_op21.py`, with both halves printed. Beware a name collision
  while reading the six-stage report: it uses `T(n)` for an unrelated quantity,
  `(9/8)π(n^{1/3})⁴`, in its `Ω ≥ 3` table.
- **Reaching 10¹⁴.** The sieve stops near `10⁹`. A Lucy_Hedgehog `O(n^{3/4})` prime-counting
  recursion produces exactly the values `π(n/p)` the closed form needs, giving *exact* `S₂(n)` to
  `n = 10¹⁴`. It overlaps the sieve over four decades and agrees throughout, so neither route is
  trusted alone.
- **Reaching 10⁴⁰⁰⁰.** Even `10¹⁴` is far from converged, so the ratio is also computed for the
  smooth model `Q(n)` that the derivation integrates, by quadrature at 50 digits, out to
  `n = 10⁴⁰⁰⁰` — where it agrees with `16/3` to one part in 1500. Two intermediate quantities
  separate the model's two approximations (π → Li, and sum over primes → dt/log t), so a
  discrepancy could be attributed rather than merely observed.

What this does **not** establish, and the note says so: the constant for the `Ω ≥ 3` remainder.
The report labels that column "NOT verified by these numbers", and the manuscript leaves it open.

```sh
cd runs
python3 ../code/sage/openproblem21_asymptotics.py all 1e9 REPORT-openproblem21.txt
sage    ../code/sage/independent_check_op21.py    # a fourth implementation, 10^6 and 10^7
sage    ../code/sage/plot_S2_ratio.sage    ../article/S2-ratio.pdf     # Figure 2
sage    ../code/sage/plot_Cnv_profile.sage ../article/Cnv-profile.pdf  # Figure 1
```

`openproblem21_asymptotics.py` needs numpy, mpmath and sympy, and takes arguments, so it is given
to a Python interpreter directly rather than to `sage` — SageMath's front end preparses the file
and does not forward `argv`. SageMath bundles all three packages; `sage -c "import sys;
print(sys.executable)"` reports the interpreter to use. The full run takes about six minutes and
~2 GB, almost all of it the `10¹⁴` pass; the individual stages (`sieve`, `brute`, `split`, `lucy`,
`model`, `const`) can be run alone, and `sieve` and `split` alone cover Lemmas 20–21 in seconds.

**The socle.** Section 7's statements — socle, Cohen–Macaulay type, Gorenstein, level — are checked
twice over, and deliberately not by the same argument the note gives. `socle_and_macaulay_check.py`
counts the socle elementarily; `verify_socle.sage` instead builds `I_n` from *all* monomials of
weight in `(n, n·p_r]`, with no appeal to any minimal-generator characterisation, and asks Singular
for the ideal quotient `(I : m)` and for a genuine minimal free resolution.

```sh
cd runs
sage ../code/sage/verify_socle.sage > REPORT-socle.txt
sage ../code/sage/socle_and_macaulay_check.py > REPORT-socle-macaulay.txt
```

The socle is confirmed for `n = 1…120` and the last Betti number for `n = 2…30`. The resolution
route stops at 30 on purpose: a first attempt at 40 was killed after Singular's `mres` passed
5.8 GB resident somewhere in `31…40`. That limit is recorded in the script rather than quietly
worked around.

**Macaulay2** (`1.26` or later). The 2000 paper computes its Poincaré–Betti series *from* the
Eliahou–Kervaire formula and never resolves anything. This script builds I_n and asks for real
minimal free resolutions, so it tests that input rather than the arithmetic downstream of it:

```sh
M2 --script code/macaulay2/verify-betti.m2
```

It confirms equation (30) of the 2000 paper, and dim_K A_n = n, for n = 2…40.

**Maple.** `code/maple/getsols.maple` is the original 1999 code, unmodified. It computes the
generator counts and assembles the Poincaré–Betti series (`PBI`, `PBKK`, and the bigraded `GPBI`,
`GPBKK`); `res1.mws` and `d2run.ms` are saved interactive sessions driving it. Kept for the record
— the SageMath scripts above supersede it and take a deliberately different route.

**Lean.** See [`LEAN/README.md`](LEAN/README.md). `cd LEAN && lake exe cache get && lake build
DirichletTruncations`. The end-to-end statement is `Conjecture46` in
`LEAN/DirichletTruncations/Chain.lean`: 667 lines over three files, 0 `sorry`, and `#print axioms`
gives `propext`, `Classical.choice`, `Quot.sound` and nothing else.

**References.** [`references/CERTIFICATE.md`](references/CERTIFICATE.md) records, for each of the
fifteen references new to this note, what the manuscript uses it for, whether a primary source is
in the working corpus, and a verbatim quotation where it is. Nine have one; six do not, and say so.
Nothing whose source is unavailable carries a proof. The 2000 paper's own six references are not
re-certified.

## The arXiv bundle

`../arxiv/dirichlet-revisited/` holds a self-contained, ready-to-upload copy: the `.tex` (which
builds with `pdflatex`, arXiv's default engine) plus the Lean formalization and all the code as
ancillary material.

## What is not here

The research corpus of cited papers, and the publisher's typeset PDF of the 2000 paper — see the
repository [README](../README.md) for why. Author's source and author's compile of the 2000 paper
are in `article/original-2000/`.

Author and licence: see the repository [README](../README.md).
