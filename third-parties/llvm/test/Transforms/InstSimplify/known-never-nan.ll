; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -S -passes=instsimplify | FileCheck %s

declare double @func()

define i1 @nnan_call() {
; CHECK-LABEL: @nnan_call(
; CHECK-NEXT:    [[OP:%.*]] = call nnan double @func()
; CHECK-NEXT:    ret i1 true
;
  %op = call nnan double @func()
  %tmp = fcmp ord double %op, %op
  ret i1 %tmp
}

define i1 @nnan_fabs_src(double %arg) {
; CHECK-LABEL: @nnan_fabs_src(
; CHECK-NEXT:    ret i1 false
;
  %nnan = fadd nnan double %arg, 1.0
  %op = call double @llvm.fabs.f64(double %nnan)
  %tmp = fcmp uno double %op, %op
  ret i1 %tmp
}

define i1 @nnan_canonicalize_src(double %arg) {
; CHECK-LABEL: @nnan_canonicalize_src(
; CHECK-NEXT:    ret i1 true
;
  %nnan = fadd nnan double %arg, 1.0
  %op = call double @llvm.canonicalize.f64(double %nnan)
  %tmp = fcmp ord double %op, %op
  ret i1 %tmp
}

define i1 @nnan_copysign_src(double %arg0, double %arg1) {
; CHECK-LABEL: @nnan_copysign_src(
; CHECK-NEXT:    ret i1 false
;
  %nnan = fadd nnan double %arg0, 1.0
  %op = call double @llvm.copysign.f64(double %nnan, double %arg1)
  %tmp = fcmp uno double %op, %op
  ret i1 %tmp
}

define i1 @fabs_sqrt_src(double %arg0, double %arg1) {
; CHECK-LABEL: @fabs_sqrt_src(
; CHECK-NEXT:    ret i1 true
;
  %nnan = fadd nnan double %arg0, 1.0
  %fabs = call double @llvm.fabs.f64(double %nnan)
  %op = call double @llvm.sqrt.f64(double %fabs)
  %tmp = fcmp ord double %op, %op
  ret i1 %tmp
}

define i1 @fabs_sqrt_src_maybe_nan(double %arg0, double %arg1) {
; CHECK-LABEL: @fabs_sqrt_src_maybe_nan(
; CHECK-NEXT:    [[FABS:%.*]] = call double @llvm.fabs.f64(double [[ARG0:%.*]])
; CHECK-NEXT:    [[OP:%.*]] = call double @llvm.sqrt.f64(double [[FABS]])
; CHECK-NEXT:    [[TMP:%.*]] = fcmp uno double [[OP]], [[OP]]
; CHECK-NEXT:    ret i1 [[TMP]]
;
  %fabs = call double @llvm.fabs.f64(double %arg0)
  %op = call double @llvm.sqrt.f64(double %fabs)
  %tmp = fcmp uno double %op, %op
  ret i1 %tmp
}

define i1 @exp_nnan_src(double %arg) {
; CHECK-LABEL: @exp_nnan_src(
; CHECK-NEXT:    ret i1 true
;
  %nnan = fadd nnan double %arg, 1.0
  %op = call double @llvm.exp.f64(double %nnan)
  %tmp = fcmp ord double %op, %op
  ret i1 %tmp
}

define i1 @exp2_nnan_src(double %arg) {
; CHECK-LABEL: @exp2_nnan_src(
; CHECK-NEXT:    ret i1 false
;
  %nnan = fadd nnan double %arg, 1.0
  %op = call double @llvm.exp2.f64(double %nnan)
  %tmp = fcmp uno double %op, %op
  ret i1 %tmp
}

define i1 @floor_nnan_src(double %arg) {
; CHECK-LABEL: @floor_nnan_src(
; CHECK-NEXT:    ret i1 true
;
  %nnan = fadd nnan double %arg, 1.0
  %op = call double @llvm.floor.f64(double %nnan)
  %tmp = fcmp ord double %op, %op
  ret i1 %tmp
}

define i1 @ceil_nnan_src(double %arg) {
; CHECK-LABEL: @ceil_nnan_src(
; CHECK-NEXT:    ret i1 false
;
  %nnan = fadd nnan double %arg, 1.0
  %op = call double @llvm.ceil.f64(double %nnan)
  %tmp = fcmp uno double %op, %op
  ret i1 %tmp
}

define i1 @trunc_nnan_src(double %arg) {
; CHECK-LABEL: @trunc_nnan_src(
; CHECK-NEXT:    ret i1 true
;
  %nnan = fadd nnan double %arg, 1.0
  %op = call double @llvm.trunc.f64(double %nnan)
  %tmp = fcmp ord double %op, %op
  ret i1 %tmp
}

define i1 @rint_nnan_src(double %arg) {
; CHECK-LABEL: @rint_nnan_src(
; CHECK-NEXT:    ret i1 false
;
  %nnan = fadd nnan double %arg, 1.0
  %op = call double @llvm.rint.f64(double %nnan)
  %tmp = fcmp uno double %op, %op
  ret i1 %tmp
}

define i1 @nearbyint_nnan_src(double %arg) {
; CHECK-LABEL: @nearbyint_nnan_src(
; CHECK-NEXT:    ret i1 true
;
  %nnan = fadd nnan double %arg, 1.0
  %op = call double @llvm.nearbyint.f64(double %nnan)
  %tmp = fcmp ord double %op, %op
  ret i1 %tmp
}

define i1 @round_nnan_src(double %arg) {
; CHECK-LABEL: @round_nnan_src(
; CHECK-NEXT:    ret i1 false
;
  %nnan = fadd nnan double %arg, 1.0
  %op = call double @llvm.round.f64(double %nnan)
  %tmp = fcmp uno double %op, %op
  ret i1 %tmp
}

define i1 @roundeven_nnan_src(double %arg) {
; CHECK-LABEL: @roundeven_nnan_src(
; CHECK-NEXT:    ret i1 false
;
  %nnan = fadd nnan double %arg, 1.0
  %op = call double @llvm.roundeven.f64(double %nnan)
  %tmp = fcmp uno double %op, %op
  ret i1 %tmp
}

define i1 @known_nan_select(i1 %cond, double %arg0, double %arg1) {
; CHECK-LABEL: @known_nan_select(
; CHECK-NEXT:    ret i1 true
;
  %lhs = fadd nnan double %arg0, 1.0
  %rhs = fadd nnan double %arg1, 2.0
  %op = select i1 %cond, double %lhs, double %rhs
  %tmp = fcmp ord double %op, %op
  ret i1 %tmp
}

define i1 @nnan_ninf_known_nan_select(i1 %cond, double %arg0, double %arg1) {
; CHECK-LABEL: @nnan_ninf_known_nan_select(
; CHECK-NEXT:    ret i1 true
;
  %lhs = fadd nnan ninf double %arg0, 1.0
  %rhs = fadd nnan ninf double %arg1, 2.0
  %op = select i1 %cond, double %lhs, double %rhs
  %mul = fmul double %op, 2.0
  %tmp = fcmp ord double %mul, %mul
  ret i1 %tmp
}

define i1 @select_maybe_nan_lhs(i1 %cond, double %lhs, double %arg1) {
; CHECK-LABEL: @select_maybe_nan_lhs(
; CHECK-NEXT:    [[RHS:%.*]] = fadd nnan double [[ARG1:%.*]], 1.000000e+00
; CHECK-NEXT:    [[OP:%.*]] = select i1 [[COND:%.*]], double [[LHS:%.*]], double [[RHS]]
; CHECK-NEXT:    [[TMP:%.*]] = fcmp uno double [[OP]], [[OP]]
; CHECK-NEXT:    ret i1 [[TMP]]
;
  %rhs = fadd nnan double %arg1, 1.0
  %op = select i1 %cond, double %lhs, double %rhs
  %tmp = fcmp uno double %op, %op
  ret i1 %tmp
}

define i1 @select_maybe_nan_rhs(i1 %cond, double %arg0, double %rhs) {
; CHECK-LABEL: @select_maybe_nan_rhs(
; CHECK-NEXT:    [[LHS:%.*]] = fadd nnan double [[ARG0:%.*]], 1.000000e+00
; CHECK-NEXT:    [[OP:%.*]] = select i1 [[COND:%.*]], double [[LHS]], double [[RHS:%.*]]
; CHECK-NEXT:    [[TMP:%.*]] = fcmp ord double [[OP]], [[OP]]
; CHECK-NEXT:    ret i1 [[TMP]]
;
  %lhs = fadd nnan double %arg0, 1.0
  %op = select i1 %cond, double %lhs, double %rhs
  %tmp = fcmp ord double %op, %op
  ret i1 %tmp
}

define i1 @nnan_fadd(double %arg0, double %arg1) {
; CHECK-LABEL: @nnan_fadd(
; CHECK-NEXT:    [[NNAN_ARG0:%.*]] = fadd nnan double [[ARG0:%.*]], 1.000000e+00
; CHECK-NEXT:    [[NNAN_ARG1:%.*]] = fadd nnan double [[ARG0]], 2.000000e+00
; CHECK-NEXT:    [[OP:%.*]] = fadd double [[NNAN_ARG0]], [[NNAN_ARG1]]
; CHECK-NEXT:    [[TMP:%.*]] = fcmp uno double [[OP]], [[OP]]
; CHECK-NEXT:    ret i1 [[TMP]]
;
  %nnan.arg0 = fadd nnan double %arg0, 1.0
  %nnan.arg1 = fadd nnan double %arg0, 2.0
  %op = fadd double %nnan.arg0, %nnan.arg1
  %tmp = fcmp uno double %op, %op
  ret i1 %tmp
}

define i1 @nnan_fadd_maybe_nan_lhs(double %arg0, double %arg1) {
; CHECK-LABEL: @nnan_fadd_maybe_nan_lhs(
; CHECK-NEXT:    [[NNAN_ARG1:%.*]] = fadd nnan double [[ARG1:%.*]], 1.000000e+00
; CHECK-NEXT:    [[OP:%.*]] = fadd double [[ARG0:%.*]], [[NNAN_ARG1]]
; CHECK-NEXT:    [[TMP:%.*]] = fcmp ord double [[OP]], [[OP]]
; CHECK-NEXT:    ret i1 [[TMP]]
;
  %nnan.arg1 = fadd nnan double %arg1, 1.0
  %op = fadd double %arg0, %nnan.arg1
  %tmp = fcmp ord double %op, %op
  ret i1 %tmp
}

define i1 @nnan_fadd_maybe_nan_rhs(double %arg0, double %arg1) {
; CHECK-LABEL: @nnan_fadd_maybe_nan_rhs(
; CHECK-NEXT:    [[NNAN_ARG0:%.*]] = fadd nnan double [[ARG0:%.*]], 1.000000e+00
; CHECK-NEXT:    [[OP:%.*]] = fadd double [[NNAN_ARG0]], [[ARG1:%.*]]
; CHECK-NEXT:    [[TMP:%.*]] = fcmp uno double [[OP]], [[OP]]
; CHECK-NEXT:    ret i1 [[TMP]]
;
  %nnan.arg0 = fadd nnan double %arg0, 1.0
  %op = fadd double %nnan.arg0, %arg1
  %tmp = fcmp uno double %op, %op
  ret i1 %tmp
}

define i1 @nnan_fmul(double %arg0, double %arg1) {
; CHECK-LABEL: @nnan_fmul(
; CHECK-NEXT:    [[NNAN_ARG0:%.*]] = fadd nnan double [[ARG0:%.*]], 1.000000e+00
; CHECK-NEXT:    [[NNAN_ARG1:%.*]] = fadd nnan double [[ARG0]], 2.000000e+00
; CHECK-NEXT:    [[OP:%.*]] = fmul double [[NNAN_ARG0]], [[NNAN_ARG1]]
; CHECK-NEXT:    [[TMP:%.*]] = fcmp ord double [[OP]], [[OP]]
; CHECK-NEXT:    ret i1 [[TMP]]
;
  %nnan.arg0 = fadd nnan double %arg0, 1.0
  %nnan.arg1 = fadd nnan double %arg0, 2.0
  %op = fmul double %nnan.arg0, %nnan.arg1
  %tmp = fcmp ord double %op, %op
  ret i1 %tmp
}

define i1 @nnan_fsub(double %arg0, double %arg1) {
; CHECK-LABEL: @nnan_fsub(
; CHECK-NEXT:    [[NNAN_ARG0:%.*]] = fadd nnan double [[ARG0:%.*]], 1.000000e+00
; CHECK-NEXT:    [[NNAN_ARG1:%.*]] = fadd nnan double [[ARG0]], 2.000000e+00
; CHECK-NEXT:    [[OP:%.*]] = fsub double [[NNAN_ARG0]], [[NNAN_ARG1]]
; CHECK-NEXT:    [[TMP:%.*]] = fcmp uno double [[OP]], [[OP]]
; CHECK-NEXT:    ret i1 [[TMP]]
;
  %nnan.arg0 = fadd nnan double %arg0, 1.0
  %nnan.arg1 = fadd nnan double %arg0, 2.0
  %op = fsub double %nnan.arg0, %nnan.arg1
  %tmp = fcmp uno double %op, %op
  ret i1 %tmp
}

define i1 @nnan_binary_fneg() {
; CHECK-LABEL: @nnan_binary_fneg(
; CHECK-NEXT:    [[NNAN:%.*]] = call nnan double @func()
; CHECK-NEXT:    ret i1 true
;
  %nnan = call nnan double @func()
  %op = fsub double -0.0, %nnan
  %tmp = fcmp ord double %op, %op
  ret i1 %tmp
}

define i1 @nnan_unary_fneg() {
; CHECK-LABEL: @nnan_unary_fneg(
; CHECK-NEXT:    [[NNAN:%.*]] = call nnan double @func()
; CHECK-NEXT:    ret i1 true
;
  %nnan = call nnan double @func()
  %op = fneg double %nnan
  %tmp = fcmp ord double %op, %op
  ret i1 %tmp
}

define i1 @isNotKnownNeverNaN_fneg(double %x) {
; CHECK-LABEL: @isNotKnownNeverNaN_fneg(
; CHECK-NEXT:    [[NEG:%.*]] = fneg double [[X:%.*]]
; CHECK-NEXT:    [[CMP:%.*]] = fcmp ord double [[NEG]], [[NEG]]
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %neg = fneg double %x
  %cmp = fcmp ord double %neg, %neg
  ret i1 %cmp
}

define i1 @sitofp(i32 %arg0) {
; CHECK-LABEL: @sitofp(
; CHECK-NEXT:    ret i1 false
;
  %op = sitofp i32 %arg0 to double
  %tmp = fcmp uno double %op, %op
  ret i1 %tmp
}

define i1 @uitofp(i32 %arg0) {
; CHECK-LABEL: @uitofp(
; CHECK-NEXT:    ret i1 true
;
  %op = uitofp i32 %arg0 to double
  %tmp = fcmp ord double %op, %op
  ret i1 %tmp
}

define i1 @uitofp_add(i32 %arg0) {
; CHECK-LABEL: @uitofp_add(
; CHECK-NEXT:    ret i1 true
;
  %op = uitofp i32 %arg0 to double
  %add = fadd double %op, %op
  %tmp = fcmp ord double %add, %add
  ret i1 %tmp
}

define i1 @uitofp_add_big(i1024 %arg0) {
; CHECK-LABEL: @uitofp_add_big(
; CHECK-NEXT:    [[OP:%.*]] = uitofp i1024 [[ARG0:%.*]] to double
; CHECK-NEXT:    [[ADD:%.*]] = fadd double [[OP]], [[OP]]
; CHECK-NEXT:    [[TMP:%.*]] = fcmp ord double [[ADD]], [[ADD]]
; CHECK-NEXT:    ret i1 [[TMP]]
;
  %op = uitofp i1024 %arg0 to double
  %add = fadd double %op, %op
  %tmp = fcmp ord double %add, %add
  ret i1 %tmp
}

define i1 @fpext(float %arg0) {
; CHECK-LABEL: @fpext(
; CHECK-NEXT:    ret i1 false
;
  %arg0.nnan = fadd nnan float %arg0, 1.0
  %op = fpext float %arg0.nnan to double
  %tmp = fcmp uno double %op, %op
  ret i1 %tmp
}

define i1 @fpext_maybe_nan(float %arg0) {
; CHECK-LABEL: @fpext_maybe_nan(
; CHECK-NEXT:    [[OP:%.*]] = fpext float [[ARG0:%.*]] to double
; CHECK-NEXT:    [[TMP:%.*]] = fcmp ord double [[OP]], [[OP]]
; CHECK-NEXT:    ret i1 [[TMP]]
;
  %op = fpext float %arg0 to double
  %tmp = fcmp ord double %op, %op
  ret i1 %tmp
}

define i1 @fptrunc(double %arg0) {
; CHECK-LABEL: @fptrunc(
; CHECK-NEXT:    ret i1 false
;
  %arg0.nnan = fadd nnan double %arg0, 1.0
  %op = fptrunc double %arg0.nnan to float
  %tmp = fcmp uno float %op, %op
  ret i1 %tmp
}

define i1 @fptrunc_maybe_nan(double %arg0) {
; CHECK-LABEL: @fptrunc_maybe_nan(
; CHECK-NEXT:    [[OP:%.*]] = fptrunc double [[ARG0:%.*]] to float
; CHECK-NEXT:    [[TMP:%.*]] = fcmp ord float [[OP]], [[OP]]
; CHECK-NEXT:    ret i1 [[TMP]]
;
  %op = fptrunc double %arg0 to float
  %tmp = fcmp ord float %op, %op
  ret i1 %tmp
}

define i1 @nnan_fdiv(double %arg0, double %arg1) {
; CHECK-LABEL: @nnan_fdiv(
; CHECK-NEXT:    [[NNAN_ARG0:%.*]] = fadd nnan double [[ARG0:%.*]], 1.000000e+00
; CHECK-NEXT:    [[NNAN_ARG1:%.*]] = fadd nnan double [[ARG0]], 2.000000e+00
; CHECK-NEXT:    [[OP:%.*]] = fdiv double [[NNAN_ARG0]], [[NNAN_ARG1]]
; CHECK-NEXT:    [[TMP:%.*]] = fcmp uno double [[OP]], [[OP]]
; CHECK-NEXT:    ret i1 [[TMP]]
;
  %nnan.arg0 = fadd nnan double %arg0, 1.0
  %nnan.arg1 = fadd nnan double %arg0, 2.0
  %op = fdiv double %nnan.arg0, %nnan.arg1
  %tmp = fcmp uno double %op, %op
  ret i1 %tmp
}

define i1 @nnan_frem(double %arg0, double %arg1) {
; CHECK-LABEL: @nnan_frem(
; CHECK-NEXT:    [[NNAN_ARG0:%.*]] = fadd nnan double [[ARG0:%.*]], 1.000000e+00
; CHECK-NEXT:    [[NNAN_ARG1:%.*]] = fadd nnan double [[ARG0]], 2.000000e+00
; CHECK-NEXT:    [[OP:%.*]] = frem double [[NNAN_ARG0]], [[NNAN_ARG1]]
; CHECK-NEXT:    [[TMP:%.*]] = fcmp ord double [[OP]], [[OP]]
; CHECK-NEXT:    ret i1 [[TMP]]
;
  %nnan.arg0 = fadd nnan double %arg0, 1.0
  %nnan.arg1 = fadd nnan double %arg0, 2.0
  %op = frem double %nnan.arg0, %nnan.arg1
  %tmp = fcmp ord double %op, %op
  ret i1 %tmp
}

define i1 @nnan_arithemtic_fence_src(double %arg) {
; CHECK-LABEL: @nnan_arithemtic_fence_src(
; CHECK-NEXT:    ret i1 true
;
  %nnan = fadd nnan double %arg, 1.0
  %op = call double @llvm.arithmetic.fence.f64(double %nnan)
  %tmp = fcmp ord double %op, %op
  ret i1 %tmp
}

declare double @llvm.sqrt.f64(double)
declare double @llvm.fabs.f64(double)
declare double @llvm.canonicalize.f64(double)
declare double @llvm.copysign.f64(double, double)
declare double @llvm.exp.f64(double)
declare double @llvm.exp2.f64(double)
declare double @llvm.floor.f64(double)
declare double @llvm.ceil.f64(double)
declare double @llvm.trunc.f64(double)
declare double @llvm.rint.f64(double)
declare double @llvm.nearbyint.f64(double)
declare double @llvm.round.f64(double)
declare double @llvm.roundeven.f64(double)
declare double @llvm.arithmetic.fence.f64(double)


define i1 @isKnownNeverNaN_nofpclass_nan_arg(double nofpclass(nan) %arg) {
; CHECK-LABEL: @isKnownNeverNaN_nofpclass_nan_arg(
; CHECK-NEXT:    ret i1 true
;
  %tmp = fcmp ord double %arg, %arg
  ret i1 %tmp
}

; Not enough nan tested
define i1 @isKnownNeverNaN_nofpclass_qnan_arg(double nofpclass(qnan) %arg) {
; CHECK-LABEL: @isKnownNeverNaN_nofpclass_qnan_arg(
; CHECK-NEXT:    [[TMP:%.*]] = fcmp ord double [[ARG:%.*]], [[ARG]]
; CHECK-NEXT:    ret i1 [[TMP]]
;
  %tmp = fcmp ord double %arg, %arg
  ret i1 %tmp
}

; Not enough nan tested
define i1 @isKnownNeverNaN_nofpclass_snan_arg(double nofpclass(snan) %arg) {
; CHECK-LABEL: @isKnownNeverNaN_nofpclass_snan_arg(
; CHECK-NEXT:    [[TMP:%.*]] = fcmp ord double [[ARG:%.*]], [[ARG]]
; CHECK-NEXT:    ret i1 [[TMP]]
;
  %tmp = fcmp ord double %arg, %arg
  ret i1 %tmp
}

; Wrong test
define i1 @isKnownNeverNaN_nofpclass_zero_arg(double nofpclass(zero) %arg) {
; CHECK-LABEL: @isKnownNeverNaN_nofpclass_zero_arg(
; CHECK-NEXT:    [[TMP:%.*]] = fcmp ord double [[ARG:%.*]], [[ARG]]
; CHECK-NEXT:    ret i1 [[TMP]]
;
  %tmp = fcmp ord double %arg, %arg
  ret i1 %tmp
}

declare nofpclass(nan) double @declare_no_nan_return()
declare double @unknown_return()

define i1 @isKnownNeverNaN_nofpclass_call_decl() {
; CHECK-LABEL: @isKnownNeverNaN_nofpclass_call_decl(
; CHECK-NEXT:    [[CALL:%.*]] = call double @declare_no_nan_return()
; CHECK-NEXT:    ret i1 true
;
  %call = call double @declare_no_nan_return()
  %tmp = fcmp ord double %call, %call
  ret i1 %tmp
}

define i1 @isKnownNeverNaN_nofpclass_callsite() {
; CHECK-LABEL: @isKnownNeverNaN_nofpclass_callsite(
; CHECK-NEXT:    [[CALL:%.*]] = call nofpclass(nan) double @unknown_return()
; CHECK-NEXT:    ret i1 true
;
  %call = call nofpclass(nan) double @unknown_return()
  %tmp = fcmp ord double %call, %call
  ret i1 %tmp
}

declare nofpclass(sub norm zero inf) double @only_nans()

; TODO: Could simplify to false
define i1 @isKnownNeverNaN_only_nans() {
; CHECK-LABEL: @isKnownNeverNaN_only_nans(
; CHECK-NEXT:    [[CALL:%.*]] = call double @only_nans()
; CHECK-NEXT:    [[TMP:%.*]] = fcmp ord double [[CALL]], [[CALL]]
; CHECK-NEXT:    ret i1 [[TMP]]
;
  %call = call double @only_nans()
  %tmp = fcmp ord double %call, %call
  ret i1 %tmp
}

define i1 @isKnownNeverNaN_nofpclass_indirect_callsite(ptr %fptr) {
; CHECK-LABEL: @isKnownNeverNaN_nofpclass_indirect_callsite(
; CHECK-NEXT:    [[CALL:%.*]] = call nofpclass(nan) double [[FPTR:%.*]]()
; CHECK-NEXT:    ret i1 true
;
  %call = call nofpclass(nan) double %fptr()
  %tmp = fcmp ord double %call, %call
  ret i1 %tmp
}

define i1 @isKnownNeverNaN_invoke_callsite(ptr %ptr) personality i8 1 {
; CHECK-LABEL: @isKnownNeverNaN_invoke_callsite(
; CHECK-NEXT:    [[INVOKE:%.*]] = invoke nofpclass(nan) float [[PTR:%.*]]()
; CHECK-NEXT:    to label [[NORMAL:%.*]] unwind label [[UNWIND:%.*]]
; CHECK:       normal:
; CHECK-NEXT:    ret i1 true
; CHECK:       unwind:
; CHECK-NEXT:    [[TMP1:%.*]] = landingpad ptr
; CHECK-NEXT:    cleanup
; CHECK-NEXT:    resume ptr null
;
  %invoke = invoke nofpclass(nan) float %ptr() to label %normal unwind label %unwind

normal:
  %ord = fcmp ord float %invoke, 0.0
  ret i1 %ord

unwind:
  landingpad ptr cleanup
  resume ptr null
}

; This should not fold to false because fmul 0 * inf = nan
define i1 @issue63316(i64 %arg) {
; CHECK-LABEL: @issue63316(
; CHECK-NEXT:    [[SITOFP:%.*]] = sitofp i64 [[ARG:%.*]] to float
; CHECK-NEXT:    [[FMUL:%.*]] = fmul float [[SITOFP]], 0x7FF0000000000000
; CHECK-NEXT:    [[FCMP:%.*]] = fcmp uno float [[FMUL]], 0.000000e+00
; CHECK-NEXT:    ret i1 [[FCMP]]
;
  %sitofp = sitofp i64 %arg to float
  %fmul = fmul float %sitofp, 0x7FF0000000000000
  %fcmp = fcmp uno float %fmul, 0.000000e+00
  ret i1 %fcmp
}

define i1 @issue63316_commute(i64 %arg) {
; CHECK-LABEL: @issue63316_commute(
; CHECK-NEXT:    [[SITOFP:%.*]] = sitofp i64 [[ARG:%.*]] to float
; CHECK-NEXT:    [[FMUL:%.*]] = fmul float 0x7FF0000000000000, [[SITOFP]]
; CHECK-NEXT:    [[FCMP:%.*]] = fcmp uno float [[FMUL]], 0.000000e+00
; CHECK-NEXT:    ret i1 [[FCMP]]
;
  %sitofp = sitofp i64 %arg to float
  %fmul = fmul float 0x7FF0000000000000, %sitofp
  %fcmp = fcmp uno float %fmul, 0.000000e+00
  ret i1 %fcmp
}