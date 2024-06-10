; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mattr=+sve < %s | FileCheck %s


target triple = "aarch64-unknown-linux-gnu"

;
; Masked Load
;

define <16 x i8> @masked_load_v16i8(ptr %src, <16 x i1> %mask) {
; CHECK-LABEL: masked_load_v16i8:
; CHECK:       // %bb.0:
; CHECK-NEXT:    ptrue p0.b, vl16
; CHECK-NEXT:    shl v0.16b, v0.16b, #7
; CHECK-NEXT:    cmlt v0.16b, v0.16b, #0
; CHECK-NEXT:    cmpne p0.b, p0/z, z0.b, #0
; CHECK-NEXT:    ld1b { z0.b }, p0/z, [x0]
; CHECK-NEXT:    // kill: def $q0 killed $q0 killed $z0
; CHECK-NEXT:    ret
  %load = call <16 x i8> @llvm.masked.load.v16i8(ptr %src, i32 8, <16 x i1> %mask, <16 x i8> zeroinitializer)
  ret <16 x i8> %load
}

define <8 x half> @masked_load_v8f16(ptr %src, <8 x i1> %mask) {
; CHECK-LABEL: masked_load_v8f16:
; CHECK:       // %bb.0:
; CHECK-NEXT:    ushll v0.8h, v0.8b, #0
; CHECK-NEXT:    ptrue p0.h, vl8
; CHECK-NEXT:    shl v0.8h, v0.8h, #15
; CHECK-NEXT:    cmlt v0.8h, v0.8h, #0
; CHECK-NEXT:    cmpne p0.h, p0/z, z0.h, #0
; CHECK-NEXT:    ld1h { z0.h }, p0/z, [x0]
; CHECK-NEXT:    // kill: def $q0 killed $q0 killed $z0
; CHECK-NEXT:    ret
  %load = call <8 x half> @llvm.masked.load.v8f16(ptr %src, i32 8, <8 x i1> %mask, <8 x half> zeroinitializer)
  ret <8 x half> %load
}

define <4 x float> @masked_load_v4f32(ptr %src, <4 x i1> %mask) {
; CHECK-LABEL: masked_load_v4f32:
; CHECK:       // %bb.0:
; CHECK-NEXT:    ushll v0.4s, v0.4h, #0
; CHECK-NEXT:    ptrue p0.s, vl4
; CHECK-NEXT:    shl v0.4s, v0.4s, #31
; CHECK-NEXT:    cmlt v0.4s, v0.4s, #0
; CHECK-NEXT:    cmpne p0.s, p0/z, z0.s, #0
; CHECK-NEXT:    ld1w { z0.s }, p0/z, [x0]
; CHECK-NEXT:    // kill: def $q0 killed $q0 killed $z0
; CHECK-NEXT:    ret
  %load = call <4 x float> @llvm.masked.load.v4f32(ptr %src, i32 8, <4 x i1> %mask, <4 x float> zeroinitializer)
  ret <4 x float> %load
}

define <2 x double> @masked_load_v2f64(ptr %src, <2 x i1> %mask) {
; CHECK-LABEL: masked_load_v2f64:
; CHECK:       // %bb.0:
; CHECK-NEXT:    ushll v0.2d, v0.2s, #0
; CHECK-NEXT:    ptrue p0.d, vl2
; CHECK-NEXT:    shl v0.2d, v0.2d, #63
; CHECK-NEXT:    cmlt v0.2d, v0.2d, #0
; CHECK-NEXT:    cmpne p0.d, p0/z, z0.d, #0
; CHECK-NEXT:    ld1d { z0.d }, p0/z, [x0]
; CHECK-NEXT:    // kill: def $q0 killed $q0 killed $z0
; CHECK-NEXT:    ret
  %load = call <2 x double> @llvm.masked.load.v2f64(ptr %src, i32 8, <2 x i1> %mask, <2 x double> zeroinitializer)
  ret <2 x double> %load
}

define <2 x double> @masked_load_passthru_v2f64(ptr %src, <2 x i1> %mask, <2 x double> %passthru) {
; CHECK-LABEL: masked_load_passthru_v2f64:
; CHECK:       // %bb.0:
; CHECK-NEXT:    ushll v0.2d, v0.2s, #0
; CHECK-NEXT:    ptrue p0.d, vl2
; CHECK-NEXT:    // kill: def $q1 killed $q1 def $z1
; CHECK-NEXT:    shl v0.2d, v0.2d, #63
; CHECK-NEXT:    cmlt v0.2d, v0.2d, #0
; CHECK-NEXT:    cmpne p0.d, p0/z, z0.d, #0
; CHECK-NEXT:    ld1d { z0.d }, p0/z, [x0]
; CHECK-NEXT:    sel z0.d, p0, z0.d, z1.d
; CHECK-NEXT:    // kill: def $q0 killed $q0 killed $z0
; CHECK-NEXT:    ret
  %load = call <2 x double> @llvm.masked.load.v2f64(ptr %src, i32 8, <2 x i1> %mask, <2 x double> %passthru)
  ret <2 x double> %load
}

declare <16 x i8> @llvm.masked.load.v16i8(ptr, i32, <16 x i1>, <16 x i8>)
declare <8 x half> @llvm.masked.load.v8f16(ptr, i32, <8 x i1>, <8 x half>)
declare <4 x float> @llvm.masked.load.v4f32(ptr, i32, <4 x i1>, <4 x float>)
declare <2 x double> @llvm.masked.load.v2f64(ptr, i32, <2 x i1>, <2 x double>)