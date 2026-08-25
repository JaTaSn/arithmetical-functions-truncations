#!/usr/bin/env python3
# compare_fig2.py -- parse the paper's own tabCg.tex (Figure 2, the numbers
# C_{n,i,d} printed as u^{-2} sum_d C_{n,i,d} u^d) and compare it, row by row
# and cell by cell, against a freshly recomputed version.  Companion to
# recompute_truncations.sage, which only spot-checked six rows.
#
# Changelog (reverse chronological):
#   2026-08-25  Claude-Code-6d5c5b66 (jts-pc) -- initial version.

import re, sys
from sympy import symbols, sympify, expand, factorint, primepi, prime

u = symbols('u')

def Omega(w):  return sum(factorint(w).values())

def minimal_generators(n):
    r = int(primepi(n)); pr = prime(r)
    out = []
    for W in range(n + 1, n * pr + 1):
        ps = sorted(factorint(W))
        if ps[-1] > n: continue
        if W <= n * ps[0]:
            out.append((W, int(primepi(ps[0])), Omega(W)))
    return out

def mine(n):
    r = int(primepi(n)); cells = []
    G = minimal_generators(n)
    for v in range(1, r + 1):
        cells.append(expand(sum(u ** (d - 2) for (_, vv, d) in G if vv == v)))
    return cells

def parse_table(path):
    txt = open(path).read()
    txt = txt[txt.index(r'\hline') + 6:]
    txt = txt[txt.index(r'\hline') + 6:]          # skip the header row
    txt = txt.split(r'\end')[0]
    txt = txt.replace('\n', '').replace(r'\hline', '')
    rows = {}
    for raw in re.split(r'\\\\', txt):
        raw = raw.strip()
        if not raw: continue
        cells = [c.strip() for c in raw.split('&')]
        n = int(cells[0])
        vals = []
        for c in cells[1:]:
            c = c.replace(r'\,', '*').replace('{', '(').replace('}', ')')
            c = re.sub(r'\)\^\(', ')**(', c)
            vals.append(expand(sympify(c)))
        rows[n] = vals
    return rows

paper = parse_table(sys.argv[1] if len(sys.argv) > 1 else 'article/tabCg.tex')
bad = []
for n in sorted(paper):
    p, m = paper[n], mine(n)
    if p != m:
        bad.append((n, p, m))
print("rows parsed from tabCg.tex: %s" % sorted(paper))
print("mismatches: %s" % (bad if bad else "NONE -- Figure 2 reproduced exactly, all %d rows" % len(paper)))
