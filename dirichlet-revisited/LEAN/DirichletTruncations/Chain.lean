/-
Copyright (c) 2026 Jan Snellman. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jan Snellman
-/
import DirichletTruncations.Sieve
import DirichletTruncations.Conjecture46

/-!
# Conjecture 4.6, end to end

`Sieve.lean` proves the arithmetic (clause (2)); `Conjecture46.lean` proves the
polynomial algebra (clauses (1), (4), (5)).  This file joins them, so that the
final statement `Conjecture46` below mentions only `n`, and every hypothesis of
`Conjecture46_core` is discharged.

The only thing still taken on trust is the *definition* of `D`, which is
Corollary 4.4 of Snellman (2000) — the Eliahou–Kervaire input.  See
`Conjecture46.lean`'s module docstring.
-/

namespace DirichletTruncations

open Polynomial Finset Nat

/-! ### Bridging `idx` to `Nat.count`, and `Nat.nth` to the primes -/

theorem idx_eq_count (y : ℕ) : idx y = Nat.count Nat.Prime (y + 1) := by
  rw [idx, Nat.count_eq_card_filter_range]
  congr 1
  ext q
  simp only [Finset.mem_filter, Finset.mem_Icc, Finset.mem_range]
  constructor
  · rintro ⟨⟨-, h2⟩, hp⟩; exact ⟨by omega, hp⟩
  · rintro ⟨h1, hp⟩; exact ⟨⟨hp.one_lt.le, by omega⟩, hp⟩

theorem idx_nth (k : ℕ) : idx (Nat.nth Nat.Prime k) = k + 1 := by
  rw [idx_eq_count]
  exact Nat.count_nth_succ (fun hf => absurd hf Nat.infinite_setOf_prime)

/-- `nth Prime j` is at most `n` exactly when `j` is below the prime count. -/
theorem nth_le_iff_lt_piCount {j n : ℕ} :
    Nat.nth Nat.Prime j ≤ n ↔ j < piCount n := by
  rw [piCount, ← Nat.lt_succ_iff, ← idx, idx_eq_count,
    Nat.lt_nth_iff_count_lt Nat.infinite_setOf_prime]

/-- `nth Prime (j+1)` is the least prime exceeding `nth Prime j`. -/
theorem nth_succ_min {j p : ℕ} (hp : Nat.Prime p) (h : Nat.nth Nat.Prime j < p) :
    Nat.nth Nat.Prime (j + 1) ≤ p := by
  have hinf := Nat.infinite_setOf_prime
  have h1 : j < Nat.count Nat.Prime p := (Nat.lt_nth_iff_count_lt hinf).mpr h
  calc Nat.nth Nat.Prime (j + 1) ≤ Nat.nth Nat.Prime (Nat.count Nat.Prime p) :=
        Nat.nth_monotone hinf (by omega)
    _ = p := Nat.nth_count hp

/-- The primes whose square is at most `n` form an initial segment. -/
theorem nth_sq_le_iff (j n : ℕ) :
    (Nat.nth Nat.Prime j) ^ 2 ≤ n ↔ j < idx (Nat.sqrt n) := by
  rw [idx_eq_count, ← Nat.le_sqrt', ← Nat.lt_succ_iff,
    Nat.lt_nth_iff_count_lt Nat.infinite_setOf_prime]

/-! ### `ℓ₁(n)`, as the conjecture defines it -/

/-- `ℓ₁(n) = #{odd primes p : p² ≤ n}`, verbatim from Conjecture 4.6. -/
def ell1 (n : ℕ) : ℕ := #{p ∈ Finset.Icc 1 n | Nat.Prime p ∧ p ≠ 2 ∧ p ^ 2 ≤ n}

theorem ell1_succ_eq {n : ℕ} (hn : 4 ≤ n) : ell1 n + 1 = idx (Nat.sqrt n) := by
  classical
  have h2 : {q ∈ Finset.Icc 1 (Nat.sqrt n) | Nat.Prime q ∧ q = 2} = {2} := by
    ext q
    simp only [Finset.mem_filter, Finset.mem_Icc, Finset.mem_singleton]
    constructor
    · rintro ⟨-, -, rfl⟩; rfl
    · rintro rfl
      exact ⟨⟨by omega, Nat.le_sqrt'.mpr (by norm_num; omega)⟩, Nat.prime_two, rfl⟩
  have hne : {q ∈ Finset.Icc 1 (Nat.sqrt n) | Nat.Prime q ∧ ¬ q = 2}
      = {p ∈ Finset.Icc 1 n | Nat.Prime p ∧ p ≠ 2 ∧ p ^ 2 ≤ n} := by
    ext q
    simp only [Finset.mem_filter, Finset.mem_Icc]
    constructor
    · rintro ⟨⟨h1, hq⟩, hp, hne2⟩
      have hsq : q ^ 2 ≤ n := Nat.le_sqrt'.mp hq
      have : q ≤ n := le_trans (Nat.le_self_pow (by norm_num) q) hsq
      exact ⟨⟨h1, this⟩, hp, hne2, hsq⟩
    · rintro ⟨⟨h1, -⟩, hp, hne2, hsq⟩
      exact ⟨⟨h1, Nat.le_sqrt'.mpr hsq⟩, hp, hne2⟩
  have split : idx (Nat.sqrt n)
      = #{q ∈ Finset.Icc 1 (Nat.sqrt n) | Nat.Prime q ∧ q = 2}
      + #{q ∈ Finset.Icc 1 (Nat.sqrt n) | Nat.Prime q ∧ ¬ q = 2} := by
    rw [idx, ← Finset.filter_filter, ← Finset.filter_filter,
      Finset.card_filter_add_card_filter_not]
  rw [split, h2, hne, Finset.card_singleton, ell1]
  omega

theorem idx_mono {y z : ℕ} (h : y ≤ z) : idx y ≤ idx z := by
  apply Finset.card_le_card
  intro q hq
  simp only [Finset.mem_filter, Finset.mem_Icc] at hq ⊢
  exact ⟨⟨hq.1.1, le_trans hq.1.2 h⟩, hq.2⟩

theorem ell1_lt_piCount {n : ℕ} (hn : 4 ≤ n) : ell1 n < piCount n := by
  have h1 : ell1 n + 1 = idx (Nat.sqrt n) := ell1_succ_eq hn
  have h2 : idx (Nat.sqrt n) ≤ idx n := idx_mono (Nat.sqrt_le_self n)
  have h3 : idx n = piCount n := rfl
  omega

/-! ### The generator counts as a sequence, indexed from the top -/

/-- `cSeq n k = C_{n, r-k} = Φ(n, p_{r-k})`, the generator counts read from the
top, which is the indexing `Conjecture46_core` expects. -/
noncomputable def cSeq (n k : ℕ) : ℕ := Phi n (Nat.nth Nat.Prime (piCount n - k - 1))

/-- The key step, stated in `v` rather than `k`: for `1 ≤ v ≤ r(n)`, the count
`C_{n,v} = Φ(n, p_v)` equals `r(n) - v + 1` exactly when `p_{v+1}² > n` —
clause (2), with the next prime's square made explicit as a comparison of `v`
against `idx (√n)`. -/
theorem Phi_nth_add_eq_iff {n v : ℕ} (hn : 1 ≤ n) (hv1 : 1 ≤ v) (hvr : v ≤ piCount n) :
    (Phi n (Nat.nth Nat.Prime (v - 1)) + v = piCount n + 1) ↔ idx (Nat.sqrt n) ≤ v := by
  have hyn : Nat.nth Nat.Prime (v - 1) ≤ n := nth_le_iff_lt_piCount.mpr (by omega)
  have hidx : idx (Nat.nth Nat.Prime (v - 1)) = v := by rw [idx_nth]; omega
  have hq : Nat.Prime (Nat.nth Nat.Prime v) := Nat.prime_nth_prime v
  have hyq : Nat.nth Nat.Prime (v - 1) < Nat.nth Nat.Prime v :=
    (Nat.nth_lt_nth Nat.infinite_setOf_prime).mpr (by omega)
  have hmin : ∀ p, Nat.Prime p → Nat.nth Nat.Prime (v - 1) < p → Nat.nth Nat.Prime v ≤ p := by
    intro p hp hlt
    have := nth_succ_min hp hlt
    rwa [show v - 1 + 1 = v by omega] at this
  have main := Phi_eq_iff (n := n) (y := Nat.nth Nat.Prime (v - 1))
    (q := Nat.nth Nat.Prime v) hn hyn hq hyq hmin
  rw [hidx] at main
  rw [main, ← not_le, nth_sq_le_iff, not_lt]

theorem cSeq_eq_iff {n k : ℕ} (hn : 1 ≤ n) (hk : k < piCount n) :
    cSeq n k = k + 1 ↔ idx (Nat.sqrt n) ≤ piCount n - k := by
  have h := Phi_nth_add_eq_iff (n := n) (v := piCount n - k) hn (by omega) (by omega)
  rw [cSeq]
  omega

/-! ### The end-to-end statement -/

/--
**Conjecture 4.6 of Snellman (2000), end to end.**

For every `n ≥ 4`, the denominator `D` of the Poincaré–Betti series of `Γ_n`
factors as `u^{r(n) - ℓ₁(n)} · q` in the shifted variable `u = 1 + t`, with

* `q 0 ≠ 0` — the order of vanishing is exactly `r(n) - ℓ₁(n)`  [clauses (1),(2)];
* `q 1 = 1` — equivalently `h₀ = -1`                            [clause (4)];
* `q' 1 = -(r(n) - ℓ₁(n))` — equivalently `h₁ = r(n) - ℓ₁(n)`   [clause (5)];

where `ℓ₁(n)` is, verbatim, the number of odd primes `p` with `p² ≤ n`, and the
generator counts entering `D` are `C_{n,v} = Φ(n, p_v)`, Legendre's sifting
function.

Clauses (3) and (6), on the degree and leading coefficient of `q`, are not
formalized.

The single thing assumed is the *definition* of `D`, which is Corollary 4.4 of
Snellman (2000) and rests on Eliahou–Kervaire and Golod.
-/
theorem Conjecture46 {n : ℕ} (hn : 4 ≤ n) :
    ∃ q : ℚ[X],
      D (piCount n) (cSeq n) = X ^ (piCount n - ell1 n) * q
      ∧ q.eval 0 ≠ 0 ∧ q.eval 1 = 1
      ∧ (derivative q).eval 1 = -((piCount n - ell1 n : ℕ) : ℚ) := by
  have hs : ell1 n + 1 = idx (Nat.sqrt n) := ell1_succ_eq hn
  have hlt : ell1 n < piCount n := ell1_lt_piCount hn
  refine Conjecture46_core (piCount n) (cSeq n) (μ := piCount n - ell1 n) (by omega) ?_ ?_
  · -- hlin: linearity holds strictly above ℓ₁(n)
    intro k hk
    rw [cSeq_eq_iff (by omega) (by omega)]
    omega
  · -- hbreak: and fails at ℓ₁(n) itself
    intro _
    rw [Ne, cSeq_eq_iff (by omega) (by omega)]
    omega

/-! ### Numerical check of the quantities the theorem produces

`ell1` is computable, so the exponent `r(n) - ℓ₁(n)` appearing in `Conjecture46`
can be checked against the paper.  At `n = 25` it is `9 - 2 = 7`, which is what
the recomputation in `code/sage/` reports.  `ℓ₁` jumps exactly at the squares of
the odd primes, `9, 25, 49, …`, as it must. -/

#guard piCount 25 = 9
#guard ell1 25 = 2
#guard piCount 25 - ell1 25 = 7
#guard ell1 8 = 0
#guard ell1 9 = 1
#guard ell1 24 = 1
#guard ell1 48 = 2
#guard ell1 49 = 3

end DirichletTruncations
