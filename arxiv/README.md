# arxiv/

One subdirectory per submission, each self-contained and ready to upload.

arXiv compiles the `.tex` itself; anything under `anc/` is carried along as **ancillary material**,
downloadable from the abstract page but not compiled. That is where code and formalizations go.

Do not commit build products (`.aux`, `.log`, `.out`, `.pdf`) here — arXiv builds its own, and a
stale PDF in the bundle is a good way to submit the wrong version.
