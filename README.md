## ocaml-yaml -- parse and generate YAML 1.1 files

This is an OCaml library to parse and generate the YAML file
format.  It is intended to interoperable with the [Ezjsonm](https://github.com/mirage/ezjsonm)
JSON handling library, if the simple common subset of Yaml 
is used.  Anchors and other advanced Yaml features are not
implemented in the JSON compatibility layer.

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

The following layers are present to make the high-level library work:

- [`vendor/`](vendor/) contains the C sources for libyaml, with some minor modifications
  to the header files to make them easier to use with Ctypes
- [`types/`](types/) has OCaml definitions for the C types defined in [`yaml.h`](vendor/yaml.h)
- [`ffi/`](ffi/) has OCaml definitions for the C functions defined in [`yaml.h`](vendor/yaml.h)
- [`lib/`](lib/) contains the high-level OCaml interface for Yaml manipulation, using the FFI definitions above
- [`tests/`](tests/) has unit tests and fuzz tests for the library functionality

A copy of the libyaml C library is included into `vendor/` to eliminate the need
for a third-party dependency.  The C code is built directly into a `yaml.a`
static library, and linked in with the OCaml bindings.

We then need to generate OCaml type definitions that correspond to the C header
definitions in libyaml.  This is all done without writing a single line of C code,
via the stub generation support in [ocaml-ctypes](https://github.com/ocamllabs/ocaml-ctypes).
We define an OCaml library that describes the C enumerations or structs that we need a
corresponding definition for (see [types/bindings/yaml_bindings_types.ml]).  This is
then compiled into an executable (see [types/stubgen/ffi_types_stubgen.ml]) which takes
care of calling the C compiler and generating a compatible OCaml module. The 

Once we have the C type definitions that we need bound into OCaml, we then need to
bind the C library functions that use them.  We do exactly the same approach as we 
did for probing types earlier, but define an OCaml descriptions of the functions
that we want to bind instead (see [ffi/bindings/yaml_bindings.ml]).

### TODO 

- Warnings: handle the unsigned char `yaml_char_t` in the Ctypes bindings.
- Warnings: const needs to be specified in the Ctypes binding.
- The `pkg/pkg.ml` file can be removed once topkg has jbuilder autodetection.
  [dbuenzli/topkg#123](https://github.com/dbuenzli/topkg/issues/123)
- Send upstream PR for forked header file (due to removal of anonymous structs).
- Use Configurator for C build rules in vendor/ (e.g. no `-fPIC` on arm32?)
