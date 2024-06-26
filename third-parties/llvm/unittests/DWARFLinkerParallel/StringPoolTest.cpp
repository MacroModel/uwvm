﻿//===- llvm/unittest/DWARFLinkerParallel/StringPoolTest.cpp ---------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "llvm/DWARFLinker/StringPool.h"
#include "llvm/Support/Parallel.h"
#include "gtest/gtest.h"
#include <cstdlib>

using namespace llvm;
using namespace dwarf_linker;

namespace {

TEST(StringPoolTest, TestStringPool) {
  StringPool Strings;

  // StringPool uses PerThreadBumpPtrAllocator which should be accessed from
  // threads created by ThreadPoolExecutor. Use TaskGroup to run on
  // ThreadPoolExecutor threads.
  parallel::TaskGroup tg;

  tg.spawn([&]() {
    std::pair<StringEntry *, bool> Entry = Strings.insert("test");
    EXPECT_TRUE(Entry.second);
    EXPECT_TRUE(Entry.first->getKey() == "test");

    StringEntry *EntryPtr = Entry.first;

    Entry = Strings.insert("test");
    EXPECT_FALSE(Entry.second);
    EXPECT_TRUE(Entry.first->getKey() == "test");
    EXPECT_TRUE(EntryPtr == Entry.first);

    Entry = Strings.insert("test2");
    EXPECT_TRUE(Entry.second);
    EXPECT_TRUE(Entry.first->getKey() == "test2");
    EXPECT_TRUE(EntryPtr != Entry.first);
  });
}

TEST(StringPoolTest, TestStringPoolParallel) {
  StringPool Strings;

  // Add data.
  parallelFor(0, 1000, [&](size_t Idx) {
    std::pair<StringEntry *, bool> Entry = Strings.insert(std::to_string(Idx));
    EXPECT_TRUE(Entry.second);
    EXPECT_TRUE(Entry.first->getKey() == std::to_string(Idx));
  });

  // Check data.
  parallelFor(0, 1000, [&](size_t Idx) {
    std::pair<StringEntry *, bool> Entry = Strings.insert(std::to_string(Idx));
    EXPECT_FALSE(Entry.second);
    EXPECT_TRUE(Entry.first->getKey() == std::to_string(Idx));
  });
}

} // anonymous namespace
