# Changelog (reverse-chronological)
# 2026-08-27 - Claude: font set to Computer Modern/serif to match amsart (matplotlib's
#   sans-serif default reads as foreign on the page).
# 2026-08-27 - Claude: created. Draws Figure 1 of "Truncations revisited": the profile
#   v -> C_{n,v} = Phi(n,p_v) against the line pi(n)-v+1, with v = ell_1(n) marked. The gap
#   between curve and line is E(n,v) of Corollary 6, and the point where the two part company
#   is what Proposition 15 and the clause-(2) remark are about. Run with `sage` (the system
#   python here has neither matplotlib nor numpy; Sage's does). Output is a vector PDF for
#   \includegraphics, written next to the manuscript.

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

# Match amsart: Computer Modern, serif, at roughly the document's footnote size.
# matplotlib's sans-serif default reads as a foreign object on the page.
matplotlib.rcParams.update({
    "font.family": "serif",
    "font.serif": ["CMU Serif", "DejaVu Serif"],
    "mathtext.fontset": "cm",
    "font.size": 9,
    "axes.labelsize": 10,
    "xtick.labelsize": 9,
    "ytick.labelsize": 9,
})

N = 200
import sys
# Output path may be given as an argument; default is the current directory, so that
# `cd runs && sage ../code/sage/plot_Cnv_profile.sage` behaves like every other script.
outfile = sys.argv[1] if len(sys.argv) > 1 else "Cnv-profile.pdf"

primes = list(prime_range(2, N + 1))
r = len(primes)

def Phi(n, y):
    return len([m for m in range(1, n + 1) if all(q > y for q in prime_divisors(m))])

vs = list(range(1, r + 1))
C = [Phi(N, p) for p in primes]
line = [r - v + 1 for v in vs]
ell1 = len([p for p in primes if p != 2 and p * p <= N])

fig, ax = plt.subplots(figsize=(5.2, 3.2))
ax.plot(vs, line, color="0.55", linewidth=1.0, linestyle="--",
        label=r"$\pi(n)-v+1$", zorder=2)
ax.plot(vs, C, color="black", linewidth=1.2, marker="o", markersize=2.4,
        label=r"$C_{n,v}=\Phi(n,p_v)$", zorder=3)
ax.axvline(ell1, color="0.7", linewidth=0.8, zorder=1)
ax.annotate(r"$v=\ell_1(n)$", xy=(ell1, max(C) * 0.72),
            xytext=(ell1 + 1.5, max(C) * 0.72), fontsize=9, va="center")

ax.set_xlabel(r"$v$")
ax.set_ylabel(r"$C_{n,v}$")
ax.set_xlim(0.5, r + 0.5)
ax.set_ylim(0, max(C) * 1.06)
ax.legend(frameon=False, fontsize=9, loc="upper right")
ax.spines["top"].set_visible(False)
ax.spines["right"].set_visible(False)
fig.tight_layout(pad=0.3)
fig.savefig(outfile)

E = [c - l for c, l in zip(C, line)]
print(f"n = {N}, pi(n) = {r}, ell_1(n) = {ell1}")
print(f"C_(n,v), v=1..8 : {C[:8]}")
print(f"pi(n)-v+1       : {line[:8]}")
print(f"E(n,v) = C-line : {E[:12]}")
print(f"last v with E(n,v) > 0: {max(v for v, e in zip(vs, E) if e > 0)}  (should be ell_1(n) = {ell1})")
print(f"E(n,v) = 0 for all v > ell_1(n): {all(e == 0 for v, e in zip(vs, E) if v > ell1)}")
print(f"wrote {outfile}")
