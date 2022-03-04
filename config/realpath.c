#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/alloc.h>
#include <caml/fail.h>
#include <caml/callback.h>
#include <errno.h>

CAMLprim value caml_unix_realpath (value p)
{
  CAMLparam1 (p);
  char *r;
  value rp;

  r = realpath (String_val (p), NULL);
  if (r == NULL) { caml_invalid_argument ("realpath returned NULL");  }
  rp = caml_copy_string (r);
  free (r);
  CAMLreturn (rp);
}
