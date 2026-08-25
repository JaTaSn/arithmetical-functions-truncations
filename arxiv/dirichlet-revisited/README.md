# arXiv bundle — Truncations revisited

Upload the contents of this directory (excluding this README).

- `truncations-revisited.tex` — the manuscript. **Builds clean with `pdflatex`**, arXiv's default
  engine: two passes, 0 errors, 0 overfull boxes, verified 2026-08-25. The only non-standard
  package is `orcidlink`, which arXiv has. The `ö` in the affiliation survives pdflatex, so no
  `fontspec`/xelatex declaration is needed.
- `anc/LEAN/` — the Lean 4 + Mathlib formalization of Conjecture 4.6, end to end.
- `anc/code/` — the SageMath, Maple and Macaulay2 code reproducing every number in the note and in
  the 2000 paper.

## Before submitting

1. Re-read `../../dirichlet-revisited/README.md`'s open questions — at the time of writing the
   manuscript still had unresolved items in the author's TODO (the venue question, and one
   theorem number in Tenenbaum that could not be verified against the book).
2. **arXiv's policy on LLM assistance** requires disclosure and places responsibility with the
   author for everything in the submission, including references. The manuscript's Acknowledgements
   disclose the assistance in full; the reference list has been checked against primary sources.
3. Suggested primary class: `math.AC` (commutative algebra), cross-list `math.NT`.
