docker run -it -e DISTRO=${DISTRO} -e OCAML_VERSIONS="${OCAML_VERSIONS}" -v `pwd`:/home/opam/src ocaml/opam2:${DISTRO}-ocaml /home/opam/src/.docker.sh
