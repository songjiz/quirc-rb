#include <ruby.h>
#include "quirc_internal.h"

#define LIB_VERSION rb_str_new_cstr(quirc_version())

VALUE mQuirc;
VALUE cQuircRecognizer;
VALUE cQuircData;

typedef struct {
  struct quirc *quirc;
} quirc_recognizer_t;

static void quirc_recognizer_t_dfree(void* _qr) {
  quirc_recognizer_t* qr = (quirc_recognizer_t*)_qr;
  if (qr->quirc != NULL) {
    quirc_destroy(qr->quirc);
  }
  free(qr);
}

static size_t quirc_recognizer_t_dsize(const void* _qr) {
  size_t size;
  quirc_recognizer_t* qr = (quirc_recognizer_t*)_qr;
  size = sizeof(quirc_recognizer_t);
  if (qr->quirc != NULL) {
    size += sizeof(struct quirc);
    size += sizeof(quirc_pixel_t);
    // image byte size
    size += qr->quirc->w * qr->quirc->h;
    size += sizeof(struct quirc_flood_fill_vars);
  }
  return size;
}

// static void quirc_recognizer_t_dmark(void* _qr) {
//   quirc_recognizer_t* qr = (quirc_recognizer_t*)_qr;
// }

static const rb_data_type_t quirc_recognizer_data_type = {
  .wrap_struct_name = "quirc recognizer object",
  .function = {
    // .dmark = quirc_recognizer_t_dmark,
    .dfree = quirc_recognizer_t_dfree,
    .dsize = quirc_recognizer_t_dsize,
  },
  .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

VALUE quirc_recognizer_t_alloc(VALUE self) {
  quirc_recognizer_t *qr = malloc(sizeof(quirc_recognizer_t));

  qr->quirc = quirc_new();

  if (qr->quirc == NULL) {
    free(qr);
    rb_raise(rb_eNoMemError, "%s", "(quirc_new) failed to allocate memory");
  }

  return TypedData_Wrap_Struct(self, &quirc_recognizer_data_type, qr);
}

VALUE quirc_recognizer_t_recognize(VALUE self, VALUE image_data, VALUE width, VALUE height) {
  quirc_recognizer_t *qr;
  uint8_t *image;
  int w, h;
  int total_pixels;
  int total_codes;
  VALUE results;

  Check_Type(image_data, T_STRING);

  total_pixels = NUM2INT(width) * NUM2INT(height);

  TypedData_Get_Struct(self, quirc_recognizer_t, &quirc_recognizer_data_type, qr);

  if (quirc_resize(qr->quirc, NUM2INT(width), NUM2INT(height)) == -1) {
    rb_raise(rb_eNoMemError, "%s", "(quirc_resize) failed to allocate memory");
  }

  image = quirc_begin(qr->quirc, &w, &h);
  total_pixels = w * h;

  // Filling the image buffer. One byte per pixel.
  if (RSTRING_LEN(image_data) >= total_pixels) {
    memcpy(image, StringValuePtr(image_data), total_pixels);
  } else {
    // rb_raise(rb_eArgError, "%s", "Expect an 8-bit image");
  }

  quirc_end(qr->quirc);

  total_codes = quirc_count(qr->quirc);
  results = rb_ary_new_capa(total_codes);

  for (int i = 0; i < total_codes; ++i) {
    struct quirc_code code;
    struct quirc_data data;
    quirc_decode_error_t err;
    VALUE result;

    quirc_extract(qr->quirc, i, &code);

    err = quirc_decode(&code, &data);

    if (err == QUIRC_ERROR_DATA_ECC) {
      quirc_flip(&code);
      err = quirc_decode(&code, &data);
    }

    if (err != QUIRC_SUCCESS) {
      rb_warn("(quirc_decode) %s", quirc_strerror(err));
      continue;
    }

    result = rb_funcall(cQuircData, rb_intern("new"), 0);
    rb_iv_set(result, "@version", INT2FIX(data.version));
    rb_iv_set(result, "@ecc_level", INT2FIX(data.ecc_level));
    rb_iv_set(result, "@mask", INT2FIX(data.mask));
    rb_iv_set(result, "@data_type", INT2FIX(data.data_type));
    rb_iv_set(result, "@payload_len", INT2FIX(data.payload_len));
    rb_iv_set(result, "@payload", rb_str_new_cstr((const char *)data.payload));
    rb_iv_set(result, "@eci", INT2NUM(data.eci));
    rb_ary_push(results, result);
  }

  return results;
}

void Init_quirc(void) {
  mQuirc = rb_define_module("Quirc");
  rb_define_const(mQuirc, "LIB_VERSION", LIB_VERSION);

  cQuircRecognizer = rb_define_class_under(mQuirc, "Recognizer", rb_cObject);
  rb_define_alloc_func(cQuircRecognizer, quirc_recognizer_t_alloc);
  rb_define_method(cQuircRecognizer, "recognize", quirc_recognizer_t_recognize, 3);

  cQuircData = rb_define_class_under(mQuirc, "Data", rb_cObject);
  rb_define_attr(cQuircData, "version", 1, 0);
  rb_define_attr(cQuircData, "ecc_level", 1, 0);
  rb_define_attr(cQuircData, "mask", 1, 0);
  rb_define_attr(cQuircData, "data_type", 1, 0);
  rb_define_attr(cQuircData, "payload_len", 1, 0);
  rb_define_attr(cQuircData, "payload", 1, 0);
  rb_define_attr(cQuircData, "eci", 1, 0);
}
