; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -passes=dse -S | FileCheck %s

target datalayout = "E-m:e-p:32:32-i64:32-f64:32:64-a:0:32-n32-S32"

%struct.ilist = type { i32, ptr }

; There is no dead store in this test. Make sure no store is deleted by DSE.
; Test case related to bug report PR52774.

define ptr @test() {
; CHECK-LABEL: @test(
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV:%.*]] = phi i32 [ 0, [[TMP0:%.*]] ], [ [[IV_NEXT:%.*]], [[LOOP]] ]
; CHECK-NEXT:    [[LIST_NEXT:%.*]] = phi ptr [ null, [[TMP0]] ], [ [[LIST_NEW_I8_PTR:%.*]], [[LOOP]] ]
; CHECK-NEXT:    [[LIST_NEW_I8_PTR]] = tail call align 8 dereferenceable_or_null(8) ptr @malloc(i32 8)
; CHECK-NEXT:    store i32 42, ptr [[LIST_NEW_I8_PTR]], align 8
; CHECK-NEXT:    [[GEP_NEW_NEXT:%.*]] = getelementptr inbounds [[STRUCT_ILIST:%.*]], ptr [[LIST_NEW_I8_PTR]], i32 0, i32 1
; CHECK-NEXT:    store ptr [[LIST_NEXT]], ptr [[GEP_NEW_NEXT]], align 4
; CHECK-NEXT:    [[IV_NEXT]] = add nuw nsw i32 [[IV]], 1
; CHECK-NEXT:    [[COND:%.*]] = icmp eq i32 [[IV_NEXT]], 10
; CHECK-NEXT:    br i1 [[COND]], label [[EXIT:%.*]], label [[LOOP]]
; CHECK:       exit:
; CHECK-NEXT:    [[GEP_LIST_LAST_NEXT:%.*]] = getelementptr inbounds [[STRUCT_ILIST]], ptr [[LIST_NEW_I8_PTR]], i32 0, i32 1
; CHECK-NEXT:    store ptr null, ptr [[GEP_LIST_LAST_NEXT]], align 4
; CHECK-NEXT:    [[GEP_LIST_NEXT_NEXT:%.*]] = getelementptr inbounds [[STRUCT_ILIST]], ptr [[LIST_NEXT]], i32 0, i32 1
; CHECK-NEXT:    [[LOADED_PTR:%.*]] = load ptr, ptr [[GEP_LIST_NEXT_NEXT]], align 4
; CHECK-NEXT:    ret ptr [[LOADED_PTR]]
;
  br label %loop

loop:
  %iv = phi i32 [ 0, %0 ], [ %iv.next, %loop ]
  %list.next = phi ptr [ null, %0 ], [ %list.new.i8.ptr, %loop ]
  %list.new.i8.ptr = tail call align 8 dereferenceable_or_null(8) ptr @malloc(i32 8)
  store i32 42, ptr %list.new.i8.ptr, align 8
  %gep.new.next = getelementptr inbounds %struct.ilist, ptr %list.new.i8.ptr, i32 0, i32 1
  store ptr %list.next, ptr %gep.new.next, align 4
  %iv.next = add nuw nsw i32 %iv, 1
  %cond = icmp eq i32 %iv.next, 10
  br i1 %cond, label %exit, label %loop

exit:
  %gep.list.last.next = getelementptr inbounds %struct.ilist, ptr %list.new.i8.ptr, i32 0, i32 1
  store ptr null, ptr %gep.list.last.next, align 4
  %gep.list.next.next = getelementptr inbounds %struct.ilist, ptr %list.next, i32 0, i32 1
  %loaded_ptr = load ptr, ptr %gep.list.next.next, align 4
  ret ptr %loaded_ptr                                      ; use loaded pointer
}

; Function Attrs: inaccessiblememonly nounwind
declare noalias noundef align 8 ptr @malloc(i32 noundef) local_unnamed_addr #0

attributes #0 = { inaccessiblememonly nounwind}