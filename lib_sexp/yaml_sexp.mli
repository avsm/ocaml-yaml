val sexp_of_value : Yaml.value -> Ppx_sexp_conv_lib.Sexp.t
val value_of_sexp : Ppx_sexp_conv_lib.Sexp.t -> Yaml.value

val sexp_of_yaml : Yaml.yaml -> Ppx_sexp_conv_lib.Sexp.t
val sexp_of_scalar : Yaml.scalar -> Ppx_sexp_conv_lib.Sexp.t
val sexp_of_scalar_style : Yaml.scalar_style -> Ppx_sexp_conv_lib.Sexp.t
val yaml_of_sexp : Ppx_sexp_conv_lib.Sexp.t -> Yaml.yaml
val scalar_of_sexp : Ppx_sexp_conv_lib.Sexp.t -> Yaml.scalar
val scalar_style_of_sexp : Ppx_sexp_conv_lib.Sexp.t -> Yaml.scalar_style

val sexp_of_yaml : Yaml.yaml -> Ppx_sexp_conv_lib.Sexp.t
val sexp_of_scalar : Yaml.scalar -> Ppx_sexp_conv_lib.Sexp.t
val sexp_of_scalar_style : Yaml.scalar_style -> Ppx_sexp_conv_lib.Sexp.t
val yaml_of_sexp : Ppx_sexp_conv_lib.Sexp.t -> Yaml.yaml
val scalar_of_sexp : Ppx_sexp_conv_lib.Sexp.t -> Yaml.scalar
val scalar_style_of_sexp : Ppx_sexp_conv_lib.Sexp.t -> Yaml.scalar_style

val sexp_of_version : Yaml.version -> Ppx_sexp_conv_lib.Sexp.t
val version_of_sexp : Ppx_sexp_conv_lib.Sexp.t -> Yaml.version

val sexp_of_layout_style : Yaml.layout_style -> Ppx_sexp_conv_lib.Sexp.t
val layout_style_of_sexp : Ppx_sexp_conv_lib.Sexp.t -> Yaml.layout_style

module Stream : sig
  module Mark : sig
    val t_of_sexp : Sexplib0.Sexp.t -> Yaml.Stream.Mark.t
    val sexp_of_t : Yaml.Stream.Mark.t -> Sexplib0.Sexp.t
  end

  module Event : sig
    val sexp_of_pos : Yaml.Stream.Event.pos -> Ppx_sexp_conv_lib.Sexp.t
    val pos_of_sexp : Ppx_sexp_conv_lib.Sexp.t -> Yaml.Stream.Event.pos

    val t_of_sexp : Sexplib0.Sexp.t -> Yaml.Stream.Event.t
    val sexp_of_t : Yaml.Stream.Event.t -> Sexplib0.Sexp.t
  end
end
