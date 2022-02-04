## v3.0.1 (04/02/2022)

* Remove dependency on Rresult (@maxtori #50).

## v3.0.0 (04/08/2021)

* Support Yaml 1.2, and stop advertising Yaml 1.0 support.
  This also updates the vendored libyaml to 0.2.5 (@favonia #37).

* Add a `Yaml.Util` module with a number of useful combinators
  to manipulate `Yaml.value` types, such as retrieving keys and
  values, finding entries and converting to OCaml native
  types (@patricoferris #43)

* Move the sexpression derivers into a separate `Yaml_sexp`
  package (the `yaml-sexp` opam package). This reduces dependencies
  on the main library.  You can still use `Yaml` types in
  `ppx_sexplib_conv` derivers by simply replacing the 
  `Yaml.value` (or other type) with `Yaml_sexp.value` which is
  an alias that also includes the Sexp conversion functions in
  its scope. (@alan-j-hu @avsm #46).

* When outputting values, wrap special values like "true" or
  "1.0" in double quotes, so that `Yaml.of_string` will not
  interpret them as a non-string value (@avsm #47).

* Track anchors and mappings in `Yaml.yaml` (but not in the
  `Yaml.value` JSON representation). This also allows non-scalar
   values to be used as keys. (@favonia #38)

* Bump the internal write buffer for stream emission to
  256k from 64k, as people are writing ever-larger Yaml
  files! In the future, this static buffer will be replaced
  by a dynamically growing output buffer but for now needs
  to be set manually.

* The minimum supported OCaml version is now OCaml 4.05.

## v2.1.0 (07/02/2020)

* Fix a memory unsoundness issue with larger files in the
  bindings to libyaml, which fixes spurious errors when parsing
  larger YAML files (#35 marcinkoziej)
* Expose more information about error locations while parsing
  a Yaml file (#34 @marcinkoziej)
* Add test for a large Yaml file (#30 @pmonson711)
* Bump size of internal serialisation buffer in `to_string`
  to 64KB from 16KB (@avsm).
* Switch CI to GitHub Actions (@avsm)
* Depend on dune-configurator in the build to be compatible
  with dune 2.0 and higher (@avsm)

## v2.0.1 (18/08/2019)

* Add unexpected error codes to error messages so that
  debugging errors from libyaml is possible (#28 @mjambon)

## v2.0.0 (24/03/2019)

* Represent quoted scalars as strings in Json encoding (#22 @rizo, fixes #20).
* Expose more detailed scalar information in `Yaml.yaml` (#22 @rizo).
* Add `Yaml.equal` (#22 @rizo)
* Avoid printing the decimal point when the float number is an
  integer (#25 @kit-ty-kate)

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
