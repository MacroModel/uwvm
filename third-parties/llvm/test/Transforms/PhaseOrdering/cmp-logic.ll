; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -passes='default<O1>' -S < %s | FileCheck %s --check-prefixes=CHECK,O1
; RUN: opt -passes='default<Oz>' -S < %s | FileCheck %s --check-prefixes=CHECK,OZ

target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"

%struct.a = type { i32 }

define i32 @PR38781(i32 noundef %a, i32 noundef %b) {
; CHECK-LABEL: @PR38781(
; CHECK-NEXT:    [[TMP1:%.*]] = or i32 [[B:%.*]], [[A:%.*]]
; CHECK-NEXT:    [[AND1:%.*]] = icmp sgt i32 [[TMP1]], -1
; CHECK-NEXT:    [[AND:%.*]] = zext i1 [[AND1]] to i32
; CHECK-NEXT:    ret i32 [[AND]]
;
  %cmp = icmp sge i32 %a, 0
  %conv = zext i1 %cmp to i32
  %cmp1 = icmp sge i32 %b, 0
  %conv2 = zext i1 %cmp1 to i32
  %and = and i32 %conv, %conv2
  ret i32 %and
}

define i1 @PR54692_a(i8 noundef signext %c) #0 {
; CHECK-LABEL: @PR54692_a(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = icmp ult i8 [[C:%.*]], 32
; CHECK-NEXT:    [[CMP5:%.*]] = icmp eq i8 [[C]], 127
; CHECK-NEXT:    [[OR1:%.*]] = or i1 [[TMP0]], [[CMP5]]
; CHECK-NEXT:    ret i1 [[OR1]]
;
entry:
  %conv = sext i8 %c to i32
  %cmp = icmp sge i32 %conv, 0
  br i1 %cmp, label %land.rhs, label %land.end

land.rhs:
  %conv1 = sext i8 %c to i32
  %cmp2 = icmp sle i32 %conv1, 31
  br label %land.end

land.end:
  %0 = phi i1 [ false, %entry ], [ %cmp2, %land.rhs ]
  %conv3 = zext i1 %0 to i32
  %conv4 = sext i8 %c to i32
  %cmp5 = icmp eq i32 %conv4, 127
  %conv6 = zext i1 %cmp5 to i32
  %or = or i32 %conv3, %conv6
  %tobool = icmp ne i32 %or, 0
  ret i1 %tobool
}

define i1 @PR54692_b(i8 noundef signext %c) {
; CHECK-LABEL: @PR54692_b(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[AND1:%.*]] = icmp ult i8 [[C:%.*]], 32
; CHECK-NEXT:    [[CMP6:%.*]] = icmp eq i8 [[C]], 127
; CHECK-NEXT:    [[OR2:%.*]] = or i1 [[AND1]], [[CMP6]]
; CHECK-NEXT:    ret i1 [[OR2]]
;
entry:
  %conv = sext i8 %c to i32
  %cmp = icmp sge i32 %conv, 0
  %conv1 = zext i1 %cmp to i32
  %conv2 = sext i8 %c to i32
  %cmp3 = icmp sle i32 %conv2, 31
  %conv4 = zext i1 %cmp3 to i32
  %and = and i32 %conv1, %conv4
  %conv5 = sext i8 %c to i32
  %cmp6 = icmp eq i32 %conv5, 127
  %conv7 = zext i1 %cmp6 to i32
  %or = or i32 %and, %conv7
  %tobool = icmp ne i32 %or, 0
  ret i1 %tobool
}

define i1 @PR54692_c(i8 noundef signext %c) {
; CHECK-LABEL: @PR54692_c(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[AND1:%.*]] = icmp ult i8 [[C:%.*]], 32
; CHECK-NEXT:    [[CMP6:%.*]] = icmp eq i8 [[C]], 127
; CHECK-NEXT:    [[T0:%.*]] = or i1 [[AND1]], [[CMP6]]
; CHECK-NEXT:    ret i1 [[T0]]
;
entry:
  %conv = sext i8 %c to i32
  %cmp = icmp sge i32 %conv, 0
  %conv1 = zext i1 %cmp to i32
  %conv2 = sext i8 %c to i32
  %cmp3 = icmp sle i32 %conv2, 31
  %conv4 = zext i1 %cmp3 to i32
  %and = and i32 %conv1, %conv4
  %tobool = icmp ne i32 %and, 0
  br i1 %tobool, label %lor.end, label %lor.rhs

lor.rhs:
  %conv5 = sext i8 %c to i32
  %cmp6 = icmp eq i32 %conv5, 127
  br label %lor.end

lor.end:
  %t0 = phi i1 [ true, %entry ], [ %cmp6, %lor.rhs ]
  ret i1 %t0
}

@c = global i32 0, align 4

declare void @foo(...) #3

define i32 @PR56119(i32 %e.coerce) {
; O1-LABEL: @PR56119(
; O1-NEXT:  entry:
; O1-NEXT:    [[CONV2:%.*]] = and i32 [[E_COERCE:%.*]], 255
; O1-NEXT:    [[REM:%.*]] = urem i32 [[CONV2]], 255
; O1-NEXT:    [[CMP:%.*]] = icmp eq i32 [[REM]], 7
; O1-NEXT:    br i1 [[CMP]], label [[IF_THEN:%.*]], label [[IF_END:%.*]]
; O1:       if.then:
; O1-NEXT:    tail call void (...) @foo()
; O1-NEXT:    br label [[IF_END]]
; O1:       if.end:
; O1-NEXT:    [[TMP0:%.*]] = load i32, ptr @c, align 4
; O1-NEXT:    ret i32 [[TMP0]]
;
; OZ-LABEL: @PR56119(
; OZ-NEXT:  entry:
; OZ-NEXT:    [[E_COERCE_FR:%.*]] = freeze i32 [[E_COERCE:%.*]]
; OZ-NEXT:    [[CONV2:%.*]] = and i32 [[E_COERCE_FR]], 255
; OZ-NEXT:    [[CMP1:%.*]] = icmp eq i32 [[CONV2]], 7
; OZ-NEXT:    br i1 [[CMP1]], label [[IF_THEN:%.*]], label [[IF_END:%.*]]
; OZ:       if.then:
; OZ-NEXT:    tail call void (...) @foo()
; OZ-NEXT:    br label [[IF_END]]
; OZ:       if.end:
; OZ-NEXT:    [[TMP0:%.*]] = load i32, ptr @c, align 4
; OZ-NEXT:    ret i32 [[TMP0]]
;
entry:
  %e = alloca %struct.a, align 4
  store i32 %e.coerce, ptr %e, align 4
  %0 = load i32, ptr %e, align 4
  %conv = trunc i32 %0 to i8
  %conv1 = trunc i64 -1 to i8
  %conv2 = zext i8 %conv to i32
  %conv3 = zext i8 %conv1 to i32
  %rem = srem i32 %conv2, %conv3
  %conv4 = trunc i32 %rem to i8
  %conv5 = sext i8 %conv4 to i32
  %cmp = icmp eq i32 7, %conv5
  br i1 %cmp, label %if.then, label %if.end

if.then:
  call void (...) @foo() #5
  br label %if.end

if.end:
  %1 = load i32, ptr @c, align 4
  ret i32 %1
}