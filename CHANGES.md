## v0.2.1

* Repair build on ppc64le by using Configurator to query CFLAGS.
  ppc64le needs an `mcmodel=small` due to a quick of the architecture.

## v0.2.0 (17/05/2018)

* Explicitly depend on `sexplib` in jbuild description.
* Remove use of deprecated build variables in jbuild file.
* Add a `Yaml_unix` module with functions to read and write
  from files directly.
* Eliminate runtime dependency on `Str` (#10 from @yallop)
* Various build fixes (#9 #8 #7 from @diml @rgrinberg).

## v0.1.0 (24/12/2017)

* Initial public release.
