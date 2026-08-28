# arXiv bundle — Truncations revisited

Upload the contents of this directory (excluding this README).

- `truncations-revisited.tex` — the manuscript. **Builds clean with `pdflatex`**, arXiv's default
  engine: two passes, 0 errors, 0 undefined references, 0 overfull boxes, re-verified 2026-08-27 after the figure was added. The only non-standard
  package is `orcidlink`, which arXiv has. The `ö` in the affiliation survives pdflatex, so no
  `fontspec`/xelatex declaration is needed.
- `Cnv-profile.pdf` — Figure 1, the profile of `C_{n,v}`; regenerate with
  `anc/code/sage/plot_Cnv_profile.sage`.
- `S2-ratio.pdf` — Figure 2, the convergence of `S_2(n)/((2/3)pi(sqrt n)^3)`; regenerate with
  `anc/code/sage/plot_S2_ratio.sage`.
  **Both figure files must be uploaded too**; they are source, not build products, and
  `.gitignore` carries explicit exceptions saying so.
- `abstract.txt` — the abstract as plain text, for pasting into arXiv's submission form: no
  LaTeX, no `\cite`, no hyperlinks, the one display written out in ASCII. Keep it in step with the
  `.tex` abstract by hand; nothing checks that they agree.
- `anc/LEAN/` — the Lean 4 + Mathlib formalization of Conjecture 4.6 and of Lemma 21, end to end.
- `anc/code/` — the SageMath, Maple and Macaulay2 code reproducing every number in the note and in
  the 2000 paper. Note that the *outputs* of those scripts are not shipped here: they live in
  `../../dirichlet-revisited/runs/` and are part of the repository, not of the submission.

## Before submitting

1. Two items were still open in the author's own notes when this bundle was assembled: the venue
   question, and one theorem number in Tenenbaum that could not be verified against the book (the
   `.tex` carries a `TODO(Jan)` comment at that citation). Neither blocks submission; both should
   be looked at once more first.
2. **arXiv's policy on LLM assistance** requires disclosure and places responsibility with the
   author for everything in the submission, including references. The manuscript's Acknowledgements
   disclose the assistance in full; the reference list has been checked against primary sources.
3. Suggested primary class: `math.AC` (commutative algebra), cross-list `math.NT`.
4. Once the preprint has an arXiv id, consider the [Palomar registry](https://palomar-registry.org/)
   for the formalization — see the repository README's *Registries* section, and note the caveat
   there about what is and is not formalized.
