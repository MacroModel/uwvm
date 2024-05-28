﻿//===- ReduceDPValues.cpp - Specialized Delta Pass ------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements a function which calls the Generic Delta pass in order
// to reduce uninteresting DPValues from defined functions.
//
// DPValues store variable-location debug-info and are attached to instructions.
// This information used to be represented by intrinsics such as dbg.value, and
// would naturally get reduced by llvm-reduce like any other instruction. As
// DPValues get stored elsewhere, they need to be enumerated and eliminated like
// any other data structure in LLVM.
//
//===----------------------------------------------------------------------===//

#include "ReduceDPValues.h"
#include "Utils.h"
#include "llvm/ADT/STLExtras.h"

using namespace llvm;

static void extractDPValuesFromModule(Oracle &O, ReducerWorkItem &WorkItem) {
  Module &M = WorkItem.getModule();

  for (auto &F : M)
    for (auto &BB : F)
      for (auto &I : BB)
        for (DPValue &DPV : llvm::make_early_inc_range(I.getDbgValueRange()))
          if (!O.shouldKeep())
            DPV.eraseFromParent();
}

void llvm::reduceDPValuesDeltaPass(TestRunner &Test) {
  runDeltaPass(Test, extractDPValuesFromModule, "Reducing DPValues");
}
