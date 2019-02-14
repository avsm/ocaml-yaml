#!/usr/bin/env bash
DISTRO=${DISTRO:-alpine}
VERSIONS=${OCAML_VERSIONS:-4.04 4.05 4.06 4.07}

set -ex
# TODO opam2 depext
case $DISTRO in
alpine*) sudo apk add m4 ;;
debian*) sudo apt update; sudo apt -y install m4 pkg-config ;;
ubuntu*) sudo apt update; sudo apt -y install m4 pkg-config ;;
esac

sudo chown -R opam /home/opam/src
cd /home/opam/src
export OPAMYES=1
export OPAMJOBS=3
opam repo set-url default https://github.com/ocaml/opam-repository.git
opam install --deps-only .
echo "(lang dune 1.0)" > dune-workspace.dev
for v in $VERSIONS; do
  echo "(context (opam (switch $v)))" >> dune-workspace.dev
  opam pin add crowbar https://github.com/stedolan/crowbar.git --switch $v
  opam install --deps-only -t --switch $v .
done

dune build --workspace dune-workspace.dev
dune runtest --workspace dune-workspace.dev
opam install -y .
rm -f dune-workspace.dev
