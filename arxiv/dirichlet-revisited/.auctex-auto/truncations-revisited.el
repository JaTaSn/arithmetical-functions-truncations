;; -*- lexical-binding: t; -*-

(TeX-add-style-hook
 "truncations-revisited"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-class-options
                     '(("amsart" "a4paper" "11pt" "oneside" "reqno")))
   (TeX-add-to-alist 'LaTeX-provided-package-options
                     '(("amsthm" "") ("amsmath" "") ("amssymb" "") ("hyperref" "") ("orcidlink" "") ("graphicx" "") ("booktabs" "")))
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "href")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "hyperimage")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "hyperbaseurl")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "nolinkurl")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "url")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "path")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "urladdr")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "email")
   (add-to-list 'LaTeX-verbatim-macros-with-delims-local "path")
   (TeX-run-style-hooks
    "latex2e"
    "amsart"
    "amsart11"
    "amsthm"
    "amsmath"
    "amssymb"
    "hyperref"
    "orcidlink"
    "graphicx"
    "booktabs")
   (TeX-add-symbols
    '("seqnum" 1)
    "NN"
    "ZZ"
    "QQ"
    "lpf"
    "Om"
    "Gam"
    "addresses")
   (LaTeX-add-labels
    "eq:monoid"
    "eq:GammaSI"
    "eq:stable"
    "eq:Cdef"
    "eq:phidef"
    "rem:m2"
    "sec:prelim"
    "thm:S32"
    "eq:CasR"
    "eq:RvsPhi"
    "sec:main"
    "thm:main"
    "eq:Rsum"
    "cor:split"
    "eq:split"
    "eq:Edef"
    "cor:total"
    "sec:errata"
    "eq:false"
    "prop:fixed35"
    "prop:fixed344"
    "prop:fixed345"
    "sec:conjecture"
    "eq:PB"
    "eq:conj"
    "lem:secondiff"
    "lem:c0"
    "prop:order"
    "thm:conj"
    "fig:profile"
    "sec:asymptotics"
    "thm:asymp"
    "eq:Sdef"
    "lem:semiprime"
    "eq:XM"
    "eq:gdef"
    "eq:S2asg"
    "lem:split"
    "eq:split-exact"
    "rem:whytwothirds"
    "eq:sqexact"
    "lem:pnt-unif"
    "eq:pnt-sub"
    "lem:tail"
    "prop:T"
    "thm:error"
    "eq:explicit"
    "rem:hypotheses"
    "fig:ratio"
    "tab:err"
    "sec:socle"
    "prop:socle"
    "cor:type"
    "rem:unitary"
    "sec:related"
    "sec:next"
    "op:lean")
   (LaTeX-add-bibitems
    "AramovaHerzog"
    "CashwellEverett"
    "EliahouKervaire"
    "GAP"
    "Golod"
    "GulliksenLevin"
    "Peeva"
    "Sage"
    "Snellman2000"
    "SnellmanUnitaryGeneral"
    "SnellmanUnitaryN"
    "HerzogHibi"
    "MillerSturmfels"
    "SnellmanLaplacians"
    "DuvalReiner"
    "Buchstab"
    "deBruijn"
    "SimplicialHomology"
    "Fan"
    "Gorodetsky"
    "GoswamiKleynPorrill"
    "HerzogReinerWelker"
    "Holt"
    "Macaulay2"
    "McCulloughPeeva"
    "Miyashita"
    "Tenenbaum"
    "OEIS"
    "gitrepo")
   (LaTeX-add-amsthm-newtheorems
    "definition"
    "example"
    "remark"
    "openproblem"
    "theorem"
    "lemma"
    "proposition"
    "corollary"
    "conjecture"))
 :latex)

