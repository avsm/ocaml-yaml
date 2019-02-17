## v1.0.0 (17/02/2019)
* Support parsing of canonical Yaml null, float and bool
  values (@avsm, fixes #15 #16).
* Port from jbuilder to dune (#2 @rgrinberg)
* Use dune.configurator for config probing (#18 @emillon)
* Upgrade opam metadata to 2.0 format (@avsm)
* Suppress some C warnings on build due to ctypes autogen
  until ctypes gains support for unsigned char types (@avsm)
* Add Windows build support (@avsm #11)
* Refresh libyaml to upstream changeset 85d1f168ef39f4 (@avsm)
* Switch CI to Azure Pipelines and test Windows, Linux and
  macOS (@avsm)
* Add Junit output to the Alcotest (@avsm)

## v0.2.1 (01/06/2018)

* Repair build on ppc64le by using Configurator to query CFLAGS.
  ppc64le needs an `mcmodel=small` due to a quick of the architecture.
* Minor improvements to ocamldoc documentation.
* Remove `pkg/pkg.ml` as `dune-release` is used for release now.

## v0.2.0 (17/05/2018)

* Explicitly depend on `sexplib` in jbuild description.
* Remove use of deprecated build variables in jbuild file.
* Add a `Yaml_unix` module with functions to read and write
  from files directly.
* Eliminate runtime dependency on `Str` (#10 from @yallop)
* Various build fixes (#9 #8 #7 from @diml @rgrinberg).

## v0.1.0 (24/12/2017)

* Initial public release.
