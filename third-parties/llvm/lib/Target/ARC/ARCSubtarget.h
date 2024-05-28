﻿//===- ARCSubtarget.h - Define Subtarget for the ARC ------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file declares the ARC specific subclass of TargetSubtargetInfo.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_ARC_ARCSUBTARGET_H
#define LLVM_LIB_TARGET_ARC_ARCSUBTARGET_H

#include "ARCFrameLowering.h"
#include "ARCISelLowering.h"
#include "ARCInstrInfo.h"
#include "llvm/CodeGen/SelectionDAGTargetInfo.h"
#include "llvm/CodeGen/TargetSubtargetInfo.h"
#include <string>

#define GET_SUBTARGETINFO_HEADER
#include "ARCGenSubtargetInfo.inc"

namespace llvm {

class StringRef;
class TargetMachine;

class ARCSubtarget : public ARCGenSubtargetInfo {
  virtual void anchor();
  ARCInstrInfo InstrInfo;
  ARCFrameLowering FrameLowering;
  ARCTargetLowering TLInfo;
  SelectionDAGTargetInfo TSInfo;

  // ARC processor extensions
  bool Xnorm = false;

public:
  /// This constructor initializes the data members to match that
  /// of the specified triple.
  ARCSubtarget(const Triple &TT, const std::string &CPU, const std::string &FS,
               const TargetMachine &TM);

  /// Parses features string setting specified subtarget options.
  /// Definition of function is auto generated by tblgen.
  void ParseSubtargetFeatures(StringRef CPU, StringRef TuneCPU, StringRef FS);

  const ARCInstrInfo *getInstrInfo() const override { return &InstrInfo; }
  const ARCFrameLowering *getFrameLowering() const override {
    return &FrameLowering;
  }
  const ARCTargetLowering *getTargetLowering() const override {
    return &TLInfo;
  }
  const ARCRegisterInfo *getRegisterInfo() const override {
    return &InstrInfo.getRegisterInfo();
  }
  const SelectionDAGTargetInfo *getSelectionDAGInfo() const override {
    return &TSInfo;
  }

  bool hasNorm() const { return Xnorm; }
};

} // end namespace llvm

#endif // LLVM_LIB_TARGET_ARC_ARCSUBTARGET_H
