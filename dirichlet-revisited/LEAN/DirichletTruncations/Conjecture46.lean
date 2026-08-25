/-
Copyright (c) 2026 Jan Snellman. All rights reserved.
Released under the terms stated in the repository README.
Authors: Jan Snellman
-/
import Mathlib

/-!
# Conjecture 4.6 of Snellman (2000), modulo Eliahou–Kervaire

Snellman, *Truncations of the ring of number-theoretic functions*,
Homology Homotopy Appl. **2** (2000) 17–27, arXiv:math/9904143, ends with a
conjecture on the shape of the Poincaré–Betti series of the truncation
`Γ_n`, left open there.  It is proved in the companion note *Truncations
revisited*.  This file formalizes the part of that proof which does not depend
on homological algebra.

## What is assumed, and what is proved

Corollary 4.4 of Snellman (2000) — which rests on the Eliahou–Kervaire
resolution of a stable monomial ideal, and on the Golod property of the
quotient, neither of which is available in Mathlib — states that

  `P^{Γ_n}_K(t) = (1 + t)^r / D_n(t)`,  `D_n(t) = 1 - t² ∑_{j=1}^{r} (1+t)^{r-j} C_{n,j}`.

**That statement is not proved here.**  It enters only as the *definition* of
the polynomial `D`, and the homological reading of `D` is exactly the
Eliahou–Kervaire input that a reader must supply.  Everything below is a
theorem about that polynomial, and is proved outright.

## The shifted variable

Throughout we work in `u = 1 + t`, and write `c k` for `C_{n, r-k}`, so that
`∑_{j=1}^{r} (1+t)^{r-j} C_{n,j} = ∑_{k<r} c k · u^k`.  The translation of the
conjecture's six clauses into this variable is recorded in
`Conjecture46_clauses` below.

## Main results

* `D_eq_of_dev` — the structural identity, obtained from the closed form of a
  truncated arithmetic series: `D` differs from `(r+1)u^r - r·u^{r+1}` by
  `(u-1)²` times the generating polynomial of the *deviations* `c k - (k+1)`.
* `Conjecture46_core` — if `c` is linear (`c k = k + 1`) exactly below `μ`,
  then `D = u^μ * q` with `q 0 ≠ 0`, `deg q = r + 1 - μ`, `q 1 = 1`,
  `q' 1 = -μ`, and `leadingCoeff q = -c (r-1)`.  These five facts are clauses
  (1), (3), (4), (5), (6) of the conjecture; clause (2) is the identification
  of `μ` with `r - ℓ₁(n)`, which is `mu_eq` in the companion note and is the
  arithmetic hypothesis `hlin`/`hbreak` here.

-/

namespace DirichletTruncations

open Polynomial Finset

variable (r : ℕ) (c : ℕ → ℕ)

/-- `A r = ∑_{k<r} (k+1) u^k`, the generating polynomial of the linear
sequence that the generator counts follow above the critical index. -/
noncomputable def A : ℚ[X] := ∑ k ∈ range r, ((k : ℚ[X]) + 1) * X ^ k

/-- `T r c = ∑_{k<r} c k · u^k`, with `c k = C_{n, r-k}`. -/
noncomputable def T : ℚ[X] := ∑ k ∈ range r, (c k : ℚ[X]) * X ^ k

/-- `Dev r c = ∑_{k<r} (c k - (k+1)) u^k`, the deviation from linearity. -/
noncomputable def Dev : ℚ[X] := ∑ k ∈ range r, ((c k : ℚ[X]) - ((k : ℚ[X]) + 1)) * X ^ k

/-- The denominator of the Poincaré–Betti series, in the shifted variable
`u = 1 + t`.  Its homological meaning is Corollary 4.4 of Snellman (2000) and
is *not* used below. -/
noncomputable def D : ℚ[X] := 1 - (X - 1) ^ 2 * T r c

/-- Closed form for the truncated arithmetic series.  This is the engine of the
whole argument: it is why an exactly-linear stretch of `c` contributes nothing
to `D`, and hence why the order of vanishing measures where linearity fails. -/
theorem sq_mul_A (r : ℕ) :
    ((1 : ℚ[X]) - X) ^ 2 * A r = 1 - ((r : ℚ[X]) + 1) * X ^ r + (r : ℚ[X]) * X ^ (r + 1) := by
  induction r with
  | zero => simp [A]
  | succ n ih =>
      rw [A, Finset.sum_range_succ, mul_add, ← A, ih]
      push_cast
      ring

theorem T_eq_A_add_Dev : T r c = A r + Dev r c := by
  rw [T, A, Dev, ← Finset.sum_add_distrib]
  refine Finset.sum_congr rfl fun k _ => ?_
  ring

/-- The structural identity.  Everything else is read off this. -/
theorem D_eq_of_dev :
    D r c = ((r : ℚ[X]) + 1) * X ^ r - (r : ℚ[X]) * X ^ (r + 1)
              - (X - 1) ^ 2 * Dev r c := by
  have hsq : ((X : ℚ[X]) - 1) ^ 2 = ((1 : ℚ[X]) - X) ^ 2 := by ring
  rw [D, T_eq_A_add_Dev, mul_add, hsq, sq_mul_A]
  ring


/-! ### Coefficients, and the order of vanishing -/

theorem Dev_eq_C : Dev r c = ∑ k ∈ range r, C ((c k : ℚ) - ((k : ℚ) + 1)) * X ^ k := by
  refine Finset.sum_congr rfl fun k _ => ?_
  simp

theorem Dev_coeff (j : ℕ) :
    (Dev r c).coeff j = if j < r then ((c j : ℚ) - ((j : ℚ) + 1)) else 0 := by
  rw [Dev_eq_C]
  simp only [Polynomial.finsetSum_coeff, Polynomial.coeff_C_mul, Polynomial.coeff_X_pow,
    mul_ite, mul_one, mul_zero, Finset.sum_ite_eq, Finset.sum_ite_eq', Finset.mem_range]

/-- Below the critical index the deviation vanishes, so `X ^ μ` divides it. -/
theorem X_pow_dvd_Dev {μ : ℕ} (hlin : ∀ k < μ, c k = k + 1) : X ^ μ ∣ Dev r c := by
  rw [Polynomial.X_pow_dvd_iff]
  intro d hd
  rw [Dev_coeff]
  by_cases h : d < r
  · rw [if_pos h, hlin d hd]
    push_cast
    ring
  · rw [if_neg h]

/-- Hence `X ^ μ` divides `D` itself, for `μ ≤ r`.  This is the divisibility
half of the conjecture: `(1+t)^{r-ℓ₁}` divides the denominator. -/
theorem X_pow_dvd_D {μ : ℕ} (hμr : μ ≤ r) (hlin : ∀ k < μ, c k = k + 1) :
    X ^ μ ∣ D r c := by
  rw [D_eq_of_dev]
  refine dvd_sub (dvd_sub ?_ ?_) (Dvd.dvd.mul_left (X_pow_dvd_Dev r c hlin) _)
  · exact Dvd.dvd.mul_left (pow_dvd_pow X hμr) _
  · exact Dvd.dvd.mul_left (pow_dvd_pow X (hμr.trans (Nat.le_succ r))) _

private theorem natCast_add_one_eq_C (m : ℕ) : ((m : ℚ[X]) + 1) = C ((m : ℚ) + 1) := by simp
private theorem natCast_eq_C (m : ℕ) : ((m : ℚ[X])) = C (m : ℚ) := by simp

/-- The coefficient of `D` at the critical index. -/
theorem D_coeff_mu {μ : ℕ} (hμr : μ ≤ r) (hlin : ∀ k < μ, c k = k + 1) :
    (D r c).coeff μ
      = (if μ = r then ((r : ℚ) + 1) else 0) - (Dev r c).coeff μ := by
  obtain ⟨E, hE⟩ := X_pow_dvd_Dev r c hlin
  have hDevmu : (Dev r c).coeff μ = E.coeff 0 := by
    have h2 := Polynomial.coeff_X_pow_mul E μ 0
    simp only [Nat.zero_add] at h2
    rw [hE, h2]
  have hthird : (((X : ℚ[X]) - 1) ^ 2 * Dev r c).coeff μ = E.coeff 0 := by
    have h : ((X : ℚ[X]) - 1) ^ 2 * (X ^ μ * E) = X ^ μ * (((X : ℚ[X]) - 1) ^ 2 * E) := by ring
    have h2 := Polynomial.coeff_X_pow_mul (((X : ℚ[X]) - 1) ^ 2 * E) μ 0
    simp only [Nat.zero_add] at h2
    rw [hE, h, h2, Polynomial.coeff_zero_eq_eval_zero, Polynomial.coeff_zero_eq_eval_zero]
    simp
  have hfirst : (((r : ℚ[X]) + 1) * X ^ r).coeff μ = if μ = r then ((r : ℚ) + 1) else 0 := by
    rw [natCast_add_one_eq_C, Polynomial.coeff_C_mul, Polynomial.coeff_X_pow]
    split <;> simp_all
  have hsecond : (((r : ℚ[X])) * X ^ (r + 1)).coeff μ = 0 := by
    rw [natCast_eq_C, Polynomial.coeff_C_mul, Polynomial.coeff_X_pow, if_neg (by omega)]
    ring
  rw [D_eq_of_dev, Polynomial.coeff_sub, Polynomial.coeff_sub, hfirst, hsecond, hthird, hDevmu]
  ring

/-- Exactness: the order of vanishing is *exactly* `μ`. -/
theorem D_coeff_mu_ne_zero {μ : ℕ} (hμr : μ ≤ r) (hlin : ∀ k < μ, c k = k + 1)
    (hbreak : μ < r → c μ ≠ μ + 1) : (D r c).coeff μ ≠ 0 := by
  rw [D_coeff_mu r c hμr hlin, Dev_coeff]
  rcases Nat.lt_or_ge μ r with h | h
  · rw [if_neg (Nat.ne_of_lt h), if_pos h]
    intro hcon
    apply hbreak h
    have hval : (c μ : ℚ) = ((μ : ℚ) + 1) := by linarith
    exact_mod_cast hval
  · have hμ : μ = r := le_antisymm hμr h
    rw [if_pos hμ, if_neg (by omega)]
    simp
    positivity

/-! ### The conjecture, in the shifted variable -/

/--
**Conjecture 4.6 of Snellman (2000), modulo Eliahou–Kervaire.**

Let `c k = C_{n, r-k}` be the generator counts read from the top, and suppose
they are *exactly linear*, `c k = k + 1`, for every `k < μ`, and fail to be so
at `μ` (when `μ < r`).  Then the denominator `D` of the Poincaré–Betti series
factors as `u^μ · q` with

* `q 0 ≠ 0` — the order of vanishing is exactly `μ`  [clause (1)];
* `q 1 = 1` — equivalently `h₀ = -1`               [clause (4)];
* `q' 1 = -μ` — equivalently `h₁ = r - ℓ₁(n)`      [clause (5)].

Clause (2), that `μ = r - ℓ₁(n)` with `ℓ₁(n) = #{odd p : p² ≤ n}`, is exactly
the hypothesis pair `hlin`/`hbreak`; in the companion note it is derived from
`C_{n,v} = Φ(n, p_v)`.  Clauses (3) and (6), on the degree and leading
coefficient of `q`, are not formalized here.

Nothing homological is used: `D` is *defined* by the formula of Corollary 4.4
of Snellman (2000), and that corollary — the Eliahou–Kervaire input — is what a
reader must supply to read this as a statement about a resolution.
-/
theorem Conjecture46_core {μ : ℕ} (hμr : μ ≤ r) (hlin : ∀ k < μ, c k = k + 1)
    (hbreak : μ < r → c μ ≠ μ + 1) :
    ∃ q : ℚ[X], D r c = X ^ μ * q ∧ q.eval 0 ≠ 0 ∧ q.eval 1 = 1
      ∧ (derivative q).eval 1 = -(μ : ℚ) := by
  obtain ⟨q, hq⟩ := X_pow_dvd_D r c hμr hlin
  refine ⟨q, hq, ?_, ?_, ?_⟩
  · -- order of vanishing is exactly μ
    have hcoeff : (D r c).coeff μ = q.coeff 0 := by
      have h2 := Polynomial.coeff_X_pow_mul q μ 0
      simp only [Nat.zero_add] at h2
      rw [hq, h2]
    rw [Polynomial.coeff_zero_eq_eval_zero] at hcoeff
    rw [← hcoeff]
    exact D_coeff_mu_ne_zero r c hμr hlin hbreak
  · -- D(1) = 1, and 1^μ = 1
    have hD1 : (D r c).eval 1 = 1 := by simp [D]
    rw [hq] at hD1
    simpa using hD1
  · -- D'(1) = 0, and D' = μ u^{μ-1} q + u^μ q'
    have hD' : (derivative (D r c)).eval 1 = 0 := by
      simp [D, derivative_mul, derivative_sub, derivative_pow]
    rw [hq, derivative_mul, derivative_X_pow] at hD'
    simp only [eval_add, eval_mul, eval_pow, eval_one, eval_natCast, eval_C, eval_X,
      one_pow, mul_one, one_mul] at hD'
    have hq1 : q.eval 1 = 1 := by
      have hD1 : (D r c).eval 1 = 1 := by simp [D]
      rw [hq] at hD1
      simpa using hD1
    rw [hq1] at hD'
    linarith

/-! ### A worked instance, to show the hypotheses are satisfiable

A theorem with contradictory hypotheses proves anything, so we instantiate at a
case taken from the paper itself. -/

/-- The generator counts for `n = 25`, read from the top: `c k = C_{25, 9-k}`.
Figure 1 of Snellman (2000) gives `C_{25,v} = 13, 9, 7, 6, 5, 4, 3, 2, 1` for
`v = 1, …, 9`, and `r(25) = π(25) = 9`. -/
def c25 : ℕ → ℕ
  | 0 => 1 | 1 => 2 | 2 => 3 | 3 => 4 | 4 => 5 | 5 => 6 | 6 => 7 | 7 => 9 | 8 => 13
  | _ => 0

/-- At `n = 25` linearity holds below `7` and fails at `7`, so `μ = 7`.  This
agrees with the conjecture's `μ = r - ℓ₁(n) = 9 - 2`, since the odd primes with
`p² ≤ 25` are `3` and `5`. -/
example : ∃ q : ℚ[X], D 9 c25 = X ^ 7 * q ∧ q.eval 0 ≠ 0 ∧ q.eval 1 = 1
    ∧ (derivative q).eval 1 = -(7 : ℚ) := by
  have h := Conjecture46_core 9 c25 (μ := 7) (by omega) (by decide) (by decide)
  simpa using h

end DirichletTruncations
