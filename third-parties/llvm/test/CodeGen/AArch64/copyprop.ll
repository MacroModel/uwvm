; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -O3 -mtriple=aarch64-- | FileCheck %s

define void @copyprop_after_mbp(i32 %v, ptr %a, ptr %b, ptr %c, ptr %d) {
; CHECK-LABEL: copyprop_after_mbp:
; CHECK:       // %bb.0:
; CHECK-NEXT:    cmp w0, #10
; CHECK-NEXT:    b.ne .LBB0_2
; CHECK-NEXT:  // %bb.1: // %bb.0
; CHECK-NEXT:    mov w8, #15 // =0xf
; CHECK-NEXT:    str w8, [x2]
; CHECK-NEXT:    mov w8, #1 // =0x1
; CHECK-NEXT:    str w8, [x1]
; CHECK-NEXT:    mov w8, #12 // =0xc
; CHECK-NEXT:    str w8, [x4]
; CHECK-NEXT:    ret
; CHECK-NEXT:  .LBB0_2: // %bb.1
; CHECK-NEXT:    mov w9, #25 // =0x19
; CHECK-NEXT:    str w9, [x3]
; CHECK-NEXT:    str wzr, [x1]
; CHECK-NEXT:    mov w8, #12 // =0xc
; CHECK-NEXT:    str w8, [x4]
; CHECK-NEXT:    ret
  %1 = icmp eq i32 %v, 10
  br i1 %1, label %bb.0, label %bb.1

bb.0:
  store i32 15, ptr %b, align 4
  br label %bb.2

bb.1:
  store i32 25, ptr %c, align 4
  br label %bb.2

bb.2:
  %2 = phi i32 [ 1, %bb.0 ], [ 0, %bb.1 ]
  store i32 %2, ptr %a, align 4
  store i32 12, ptr %d, align 4
  ret void
}