# arXiv bundle — Truncations revisited

Upload the contents of this directory (excluding this README).

- `truncations-revisited.tex` — the manuscript. **Builds clean with `pdflatex`**, arXiv's default
  engine: two passes, 0 errors, 0 undefined references, 0 overfull boxes, re-verified 2026-08-27 after the figure was added. The only non-standard
  package is `orcidlink`, which arXiv has. The `ö` in the affiliation survives pdflatex, so no
  `fontspec`/xelatex declaration is needed.
- `Cnv-profile.pdf` — Figure 1, the profile of `C_{n,v}`. **This file must be uploaded too**; it is
  source, not a build product, and `.gitignore` carries an explicit exception saying so. Regenerate
  it with `code/plot_Cnv_profile.sage` if the figure ever changes.
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
4. Once the preprint has an arXiv id, consider the [Palomar registry](https://palomar-registry.org/)
   for the formalization — see the repository README's *Registries* section, and note the caveat
   there about what is and is not formalized.
