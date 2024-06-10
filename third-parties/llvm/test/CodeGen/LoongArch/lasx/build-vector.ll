; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py UTC_ARGS: --version 3
; RUN: llc --mtriple=loongarch64 --mattr=+lasx < %s | FileCheck %s

define void @buildvector_v32i8_splat(ptr %dst, i8 %a0) nounwind {
; CHECK-LABEL: buildvector_v32i8_splat:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    xvreplgr2vr.b $xr0, $a1
; CHECK-NEXT:    xvst $xr0, $a0, 0
; CHECK-NEXT:    ret
entry:
  %insert = insertelement <32 x i8> undef, i8 %a0, i8 0
  %splat = shufflevector <32 x i8> %insert, <32 x i8> undef, <32 x i32> zeroinitializer
  store <32 x i8> %splat, ptr %dst
  ret void
}

define void @buildvector_v16i16_splat(ptr %dst, i16 %a0) nounwind {
; CHECK-LABEL: buildvector_v16i16_splat:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    xvreplgr2vr.h $xr0, $a1
; CHECK-NEXT:    xvst $xr0, $a0, 0
; CHECK-NEXT:    ret
entry:
  %insert = insertelement <16 x i16> undef, i16 %a0, i8 0
  %splat = shufflevector <16 x i16> %insert, <16 x i16> undef, <16 x i32> zeroinitializer
  store <16 x i16> %splat, ptr %dst
  ret void
}

define void @buildvector_v8i32_splat(ptr %dst, i32 %a0) nounwind {
; CHECK-LABEL: buildvector_v8i32_splat:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    xvreplgr2vr.w $xr0, $a1
; CHECK-NEXT:    xvst $xr0, $a0, 0
; CHECK-NEXT:    ret
entry:
  %insert = insertelement <8 x i32> undef, i32 %a0, i8 0
  %splat = shufflevector <8 x i32> %insert, <8 x i32> undef, <8 x i32> zeroinitializer
  store <8 x i32> %splat, ptr %dst
  ret void
}

define void @buildvector_v4i64_splat(ptr %dst, i64 %a0) nounwind {
; CHECK-LABEL: buildvector_v4i64_splat:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    xvreplgr2vr.d $xr0, $a1
; CHECK-NEXT:    xvst $xr0, $a0, 0
; CHECK-NEXT:    ret
entry:
  %insert = insertelement <4 x i64> undef, i64 %a0, i8 0
  %splat = shufflevector <4 x i64> %insert, <4 x i64> undef, <4 x i32> zeroinitializer
  store <4 x i64> %splat, ptr %dst
  ret void
}

define void @buildvector_v8f32_splat(ptr %dst, float %a0) nounwind {
; CHECK-LABEL: buildvector_v8f32_splat:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    # kill: def $f0 killed $f0 def $xr0
; CHECK-NEXT:    xvreplve0.w $xr0, $xr0
; CHECK-NEXT:    xvst $xr0, $a0, 0
; CHECK-NEXT:    ret
entry:
  %insert = insertelement <8 x float> undef, float %a0, i8 0
  %splat = shufflevector <8 x float> %insert, <8 x float> undef, <8 x i32> zeroinitializer
  store <8 x float> %splat, ptr %dst
  ret void
}

define void @buildvector_v4f64_splat(ptr %dst, double %a0) nounwind {
; CHECK-LABEL: buildvector_v4f64_splat:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    # kill: def $f0_64 killed $f0_64 def $xr0
; CHECK-NEXT:    xvreplve0.d $xr0, $xr0
; CHECK-NEXT:    xvst $xr0, $a0, 0
; CHECK-NEXT:    ret
entry:
  %insert = insertelement <4 x double> undef, double %a0, i8 0
  %splat = shufflevector <4 x double> %insert, <4 x double> undef, <4 x i32> zeroinitializer
  store <4 x double> %splat, ptr %dst
  ret void
}

define void @buildvector_v32i8_const_splat(ptr %dst) nounwind {
; CHECK-LABEL: buildvector_v32i8_const_splat:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    xvrepli.b $xr0, 1
; CHECK-NEXT:    xvst $xr0, $a0, 0
; CHECK-NEXT:    ret
entry:
  store <32 x i8> <i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1>, ptr %dst
  ret void
}

define void @buildvector_v16i16_const_splat(ptr %dst) nounwind {
; CHECK-LABEL: buildvector_v16i16_const_splat:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    xvrepli.h $xr0, 1
; CHECK-NEXT:    xvst $xr0, $a0, 0
; CHECK-NEXT:    ret
entry:
  store <16 x i16> <i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1>, ptr %dst
  ret void
}

define void @buildvector_v8i32_const_splat(ptr %dst) nounwind {
; CHECK-LABEL: buildvector_v8i32_const_splat:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    xvrepli.w $xr0, 1
; CHECK-NEXT:    xvst $xr0, $a0, 0
; CHECK-NEXT:    ret
entry:
  store <8 x i32> <i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1>, ptr %dst
  ret void
}

define void @buildvector_v4i64_const_splat(ptr %dst) nounwind {
; CHECK-LABEL: buildvector_v4i64_const_splat:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    xvrepli.d $xr0, 1
; CHECK-NEXT:    xvst $xr0, $a0, 0
; CHECK-NEXT:    ret
entry:
  store <4 x i64> <i64 1, i64 1, i64 1, i64 1>, ptr %dst
  ret void
}

define void @buildvector_v2f32_const_splat(ptr %dst) nounwind {
; CHECK-LABEL: buildvector_v2f32_const_splat:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lu12i.w $a1, 260096
; CHECK-NEXT:    xvreplgr2vr.w $xr0, $a1
; CHECK-NEXT:    xvst $xr0, $a0, 0
; CHECK-NEXT:    ret
entry:
  store <8 x float> <float 1.0, float 1.0, float 1.0, float 1.0, float 1.0, float 1.0, float 1.0, float 1.0>, ptr %dst
  ret void
}

define void @buildvector_v4f64_const_splat(ptr %dst) nounwind {
; CHECK-LABEL: buildvector_v4f64_const_splat:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lu52i.d $a1, $zero, 1023
; CHECK-NEXT:    xvreplgr2vr.d $xr0, $a1
; CHECK-NEXT:    xvst $xr0, $a0, 0
; CHECK-NEXT:    ret
entry:
  store <4 x double> <double 1.0, double 1.0, double 1.0, double 1.0>, ptr %dst
  ret void
}

define void @buildvector_v32i8_const(ptr %dst) nounwind {
; CHECK-LABEL: buildvector_v32i8_const:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    pcalau12i $a1, %pc_hi20(.LCPI12_0)
; CHECK-NEXT:    addi.d $a1, $a1, %pc_lo12(.LCPI12_0)
; CHECK-NEXT:    xvld $xr0, $a1, 0
; CHECK-NEXT:    xvst $xr0, $a0, 0
; CHECK-NEXT:    ret
entry:
  store <32 x i8> <i8 0, i8 1, i8 2, i8 3, i8 4, i8 5, i8 6, i8 7, i8 8, i8 9, i8 10, i8 11, i8 12, i8 13, i8 14, i8 15, i8 16, i8 17, i8 18, i8 19, i8 20, i8 21, i8 22, i8 23, i8 24, i8 25, i8 26, i8 27, i8 28, i8 29, i8 30, i8 31>, ptr %dst
  ret void
}

define void @buildvector_v16i16_const(ptr %dst) nounwind {
; CHECK-LABEL: buildvector_v16i16_const:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    pcalau12i $a1, %pc_hi20(.LCPI13_0)
; CHECK-NEXT:    addi.d $a1, $a1, %pc_lo12(.LCPI13_0)
; CHECK-NEXT:    xvld $xr0, $a1, 0
; CHECK-NEXT:    xvst $xr0, $a0, 0
; CHECK-NEXT:    ret
entry:
  store <16 x i16> <i16 0, i16 1, i16 2, i16 3, i16 4, i16 5, i16 6, i16 7, i16 8, i16 9, i16 10, i16 11, i16 12, i16 13, i16 14, i16 15>, ptr %dst
  ret void
}

define void @buildvector_v8i32_const(ptr %dst) nounwind {
; CHECK-LABEL: buildvector_v8i32_const:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    pcalau12i $a1, %pc_hi20(.LCPI14_0)
; CHECK-NEXT:    addi.d $a1, $a1, %pc_lo12(.LCPI14_0)
; CHECK-NEXT:    xvld $xr0, $a1, 0
; CHECK-NEXT:    xvst $xr0, $a0, 0
; CHECK-NEXT:    ret
entry:
  store <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>, ptr %dst
  ret void
}

define void @buildvector_v4i64_const(ptr %dst) nounwind {
; CHECK-LABEL: buildvector_v4i64_const:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    pcalau12i $a1, %pc_hi20(.LCPI15_0)
; CHECK-NEXT:    addi.d $a1, $a1, %pc_lo12(.LCPI15_0)
; CHECK-NEXT:    xvld $xr0, $a1, 0
; CHECK-NEXT:    xvst $xr0, $a0, 0
; CHECK-NEXT:    ret
entry:
  store <4 x i64> <i64 0, i64 1, i64 2, i64 3>, ptr %dst
  ret void
}

define void @buildvector_v2f32_const(ptr %dst) nounwind {
; CHECK-LABEL: buildvector_v2f32_const:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    pcalau12i $a1, %pc_hi20(.LCPI16_0)
; CHECK-NEXT:    addi.d $a1, $a1, %pc_lo12(.LCPI16_0)
; CHECK-NEXT:    xvld $xr0, $a1, 0
; CHECK-NEXT:    xvst $xr0, $a0, 0
; CHECK-NEXT:    ret
entry:
  store <8 x float> <float 0.0, float 1.0, float 2.0, float 3.0, float 4.0, float 5.0, float 6.0, float 7.0>, ptr %dst
  ret void
}

define void @buildvector_v4f64_const(ptr %dst) nounwind {
; CHECK-LABEL: buildvector_v4f64_const:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    pcalau12i $a1, %pc_hi20(.LCPI17_0)
; CHECK-NEXT:    addi.d $a1, $a1, %pc_lo12(.LCPI17_0)
; CHECK-NEXT:    xvld $xr0, $a1, 0
; CHECK-NEXT:    xvst $xr0, $a0, 0
; CHECK-NEXT:    ret
entry:
  store <4 x double> <double 0.0, double 1.0, double 2.0, double 3.0>, ptr %dst
  ret void
}

define void @buildvector_v32i8(ptr %dst, i8 %a0, i8 %a1, i8 %a2, i8 %a3, i8 %a4, i8 %a5, i8 %a6, i8 %a7, i8 %a8, i8 %a9, i8 %a10, i8 %a11, i8 %a12, i8 %a13, i8 %a14, i8 %a15, i8 %a16, i8 %a17, i8 %a18, i8 %a19, i8 %a20, i8 %a21, i8 %a22, i8 %a23, i8 %a24, i8 %a25, i8 %a26, i8 %a27, i8 %a28, i8 %a29, i8 %a30, i8 %a31) nounwind {
; CHECK-LABEL: buildvector_v32i8:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    vinsgr2vr.b $vr0, $a1, 0
; CHECK-NEXT:    vinsgr2vr.b $vr0, $a2, 1
; CHECK-NEXT:    vinsgr2vr.b $vr0, $a3, 2
; CHECK-NEXT:    vinsgr2vr.b $vr0, $a4, 3
; CHECK-NEXT:    vinsgr2vr.b $vr0, $a5, 4
; CHECK-NEXT:    vinsgr2vr.b $vr0, $a6, 5
; CHECK-NEXT:    vinsgr2vr.b $vr0, $a7, 6
; CHECK-NEXT:    ld.b $a1, $sp, 0
; CHECK-NEXT:    vinsgr2vr.b $vr0, $a1, 7
; CHECK-NEXT:    ld.b $a1, $sp, 8
; CHECK-NEXT:    vinsgr2vr.b $vr0, $a1, 8
; CHECK-NEXT:    ld.b $a1, $sp, 16
; CHECK-NEXT:    vinsgr2vr.b $vr0, $a1, 9
; CHECK-NEXT:    ld.b $a1, $sp, 24
; CHECK-NEXT:    vinsgr2vr.b $vr0, $a1, 10
; CHECK-NEXT:    ld.b $a1, $sp, 32
; CHECK-NEXT:    vinsgr2vr.b $vr0, $a1, 11
; CHECK-NEXT:    ld.b $a1, $sp, 40
; CHECK-NEXT:    vinsgr2vr.b $vr0, $a1, 12
; CHECK-NEXT:    ld.b $a1, $sp, 48
; CHECK-NEXT:    vinsgr2vr.b $vr0, $a1, 13
; CHECK-NEXT:    ld.b $a1, $sp, 56
; CHECK-NEXT:    vinsgr2vr.b $vr0, $a1, 14
; CHECK-NEXT:    ld.b $a1, $sp, 64
; CHECK-NEXT:    vinsgr2vr.b $vr0, $a1, 15
; CHECK-NEXT:    ld.b $a1, $sp, 72
; CHECK-NEXT:    xvori.b $xr1, $xr0, 0
; CHECK-NEXT:    xvpermi.q $xr1, $xr0, 1
; CHECK-NEXT:    vinsgr2vr.b $vr1, $a1, 0
; CHECK-NEXT:    xvpermi.q $xr0, $xr1, 2
; CHECK-NEXT:    ld.b $a1, $sp, 80
; CHECK-NEXT:    xvori.b $xr1, $xr0, 0
; CHECK-NEXT:    xvpermi.q $xr1, $xr0, 1
; CHECK-NEXT:    vinsgr2vr.b $vr1, $a1, 1
; CHECK-NEXT:    xvpermi.q $xr0, $xr1, 2
; CHECK-NEXT:    ld.b $a1, $sp, 88
; CHECK-NEXT:    xvori.b $xr1, $xr0, 0
; CHECK-NEXT:    xvpermi.q $xr1, $xr0, 1
; CHECK-NEXT:    vinsgr2vr.b $vr1, $a1, 2
; CHECK-NEXT:    xvpermi.q $xr0, $xr1, 2
; CHECK-NEXT:    ld.b $a1, $sp, 96
; CHECK-NEXT:    xvori.b $xr1, $xr0, 0
; CHECK-NEXT:    xvpermi.q $xr1, $xr0, 1
; CHECK-NEXT:    vinsgr2vr.b $vr1, $a1, 3
; CHECK-NEXT:    xvpermi.q $xr0, $xr1, 2
; CHECK-NEXT:    ld.b $a1, $sp, 104
; CHECK-NEXT:    xvori.b $xr1, $xr0, 0
; CHECK-NEXT:    xvpermi.q $xr1, $xr0, 1
; CHECK-NEXT:    vinsgr2vr.b $vr1, $a1, 4
; CHECK-NEXT:    xvpermi.q $xr0, $xr1, 2
; CHECK-NEXT:    ld.b $a1, $sp, 112
; CHECK-NEXT:    xvori.b $xr1, $xr0, 0
; CHECK-NEXT:    xvpermi.q $xr1, $xr0, 1
; CHECK-NEXT:    vinsgr2vr.b $vr1, $a1, 5
; CHECK-NEXT:    xvpermi.q $xr0, $xr1, 2
; CHECK-NEXT:    ld.b $a1, $sp, 120
; CHECK-NEXT:    xvori.b $xr1, $xr0, 0
; CHECK-NEXT:    xvpermi.q $xr1, $xr0, 1
; CHECK-NEXT:    vinsgr2vr.b $vr1, $a1, 6
; CHECK-NEXT:    xvpermi.q $xr0, $xr1, 2
; CHECK-NEXT:    ld.b $a1, $sp, 128
; CHECK-NEXT:    xvori.b $xr1, $xr0, 0
; CHECK-NEXT:    xvpermi.q $xr1, $xr0, 1
; CHECK-NEXT:    vinsgr2vr.b $vr1, $a1, 7
; CHECK-NEXT:    xvpermi.q $xr0, $xr1, 2
; CHECK-NEXT:    ld.b $a1, $sp, 136
; CHECK-NEXT:    xvori.b $xr1, $xr0, 0
; CHECK-NEXT:    xvpermi.q $xr1, $xr0, 1
; CHECK-NEXT:    vinsgr2vr.b $vr1, $a1, 8
; CHECK-NEXT:    xvpermi.q $xr0, $xr1, 2
; CHECK-NEXT:    ld.b $a1, $sp, 144
; CHECK-NEXT:    xvori.b $xr1, $xr0, 0
; CHECK-NEXT:    xvpermi.q $xr1, $xr0, 1
; CHECK-NEXT:    vinsgr2vr.b $vr1, $a1, 9
; CHECK-NEXT:    xvpermi.q $xr0, $xr1, 2
; CHECK-NEXT:    ld.b $a1, $sp, 152
; CHECK-NEXT:    xvori.b $xr1, $xr0, 0
; CHECK-NEXT:    xvpermi.q $xr1, $xr0, 1
; CHECK-NEXT:    vinsgr2vr.b $vr1, $a1, 10
; CHECK-NEXT:    xvpermi.q $xr0, $xr1, 2
; CHECK-NEXT:    ld.b $a1, $sp, 160
; CHECK-NEXT:    xvori.b $xr1, $xr0, 0
; CHECK-NEXT:    xvpermi.q $xr1, $xr0, 1
; CHECK-NEXT:    vinsgr2vr.b $vr1, $a1, 11
; CHECK-NEXT:    xvpermi.q $xr0, $xr1, 2
; CHECK-NEXT:    ld.b $a1, $sp, 168
; CHECK-NEXT:    xvori.b $xr1, $xr0, 0
; CHECK-NEXT:    xvpermi.q $xr1, $xr0, 1
; CHECK-NEXT:    vinsgr2vr.b $vr1, $a1, 12
; CHECK-NEXT:    xvpermi.q $xr0, $xr1, 2
; CHECK-NEXT:    ld.b $a1, $sp, 176
; CHECK-NEXT:    xvori.b $xr1, $xr0, 0
; CHECK-NEXT:    xvpermi.q $xr1, $xr0, 1
; CHECK-NEXT:    vinsgr2vr.b $vr1, $a1, 13
; CHECK-NEXT:    xvpermi.q $xr0, $xr1, 2
; CHECK-NEXT:    ld.b $a1, $sp, 184
; CHECK-NEXT:    xvori.b $xr1, $xr0, 0
; CHECK-NEXT:    xvpermi.q $xr1, $xr0, 1
; CHECK-NEXT:    vinsgr2vr.b $vr1, $a1, 14
; CHECK-NEXT:    xvpermi.q $xr0, $xr1, 2
; CHECK-NEXT:    ld.b $a1, $sp, 192
; CHECK-NEXT:    xvori.b $xr1, $xr0, 0
; CHECK-NEXT:    xvpermi.q $xr1, $xr0, 1
; CHECK-NEXT:    vinsgr2vr.b $vr1, $a1, 15
; CHECK-NEXT:    xvpermi.q $xr0, $xr1, 2
; CHECK-NEXT:    xvst $xr0, $a0, 0
; CHECK-NEXT:    ret
entry:
  %ins0  = insertelement <32 x i8> undef,  i8 %a0,  i32 0
  %ins1  = insertelement <32 x i8> %ins0,  i8 %a1,  i32 1
  %ins2  = insertelement <32 x i8> %ins1,  i8 %a2,  i32 2
  %ins3  = insertelement <32 x i8> %ins2,  i8 %a3,  i32 3
  %ins4  = insertelement <32 x i8> %ins3,  i8 %a4,  i32 4
  %ins5  = insertelement <32 x i8> %ins4,  i8 %a5,  i32 5
  %ins6  = insertelement <32 x i8> %ins5,  i8 %a6,  i32 6
  %ins7  = insertelement <32 x i8> %ins6,  i8 %a7,  i32 7
  %ins8  = insertelement <32 x i8> %ins7,  i8 %a8,  i32 8
  %ins9  = insertelement <32 x i8> %ins8,  i8 %a9,  i32 9
  %ins10 = insertelement <32 x i8> %ins9,  i8 %a10, i32 10
  %ins11 = insertelement <32 x i8> %ins10, i8 %a11, i32 11
  %ins12 = insertelement <32 x i8> %ins11, i8 %a12, i32 12
  %ins13 = insertelement <32 x i8> %ins12, i8 %a13, i32 13
  %ins14 = insertelement <32 x i8> %ins13, i8 %a14, i32 14
  %ins15 = insertelement <32 x i8> %ins14, i8 %a15, i32 15
  %ins16 = insertelement <32 x i8> %ins15, i8 %a16, i32 16
  %ins17 = insertelement <32 x i8> %ins16, i8 %a17, i32 17
  %ins18 = insertelement <32 x i8> %ins17, i8 %a18, i32 18
  %ins19 = insertelement <32 x i8> %ins18, i8 %a19, i32 19
  %ins20 = insertelement <32 x i8> %ins19, i8 %a20, i32 20
  %ins21 = insertelement <32 x i8> %ins20, i8 %a21, i32 21
  %ins22 = insertelement <32 x i8> %ins21, i8 %a22, i32 22
  %ins23 = insertelement <32 x i8> %ins22, i8 %a23, i32 23
  %ins24 = insertelement <32 x i8> %ins23, i8 %a24, i32 24
  %ins25 = insertelement <32 x i8> %ins24, i8 %a25, i32 25
  %ins26 = insertelement <32 x i8> %ins25, i8 %a26, i32 26
  %ins27 = insertelement <32 x i8> %ins26, i8 %a27, i32 27
  %ins28 = insertelement <32 x i8> %ins27, i8 %a28, i32 28
  %ins29 = insertelement <32 x i8> %ins28, i8 %a29, i32 29
  %ins30 = insertelement <32 x i8> %ins29, i8 %a30, i32 30
  %ins31 = insertelement <32 x i8> %ins30, i8 %a31, i32 31
  store <32 x i8> %ins31, ptr %dst
  ret void
}

define void @buildvector_v16i16(ptr %dst, i16 %a0, i16 %a1, i16 %a2, i16 %a3, i16 %a4, i16 %a5, i16 %a6, i16 %a7, i16 %a8, i16 %a9, i16 %a10, i16 %a11, i16 %a12, i16 %a13, i16 %a14, i16 %a15) nounwind {
; CHECK-LABEL: buildvector_v16i16:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    vinsgr2vr.h $vr0, $a1, 0
; CHECK-NEXT:    vinsgr2vr.h $vr0, $a2, 1
; CHECK-NEXT:    vinsgr2vr.h $vr0, $a3, 2
; CHECK-NEXT:    vinsgr2vr.h $vr0, $a4, 3
; CHECK-NEXT:    vinsgr2vr.h $vr0, $a5, 4
; CHECK-NEXT:    vinsgr2vr.h $vr0, $a6, 5
; CHECK-NEXT:    vinsgr2vr.h $vr0, $a7, 6
; CHECK-NEXT:    ld.h $a1, $sp, 0
; CHECK-NEXT:    vinsgr2vr.h $vr0, $a1, 7
; CHECK-NEXT:    ld.h $a1, $sp, 8
; CHECK-NEXT:    xvori.b $xr1, $xr0, 0
; CHECK-NEXT:    xvpermi.q $xr1, $xr0, 1
; CHECK-NEXT:    vinsgr2vr.h $vr1, $a1, 0
; CHECK-NEXT:    xvpermi.q $xr0, $xr1, 2
; CHECK-NEXT:    ld.h $a1, $sp, 16
; CHECK-NEXT:    xvori.b $xr1, $xr0, 0
; CHECK-NEXT:    xvpermi.q $xr1, $xr0, 1
; CHECK-NEXT:    vinsgr2vr.h $vr1, $a1, 1
; CHECK-NEXT:    xvpermi.q $xr0, $xr1, 2
; CHECK-NEXT:    ld.h $a1, $sp, 24
; CHECK-NEXT:    xvori.b $xr1, $xr0, 0
; CHECK-NEXT:    xvpermi.q $xr1, $xr0, 1
; CHECK-NEXT:    vinsgr2vr.h $vr1, $a1, 2
; CHECK-NEXT:    xvpermi.q $xr0, $xr1, 2
; CHECK-NEXT:    ld.h $a1, $sp, 32
; CHECK-NEXT:    xvori.b $xr1, $xr0, 0
; CHECK-NEXT:    xvpermi.q $xr1, $xr0, 1
; CHECK-NEXT:    vinsgr2vr.h $vr1, $a1, 3
; CHECK-NEXT:    xvpermi.q $xr0, $xr1, 2
; CHECK-NEXT:    ld.h $a1, $sp, 40
; CHECK-NEXT:    xvori.b $xr1, $xr0, 0
; CHECK-NEXT:    xvpermi.q $xr1, $xr0, 1
; CHECK-NEXT:    vinsgr2vr.h $vr1, $a1, 4
; CHECK-NEXT:    xvpermi.q $xr0, $xr1, 2
; CHECK-NEXT:    ld.h $a1, $sp, 48
; CHECK-NEXT:    xvori.b $xr1, $xr0, 0
; CHECK-NEXT:    xvpermi.q $xr1, $xr0, 1
; CHECK-NEXT:    vinsgr2vr.h $vr1, $a1, 5
; CHECK-NEXT:    xvpermi.q $xr0, $xr1, 2
; CHECK-NEXT:    ld.h $a1, $sp, 56
; CHECK-NEXT:    xvori.b $xr1, $xr0, 0
; CHECK-NEXT:    xvpermi.q $xr1, $xr0, 1
; CHECK-NEXT:    vinsgr2vr.h $vr1, $a1, 6
; CHECK-NEXT:    xvpermi.q $xr0, $xr1, 2
; CHECK-NEXT:    ld.h $a1, $sp, 64
; CHECK-NEXT:    xvori.b $xr1, $xr0, 0
; CHECK-NEXT:    xvpermi.q $xr1, $xr0, 1
; CHECK-NEXT:    vinsgr2vr.h $vr1, $a1, 7
; CHECK-NEXT:    xvpermi.q $xr0, $xr1, 2
; CHECK-NEXT:    xvst $xr0, $a0, 0
; CHECK-NEXT:    ret
entry:
  %ins0  = insertelement <16 x i16> undef,  i16 %a0,  i32 0
  %ins1  = insertelement <16 x i16> %ins0,  i16 %a1,  i32 1
  %ins2  = insertelement <16 x i16> %ins1,  i16 %a2,  i32 2
  %ins3  = insertelement <16 x i16> %ins2,  i16 %a3,  i32 3
  %ins4  = insertelement <16 x i16> %ins3,  i16 %a4,  i32 4
  %ins5  = insertelement <16 x i16> %ins4,  i16 %a5,  i32 5
  %ins6  = insertelement <16 x i16> %ins5,  i16 %a6,  i32 6
  %ins7  = insertelement <16 x i16> %ins6,  i16 %a7,  i32 7
  %ins8  = insertelement <16 x i16> %ins7,  i16 %a8,  i32 8
  %ins9  = insertelement <16 x i16> %ins8,  i16 %a9,  i32 9
  %ins10 = insertelement <16 x i16> %ins9,  i16 %a10, i32 10
  %ins11 = insertelement <16 x i16> %ins10, i16 %a11, i32 11
  %ins12 = insertelement <16 x i16> %ins11, i16 %a12, i32 12
  %ins13 = insertelement <16 x i16> %ins12, i16 %a13, i32 13
  %ins14 = insertelement <16 x i16> %ins13, i16 %a14, i32 14
  %ins15 = insertelement <16 x i16> %ins14, i16 %a15, i32 15
  store <16 x i16> %ins15, ptr %dst
  ret void
}

define void @buildvector_v8i32(ptr %dst, i32 %a0, i32 %a1, i32 %a2, i32 %a3, i32 %a4, i32 %a5, i32 %a6, i32 %a7) nounwind {
; CHECK-LABEL: buildvector_v8i32:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    xvinsgr2vr.w $xr0, $a1, 0
; CHECK-NEXT:    xvinsgr2vr.w $xr0, $a2, 1
; CHECK-NEXT:    xvinsgr2vr.w $xr0, $a3, 2
; CHECK-NEXT:    xvinsgr2vr.w $xr0, $a4, 3
; CHECK-NEXT:    xvinsgr2vr.w $xr0, $a5, 4
; CHECK-NEXT:    xvinsgr2vr.w $xr0, $a6, 5
; CHECK-NEXT:    xvinsgr2vr.w $xr0, $a7, 6
; CHECK-NEXT:    ld.w $a1, $sp, 0
; CHECK-NEXT:    xvinsgr2vr.w $xr0, $a1, 7
; CHECK-NEXT:    xvst $xr0, $a0, 0
; CHECK-NEXT:    ret
entry:
  %ins0 = insertelement <8 x i32> undef, i32 %a0, i32 0
  %ins1 = insertelement <8 x i32> %ins0, i32 %a1, i32 1
  %ins2 = insertelement <8 x i32> %ins1, i32 %a2, i32 2
  %ins3 = insertelement <8 x i32> %ins2, i32 %a3, i32 3
  %ins4 = insertelement <8 x i32> %ins3, i32 %a4, i32 4
  %ins5 = insertelement <8 x i32> %ins4, i32 %a5, i32 5
  %ins6 = insertelement <8 x i32> %ins5, i32 %a6, i32 6
  %ins7 = insertelement <8 x i32> %ins6, i32 %a7, i32 7
  store <8 x i32> %ins7, ptr %dst
  ret void
}

define void @buildvector_v4i64(ptr %dst, i64 %a0, i64 %a1, i64 %a2, i64 %a3) nounwind {
; CHECK-LABEL: buildvector_v4i64:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    xvinsgr2vr.d $xr0, $a1, 0
; CHECK-NEXT:    xvinsgr2vr.d $xr0, $a2, 1
; CHECK-NEXT:    xvinsgr2vr.d $xr0, $a3, 2
; CHECK-NEXT:    xvinsgr2vr.d $xr0, $a4, 3
; CHECK-NEXT:    xvst $xr0, $a0, 0
; CHECK-NEXT:    ret
entry:
  %ins0 = insertelement <4 x i64> undef, i64 %a0, i32 0
  %ins1 = insertelement <4 x i64> %ins0, i64 %a1, i32 1
  %ins2 = insertelement <4 x i64> %ins1, i64 %a2, i32 2
  %ins3 = insertelement <4 x i64> %ins2, i64 %a3, i32 3
  store <4 x i64> %ins3, ptr %dst
  ret void
}

define void @buildvector_v8f32(ptr %dst, float %a0, float %a1, float %a2, float %a3, float %a4, float %a5, float %a6, float %a7) nounwind {
; CHECK-LABEL: buildvector_v8f32:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    movfr2gr.s $a1, $fa0
; CHECK-NEXT:    xvinsgr2vr.w $xr0, $a1, 0
; CHECK-NEXT:    movfr2gr.s $a1, $fa1
; CHECK-NEXT:    xvinsgr2vr.w $xr0, $a1, 1
; CHECK-NEXT:    movfr2gr.s $a1, $fa2
; CHECK-NEXT:    xvinsgr2vr.w $xr0, $a1, 2
; CHECK-NEXT:    movfr2gr.s $a1, $fa3
; CHECK-NEXT:    xvinsgr2vr.w $xr0, $a1, 3
; CHECK-NEXT:    movfr2gr.s $a1, $fa4
; CHECK-NEXT:    xvinsgr2vr.w $xr0, $a1, 4
; CHECK-NEXT:    movfr2gr.s $a1, $fa5
; CHECK-NEXT:    xvinsgr2vr.w $xr0, $a1, 5
; CHECK-NEXT:    movfr2gr.s $a1, $fa6
; CHECK-NEXT:    xvinsgr2vr.w $xr0, $a1, 6
; CHECK-NEXT:    movfr2gr.s $a1, $fa7
; CHECK-NEXT:    xvinsgr2vr.w $xr0, $a1, 7
; CHECK-NEXT:    xvst $xr0, $a0, 0
; CHECK-NEXT:    ret
entry:
  %ins0 = insertelement <8 x float> undef, float %a0, i32 0
  %ins1 = insertelement <8 x float> %ins0, float %a1, i32 1
  %ins2 = insertelement <8 x float> %ins1, float %a2, i32 2
  %ins3 = insertelement <8 x float> %ins2, float %a3, i32 3
  %ins4 = insertelement <8 x float> %ins3, float %a4, i32 4
  %ins5 = insertelement <8 x float> %ins4, float %a5, i32 5
  %ins6 = insertelement <8 x float> %ins5, float %a6, i32 6
  %ins7 = insertelement <8 x float> %ins6, float %a7, i32 7
  store <8 x float> %ins7, ptr %dst
  ret void
}

define void @buildvector_v4f64(ptr %dst, double %a0, double %a1, double %a2, double %a3) nounwind {
; CHECK-LABEL: buildvector_v4f64:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    movfr2gr.d $a1, $fa0
; CHECK-NEXT:    xvinsgr2vr.d $xr0, $a1, 0
; CHECK-NEXT:    movfr2gr.d $a1, $fa1
; CHECK-NEXT:    xvinsgr2vr.d $xr0, $a1, 1
; CHECK-NEXT:    movfr2gr.d $a1, $fa2
; CHECK-NEXT:    xvinsgr2vr.d $xr0, $a1, 2
; CHECK-NEXT:    movfr2gr.d $a1, $fa3
; CHECK-NEXT:    xvinsgr2vr.d $xr0, $a1, 3
; CHECK-NEXT:    xvst $xr0, $a0, 0
; CHECK-NEXT:    ret
entry:
  %ins0 = insertelement <4 x double> undef, double %a0, i32 0
  %ins1 = insertelement <4 x double> %ins0, double %a1, i32 1
  %ins2 = insertelement <4 x double> %ins1, double %a2, i32 2
  %ins3 = insertelement <4 x double> %ins2, double %a3, i32 3
  store <4 x double> %ins3, ptr %dst
  ret void
}