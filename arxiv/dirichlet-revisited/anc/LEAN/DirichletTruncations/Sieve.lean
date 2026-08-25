/-
Copyright (c) 2026 Jan Snellman. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jan Snellman
-/
import Mathlib

/-!
# Clause (2): the generator counts, and where they stop being linear

This file supplies the arithmetic input that `Conjecture46.lean` takes as a
hypothesis.  Nothing here is homological; it is all elementary number theory.

Following *Truncations revisited*, the generator counts of the truncation ideal
are values of Legendre's sifting function,
`C_{n,v} = Φ(n, p_v)`, and the content of clause (2) of Snellman's Conjecture
4.6 is the following statement about them:

  `C_{n,v} = r(n) - v + 1`  ⟺  `p_{v+1}² > n`.

That is `Phi_eq_iff` below.  Everything is phrased so that no truncated natural
subtraction ever occurs: `r(n) - v + 1` appears as `Phi n y + idx y = piCount n + 1`.

## Main results

* `Phi_split` — `Φ(n,y) = 1 + (primes in (y,n]) + (composite y-rough numbers ≤ n)`.
* `Ecount_eq_zero_iff` — the composite count vanishes exactly when `n < q²`,
  where `q` is the least prime exceeding `y`.
* `Phi_add_idx` — Corollary 6 of the note: `Φ(n,y) + idx y = π(n) + 1 + E(n,y)`.
* `Phi_eq_iff` — **clause (2)**.
-/

namespace DirichletTruncations

open Finset

/-- `m` is `y`-rough: every prime factor of `m` exceeds `y`. -/
def Rough (y m : ℕ) : Prop := ∀ p ∈ m.primeFactors, y < p

instance (y : ℕ) : DecidablePred (Rough y) := fun _ => Finset.decidableDforallFinset

/-- Legendre's sifting function: the number of integers in `[1,n]` with no
prime factor `≤ y`. -/
def Phi (n y : ℕ) : ℕ := #{m ∈ Finset.Icc 1 n | Rough y m}

/-- The number of primes in `(y, n]`. -/
def Pcount (n y : ℕ) : ℕ := #{m ∈ Finset.Icc 1 n | Nat.Prime m ∧ y < m}

/-- The number of *composite* `y`-rough integers in `[1,n]`. -/
def Ecount (n y : ℕ) : ℕ := #{m ∈ Finset.Icc 1 n | Rough y m ∧ ¬ Nat.Prime m ∧ m ≠ 1}

/-- `π(n)`, as a `Finset` cardinality. -/
def piCount (n : ℕ) : ℕ := #{q ∈ Finset.Icc 1 n | Nat.Prime q}

/-- The index of `y` in the sequence of primes: for `y` prime this is the `v`
with `y = p_v`. -/
def idx (y : ℕ) : ℕ := #{q ∈ Finset.Icc 1 y | Nat.Prime q}

/-! ### Basic facts about roughness -/

theorem rough_one (y : ℕ) : Rough y 1 := by unfold Rough; simp

theorem rough_prime_iff {q y : ℕ} (hq : Nat.Prime q) : Rough y q ↔ y < q := by
  unfold Rough
  simp only [Nat.mem_primeFactors]
  constructor
  · intro h; exact h q ⟨hq, dvd_rfl, hq.ne_zero⟩
  · rintro h p ⟨hp, hpq, -⟩
    rwa [(Nat.prime_dvd_prime_iff_eq hp hq).mp hpq]

/-- For a composite `m ≥ 1`, roughness is a statement about its least factor. -/
theorem lt_minFac_of_rough {y m : ℕ} (hm : m ≠ 1) (hm0 : m ≠ 0) (h : Rough y m) :
    y < m.minFac := by
  refine h _ ?_
  rw [Nat.mem_primeFactors]
  exact ⟨Nat.minFac_prime hm, Nat.minFac_dvd m, hm0⟩

/-! ### The three-way split -/

theorem Phi_split {n : ℕ} (hn : 1 ≤ n) (y : ℕ) :
    Phi n y = 1 + Pcount n y + Ecount n y := by
  classical
  have h1 : {m ∈ Finset.Icc 1 n | Rough y m ∧ m = 1} = {1} := by
    ext m
    simp only [Finset.mem_filter, Finset.mem_Icc, Finset.mem_singleton]
    constructor
    · rintro ⟨-, -, rfl⟩; rfl
    · rintro rfl; exact ⟨⟨le_rfl, hn⟩, rough_one y, rfl⟩
  have h2 : {m ∈ Finset.Icc 1 n | Rough y m ∧ ¬ m = 1 ∧ Nat.Prime m}
      = {m ∈ Finset.Icc 1 n | Nat.Prime m ∧ y < m} := by
    ext m
    simp only [Finset.mem_filter]
    constructor
    · rintro ⟨hm, hr, -, hp⟩; exact ⟨hm, hp, (rough_prime_iff hp).mp hr⟩
    · rintro ⟨hm, hp, hy⟩
      exact ⟨hm, (rough_prime_iff hp).mpr hy, hp.ne_one, hp⟩
  have h3 : {m ∈ Finset.Icc 1 n | Rough y m ∧ ¬ m = 1 ∧ ¬ Nat.Prime m}
      = {m ∈ Finset.Icc 1 n | Rough y m ∧ ¬ Nat.Prime m ∧ m ≠ 1} := by
    ext m; simp only [Finset.mem_filter]; tauto
  -- split off `m = 1`, then split the rest by primality
  have key : Phi n y
      = #{m ∈ Finset.Icc 1 n | Rough y m ∧ m = 1}
      + #{m ∈ Finset.Icc 1 n | Rough y m ∧ ¬ m = 1} := by
    rw [Phi, ← Finset.filter_filter, ← Finset.filter_filter,
      Finset.card_filter_add_card_filter_not]
  have key2 : #{m ∈ Finset.Icc 1 n | Rough y m ∧ ¬ m = 1}
      = #{m ∈ Finset.Icc 1 n | Rough y m ∧ ¬ m = 1 ∧ Nat.Prime m}
      + #{m ∈ Finset.Icc 1 n | Rough y m ∧ ¬ m = 1 ∧ ¬ Nat.Prime m} := by
    have e1 : {m ∈ Finset.Icc 1 n | Rough y m ∧ ¬ m = 1 ∧ Nat.Prime m}
        = {m ∈ {m ∈ Finset.Icc 1 n | Rough y m ∧ ¬ m = 1} | Nat.Prime m} := by
      rw [Finset.filter_filter]; ext m; simp only [Finset.mem_filter]; tauto
    have e2 : {m ∈ Finset.Icc 1 n | Rough y m ∧ ¬ m = 1 ∧ ¬ Nat.Prime m}
        = {m ∈ {m ∈ Finset.Icc 1 n | Rough y m ∧ ¬ m = 1} | ¬ Nat.Prime m} := by
      rw [Finset.filter_filter]; ext m; simp only [Finset.mem_filter]; tauto
    rw [e1, e2, Finset.card_filter_add_card_filter_not]
  rw [key, key2, h1, h2, h3, Finset.card_singleton, Pcount, Ecount]
  omega

/-! ### When are there no composite rough numbers? -/

theorem Ecount_eq_zero_iff {n y q : ℕ} (hq : Nat.Prime q) (hyq : y < q)
    (hmin : ∀ p, Nat.Prime p → y < p → q ≤ p) :
    Ecount n y = 0 ↔ n < q ^ 2 := by
  classical
  constructor
  · intro h
    by_contra hcon
    push_neg at hcon
    have hmem : q ^ 2 ∈ {m ∈ Finset.Icc 1 n | Rough y m ∧ ¬ Nat.Prime m ∧ m ≠ 1} := by
      have hq2ne : q ^ 2 ≠ 0 := pow_ne_zero 2 hq.ne_zero
      refine Finset.mem_filter.mpr ⟨Finset.mem_Icc.mpr ⟨Nat.one_le_iff_ne_zero.mpr hq2ne, hcon⟩,
        ?_, ?_, ?_⟩
      · intro p hp
        rw [Nat.mem_primeFactors] at hp
        obtain ⟨hpp, hpd, -⟩ := hp
        have : p = q := by
          have := hpp.dvd_of_dvd_pow hpd
          exact (Nat.prime_dvd_prime_iff_eq hpp hq).mp this
        omega
      · exact Nat.Prime.not_prime_pow (n := 2) (by omega)
      · have h2 := hq.two_le; intro hcon; nlinarith [hcon]
    rw [Ecount, Finset.card_eq_zero] at h
    simp [h] at hmem
  · intro hn
    rw [Ecount, Finset.card_eq_zero, Finset.filter_eq_empty_iff]
    rintro m hm ⟨hr, hnp, hne1⟩
    rw [Finset.mem_Icc] at hm
    have hm0 : m ≠ 0 := by omega
    have hmf : y < m.minFac := lt_minFac_of_rough hne1 hm0 hr
    have hqle : q ≤ m.minFac := hmin _ (Nat.minFac_prime hne1) hmf
    have hsq : m.minFac ^ 2 ≤ m := Nat.minFac_sq_le_self (by omega) hnp
    have : q ^ 2 ≤ m := le_trans (Nat.pow_le_pow_left hqle 2) hsq
    omega

/-! ### The prime count splits at `y` -/

theorem piCount_eq_idx_add_Pcount {n y : ℕ} (hyn : y ≤ n) :
    piCount n = idx y + Pcount n y := by
  classical
  have e1 : {q ∈ Finset.Icc 1 n | Nat.Prime q ∧ q ≤ y} = {q ∈ Finset.Icc 1 y | Nat.Prime q} := by
    ext q
    simp only [Finset.mem_filter, Finset.mem_Icc]
    constructor
    · rintro ⟨⟨h1, -⟩, hp, hqy⟩; exact ⟨⟨h1, hqy⟩, hp⟩
    · rintro ⟨⟨h1, hqy⟩, hp⟩; exact ⟨⟨h1, le_trans hqy hyn⟩, hp, hqy⟩
  have e2 : {q ∈ Finset.Icc 1 n | Nat.Prime q ∧ ¬ q ≤ y}
      = {q ∈ Finset.Icc 1 n | Nat.Prime q ∧ y < q} := by
    ext q; simp only [Finset.mem_filter]; constructor
    · rintro ⟨h, hp, hy⟩; exact ⟨h, hp, by omega⟩
    · rintro ⟨h, hp, hy⟩; exact ⟨h, hp, by omega⟩
  have : #{q ∈ Finset.Icc 1 n | Nat.Prime q ∧ q ≤ y}
       + #{q ∈ Finset.Icc 1 n | Nat.Prime q ∧ ¬ q ≤ y} = piCount n := by
    rw [piCount]
    have f1 : {q ∈ Finset.Icc 1 n | Nat.Prime q ∧ q ≤ y}
        = {q ∈ {q ∈ Finset.Icc 1 n | Nat.Prime q} | q ≤ y} := by
      rw [Finset.filter_filter]
    have f2 : {q ∈ Finset.Icc 1 n | Nat.Prime q ∧ ¬ q ≤ y}
        = {q ∈ {q ∈ Finset.Icc 1 n | Nat.Prime q} | ¬ q ≤ y} := by
      rw [Finset.filter_filter]
    rw [f1, f2, Finset.card_filter_add_card_filter_not]
  rw [← this, e1, e2, idx, Pcount]

/-! ### Corollary 6 of the note, and clause (2) -/

/-- **Corollary 6.**  Stated additively, so that no truncated subtraction
appears: with `y = p_v`, `idx y = v` and `piCount n = r(n)`, this says
`C_{n,v} = r(n) - v + 1 + E(n,v)`. -/
theorem Phi_add_idx {n y : ℕ} (hn : 1 ≤ n) (hyn : y ≤ n) :
    Phi n y + idx y = piCount n + 1 + Ecount n y := by
  rw [Phi_split hn y, piCount_eq_idx_add_Pcount hyn]
  omega

/-- **Clause (2) of Conjecture 4.6.**  The generator count `C_{n,v} = Φ(n,p_v)`
equals `r(n) - v + 1` exactly when the *next* prime `q` after `p_v` satisfies
`q² > n`.  Since the least prime with `q² ≤ n` runs over the odd primes up to
`√n`, this is precisely the statement that linearity holds above `ℓ₁(n)` and
fails at it. -/
theorem Phi_eq_iff {n y q : ℕ} (hn : 1 ≤ n) (hyn : y ≤ n)
    (hq : Nat.Prime q) (hyq : y < q) (hmin : ∀ p, Nat.Prime p → y < p → q ≤ p) :
    (Phi n y + idx y = piCount n + 1) ↔ n < q ^ 2 := by
  rw [Phi_add_idx hn hyn, ← Ecount_eq_zero_iff (n := n) hq hyq hmin]
  omega

/-! ### A worked instance

At `n = 25` we have `r(25) = 9`, and `ℓ₁(25) = 2` because the odd primes `p`
with `p² ≤ 25` are `3` and `5`.  So linearity should *fail* at `v = 2`
(`y = p₂ = 3`, next prime `5`, and `5² = 25 ≤ 25`) and *hold* at `v = 3`
(`y = p₃ = 5`, next prime `7`, and `7² = 49 > 25`) — which is exactly what the
counts do.  These `#guard`s are evaluated at build time and fail the build if
wrong.  They also confirm the identification `C_{n,v} = Φ(n,p_v)` against
Figure 1 of Snellman (2000), which lists `C_{25,v} = 13, 9, 7, 6, …`. -/

#guard piCount 25 = 9
#guard Phi 25 2 = 13            -- C_{25,1}
#guard Phi 25 3 = 9             -- C_{25,2}
#guard Phi 25 5 = 7             -- C_{25,3}
#guard Phi 25 7 = 6             -- C_{25,4}
#guard idx 3 = 2
#guard idx 5 = 3
#guard Ecount 25 3 = 1          -- the single composite is 25 = 5² itself
#guard Ecount 25 5 = 0
#guard Phi 25 3 + idx 3 = 11    -- ≠ piCount 25 + 1 = 10 : deviation at v = 2
#guard Phi 25 5 + idx 5 = 10    -- = piCount 25 + 1     : linear at v = 3

end DirichletTruncations
