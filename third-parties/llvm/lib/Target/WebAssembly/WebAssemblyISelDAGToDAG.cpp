﻿//- WebAssemblyISelDAGToDAG.cpp - A dag to dag inst selector for WebAssembly -//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
///
/// \file
/// This file defines an instruction selector for the WebAssembly target.
///
//===----------------------------------------------------------------------===//

#include "MCTargetDesc/WebAssemblyMCTargetDesc.h"
#include "WebAssembly.h"
#include "WebAssemblyISelLowering.h"
#include "WebAssemblyTargetMachine.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/SelectionDAGISel.h"
#include "llvm/CodeGen/WasmEHFuncInfo.h"
#include "llvm/IR/DiagnosticInfo.h"
#include "llvm/IR/Function.h" // To access function attributes.
#include "llvm/IR/IntrinsicsWebAssembly.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/KnownBits.h"
#include "llvm/Support/MathExtras.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

#define DEBUG_TYPE "wasm-isel"
#define PASS_NAME "WebAssembly Instruction Selection"

//===--------------------------------------------------------------------===//
/// WebAssembly-specific code to select WebAssembly machine instructions for
/// SelectionDAG operations.
///
namespace {
class WebAssemblyDAGToDAGISel final : public SelectionDAGISel {
  /// Keep a pointer to the WebAssemblySubtarget around so that we can make the
  /// right decision when generating code for different targets.
  const WebAssemblySubtarget *Subtarget;

public:
  static char ID;

  WebAssemblyDAGToDAGISel() = delete;

  WebAssemblyDAGToDAGISel(WebAssemblyTargetMachine &TM,
                          CodeGenOptLevel OptLevel)
      : SelectionDAGISel(ID, TM, OptLevel), Subtarget(nullptr) {}

  bool runOnMachineFunction(MachineFunction &MF) override {
    LLVM_DEBUG(dbgs() << "********** ISelDAGToDAG **********\n"
                         "********** Function: "
                      << MF.getName() << '\n');

    Subtarget = &MF.getSubtarget<WebAssemblySubtarget>();

    return SelectionDAGISel::runOnMachineFunction(MF);
  }

  void PreprocessISelDAG() override;

  void Select(SDNode *Node) override;

  bool SelectInlineAsmMemoryOperand(const SDValue &Op,
                                    InlineAsm::ConstraintCode ConstraintID,
                                    std::vector<SDValue> &OutOps) override;

  bool SelectAddrOperands32(SDValue Op, SDValue &Offset, SDValue &Addr);
  bool SelectAddrOperands64(SDValue Op, SDValue &Offset, SDValue &Addr);

// Include the pieces autogenerated from the target description.
#include "WebAssemblyGenDAGISel.inc"

private:
  // add select functions here...

  bool SelectAddrOperands(MVT AddrType, unsigned ConstOpc, SDValue Op,
                          SDValue &Offset, SDValue &Addr);
  bool SelectAddrAddOperands(MVT OffsetType, SDValue N, SDValue &Offset,
                             SDValue &Addr);
};
} // end anonymous namespace

char WebAssemblyDAGToDAGISel::ID;

INITIALIZE_PASS(WebAssemblyDAGToDAGISel, DEBUG_TYPE, PASS_NAME, false, false)

void WebAssemblyDAGToDAGISel::PreprocessISelDAG() {
  // Stack objects that should be allocated to locals are hoisted to WebAssembly
  // locals when they are first used.  However for those without uses, we hoist
  // them here.  It would be nice if there were some hook to do this when they
  // are added to the MachineFrameInfo, but that's not the case right now.
  MachineFrameInfo &FrameInfo = MF->getFrameInfo();
  for (int Idx = 0; Idx < FrameInfo.getObjectIndexEnd(); Idx++)
    WebAssemblyFrameLowering::getLocalForStackObject(*MF, Idx);

  SelectionDAGISel::PreprocessISelDAG();
}

static SDValue getTagSymNode(int Tag, SelectionDAG *DAG) {
  assert(Tag == WebAssembly::CPP_EXCEPTION || WebAssembly::C_LONGJMP);
  auto &MF = DAG->getMachineFunction();
  const auto &TLI = DAG->getTargetLoweringInfo();
  MVT PtrVT = TLI.getPointerTy(DAG->getDataLayout());
  const char *SymName = Tag == WebAssembly::CPP_EXCEPTION
                            ? MF.createExternalSymbolName("__cpp_exception")
                            : MF.createExternalSymbolName("__c_longjmp");
  return DAG->getTargetExternalSymbol(SymName, PtrVT);
}

void WebAssemblyDAGToDAGISel::Select(SDNode *Node) {
  // If we have a custom node, we already have selected!
  if (Node->isMachineOpcode()) {
    LLVM_DEBUG(errs() << "== "; Node->dump(CurDAG); errs() << "\n");
    Node->setNodeId(-1);
    return;
  }

  MVT PtrVT = TLI->getPointerTy(CurDAG->getDataLayout());
  auto GlobalGetIns = PtrVT == MVT::i64 ? WebAssembly::GLOBAL_GET_I64
                                        : WebAssembly::GLOBAL_GET_I32;

  // Few custom selection stuff.
  SDLoc DL(Node);
  MachineFunction &MF = CurDAG->getMachineFunction();
  switch (Node->getOpcode()) {
  case ISD::ATOMIC_FENCE: {
    if (!MF.getSubtarget<WebAssemblySubtarget>().hasAtomics())
      break;

    uint64_t SyncScopeID = Node->getConstantOperandVal(2);
    MachineSDNode *Fence = nullptr;
    switch (SyncScopeID) {
    case SyncScope::SingleThread:
      // We lower a single-thread fence to a pseudo compiler barrier instruction
      // preventing instruction reordering. This will not be emitted in final
      // binary.
      Fence = CurDAG->getMachineNode(WebAssembly::COMPILER_FENCE,
                                     DL,                 // debug loc
                                     MVT::Other,         // outchain type
                                     Node->getOperand(0) // inchain
      );
      break;
    case SyncScope::System:
      // Currently wasm only supports sequentially consistent atomics, so we
      // always set the order to 0 (sequentially consistent).
      Fence = CurDAG->getMachineNode(
          WebAssembly::ATOMIC_FENCE,
          DL,                                         // debug loc
          MVT::Other,                                 // outchain type
          CurDAG->getTargetConstant(0, DL, MVT::i32), // order
          Node->getOperand(0)                         // inchain
      );
      break;
    default:
      llvm_unreachable("Unknown scope!");
    }

    ReplaceNode(Node, Fence);
    CurDAG->RemoveDeadNode(Node);
    return;
  }

  case ISD::INTRINSIC_WO_CHAIN: {
    unsigned IntNo = Node->getConstantOperandVal(0);
    switch (IntNo) {
    case Intrinsic::wasm_tls_size: {
      MachineSDNode *TLSSize = CurDAG->getMachineNode(
          GlobalGetIns, DL, PtrVT,
          CurDAG->getTargetExternalSymbol("__tls_size", PtrVT));
      ReplaceNode(Node, TLSSize);
      return;
    }

    case Intrinsic::wasm_tls_align: {
      MachineSDNode *TLSAlign = CurDAG->getMachineNode(
          GlobalGetIns, DL, PtrVT,
          CurDAG->getTargetExternalSymbol("__tls_align", PtrVT));
      ReplaceNode(Node, TLSAlign);
      return;
    }
    }
    break;
  }

  case ISD::INTRINSIC_W_CHAIN: {
    unsigned IntNo = Node->getConstantOperandVal(1);
    const auto &TLI = CurDAG->getTargetLoweringInfo();
    MVT PtrVT = TLI.getPointerTy(CurDAG->getDataLayout());
    switch (IntNo) {
    case Intrinsic::wasm_tls_base: {
      MachineSDNode *TLSBase = CurDAG->getMachineNode(
          GlobalGetIns, DL, PtrVT, MVT::Other,
          CurDAG->getTargetExternalSymbol("__tls_base", PtrVT),
          Node->getOperand(0));
      ReplaceNode(Node, TLSBase);
      return;
    }

    case Intrinsic::wasm_catch: {
      int Tag = Node->getConstantOperandVal(2);
      SDValue SymNode = getTagSymNode(Tag, CurDAG);
      MachineSDNode *Catch =
          CurDAG->getMachineNode(WebAssembly::CATCH, DL,
                                 {
                                     PtrVT,     // exception pointer
                                     MVT::Other // outchain type
                                 },
                                 {
                                     SymNode,            // exception symbol
                                     Node->getOperand(0) // inchain
                                 });
      ReplaceNode(Node, Catch);
      return;
    }
    }
    break;
  }

  case ISD::INTRINSIC_VOID: {
    unsigned IntNo = Node->getConstantOperandVal(1);
    switch (IntNo) {
    case Intrinsic::wasm_throw: {
      int Tag = Node->getConstantOperandVal(2);
      SDValue SymNode = getTagSymNode(Tag, CurDAG);
      MachineSDNode *Throw =
          CurDAG->getMachineNode(WebAssembly::THROW, DL,
                                 MVT::Other, // outchain type
                                 {
                                     SymNode,             // exception symbol
                                     Node->getOperand(3), // thrown value
                                     Node->getOperand(0)  // inchain
                                 });
      ReplaceNode(Node, Throw);
      return;
    }
    }
    break;
  }

  case WebAssemblyISD::CALL:
  case WebAssemblyISD::RET_CALL: {
    // CALL has both variable operands and variable results, but ISel only
    // supports one or the other. Split calls into two nodes glued together, one
    // for the operands and one for the results. These two nodes will be
    // recombined in a custom inserter hook into a single MachineInstr.
    SmallVector<SDValue, 16> Ops;
    for (size_t i = 1; i < Node->getNumOperands(); ++i) {
      SDValue Op = Node->getOperand(i);
      // Remove the wrapper when the call target is a function, an external
      // symbol (which will be lowered to a library function), or an alias of
      // a function. If the target is not a function/external symbol, we
      // shouldn't remove the wrapper, because we cannot call it directly and
      // instead we want it to be loaded with a CONST instruction and called
      // with a call_indirect later.
      if (i == 1 && Op->getOpcode() == WebAssemblyISD::Wrapper) {
        SDValue NewOp = Op->getOperand(0);
        if (auto *GlobalOp = dyn_cast<GlobalAddressSDNode>(NewOp.getNode())) {
          if (isa<Function>(
                  GlobalOp->getGlobal()->stripPointerCastsAndAliases()))
            Op = NewOp;
        } else if (isa<ExternalSymbolSDNode>(NewOp.getNode())) {
          Op = NewOp;
        }
      }
      Ops.push_back(Op);
    }

    // Add the chain last
    Ops.push_back(Node->getOperand(0));
    MachineSDNode *CallParams =
        CurDAG->getMachineNode(WebAssembly::CALL_PARAMS, DL, MVT::Glue, Ops);

    unsigned Results = Node->getOpcode() == WebAssemblyISD::CALL
                           ? WebAssembly::CALL_RESULTS
                           : WebAssembly::RET_CALL_RESULTS;

    SDValue Link(CallParams, 0);
    MachineSDNode *CallResults =
        CurDAG->getMachineNode(Results, DL, Node->getVTList(), Link);
    ReplaceNode(Node, CallResults);
    return;
  }

  default:
    break;
  }

  // Select the default instruction.
  SelectCode(Node);
}

bool WebAssemblyDAGToDAGISel::SelectInlineAsmMemoryOperand(
    const SDValue &Op, InlineAsm::ConstraintCode ConstraintID,
    std::vector<SDValue> &OutOps) {
  switch (ConstraintID) {
  case InlineAsm::ConstraintCode::m:
    // We just support simple memory operands that just have a single address
    // operand and need no special handling.
    OutOps.push_back(Op);
    return false;
  default:
    break;
  }

  return true;
}

bool WebAssemblyDAGToDAGISel::SelectAddrAddOperands(MVT OffsetType, SDValue N,
                                                    SDValue &Offset,
                                                    SDValue &Addr) {
  assert(N.getNumOperands() == 2 && "Attempting to fold in a non-binary op");

  // WebAssembly constant offsets are performed as unsigned with infinite
  // precision, so we need to check for NoUnsignedWrap so that we don't fold an
  // offset for an add that needs wrapping.
  if (N.getOpcode() == ISD::ADD && !N.getNode()->getFlags().hasNoUnsignedWrap())
    return false;

  // Folds constants in an add into the offset.
  for (size_t i = 0; i < 2; ++i) {
    SDValue Op = N.getOperand(i);
    SDValue OtherOp = N.getOperand(i == 0 ? 1 : 0);

    if (ConstantSDNode *CN = dyn_cast<ConstantSDNode>(Op)) {
      Offset =
          CurDAG->getTargetConstant(CN->getZExtValue(), SDLoc(N), OffsetType);
      Addr = OtherOp;
      return true;
    }
  }
  return false;
}

bool WebAssemblyDAGToDAGISel::SelectAddrOperands(MVT AddrType,
                                                 unsigned ConstOpc, SDValue N,
                                                 SDValue &Offset,
                                                 SDValue &Addr) {
  SDLoc DL(N);

  // Fold target global addresses into the offset.
  if (!TM.isPositionIndependent()) {
    SDValue Op(N);
    if (Op.getOpcode() == WebAssemblyISD::Wrapper)
      Op = Op.getOperand(0);

    if (Op.getOpcode() == ISD::TargetGlobalAddress) {
      Offset = Op;
      Addr = SDValue(
          CurDAG->getMachineNode(ConstOpc, DL, AddrType,
                                 CurDAG->getTargetConstant(0, DL, AddrType)),
          0);
      return true;
    }
  }

  // Fold anything inside an add into the offset.
  if (N.getOpcode() == ISD::ADD &&
      SelectAddrAddOperands(AddrType, N, Offset, Addr))
    return true;

  // Likewise, treat an 'or' node as an 'add' if the or'ed bits are known to be
  // zero and fold them into the offset too.
  if (N.getOpcode() == ISD::OR) {
    bool OrIsAdd;
    if (ConstantSDNode *CN = dyn_cast<ConstantSDNode>(N.getOperand(1))) {
      OrIsAdd =
          CurDAG->MaskedValueIsZero(N->getOperand(0), CN->getAPIntValue());
    } else {
      KnownBits Known0 = CurDAG->computeKnownBits(N->getOperand(0), 0);
      KnownBits Known1 = CurDAG->computeKnownBits(N->getOperand(1), 0);
      OrIsAdd = (~Known0.Zero & ~Known1.Zero) == 0;
    }

    if (OrIsAdd && SelectAddrAddOperands(AddrType, N, Offset, Addr))
      return true;
  }

  // Fold constant addresses into the offset.
  if (ConstantSDNode *CN = dyn_cast<ConstantSDNode>(N)) {
    Offset = CurDAG->getTargetConstant(CN->getZExtValue(), DL, AddrType);
    Addr = SDValue(
        CurDAG->getMachineNode(ConstOpc, DL, AddrType,
                               CurDAG->getTargetConstant(0, DL, AddrType)),
        0);
    return true;
  }

  // Else it's a plain old load/store with no offset.
  Offset = CurDAG->getTargetConstant(0, DL, AddrType);
  Addr = N;
  return true;
}

bool WebAssemblyDAGToDAGISel::SelectAddrOperands32(SDValue Op, SDValue &Offset,
                                                   SDValue &Addr) {
  return SelectAddrOperands(MVT::i32, WebAssembly::CONST_I32, Op, Offset, Addr);
}

bool WebAssemblyDAGToDAGISel::SelectAddrOperands64(SDValue Op, SDValue &Offset,
                                                   SDValue &Addr) {
  return SelectAddrOperands(MVT::i64, WebAssembly::CONST_I64, Op, Offset, Addr);
}

/// This pass converts a legalized DAG into a WebAssembly-specific DAG, ready
/// for instruction scheduling.
FunctionPass *llvm::createWebAssemblyISelDag(WebAssemblyTargetMachine &TM,
                                             CodeGenOptLevel OptLevel) {
  return new WebAssemblyDAGToDAGISel(TM, OptLevel);
}
