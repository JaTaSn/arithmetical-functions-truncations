/-
Copyright (c) 2026 Jan Snellman. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jan Snellman
-/
import DirichletTruncations.Sieve
import DirichletTruncations.Chain

/-!
# The exact splitting of `S₂`

This is Lemma 21 of *Truncations of the ring of number-theoretic functions, revisited*: the
identity

    S₂(n)  =  T(n)  −  (P−1)P(2P−1)/6,      T(n) = Σ_j (j−1)·π(n/p_j),

where `p_1 < ⋯ < p_P` are the primes `≤ √n` and `P = π(√n)`.

## What is assumed, and what is proved

**Nothing is assumed.** Unlike `Conjecture46.lean`, which takes the Poincaré–Betti reading of `D`
on trust, and unlike `Chain.lean`, which takes `C_{n,v} = Φ(n,p_v)` as a definition, this file
proves its statement outright from the definitions below. It needs no prime number theorem, no
homological algebra, and no analytic input of any kind — which is exactly why it is the first
piece of the asymptotics worth formalising.

The mathematical content is one observation: `p_j` is the `j`-th prime, so `π(p_j) = j` *exactly*.
That is already available here as `Chain.idx_nth`. Everything else is rearrangement.

## Indexing

The note writes `p_1 < ⋯ < p_P` and `π(p_j) = j`; Lean's `Nat.nth Nat.Prime` is 0-based, with
`Nat.nth Nat.Prime 0 = 2`. So the note's `p_j` is `Nat.nth Nat.Prime (j-1)`, and with the 0-based
index `k = j-1` running over `range P` the note's weight `j - 1` is simply `k`. Statements are
phrased additively (`S₂ + Σk² = T` rather than `S₂ = T - Σk²`) to keep truncated `ℕ` subtraction
out of them, following the convention of `Sieve.lean`.

## Main results

- `sum_range_sq` — `(Σ_{i<m+1} i²)·6 = m(m+1)(2m+1)`, the elementary sum Mathlib lacks.
- `succ_le_piCount_div` — for `k < P`, `k + 1 ≤ π(n / p_k)`. This is what makes the subtraction in
  the definition of `S₂` harmless.
- `S2_add_sq_eq_Tsum` — Lemma 21 itself.
- `S2_add_sq_eq_Tsum'` — the same with the square sum in closed form.
-/

namespace DirichletTruncations

open Finset

/-! ### The elementary sum of squares -/

/-- `Σ_{i<m+1} i² = m(m+1)(2m+1)/6`, stated multiplicatively to stay inside `ℕ`.
Mathlib has `Finset.sum_range_id` for the linear case and the Bernoulli machinery for the
general one, but nothing directly usable for `p = 2` over `ℕ`. -/
theorem sum_range_sq (m : ℕ) :
    (∑ i ∈ range (m + 1), i ^ 2) * 6 = m * (m + 1) * (2 * m + 1) := by
  induction m with
  | zero => simp
  | succ d ih =>
    rw [Finset.sum_range_succ, add_mul, ih]
    ring

/-! ### The objects of Lemma 21 -/

/-- `P = π(√n)`, the number of primes `≤ √n`. -/
def Psqrt (n : ℕ) : ℕ := piCount (Nat.sqrt n)

/-- The `k`-th prime `≤ √n`, 0-based: this is the note's `p_{k+1}`. -/
noncomputable def pr (k : ℕ) : ℕ := Nat.nth Nat.Prime k

/-- `S₂(n) = Σ_{p ≤ √n} (π(p)−1)(π(n/p)−π(p)+1)`, Lemma 20's closed form, written with the
0-based index `k = π(p) − 1`. -/
noncomputable def S2 (n : ℕ) : ℕ :=
  ∑ k ∈ range (Psqrt n), k * (piCount (n / pr k) - k)

/-- `T(n) = Σ_j (j−1)·π(n/p_j)`, the part of `S₂` that still needs the prime number theorem. -/
noncomputable def Tsum (n : ℕ) : ℕ := ∑ k ∈ range (Psqrt n), k * piCount (n / pr k)

/-! ### The subtraction in `S₂` never truncates -/

/-- For `k < P` the `k`-th prime is at most `√n`. -/
theorem pr_le_sqrt {n k : ℕ} (hk : k < Psqrt n) : pr k ≤ Nat.sqrt n :=
  nth_le_iff_lt_piCount.mpr hk

/-- Hence `√n ≤ n / p_k`: the cofactor is at least as large as the factor. -/
theorem sqrt_le_div {n k : ℕ} (hk : k < Psqrt n) : Nat.sqrt n ≤ n / pr k := by
  have hp : pr k ≤ Nat.sqrt n := pr_le_sqrt hk
  have hpos : 0 < pr k := (Nat.prime_nth_prime k).pos
  refine Nat.le_div_iff_mul_le hpos |>.mpr ?_
  calc Nat.sqrt n * pr k ≤ Nat.sqrt n * Nat.sqrt n := Nat.mul_le_mul_left _ hp
    _ ≤ n := Nat.sqrt_le n

/-- **The key inequality.** For `k < P`, `k + 1 ≤ π(n / p_k)`. Since the note's weight at this
index is `k`, the subtraction `π(n/p_k) − k` in `S2` is therefore exact. -/
theorem succ_le_piCount_div {n k : ℕ} (hk : k < Psqrt n) :
    k + 1 ≤ piCount (n / pr k) := by
  have h1 : idx (pr k) = k + 1 := idx_nth k
  have h2 : pr k ≤ n / pr k := le_trans (pr_le_sqrt hk) (sqrt_le_div hk)
  calc k + 1 = idx (pr k) := h1.symm
    _ ≤ idx (n / pr k) := idx_mono h2
    _ = piCount (n / pr k) := rfl

/-! ### Lemma 21 -/

/-- **Lemma 21, the exact splitting.** `S₂(n) + Σ_{k<P} k² = T(n)`.

Stated additively so that no truncated subtraction appears in the statement itself. The content
is that `π(p_j) = j` exactly, so the second factor of `S₂`'s summand is `π(n/p_k) − k`, and
`k·(π(n/p_k) − k) + k² = k·π(n/p_k)`. -/
theorem S2_add_sq_eq_Tsum (n : ℕ) :
    S2 n + ∑ k ∈ range (Psqrt n), k ^ 2 = Tsum n := by
  rw [S2, Tsum, ← Finset.sum_add_distrib]
  refine Finset.sum_congr rfl ?_
  intro k hk
  have h : k + 1 ≤ piCount (n / pr k) := succ_le_piCount_div (mem_range.mp hk)
  obtain ⟨d, hd⟩ : ∃ d, piCount (n / pr k) = k + d := ⟨piCount (n / pr k) - k, by omega⟩
  rw [hd]
  simp only [Nat.add_sub_cancel_left]
  ring

/-- Lemma 21 with the square sum in the closed form the note prints, multiplied through by `6`
to stay inside `ℕ`. -/
theorem S2_add_sq_eq_Tsum' (n : ℕ) (h : 0 < Psqrt n) :
    S2 n * 6 + (Psqrt n - 1) * Psqrt n * (2 * Psqrt n - 1) = Tsum n * 6 := by
  obtain ⟨m, hm⟩ : ∃ m, Psqrt n = m + 1 := ⟨Psqrt n - 1, by omega⟩
  have h1 : (∑ i ∈ range (Psqrt n), i ^ 2) * 6
      = (Psqrt n - 1) * Psqrt n * (2 * Psqrt n - 1) := by
    rw [hm, Nat.add_sub_cancel]
    have h2 : 2 * (m + 1) - 1 = 2 * m + 1 := by omega
    rw [h2]
    exact sum_range_sq m
  calc S2 n * 6 + (Psqrt n - 1) * Psqrt n * (2 * Psqrt n - 1)
      = S2 n * 6 + (∑ i ∈ range (Psqrt n), i ^ 2) * 6 := by rw [h1]
    _ = (S2 n + ∑ i ∈ range (Psqrt n), i ^ 2) * 6 := by ring
    _ = Tsum n * 6 := by rw [S2_add_sq_eq_Tsum]

/-! ### Sanity checks

`Psqrt` computes, so it can be checked in the kernel. `S2` and `Tsum` cannot: they are
`noncomputable`, because `Nat.nth` is — the same obstruction that stops `Chain.lean` from
`#guard`ing `cSeq`. The identity itself is checked numerically instead, outside Lean, by
`code/independent_check_op21.py`, which prints both halves at `n = 10⁶` and `10⁷`.

Vacuity is not a concern here in any case: `S2_add_sq_eq_Tsum` has no hypotheses at all. -/

#guard Psqrt 100 = 4          -- primes ≤ 10:  2, 3, 5, 7
#guard Psqrt 200 = 6          -- primes ≤ 14:  2, 3, 5, 7, 11, 13
#guard Psqrt 1000 = 11        -- primes ≤ 31
#guard (∑ i ∈ Finset.range 11, i ^ 2) * 6 = 10 * 11 * 21   -- sum_range_sq at m = 10

/-- info: 'DirichletTruncations.S2_add_sq_eq_Tsum' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms S2_add_sq_eq_Tsum

end DirichletTruncations
