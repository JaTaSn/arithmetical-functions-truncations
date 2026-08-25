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
C_n with OEIS [A182843](https://oeis.org/A182843). Errata for the 2000 paper are also recorded —
one stated result is false and two proofs are incomplete.

## Layout

```
article/          the new manuscript (.tex, .pdf)
  original-2000/  the 2000 paper's source and its three data tables, for reference
                  and so the scripts below have something to diff against
code/sage/        the 2026 recomputation -- SageMath + Python
code/maple/       the original 1999 Maple code, as it was
code/macaulay2/   an independent check of Section 4 via genuine free resolutions
runs/            raw output of all of the above
LEAN/            Lean 4 + Mathlib formalization -- see LEAN/README.md
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

## The arXiv bundle

`../arxiv/dirichlet-revisited/` holds a self-contained, ready-to-upload copy: the `.tex` (which
builds with `pdflatex`, arXiv's default engine) plus the Lean formalization and all the code as
ancillary material.

## What is not here

The research corpus of cited papers, and the publisher's typeset PDF of the 2000 paper — see the
repository [README](../README.md) for why. Author's source and author's compile of the 2000 paper
are in `article/original-2000/`.

Author and licence: see the repository [README](../README.md).
