# Arithmetical functions: truncations, revisited

Supporting material for a series of notes revisiting Jan Snellman's papers on **truncations of
rings of arithmetical functions** — the finite-dimensional quotients Γ_n obtained by discarding
everything supported above n, which turn out to be polynomial rings modulo monomial ideals and so
have computable minimal free resolutions.

Each note gets its own directory: the manuscript, every script needed to reproduce its numbers, and
any formalization. Below, the arXiv-ready bundles.

## Contents

| Directory | Status |
|---|---|
| **[`dirichlet-revisited/`](dirichlet-revisited/)** | **Complete.** Revisits *Truncations of the ring of number-theoretic functions*, Homology Homotopy Appl. **2** (2000) 17–27, arXiv:math/9904143. |
| [`unitary-revisited/`](unitary-revisited/) | Planned — the unitary-convolution truncations. |
| [`ternary/`](ternary/) | Speculative — the ternary convolution, where no truncation analysis exists yet. |
| [`arxiv/`](arxiv/) | Submission bundles, one subdirectory per note. |

## The Dirichlet case, in one line

The generator counts governing the minimal free resolution of Γ_n turn out to be

> **C_{n,v} = Φ(n, p_v)**,

Legendre's sifting function — the number of integers in [1,n] with no prime factor ≤ p_v. So an
invariant of commutative algebra is literally a value of the classical sieve. From that: a proof of
Conjecture 4.6 of the 2000 paper, which was left open there; the average order C_n ~ π(n)²/2,
showing the paper's own lower bound is asymptotically an equality; the identification of C_n with
OEIS [A182843](https://oeis.org/A182843); and errata — one stated result of the 2000 paper is
false, and two of its proofs are incomplete.

A **[browsable rendering of the Lean code](dirichlet-revisited/LEAN/docs/)** is committed
alongside it, generated with doc-gen4 — the same tool behind the Mathlib API docs.

The central algebraic step is **machine-checked**: `dirichlet-revisited/LEAN/` proves Conjecture
4.6 end to end in Lean 4 + Mathlib, 0 `sorry`, standard axioms only, assuming nothing but the
Eliahou–Kervaire input (which enters as a definition, not an axiom).

## Registries

The Lean formalization is a candidate for the **[Palomar registry](https://palomar-registry.org/)**,
Terence Tao's registry of formalized mathematical results. A submission package for a different
project of the author's (`lattice-line-covers`) was prepared in August 2026 and the same shape
applies here — with the caveat that what is formalized in `dirichlet-revisited/LEAN/` is
Conjecture 4.6 *given* the Eliahou–Kervaire input, not the full chain down to the ring `Γ_n`, and
any registry entry must say so.

## What is deliberately absent

**The research corpus of cited papers.** Those are other people's copyrighted PDFs — two of them
not open access — and have no business in a public repository. They live with the working notes in
a private workspace. Everything cited is on arXiv, in an open archive, or named precisely enough to
find.

Also absent: the publisher's typeset PDF of the 2000 paper. `dirichlet-revisited/article/original-2000/`
holds the author's own source and his own compile of it; the published version is freely readable at
[International Press](https://intlpress.com/) and on [arXiv](https://arxiv.org/abs/math/9904143).

## Licence

Two licences, split the usual way:

| What | Licence |
|---|---|
| **Code and the Lean formalization** — `code/`, `LEAN/`, `runs/`, `arxiv/*/anc/` | **Apache License 2.0** — [`LICENSE`](LICENSE) |
| **Manuscripts and prose** — `article/`, and the READMEs | **CC BY 4.0** — [`LICENSE-CC-BY-4.0`](LICENSE-CC-BY-4.0) |

Copyright © 2026 Jan Snellman.

Apache-2.0 for the Lean is the natural choice: it is what Mathlib itself uses, so the formalization
carries the same terms as everything it is built on, and its file headers say so in Mathlib's own
words. CC BY 4.0 for the prose is what arXiv and most maths preprint venues expect, and permits
reuse with attribution.

## Author

Jan Snellman, Matematiska Institutionen, Linköpings Universitet, 581 83 Linköping, Sweden ·
<jan.snellman@liu.se> · ORCID [0009-0002-6676-5068](https://orcid.org/0009-0002-6676-5068)

Produced with substantial assistance from Claude (Anthropic), working under the author's direction
— as an assistant, not a co-author. Each manuscript's Acknowledgements give the specifics.
