## ocaml-yaml -- parse and generate YAML 1.1 files

This is an OCaml library to parse and generate the YAML file
format.

*Status:* Work in progress, no stable release yet.

### TODO before release

- Document the repository layout
- Vendor the C library in (as Haskell bindings do)
- Send upstream PR for forked header file (due to anonymous structs)
- Finish the bindings:
  - Parser needs to resolve aliases and expose a single document
  - Emitter needs to be bound. Translate a document into an emitter
- Add Crowbar fuzz testing to check the (parser <-> emitter) is lossless.
