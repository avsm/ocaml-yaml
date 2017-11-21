#!/bin/sh

DISTRO=${DISTRO:-alpine-3.6}
OCAML_VERSIONS=${OCAML_VERSIONS:4.04.2 4.05.0 4.06.0}
docker run -it -e DISTRO=${DISTRO} -e OCAML_VERSIONS="${OCAML_VERSIONS}" -v `pwd`:/home/opam/src ocaml/opam2:${DISTRO}-ocaml /home/opam/src/.docker.sh
