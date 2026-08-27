# LEAN/ — Conjecture 4.6, modulo Eliahou–Kervaire

A Lean 4 + Mathlib formalization of the part of *Truncations revisited*'s proof of
Snellman's Conjecture 4.6 that does not depend on homological algebra.

Three files: `Conjecture46.lean` (the polynomial core), `Sieve.lean` (the arithmetic input,
clause (2)), and `Chain.lean` (which joins them into one end-to-end statement).

**Status: complete, 0 `sorry`, standard axioms only** (`propext`, `Classical.choice`, `Quot.sound`
— verified with `#print axioms`). Built 2026-08-25 against Mathlib `v4.33.0-rc1`.

```sh
cd LEAN && lake exe cache get && lake build DirichletTruncations
```

**What to expect on a cold machine**: `lake exe cache get` downloads Mathlib's prebuilt `.olean`
cache — roughly **900 MB compressed, unpacking to about 7 GB** — which is much the longest part and
is a one-off. Once that is in `~/.cache/mathlib`, *this project itself* compiles in **about 20
seconds**; a later `lake exe cache get` in a fresh clone then finds everything locally and returns
in seconds. Nothing here is built from Mathlib source, so the hour-plus figure you may have seen
for Mathlib projects does not apply.

## A readable view

**[`docs/`](docs/)** holds a **doc-gen4** rendering of the whole formalization — the same tool that
produces the Mathlib API documentation. Every declaration with its signature, docstring and
defining equation, navigable, with `source` links back to GitLab. Open `docs/index.html`, or go
straight to [`docs/DirichletTruncations/Chain.html`](docs/DirichletTruncations/Chain.html) for the
end-to-end theorem. 244 KB, committed as generated; see [`docs/README.md`](docs/README.md) for how
it was built and the two traps in doing so.

## What is assumed and what is proved

Two things are taken on trust, and it is worth naming both.

**First, Corollary 4.4 of Snellman (2000)** — that

    P^{Γ_n}_K(t) = (1+t)^r / D_n(t),   D_n(t) = 1 − t²·Σ_{j=1}^{r} (1+t)^{r−j} C_{n,j}

which rests on the Eliahou–Kervaire resolution of a stable monomial ideal and on the Golod property
of the quotient. Neither is in Mathlib, and neither is proved here. It enters **only as the
definition of the polynomial `D`**; the homological reading of `D` is precisely what a reader must
supply.

**Second, `C_{n,v} = Φ(n, p_v)`** — Theorem 4 of the new note. In Lean this is not a theorem but a
*definition*: `cSeq n k := Phi n (Nat.nth Nat.Prime (piCount n - k - 1))` in `Chain.lean`. Nothing
here defines `I_n`, or a minimal monomial generating set, so there is no independent `C_{n,v}` for
the identity to be proved *against*. It is corroborated numerically instead, by the `#guard`s at
the end of `Sieve.lean` checking `Φ(25,2)=13`, `Φ(25,3)=9`, `Φ(25,5)=7`, `Φ(25,7)=6` against
Figure 1 of the 2000 paper — and those run at build time, so they fail the build if wrong.

Unlike the first assumption, this one is *not* out of reach: Theorem 4 is elementary, and closing
the gap is the obvious next increment. It is recorded here rather than left for a reader to
discover, because nothing in the Lean text itself marks it as an assumption.

Everything else is proved outright.

## The mathematical content

Working in the shifted variable `u = 1 + t`, with `c k = C_{n, r−k}`:

- **`sq_mul_A`** — the closed form `(1−u)²·Σ_{k<r}(k+1)u^k = 1 − (r+1)u^r + r·u^{r+1}`. This is the
  engine: it is *why* an exactly-linear stretch of `c` contributes nothing to `D`.
- **`D_eq_of_dev`** — hence `D` differs from `(r+1)u^r − r·u^{r+1}` by `(u−1)²` times the
  generating polynomial of the **deviations** `c k − (k+1)`.
- **`X_pow_dvd_D`** — if `c k = k+1` for all `k < μ`, then `u^μ ∣ D`.
- **`D_coeff_mu_ne_zero`** — and the order is *exactly* `μ`.
- **`Conjecture46_core`** — the packaged statement: `D = u^μ·q` with `q(0) ≠ 0`, `q(1) = 1`,
  `q′(1) = −μ`. In the paper's variable these are clauses **(1)**, **(4)** and **(5)**.

### Clause (2) — `Sieve.lean`

Added 2026-08-25. This is the arithmetic that `Conjecture46.lean` takes as a hypothesis, and it is
now proved rather than assumed.

- **`Phi`** is Legendre's sifting function, defined directly as a `Finset` cardinality:
  the integers in `[1,n]` all of whose prime factors exceed `y`. It is *computable* —
  `#guard Phi 25 3 = 9` — and those values are exactly the `C_{n,v}` of Figure 1 of the 2000
  paper, so the identification `C_{n,v} = Φ(n,p_v)` is checked numerically as well as used.
- **`Phi_split`** — `Φ(n,y) = 1 + #(primes in (y,n]) + #(composite y-rough numbers ≤ n)`.
- **`Ecount_eq_zero_iff`** — that composite count vanishes iff `n < q²`, where `q` is the least
  prime exceeding `y`. The proof is `Nat.minFac_sq_le_self` in one direction and exhibiting `q²`
  in the other.
- **`piCount_eq_idx_add_Pcount`** — the primes `≤ n` split at `y`. This is what lets `r − v + 1`
  be handled without any truncated natural subtraction.
- **`Phi_add_idx`** — Corollary 6 of the note, stated additively:
  `Φ(n,y) + idx y = π(n) + 1 + E(n,y)`.
- **`Phi_eq_iff`** — **clause (2)**: `Φ(n,y) + idx y = π(n) + 1  ↔  n < q²`. In the paper's
  notation, `C_{n,v} = r(n) − v + 1` exactly when `p_{v+1}² > n`.

### End to end — `Chain.lean`

Added 2026-08-25. The two files above are now joined, so the final theorem mentions only `n`:

```lean
theorem Conjecture46 {n : ℕ} (hn : 4 ≤ n) :
    ∃ q : ℚ[X],
      D (piCount n) (cSeq n) = X ^ (piCount n - ell1 n) * q
      ∧ q.eval 0 ≠ 0 ∧ q.eval 1 = 1
      ∧ (derivative q).eval 1 = -((piCount n - ell1 n : ℕ) : ℚ)
```

with `ell1 n` defined **verbatim as the conjecture defines it** — the number of odd primes `p` with
`p² ≤ n` — and the generator counts entering `D` being `C_{n,v} = Φ(n, p_v)`. Every hypothesis of
`Conjecture46_core` is discharged; nothing is assumed but the definition of `D`.

The bridging work is in `Chain.lean`: `idx_eq_count` and `idx_nth` connect the `Finset`-level prime
counts to `Nat.count`/`Nat.nth`; `nth_succ_min` says `p_{v+1}` really is the least prime after
`p_v`; `nth_sq_le_iff` says the primes with `p² ≤ n` form an initial segment (via `Nat.le_sqrt'`);
and `ell1_succ_eq` proves `ℓ₁(n) + 1 = idx(√n)` for `n ≥ 4`, which is where the "odd" in the
conjecture's definition is accounted for.

`ell1` computes, so the exponent is checkable: `#guard piCount 25 - ell1 25 = 7`, matching the
`code/sage/` recomputation, and `ℓ₁` jumps at `9, 25, 49` exactly as it should.

Clauses **(3)** and **(6)**, on the degree and leading coefficient of `q`, are **not** formalized.
They are degree computations, not deep, but fiddly in Lean, and not attempted here.

## Non-vacuity

The file ends with the hypotheses instantiated at `n = 25` (`r = 9`, `μ = 7`, counts read off
Figure 1 of the 2000 paper), discharged by `decide`. A theorem with contradictory hypotheses proves
anything, so this matters.

Precedent for the layout: `projects/lattice-line-covers/LEAN/`.
