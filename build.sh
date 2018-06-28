#!/usr/bin/env bash
# Reproducible build with the TeX Live version the originals were built with. Requires podman (or docker: export ENGINE=docker).
#   ./build.sh          paper (as submitted, v1.0) → build/vinci2018.pdf                 (TeX Live 2017, pdfTeX 1.40.18)
#   ./build.sh author   paper with the acmart "authorversion" notice, for Zenodo → build/vinci2018-author.pdf
#   ./build.sh slides   talk → build-slides/vinci-refsurface.pdf                         (TeX Live 2018, pdfTeX 1.40.19)
# The paper used the acmart.cls of TeX Live 2017 (v1.50, 2018/02/07); the acmart.dtx (v1.53) shipped with the
# camera-ready sources rewords the copyright block ("licensed to ACM") and is therefore not included.
set -euo pipefail
cd "$(dirname "$0")"
ENGINE=${ENGINE:-podman}
dir=src out=build main=vinci2018 tl=TL2017
args=(-pdf -interaction=nonstopmode -outdir=/out)
case ${1:-} in
  slides) dir=slides out=build-slides main=vinci-refsurface tl=TL2018 ;;
  author) args+=(-jobname="$main-author" -pdflatex='pdflatex %O "\PassOptionsToClass{authorversion}{acmart}\input{%S}"') ;;  # old latexmk: no -usepretex
esac
mkdir -p "$out"
"$ENGINE" run --rm -e openout_any=a -v "$PWD/$dir:/src:ro,Z" -v "$PWD/$out:/out:Z" -w /src \
  "docker.io/texlive/texlive:$tl-historic" latexmk "${args[@]}" "$main.tex"
