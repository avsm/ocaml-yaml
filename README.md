## ocaml-yaml -- parse and generate YAML 1.1 files

This is an OCaml library to parse and generate the YAML file
format.  It is intended to interoperable with the [Ezjsonm](https://github.com/mirage/ezjsonm)
JSON handling library, if the simple common subset of Yaml 
is used.  Anchors and other advanced Yaml features are not
implemented in the JSON compatibility layer.

The [Yaml module docs](http://anil-code.recoil.org/ocaml-yaml/yaml/Yaml/index.html) are browseable online.

## Example of use

Install the library via `opam install yaml`, and then execute a
toplevel via `utop`.  You can also build and execute the toplevel
locally:

```
$ jbuilder exec utop
# #require "yaml";;
# Yaml.of_string "foo";;
- : Yaml.value Yaml.res = Result.Ok (`String "foo")
# Yaml.of_string "- foo";;
- : Yaml.value Yaml.res = Result.Ok (`A [`String "foo"])
# Yaml.to_string (`O ["foo1", `String "bar1"; "foo2", `Float 1.0]);;
- : string Yaml.res = Result.Ok "foo1: bar1\nfoo2: 1.\n"
# #require "yaml.unix" ;;
# Yaml_unix.to_file Fpath.(v "my.yml") (`String "bar") ;;
- : (unit, Rresult.R.msg) result = Result.Ok ()
# Yaml_unix.of_file Fpath.(v "my.yml");;
- : (Yaml.value, Rresult.R.msg) result = Result.Ok (`String "bar")
# Yaml_unix.of_file_exn Fpath.(v "my.yml");;
- : Yaml.value = `String "bar"
```

### Repository Structure

ocaml-yaml is based around a binding to the C [libyaml](http://pyyaml.org/wiki/LibYAML)
library to do the majority of the low-level parsing and serialisation,
with a higher-level OCaml module that provids a simple interface for the
majority of common uses.

We use the following major OCaml tools and libraries:

- **build:** [jbuilder](https://github.com/janestreet/jbuilder) is the build tool used.
- **ffi:** [ctypes](https://github.com/ocamllabs/ocaml-ctypes) is the library to interface with the C FFI exposed by libYaml.
- **preprocessor:** [ppx_sexp_conv](https://github.com/janestreet/ppx_sexp_conv) generates s-expression serialises and deserialisers for the types exposed by the library.
- **error handling:** [rresult](https://github.com/dbuenzli/rresult) is a set of combinators for returning errors as values, instead of raising OCaml exceptions.
- **tests:** [alcotest](https://github.com/mirage/alcotest) specifies conventional unit tests, and [crowbar](https://github.com/stedolan/crowbar) is used to drive property-based fuzz-testing of the library.

#### Library Architecture

The following layers are present to make the high-level library work, contained
within the following directories in the repository:

- [`vendor/`](vendor/) contains the C sources for libyaml, with some minor modifications.
  to the header files to make them easier to use with Ctypes.
- [`types/`](types/) has OCaml definitions for the C types defined in [`yaml.h`](vendor/yaml.h).
- [`ffi/`](ffi/) has OCaml definitions for the C functions defined in [`yaml.h`](vendor/yaml.h).
- [`lib/`](lib/) contains the high-level OCaml interface for Yaml manipulation, using the FFI definitions above.
- [`unix/`](unix/) contains OS-specific bindings with file-handling.
- [`tests/`](tests/) has unit tests for the library functionality.
- [`fuzz/`](fuzz/) contains exploratory fuzz testing that randomises inputs to find bugs.
- [`config/`](config/) has configuration tests to set the C compilation flags.

**C library:** A copy of the libyaml C library is included into `vendor/` to eliminate the need
for a third-party dependency.  The C code is built directly into a `yaml.a`
static library, and linked in with the OCaml bindings.

**Bindings to C types:** We then need to generate OCaml type definitions that correspond to the C header
definitions in libyaml.  This is all done without writing a single line of C code,
via the stub generation support in [ocaml-ctypes](https://github.com/ocamllabs/ocaml-ctypes).
We define an OCaml library that describes the C enumerations or structs that we need a
corresponding definition for (see [yaml_bindings_types.ml](types/bindings/yaml_bindings_types.ml)).
This code is also exported in the `yaml.bindings.types` ocamlfind library.

These binding descriptions are then then compiled into an executable (see [ffi_types_stubgen.ml](types/stubgen/ffi_types_stubgen.ml)).
When run, this calls the C compiler and generating a compatible OCaml module with the results
of probing the C library and statically determining values for (e.g.) struct offsets or macros.
The resulting OCaml library is expored in the `yaml.types` ocamlfind library.

**Bindings to C functions:** Once we have the C type definitions bound into OCaml, we then need to
bind the corresponding C library functions that use them.  We do exactly the same approach as we 
did for probing types earlier, but define an OCaml descriptions of the functions
that we want to bind instead (see [yaml_bindings.ml](ffi/bindings/yaml_bindings.ml)).
The [ffi_stubgen](ffi/stubgen/ffi_stubgen.ml) executable then takes these descriptions and
generates *two* source code files: an OCaml module containing the typed function calls,
and the corresponding C bindings that link those typed function calls to the C library.
Again, this is all done automatically via Ctypes functions, and we never had to write
any manual C code.  As an additional layer of safety, mistakes when writing the Ctypes
bindings will also result in a compile-time error, since the generated C code will fail
to compile with the C header files for the yaml library.  The resulting OCaml functions
are exported in the `yaml.ffi` ocamlfind library.

**OCaml API:** Finally, we define the OCaml API that uses the low-level FFI to expose
a well-typed OCaml interface. We adopt a convention of using the [Rresult](https://github.com/dbuenzli/rresult)
library to return explicit errors instead of raising OCaml exceptions.  We also
define some polymorphic variant types to represent various configuration options
(such as the printing style of different Yaml values).

Since the most common use of Yaml is for relatively simple key-value stores, the
OCaml API by default exposes polymorphic variant types that are completely compatible
with the Ezjsonm library, meaning that you can print JSON or Yaml back and forth
very easily.  However, if you do need the advanced Yaml functions like anchors and
aliases, then there are definitions that expose them too.

**Testing:** There are two test suites included with the repository.  The first is
a conventional unit test infrastructure that uses the [Alcotest](https://github.com/mirage/alcotest)
framework from MirageOS.  The second is a property-based fuzz testing framework
via [Crowbar](https://github.com/stedolan/crowbar), which tries to find unexpected
issues by exploring the library with randomised inputs that are guided by the
control flow of the execution. 

**Docs:** Documentation can be locally generated by running `make doc`, and looking
in `_build/default/_doc/index.html` with a web browser. The URL for online docs
is listed below.

### Further Information

- **Discussion:** Post on <https://discuss.ocaml.org/> with the `yaml` tag under
  the Ecosystem categoey.
- **Bugs:** <https://github.com/avsm/ocaml-yaml/issues>
- **Docs:** <http://anil-code.recoil.org/ocaml-yaml>

Contributions are very welcome.  Please see the overall TODO list below, or
please get in touch with any particular comments you might have.

### TODO 

- Warnings: handle the unsigned char `yaml_char_t` in the Ctypes bindings.
- Warnings: const needs to be specified in the Ctypes binding.
- Send upstream PR for forked header file (due to removal of anonymous structs).
