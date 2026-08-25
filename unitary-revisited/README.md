# unitary-revisited — planned

Nothing here yet.

The intended subject is the pair of papers on the **unitary** convolution:

- *The ring of arithmetical functions with unitary convolution: divisorial and topological
  properties*, Arch. Math. (Brno) **40** (2004) 161–179, arXiv:math/0201082
  ([open access at dml.cz](https://dml.cz/handle/10338.dmlcz/107898));
- *Truncations of the ring of arithmetical functions with unitary convolution*,
  Int. J. Math. Game Theory Algebra **13** (2003) 485–519, arXiv:math/0205242,
  together with the unpublished preprint arXiv:math/0208183.

## Why this is the natural next one

The Dirichlet note's main theorem says the generator counts of the truncation ideal are values of
Legendre's Φ. The obvious question is whether the unitary truncations admit anything comparable.
There is reason for caution: in the unitary case the truncation ideals are indexed by *unitary
ideals* (finite sets closed under unitary divisors) rather than by initial segments [n], and the
2003 analysis runs through Stanley–Reisner theory rather than stable ideals — precisely because the
Dirichlet [n]-truncation happens already to be a full simplex. It is not obvious that a sifting
function appears there at all.

## What already exists

The original computations survive in `jts-forskning`, and are worth knowing about before starting:
the unitary work used **Maple to generate Macaulay2 input**, with Macaulay2 computing the
resolutions and Poincaré–Betti series, and the **GAP** package *Simplicial Homology* (Dumas,
Heckenbach, Saunders, Welker) for the homology of the associated complex, plus a short GAP
programme to test lex-shellability. That division of labour is recorded in the 2003 paper's own
Acknowledgement.
