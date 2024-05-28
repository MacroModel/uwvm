﻿//===-- M68kLegalizerInfo ---------------------------------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
/// \file
/// This file declares the targeting of the MachineLegalizer class for
/// M68k.
/// \todo This should be generated by TableGen.
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_M68K_GLSEL_M68KLEGALIZERINFO_H
#define LLVM_LIB_TARGET_M68K_GLSEL_M68KLEGALIZERINFO_H

#include "llvm/CodeGen/GlobalISel/LegalizerInfo.h"

namespace llvm {

class M68kSubtarget;

struct M68kLegalizerInfo : public LegalizerInfo {
public:
  M68kLegalizerInfo(const M68kSubtarget &ST);
};
} // end namespace llvm
#endif // LLVM_LIB_TARGET_M68K_GLSEL_M68KLEGALIZERINFO_H
