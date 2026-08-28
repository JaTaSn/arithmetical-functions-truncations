# Certificate of existence — the references new to *Truncations revisited*

## Purpose

arXiv's 2026 enforcement policy imposes a one-year submission ban on authors for whom there is
"incontrovertible evidence" of unchecked large-language-model output in a paper, and names
hallucinated or fabricated references as a trigger. This note was written with substantial AI
assistance, disclosed in full in its own *Disclosure of AI assistance* section. So it is worth
being able to show, plainly and checkably, that the references are real and that what is
attributed to them is what they say.

**Scope.** The 2000 paper this note revisits cites six works: Aramova–Herzog, Cashwell–Everett,
Eliahou–Kervaire, Golod, Gulliksen–Levin, Peeva. Those are the author's own from twenty-six years
ago and are not re-certified here. This document covers the **fifteen references new to the
revisit**, excluding software (SageMath, Macaulay2, GAP, the Simplicial Homology package), the
OEIS, and this repository.

For each: the citation, what the manuscript uses it for and where, whether a primary source is
available in the working corpus, and — where it is — a verbatim quotation with a locator.

**Every quotation below was extracted with `pdftotext` from a PDF actually present in
`ai-workspace/projects/dirichlet-truncations/literature/` and read while preparing this file.**
None were reconstructed from familiarity. Nine of the fifteen have a primary source to hand; six do
not, and are marked as such rather than quietly asserted.

---

## A. With primary source (9)

### 1. Fan — `\cite{Fan}`

**Citation:** Kai (Steve) Fan, *Numerically explicit estimates for the distribution of rough
numbers*, arXiv:2306.03347.

**Used at** lines 998, 1220, 1243. The load-bearing use is line 998, in the five-comment remark:
the one-term Buchstab estimate "is uniform only for `u ≥ 2` \cite{Fan}, which excludes precisely
the region carrying the mass". The remark also uses `ω(u) = 1/u` on `1 ≤ u ≤ 2`.

**Primary source: available** — `literature/fan-2023-explicit-estimates-rough-numbers.pdf`.

**Quotation**, §1, equation (1.3) and the sentence following:

> Φ(x, y) = (x / log y) (ω(u) + O(1 / log y))   (1.3)
>
> uniformly for 2 ≤ y ≤ √x (see [13, Theorem III.6.4]).

`2 ≤ y ≤ √x` is exactly `u = log x / log y ≥ 2`, so the manuscript's "uniform only for `u ≥ 2`" is
the cited statement. Earlier on the same page:

> In 1937, Buchstab [3] showed that for any fixed u > 1, one has Φ(x, y) ∼ ω(u)x/log y as x → ∞,
> where ω(u) is defined to be the unique continuous solution to the delay differential equation
> (uω(u))′ = ω(u − 1) for u ≥ 2, subject to the initial value condition **ω(u) = 1/u for u ∈ [1, 2]**.

which is the second thing the remark uses, and also corroborates the Buchstab citation (see B.1).
And, two lines above (1.3):

> it turns out that this nice asymptotic formula does not hold uniformly, as already exemplified by
> the base case 1 ≤ u ≤ 2.

— i.e. Fan makes the same point the manuscript makes, in the same range.

### 2. Holt — `\cite{Holt}`

**Citation:** Fred B. Holt, *On the counts of p-rough numbers*, arXiv:2308.07570.

**Used at** line 1221, in the survey sentence of §"Related work": cited "for the regime of fixed
`p`, which is the one closest to ours".

**Primary source: available** — `literature/holt-2023-counts-of-p-rough-numbers.pdf`.

**Quotation**, abstract:

> We denote by Φ(x, p) the count of p-rough numbers up to and including x. … we identify symmetries
> for Φ(x, p) **for fixed p**.

### 3. Gorodetsky — `\cite{Gorodetsky}`

**Citation:** Ofir Gorodetsky, *The variance of integers without small prime factors in short
intervals*, Math. Z. **308** (2024), no. 4, Paper No. 59; arXiv:2111.00853.

**Used at** line 1221, cited "for short intervals" in the same survey sentence.

**Primary source: available** —
`literature/gorodetsky-2024-variance-integers-no-small-prime-factors.pdf`.

**Quotation**, title and abstract:

> The variance of integers without small prime factors in short intervals … We study the variance
> of integers without prime factors below y, **in short intervals**.

### 4. Goswami–Kleyn–Porrill — `\cite{GoswamiKleynPorrill}`

**Citation:** Amit Goswami, Steven Kleyn and Lauren Porrill, *On structures of the ring of
arithmetical functions: prime ideals and beyond*, arXiv:2410.10824.

**Used at** line 1192, §"Related work": the ring Γ "continues to be studied — recently in
\cite{GoswamiKleynPorrill}, which shows it is neither Noetherian nor Artinian, constructs several
families of prime ideals, and computes its Krull dimension to be infinite".

**Primary source: available** —
`literature/goswami-kleyn-porrill-2024-structures-ring-arithmetical-functions.pdf`.

**Quotation**, abstract:

> We prove that this ring is **neither Noetherian nor Artinian**. Furthermore, we construct
> various types of prime ideals.

and Proposition 3.22:

> **The Krull dimension of A is infinite.**

All three clauses of the manuscript's sentence are accounted for.

### 5. Miyashita — `\cite{Miyashita}`

**Citation:** Sora Miyashita, *Canonical traces of Artinian truncations of Stanley–Reisner rings*,
arXiv:2608.15955.

**Used at** line 1212, §"Related work": "Artinian truncations of Stanley–Reisner rings are an
active topic \cite{Miyashita}, and Γ_n is an object of that general shape, but no arithmetic
enters there."

**Primary source: available** — `literature/miyashita-2026-canonical-traces-artinian-truncations.pdf`.

**Quotation**, abstract, which fixes the family studied:

> A_{Δ,n} = k[x₁, …, x_m] / (I_Δ + (x₁^{n₁}, …, x_m^{n_m}))
>
> We give an exact combinatorial formula for the canonical trace for arbitrary truncation exponents
> and for an arbitrary simplicial complex …

**Caveat, recorded deliberately.** An adversarial review on 2026-08-27 observed that Γ_n is *not*
in this family — `x₁²x₂` minimally generates `I_10`, and is neither squarefree nor a pure power.
The manuscript's hedge, "an object of that general shape", is therefore doing real work and should
not be strengthened.

### 6. Herzog–Reiner–Welker — `\cite{HerzogReinerWelker}`

**Citation:** Jürgen Herzog, Victor Reiner and Volkmar Welker, *Componentwise linear ideals and
Golod rings*, Michigan Math. J. **46** (1999), no. 2, 211–223.

**Used at** line 509, §"Errata": "An alternative route to the same conclusion runs through
componentwise linearity \cite{HerzogReinerWelker}, since stable ideals have linear quotients."

**Primary source: available** —
`literature/herzog-reiner-welker-1999-componentwise-linear-golod.pdf`.

**Quotation**, §1:

> It is known [3] that if a homogeneous ideal I has linear resolution as an A-module … then
> R = A/I is Golod. Herzog and Hibi [13] generalized the notion of linear resolution to that of
> **componentwise linearity**, and our main result (Theorem 4) states that, when I is a
> componentwise linear [ideal] …

The paper is what the manuscript says it is: the componentwise-linear route to Golodness.

### 7. McCullough–Peeva — `\cite[Thm.~6.16(6)]{McCulloughPeeva}`

**Citation:** Jason McCullough and Irena Peeva, *Infinite graded free resolutions*, in: Commutative
Algebra and Noncommutative Algebraic Geometry, Vol. I, MSRI Publ. **67**, CUP, 2015, 215–257.

**Used at** line 502, §"Errata", with a specific numbered locator — the strongest kind of claim to
make, and so the one most worth checking. The manuscript says the Aramova–Herzog/Peeva result "is
standard" in the 0-Borel-fixed form, "see \cite[Thm.~6.16(6)]{McCulloughPeeva}".

**Primary source: available** — `literature/mccullough-peeva-2015-infinite-graded-free-resolutions.pdf`.

**Quotation**, Theorem 6.16, item (6), verbatim:

> (6) (Aramova-Herzog (1996) [AH], and Peeva (1996) [Pe1]) An ideal L generated by monomials in S
> is called 0-Borel fixed (also referred to as strongly stable) if whenever m is a monomial in L
> and x_i divides m, then x_j m/x_i ∈ L for all 1 ≤ j < i. … If L is a 0-Borel fixed ideal
> **contained in (x₁, …, x_n)²**, then S/L is a Golod ring.

The locator is correct, the joint attribution is there, and the `(x₁,…,x_n)²` hypothesis — which
Remark 1 of the manuscript exists to verify — is stated in the source.

### 8. Snellman, unitary truncations — `\cite{SnellmanUnitaryTrunc}`

**Citation:** Jan Snellman, *Truncations of the ring of arithmetical functions with unitary
convolution*, Int. J. Math. Game Theory Algebra **13** (2003), no. 6, 485–519; arXiv:math/0205242.

**Used at** lines 1262 and 1399. The quantitative use is line 1262, Remark 32: the unitary socle
dimension is known "only asymptotically, as δn with δ = ½ + Σ … ≈ 0.6077".

**Primary source: available** — `literature/snellman-2003-unitary-truncations-b.pdf`.

**Quotation**, §7.1, Theorem 7.2:

> Theorem 7.2. Let dim_C Socle(A_[n]) denote the vector space dimension of the socle of A_[n]. Then
> … **≈ 0.60771435951661818**

The manuscript's `0.6077` is the leading digits of the source's own figure.

### 9. Snellman, Laplacians — `\cite{SnellmanLaplacians}`

**Citation:** Jan Snellman, *Laplacians on shifted multicomplexes*, arXiv:math/0606104.

**Used at** lines 1199 and 1378. §"Related work" states that this paper computes the Laplacian
spectrum of the multicomplex `{1,…,n}` and identifies its multiplicities as arithmetic counts.

**Primary source: available** —
`ai-workspace/preprints-publications/preprints/math_0606104_laplacians-on-shifted-multicomplexes.pdf`.

**Quotation**, §1 and §6, Corollary 14:

> The present author [11] studied a family of monomial algebras, corresponding to truncations of
> the ring of arithmetical functions with Dirichlet convolution. … We finally arrive at a formula
> for the spectrum of the Laplacian of the defining ideals of the truncation algebras studied by
> the author in [11].

> Corollary 14. The spectrum s′_k of the k'th Laplacian L′_k of the multicomplex M_N is given by
> s′_k = Σ_{1≤ℓ≤N, Ω(ℓ)=k} log(sfp(ℓ))

and its reference [11] is the 2000 paper. This is why the manuscript's related-work section says
the truncations were taken up once more by the same author rather than by nobody.

---

## B. Without primary source in the corpus (6)

None of these is load-bearing for a proof. Each is cited for context, for an attribution, or for a
standard fact; where a claim rests on one, secondary corroboration is given.

### B.1 Buchstab (1937) — `\cite{Buchstab}`

A. A. Buchstab, *Asymptotic estimates of a general number-theoretic function*, Mat. Sb. **44**
(1937), 1239–1246. Russian, 1937, not obtained. **Corroborated** by Fan (A.1 above), who states
the result and attributes it identically: "In 1937, Buchstab [3] showed that for any fixed u > 1,
one has Φ(x, y) ∼ ω(u)x/log y as x → ∞". The manuscript's use (line 1217) is the same statement.

### B.2 de Bruijn (1950) — `\cite{deBruijn}`

N. G. de Bruijn, *On the number of uncancelled elements in the sieve of Eratosthenes*, Indag. Math.
**12** (1950), 247–256. Not obtained. **Corroborated** by Fan, who describes it as the source of a
"more precise approximation for Φ(x, y) than ω(u)x/log y" — which is what the manuscript cites it
for (lines 1218, 1238, 1243). Cited only in survey sentences and open problems.

### B.3 Tenenbaum — `\cite{Tenenbaum}`

Gérald Tenenbaum, *Introduction to Analytic and Probabilistic Number Theory*, 3rd ed., GSM **163**,
AMS, 2015. A commercial textbook; not downloaded, per this project's rule against acquiring
commercial texts. Cited at lines 1220 and 1238 as a textbook account, with **no theorem number**.

**This entry resolves a standing open question.** An earlier draft carried a `TODO` recording that
the citing literature seemed to point at Theorem III.6.7 for the uniform Φ(x,y) statement, and that
the number could not be verified. Fan's paper, read for entry A.1, gives the locator directly:

> uniformly for 2 ≤ y ≤ √x (see **[13, Theorem III.6.4]**)

where Fan's [13] is Tenenbaum's book. Fan also cites **[13, Corollary III.6.5]** for
`ω(u) = e^{−γ} + O(u^{−u/2})`. So the correct locator is **III.6.4**, not III.6.7 — but this is
*secondary* corroboration from a paper that cites the book, not verification against the book
itself. **The manuscript still cites Tenenbaum without a theorem number, and should continue to do
so** until someone opens a physical or subscription copy.

### B.4 Duval–Reiner — `\cite{DuvalReiner}`

Art M. Duval and Victor Reiner, *Shifted simplicial complexes are Laplacian integral*, Trans. Amer.
Math. Soc. **354** (2002), no. 11, 4313–4344. Not obtained. Cited once (line 1200) for the fact
named in its own title, which the manuscript uses only qualitatively ("By the theorem of Duval and
Reiner that spectrum is integral"). **Corroborated** by Snellman, *Laplacians on shifted
multicomplexes* (A.9), whose introduction states: "Duval and Reiner [5] have studied Laplacians of
a special class of simplicial complexes, the so called shifted simplicial complexes. They show that
such Laplacians have integral spectra, computable by a simple combinatorial formula."

### B.5 Herzog–Hibi — `\cite{HerzogHibi}`

Jürgen Herzog and Takayuki Hibi, *Monomial Ideals*, GTM **260**, Springer, 2011. Commercial
textbook, not downloaded. Cited at line 1099, together with B.6, for the standard multigraded
reduction that the socle of a monomial quotient is spanned by monomials. Textbook fact, no
numbered locator given, and the manuscript proves the statement it needs rather than importing it.

### B.6 Miller–Sturmfels — `\cite{MillerSturmfels}`

Ezra Miller and Bernd Sturmfels, *Combinatorial Commutative Algebra*, GTM **227**, Springer, 2005.
As B.5: commercial textbook, cited for the same standard fact, no locator, statement proved in
place.

---

## Summary

| reference | primary source | load-bearing? |
|---|---|---|
| Fan | yes | yes — the `u ≥ 2` uniformity |
| McCullough–Peeva | yes | yes — a numbered locator, verified |
| Snellman (unitary) | yes | yes — the 0.6077 figure |
| Snellman (Laplacians) | yes | yes — Corollary 14 |
| Goswami–Kleyn–Porrill | yes | no — related work |
| Herzog–Reiner–Welker | yes | no — an alternative route, noted |
| Holt, Gorodetsky, Miyashita | yes | no — related work |
| Buchstab, de Bruijn | no | no — corroborated via Fan |
| Tenenbaum | no | no — cited without a theorem number, deliberately |
| Duval–Reiner | no | no — corroborated via math/0606104 |
| Herzog–Hibi, Miller–Sturmfels | no | no — textbook fact, proved in place |

Nothing whose primary source is unavailable carries a proof. The two places where a specific
numbered claim is made about a source — McCullough–Peeva Theorem 6.16(6), and the 0.6077 socle
density — both have the source to hand and both check out verbatim.
