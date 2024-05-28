﻿//===-- llvm/MC/MCSectionGOFF.h - GOFF Machine Code Sections ----*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
///
/// \file
/// This file declares the MCSectionGOFF class, which contains all of the
/// necessary machine code sections for the GOFF file format.
///
//===----------------------------------------------------------------------===//

#ifndef LLVM_MC_MCSECTIONGOFF_H
#define LLVM_MC_MCSECTIONGOFF_H

#include "llvm/BinaryFormat/GOFF.h"
#include "llvm/MC/MCSection.h"
#include "llvm/Support/raw_ostream.h"

namespace llvm {

class MCExpr;

class MCSectionGOFF final : public MCSection {
private:
  MCSection *Parent;
  const MCExpr *SubsectionId;

  friend class MCContext;
  MCSectionGOFF(StringRef Name, SectionKind K, MCSection *P, const MCExpr *Sub)
      : MCSection(SV_GOFF, Name, K, nullptr), Parent(P), SubsectionId(Sub) {}

public:
  void printSwitchToSection(const MCAsmInfo &MAI, const Triple &T,
                            raw_ostream &OS,
                            const MCExpr *Subsection) const override {
    OS << "\t.section\t\"" << getName() << "\"\n";
  }

  bool useCodeAlign() const override { return false; }

  bool isVirtualSection() const override { return false; }

  MCSection *getParent() const { return Parent; }
  const MCExpr *getSubsectionId() const { return SubsectionId; }

  static bool classof(const MCSection *S) { return S->getVariant() == SV_GOFF; }
};
} // end namespace llvm

#endif
