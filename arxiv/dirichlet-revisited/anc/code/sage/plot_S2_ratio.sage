# Changelog (reverse-chronological)
# 2026-08-27 - created.  Draws Figure 2 of the manuscript: S_2(n) / ((2/3) pi(sqrt n)^3)
#   against n on a logarithmic n-axis, illustrating that the ratio approaches 1 slowly and
#   NON-monotonically -- the point of the remark on the Buchstab route.  The values are the
#   exact ones from runs/REPORT-openproblem21.txt (10^4..10^9 from its `split` stage, which
#   sieves; 10^10..10^14 from its `lucy` stage, which counts primes by the O(n^{3/4})
#   recursion) and are not recomputed here, the expensive ones taking minutes.  Run under
#   SageMath, whose Python carries matplotlib.

# Output path may be given as an argument; by default the figure is written to the
# current directory, so that `cd runs && sage ../code/sage/plot_S2_ratio.sage` behaves
# like every other script here.  Pass ../article/S2-ratio.pdf to place it beside the
# manuscript.
import sys
outfile = sys.argv[1] if len(sys.argv) > 1 else "S2-ratio.pdf"

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

matplotlib.rcParams.update({
    "font.family": "serif", "font.serif": ["CMU Serif", "DejaVu Serif"],
    "mathtext.fontset": "cm", "font.size": 9,
    "axes.labelsize": 10, "xtick.labelsize": 9, "ytick.labelsize": 9,
})

# (exponent k, S_2(10^k) / A(10^k)) with A(n) = (2/3) pi(sqrt n)^3
data = [(4, 1.00051), (5, 1.00217), (6, 1.05931), (7, 1.08534), (8, 1.04811),
        (9, 1.04923), (10, 1.03526), (11, 1.03129), (12, 1.02546),
        (13, 1.02041), (14, 1.01713)]
ks = [d[0] for d in data]
rs = [d[1] for d in data]

fig, ax = plt.subplots(figsize=(5.2, 3.0))
ax.axhline(1.0, color="0.55", linewidth=1.0, linestyle="--", zorder=2)
ax.plot(ks, rs, color="black", linewidth=1.2, marker="o", markersize=3.0, zorder=3)
ax.annotate("limit $1$", xy=(13.2, 1.0), xytext=(13.2, 1.006), fontsize=9, color="0.35")

ax.set_xlabel(r"$n$")
ax.set_ylabel(r"$S_2(n) \, / \, \frac{2}{3}\pi(\sqrt{n})^3$")
ax.set_xticks(range(4, 15, 2))
ax.set_xticklabels([r"$10^{%d}$" % k for k in range(4, 15, 2)])
ax.set_ylim(0.995, 1.095)
ax.spines["top"].set_visible(False)
ax.spines["right"].set_visible(False)
fig.tight_layout(pad=0.3)
fig.savefig(outfile)

print("peak at 10^%d, ratio %.5f" % (ks[rs.index(max(rs))], max(rs)))
# NOT "monotone from 10^7 onwards" -- it is not, and the caption says so: there is a
# second, smaller rise between 10^8 and 10^9.  Report the rises explicitly instead, so the
# diagnostic agrees with the figure rather than contradicting it.
rises = [(ks[i], ks[i+1]) for i in range(len(rs)-1) if rs[i+1] > rs[i]]
print("ratio rises across: " + ", ".join("10^%d->10^%d" % r for r in rises))
print("monotone decreasing after the last rise:",
      all(rs[i] > rs[i+1] for i in range(ks.index(rises[-1][1]), len(rs)-1)))
print("wrote %s" % outfile)
