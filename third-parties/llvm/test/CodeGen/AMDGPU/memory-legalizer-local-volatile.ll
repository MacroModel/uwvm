; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=amdgcn-amd- -mcpu=gfx600 < %s | FileCheck --check-prefixes=GFX6 %s
; RUN: llc -mtriple=amdgcn-amd-amdhsa -mcpu=gfx700 < %s | FileCheck --check-prefixes=GFX7 %s
; RUN: llc -mtriple=amdgcn-amd-amdhsa -mcpu=gfx1010 < %s | FileCheck --check-prefixes=GFX10-WGP %s
; RUN: llc -mtriple=amdgcn-amd-amdhsa -mcpu=gfx1010 -mattr=+cumode < %s | FileCheck --check-prefixes=GFX10-CU %s
; RUN: llc -mtriple=amdgcn-amd-amdpal -mcpu=gfx700 -amdgcn-skip-cache-invalidations < %s | FileCheck --check-prefixes=SKIP-CACHE-INV %s
; RUN: llc -mtriple=amdgcn-amd-amdhsa -mcpu=gfx1100 < %s | FileCheck --check-prefixes=GFX11-WGP %s
; RUN: llc -mtriple=amdgcn-amd-amdhsa -mcpu=gfx1100 -mattr=+cumode < %s | FileCheck --check-prefixes=GFX11-CU %s

define amdgpu_kernel void @local_volatile_load_0(
; GFX6-LABEL: local_volatile_load_0:
; GFX6:       ; %bb.0: ; %entry
; GFX6-NEXT:    s_load_dword s2, s[0:1], 0x9
; GFX6-NEXT:    s_load_dwordx2 s[0:1], s[0:1], 0xb
; GFX6-NEXT:    s_mov_b32 m0, -1
; GFX6-NEXT:    s_mov_b32 s3, 0xf000
; GFX6-NEXT:    s_waitcnt lgkmcnt(0)
; GFX6-NEXT:    v_mov_b32_e32 v0, s2
; GFX6-NEXT:    ds_read_b32 v0, v0
; GFX6-NEXT:    s_mov_b32 s2, -1
; GFX6-NEXT:    s_waitcnt lgkmcnt(0)
; GFX6-NEXT:    buffer_store_dword v0, off, s[0:3], 0
; GFX6-NEXT:    s_endpgm
;
; GFX7-LABEL: local_volatile_load_0:
; GFX7:       ; %bb.0: ; %entry
; GFX7-NEXT:    s_load_dword s2, s[4:5], 0x0
; GFX7-NEXT:    s_load_dwordx2 s[0:1], s[4:5], 0x2
; GFX7-NEXT:    s_mov_b32 m0, -1
; GFX7-NEXT:    s_waitcnt lgkmcnt(0)
; GFX7-NEXT:    v_mov_b32_e32 v0, s2
; GFX7-NEXT:    ds_read_b32 v2, v0
; GFX7-NEXT:    v_mov_b32_e32 v0, s0
; GFX7-NEXT:    v_mov_b32_e32 v1, s1
; GFX7-NEXT:    s_waitcnt lgkmcnt(0)
; GFX7-NEXT:    flat_store_dword v[0:1], v2
; GFX7-NEXT:    s_endpgm
;
; GFX10-WGP-LABEL: local_volatile_load_0:
; GFX10-WGP:       ; %bb.0: ; %entry
; GFX10-WGP-NEXT:    s_clause 0x1
; GFX10-WGP-NEXT:    s_load_dword s2, s[4:5], 0x0
; GFX10-WGP-NEXT:    s_load_dwordx2 s[0:1], s[4:5], 0x8
; GFX10-WGP-NEXT:    v_mov_b32_e32 v1, 0
; GFX10-WGP-NEXT:    s_waitcnt lgkmcnt(0)
; GFX10-WGP-NEXT:    v_mov_b32_e32 v0, s2
; GFX10-WGP-NEXT:    ds_read_b32 v0, v0
; GFX10-WGP-NEXT:    s_waitcnt lgkmcnt(0)
; GFX10-WGP-NEXT:    global_store_dword v1, v0, s[0:1]
; GFX10-WGP-NEXT:    s_endpgm
;
; GFX10-CU-LABEL: local_volatile_load_0:
; GFX10-CU:       ; %bb.0: ; %entry
; GFX10-CU-NEXT:    s_clause 0x1
; GFX10-CU-NEXT:    s_load_dword s2, s[4:5], 0x0
; GFX10-CU-NEXT:    s_load_dwordx2 s[0:1], s[4:5], 0x8
; GFX10-CU-NEXT:    v_mov_b32_e32 v1, 0
; GFX10-CU-NEXT:    s_waitcnt lgkmcnt(0)
; GFX10-CU-NEXT:    v_mov_b32_e32 v0, s2
; GFX10-CU-NEXT:    ds_read_b32 v0, v0
; GFX10-CU-NEXT:    s_waitcnt lgkmcnt(0)
; GFX10-CU-NEXT:    global_store_dword v1, v0, s[0:1]
; GFX10-CU-NEXT:    s_endpgm
;
; SKIP-CACHE-INV-LABEL: local_volatile_load_0:
; SKIP-CACHE-INV:       ; %bb.0: ; %entry
; SKIP-CACHE-INV-NEXT:    s_load_dword s2, s[0:1], 0x0
; SKIP-CACHE-INV-NEXT:    s_load_dwordx2 s[0:1], s[0:1], 0x2
; SKIP-CACHE-INV-NEXT:    s_mov_b32 m0, -1
; SKIP-CACHE-INV-NEXT:    s_mov_b32 s3, 0xf000
; SKIP-CACHE-INV-NEXT:    s_waitcnt lgkmcnt(0)
; SKIP-CACHE-INV-NEXT:    v_mov_b32_e32 v0, s2
; SKIP-CACHE-INV-NEXT:    ds_read_b32 v0, v0
; SKIP-CACHE-INV-NEXT:    s_mov_b32 s2, -1
; SKIP-CACHE-INV-NEXT:    s_waitcnt lgkmcnt(0)
; SKIP-CACHE-INV-NEXT:    buffer_store_dword v0, off, s[0:3], 0
; SKIP-CACHE-INV-NEXT:    s_endpgm
;
; GFX11-WGP-LABEL: local_volatile_load_0:
; GFX11-WGP:       ; %bb.0: ; %entry
; GFX11-WGP-NEXT:    s_clause 0x1
; GFX11-WGP-NEXT:    s_load_b32 s2, s[0:1], 0x0
; GFX11-WGP-NEXT:    s_load_b64 s[0:1], s[0:1], 0x8
; GFX11-WGP-NEXT:    s_waitcnt lgkmcnt(0)
; GFX11-WGP-NEXT:    v_dual_mov_b32 v1, 0 :: v_dual_mov_b32 v0, s2
; GFX11-WGP-NEXT:    ds_load_b32 v0, v0
; GFX11-WGP-NEXT:    s_waitcnt lgkmcnt(0)
; GFX11-WGP-NEXT:    global_store_b32 v1, v0, s[0:1]
; GFX11-WGP-NEXT:    s_nop 0
; GFX11-WGP-NEXT:    s_sendmsg sendmsg(MSG_DEALLOC_VGPRS)
; GFX11-WGP-NEXT:    s_endpgm
;
; GFX11-CU-LABEL: local_volatile_load_0:
; GFX11-CU:       ; %bb.0: ; %entry
; GFX11-CU-NEXT:    s_clause 0x1
; GFX11-CU-NEXT:    s_load_b32 s2, s[0:1], 0x0
; GFX11-CU-NEXT:    s_load_b64 s[0:1], s[0:1], 0x8
; GFX11-CU-NEXT:    s_waitcnt lgkmcnt(0)
; GFX11-CU-NEXT:    v_dual_mov_b32 v1, 0 :: v_dual_mov_b32 v0, s2
; GFX11-CU-NEXT:    ds_load_b32 v0, v0
; GFX11-CU-NEXT:    s_waitcnt lgkmcnt(0)
; GFX11-CU-NEXT:    global_store_b32 v1, v0, s[0:1]
; GFX11-CU-NEXT:    s_nop 0
; GFX11-CU-NEXT:    s_sendmsg sendmsg(MSG_DEALLOC_VGPRS)
; GFX11-CU-NEXT:    s_endpgm
    ptr addrspace(3) %in, ptr addrspace(1) %out) {
entry:
  %val = load volatile i32, ptr addrspace(3) %in, align 4
  store i32 %val, ptr addrspace(1) %out
  ret void
}

define amdgpu_kernel void @local_volatile_load_1(
; GFX6-LABEL: local_volatile_load_1:
; GFX6:       ; %bb.0: ; %entry
; GFX6-NEXT:    s_load_dword s2, s[0:1], 0x9
; GFX6-NEXT:    s_load_dwordx2 s[0:1], s[0:1], 0xb
; GFX6-NEXT:    v_lshlrev_b32_e32 v0, 2, v0
; GFX6-NEXT:    s_mov_b32 m0, -1
; GFX6-NEXT:    s_mov_b32 s3, 0xf000
; GFX6-NEXT:    s_waitcnt lgkmcnt(0)
; GFX6-NEXT:    v_add_i32_e32 v0, vcc, s2, v0
; GFX6-NEXT:    ds_read_b32 v0, v0
; GFX6-NEXT:    s_mov_b32 s2, -1
; GFX6-NEXT:    s_waitcnt lgkmcnt(0)
; GFX6-NEXT:    buffer_store_dword v0, off, s[0:3], 0
; GFX6-NEXT:    s_endpgm
;
; GFX7-LABEL: local_volatile_load_1:
; GFX7:       ; %bb.0: ; %entry
; GFX7-NEXT:    s_load_dword s2, s[4:5], 0x0
; GFX7-NEXT:    s_load_dwordx2 s[0:1], s[4:5], 0x2
; GFX7-NEXT:    v_lshlrev_b32_e32 v0, 2, v0
; GFX7-NEXT:    s_mov_b32 m0, -1
; GFX7-NEXT:    s_waitcnt lgkmcnt(0)
; GFX7-NEXT:    v_add_i32_e32 v0, vcc, s2, v0
; GFX7-NEXT:    ds_read_b32 v2, v0
; GFX7-NEXT:    v_mov_b32_e32 v0, s0
; GFX7-NEXT:    v_mov_b32_e32 v1, s1
; GFX7-NEXT:    s_waitcnt lgkmcnt(0)
; GFX7-NEXT:    flat_store_dword v[0:1], v2
; GFX7-NEXT:    s_endpgm
;
; GFX10-WGP-LABEL: local_volatile_load_1:
; GFX10-WGP:       ; %bb.0: ; %entry
; GFX10-WGP-NEXT:    s_clause 0x1
; GFX10-WGP-NEXT:    s_load_dword s2, s[4:5], 0x0
; GFX10-WGP-NEXT:    s_load_dwordx2 s[0:1], s[4:5], 0x8
; GFX10-WGP-NEXT:    v_mov_b32_e32 v1, 0
; GFX10-WGP-NEXT:    s_waitcnt lgkmcnt(0)
; GFX10-WGP-NEXT:    v_lshl_add_u32 v0, v0, 2, s2
; GFX10-WGP-NEXT:    ds_read_b32 v0, v0
; GFX10-WGP-NEXT:    s_waitcnt lgkmcnt(0)
; GFX10-WGP-NEXT:    global_store_dword v1, v0, s[0:1]
; GFX10-WGP-NEXT:    s_endpgm
;
; GFX10-CU-LABEL: local_volatile_load_1:
; GFX10-CU:       ; %bb.0: ; %entry
; GFX10-CU-NEXT:    s_clause 0x1
; GFX10-CU-NEXT:    s_load_dword s2, s[4:5], 0x0
; GFX10-CU-NEXT:    s_load_dwordx2 s[0:1], s[4:5], 0x8
; GFX10-CU-NEXT:    v_mov_b32_e32 v1, 0
; GFX10-CU-NEXT:    s_waitcnt lgkmcnt(0)
; GFX10-CU-NEXT:    v_lshl_add_u32 v0, v0, 2, s2
; GFX10-CU-NEXT:    ds_read_b32 v0, v0
; GFX10-CU-NEXT:    s_waitcnt lgkmcnt(0)
; GFX10-CU-NEXT:    global_store_dword v1, v0, s[0:1]
; GFX10-CU-NEXT:    s_endpgm
;
; SKIP-CACHE-INV-LABEL: local_volatile_load_1:
; SKIP-CACHE-INV:       ; %bb.0: ; %entry
; SKIP-CACHE-INV-NEXT:    s_load_dword s2, s[0:1], 0x0
; SKIP-CACHE-INV-NEXT:    s_load_dwordx2 s[0:1], s[0:1], 0x2
; SKIP-CACHE-INV-NEXT:    v_lshlrev_b32_e32 v0, 2, v0
; SKIP-CACHE-INV-NEXT:    s_mov_b32 m0, -1
; SKIP-CACHE-INV-NEXT:    s_mov_b32 s3, 0xf000
; SKIP-CACHE-INV-NEXT:    s_waitcnt lgkmcnt(0)
; SKIP-CACHE-INV-NEXT:    v_add_i32_e32 v0, vcc, s2, v0
; SKIP-CACHE-INV-NEXT:    ds_read_b32 v0, v0
; SKIP-CACHE-INV-NEXT:    s_mov_b32 s2, -1
; SKIP-CACHE-INV-NEXT:    s_waitcnt lgkmcnt(0)
; SKIP-CACHE-INV-NEXT:    buffer_store_dword v0, off, s[0:3], 0
; SKIP-CACHE-INV-NEXT:    s_endpgm
;
; GFX11-WGP-LABEL: local_volatile_load_1:
; GFX11-WGP:       ; %bb.0: ; %entry
; GFX11-WGP-NEXT:    s_clause 0x1
; GFX11-WGP-NEXT:    s_load_b32 s2, s[0:1], 0x0
; GFX11-WGP-NEXT:    s_load_b64 s[0:1], s[0:1], 0x8
; GFX11-WGP-NEXT:    v_mov_b32_e32 v1, 0
; GFX11-WGP-NEXT:    s_waitcnt lgkmcnt(0)
; GFX11-WGP-NEXT:    v_lshl_add_u32 v0, v0, 2, s2
; GFX11-WGP-NEXT:    ds_load_b32 v0, v0
; GFX11-WGP-NEXT:    s_waitcnt lgkmcnt(0)
; GFX11-WGP-NEXT:    global_store_b32 v1, v0, s[0:1]
; GFX11-WGP-NEXT:    s_nop 0
; GFX11-WGP-NEXT:    s_sendmsg sendmsg(MSG_DEALLOC_VGPRS)
; GFX11-WGP-NEXT:    s_endpgm
;
; GFX11-CU-LABEL: local_volatile_load_1:
; GFX11-CU:       ; %bb.0: ; %entry
; GFX11-CU-NEXT:    s_clause 0x1
; GFX11-CU-NEXT:    s_load_b32 s2, s[0:1], 0x0
; GFX11-CU-NEXT:    s_load_b64 s[0:1], s[0:1], 0x8
; GFX11-CU-NEXT:    v_mov_b32_e32 v1, 0
; GFX11-CU-NEXT:    s_waitcnt lgkmcnt(0)
; GFX11-CU-NEXT:    v_lshl_add_u32 v0, v0, 2, s2
; GFX11-CU-NEXT:    ds_load_b32 v0, v0
; GFX11-CU-NEXT:    s_waitcnt lgkmcnt(0)
; GFX11-CU-NEXT:    global_store_b32 v1, v0, s[0:1]
; GFX11-CU-NEXT:    s_nop 0
; GFX11-CU-NEXT:    s_sendmsg sendmsg(MSG_DEALLOC_VGPRS)
; GFX11-CU-NEXT:    s_endpgm
    ptr addrspace(3) %in, ptr addrspace(1) %out) {
entry:
  %tid = call i32 @llvm.amdgcn.workitem.id.x()
  %val.gep = getelementptr inbounds i32, ptr addrspace(3) %in, i32 %tid
  %val = load volatile i32, ptr addrspace(3) %val.gep, align 4
  store i32 %val, ptr addrspace(1) %out
  ret void
}

define amdgpu_kernel void @local_volatile_store_0(
; GFX6-LABEL: local_volatile_store_0:
; GFX6:       ; %bb.0: ; %entry
; GFX6-NEXT:    s_load_dwordx2 s[2:3], s[0:1], 0x9
; GFX6-NEXT:    s_load_dword s0, s[0:1], 0xb
; GFX6-NEXT:    s_mov_b32 m0, -1
; GFX6-NEXT:    s_waitcnt lgkmcnt(0)
; GFX6-NEXT:    s_load_dword s1, s[2:3], 0x0
; GFX6-NEXT:    v_mov_b32_e32 v0, s0
; GFX6-NEXT:    s_waitcnt lgkmcnt(0)
; GFX6-NEXT:    v_mov_b32_e32 v1, s1
; GFX6-NEXT:    ds_write_b32 v0, v1
; GFX6-NEXT:    s_endpgm
;
; GFX7-LABEL: local_volatile_store_0:
; GFX7:       ; %bb.0: ; %entry
; GFX7-NEXT:    s_load_dwordx2 s[0:1], s[4:5], 0x0
; GFX7-NEXT:    s_load_dword s2, s[4:5], 0x2
; GFX7-NEXT:    s_mov_b32 m0, -1
; GFX7-NEXT:    s_waitcnt lgkmcnt(0)
; GFX7-NEXT:    s_load_dword s0, s[0:1], 0x0
; GFX7-NEXT:    v_mov_b32_e32 v0, s2
; GFX7-NEXT:    s_waitcnt lgkmcnt(0)
; GFX7-NEXT:    v_mov_b32_e32 v1, s0
; GFX7-NEXT:    ds_write_b32 v0, v1
; GFX7-NEXT:    s_endpgm
;
; GFX10-WGP-LABEL: local_volatile_store_0:
; GFX10-WGP:       ; %bb.0: ; %entry
; GFX10-WGP-NEXT:    s_clause 0x1
; GFX10-WGP-NEXT:    s_load_dwordx2 s[0:1], s[4:5], 0x0
; GFX10-WGP-NEXT:    s_load_dword s2, s[4:5], 0x8
; GFX10-WGP-NEXT:    s_waitcnt lgkmcnt(0)
; GFX10-WGP-NEXT:    v_mov_b32_e32 v0, s2
; GFX10-WGP-NEXT:    s_load_dword s0, s[0:1], 0x0
; GFX10-WGP-NEXT:    s_waitcnt lgkmcnt(0)
; GFX10-WGP-NEXT:    v_mov_b32_e32 v1, s0
; GFX10-WGP-NEXT:    ds_write_b32 v0, v1
; GFX10-WGP-NEXT:    s_endpgm
;
; GFX10-CU-LABEL: local_volatile_store_0:
; GFX10-CU:       ; %bb.0: ; %entry
; GFX10-CU-NEXT:    s_clause 0x1
; GFX10-CU-NEXT:    s_load_dwordx2 s[0:1], s[4:5], 0x0
; GFX10-CU-NEXT:    s_load_dword s2, s[4:5], 0x8
; GFX10-CU-NEXT:    s_waitcnt lgkmcnt(0)
; GFX10-CU-NEXT:    v_mov_b32_e32 v0, s2
; GFX10-CU-NEXT:    s_load_dword s0, s[0:1], 0x0
; GFX10-CU-NEXT:    s_waitcnt lgkmcnt(0)
; GFX10-CU-NEXT:    v_mov_b32_e32 v1, s0
; GFX10-CU-NEXT:    ds_write_b32 v0, v1
; GFX10-CU-NEXT:    s_endpgm
;
; SKIP-CACHE-INV-LABEL: local_volatile_store_0:
; SKIP-CACHE-INV:       ; %bb.0: ; %entry
; SKIP-CACHE-INV-NEXT:    s_load_dwordx2 s[2:3], s[0:1], 0x0
; SKIP-CACHE-INV-NEXT:    s_load_dword s0, s[0:1], 0x2
; SKIP-CACHE-INV-NEXT:    s_mov_b32 m0, -1
; SKIP-CACHE-INV-NEXT:    s_waitcnt lgkmcnt(0)
; SKIP-CACHE-INV-NEXT:    s_load_dword s1, s[2:3], 0x0
; SKIP-CACHE-INV-NEXT:    v_mov_b32_e32 v0, s0
; SKIP-CACHE-INV-NEXT:    s_waitcnt lgkmcnt(0)
; SKIP-CACHE-INV-NEXT:    v_mov_b32_e32 v1, s1
; SKIP-CACHE-INV-NEXT:    ds_write_b32 v0, v1
; SKIP-CACHE-INV-NEXT:    s_endpgm
;
; GFX11-WGP-LABEL: local_volatile_store_0:
; GFX11-WGP:       ; %bb.0: ; %entry
; GFX11-WGP-NEXT:    s_clause 0x1
; GFX11-WGP-NEXT:    s_load_b64 s[2:3], s[0:1], 0x0
; GFX11-WGP-NEXT:    s_load_b32 s0, s[0:1], 0x8
; GFX11-WGP-NEXT:    s_waitcnt lgkmcnt(0)
; GFX11-WGP-NEXT:    s_load_b32 s1, s[2:3], 0x0
; GFX11-WGP-NEXT:    s_waitcnt lgkmcnt(0)
; GFX11-WGP-NEXT:    v_dual_mov_b32 v0, s0 :: v_dual_mov_b32 v1, s1
; GFX11-WGP-NEXT:    ds_store_b32 v0, v1
; GFX11-WGP-NEXT:    s_endpgm
;
; GFX11-CU-LABEL: local_volatile_store_0:
; GFX11-CU:       ; %bb.0: ; %entry
; GFX11-CU-NEXT:    s_clause 0x1
; GFX11-CU-NEXT:    s_load_b64 s[2:3], s[0:1], 0x0
; GFX11-CU-NEXT:    s_load_b32 s0, s[0:1], 0x8
; GFX11-CU-NEXT:    s_waitcnt lgkmcnt(0)
; GFX11-CU-NEXT:    s_load_b32 s1, s[2:3], 0x0
; GFX11-CU-NEXT:    s_waitcnt lgkmcnt(0)
; GFX11-CU-NEXT:    v_dual_mov_b32 v0, s0 :: v_dual_mov_b32 v1, s1
; GFX11-CU-NEXT:    ds_store_b32 v0, v1
; GFX11-CU-NEXT:    s_endpgm
    ptr addrspace(1) %in, ptr addrspace(3) %out) {
entry:
  %val = load i32, ptr addrspace(1) %in, align 4
  store volatile i32 %val, ptr addrspace(3) %out
  ret void
}

define amdgpu_kernel void @local_volatile_store_1(
; GFX6-LABEL: local_volatile_store_1:
; GFX6:       ; %bb.0: ; %entry
; GFX6-NEXT:    s_load_dwordx2 s[2:3], s[0:1], 0x9
; GFX6-NEXT:    s_load_dword s0, s[0:1], 0xb
; GFX6-NEXT:    v_lshlrev_b32_e32 v0, 2, v0
; GFX6-NEXT:    s_mov_b32 m0, -1
; GFX6-NEXT:    s_waitcnt lgkmcnt(0)
; GFX6-NEXT:    s_load_dword s1, s[2:3], 0x0
; GFX6-NEXT:    v_add_i32_e32 v0, vcc, s0, v0
; GFX6-NEXT:    s_waitcnt lgkmcnt(0)
; GFX6-NEXT:    v_mov_b32_e32 v1, s1
; GFX6-NEXT:    ds_write_b32 v0, v1
; GFX6-NEXT:    s_endpgm
;
; GFX7-LABEL: local_volatile_store_1:
; GFX7:       ; %bb.0: ; %entry
; GFX7-NEXT:    s_load_dwordx2 s[0:1], s[4:5], 0x0
; GFX7-NEXT:    s_load_dword s2, s[4:5], 0x2
; GFX7-NEXT:    v_lshlrev_b32_e32 v0, 2, v0
; GFX7-NEXT:    s_mov_b32 m0, -1
; GFX7-NEXT:    s_waitcnt lgkmcnt(0)
; GFX7-NEXT:    s_load_dword s0, s[0:1], 0x0
; GFX7-NEXT:    v_add_i32_e32 v0, vcc, s2, v0
; GFX7-NEXT:    s_waitcnt lgkmcnt(0)
; GFX7-NEXT:    v_mov_b32_e32 v1, s0
; GFX7-NEXT:    ds_write_b32 v0, v1
; GFX7-NEXT:    s_endpgm
;
; GFX10-WGP-LABEL: local_volatile_store_1:
; GFX10-WGP:       ; %bb.0: ; %entry
; GFX10-WGP-NEXT:    s_clause 0x1
; GFX10-WGP-NEXT:    s_load_dwordx2 s[0:1], s[4:5], 0x0
; GFX10-WGP-NEXT:    s_load_dword s2, s[4:5], 0x8
; GFX10-WGP-NEXT:    s_waitcnt lgkmcnt(0)
; GFX10-WGP-NEXT:    v_lshl_add_u32 v0, v0, 2, s2
; GFX10-WGP-NEXT:    s_load_dword s0, s[0:1], 0x0
; GFX10-WGP-NEXT:    s_waitcnt lgkmcnt(0)
; GFX10-WGP-NEXT:    v_mov_b32_e32 v1, s0
; GFX10-WGP-NEXT:    ds_write_b32 v0, v1
; GFX10-WGP-NEXT:    s_endpgm
;
; GFX10-CU-LABEL: local_volatile_store_1:
; GFX10-CU:       ; %bb.0: ; %entry
; GFX10-CU-NEXT:    s_clause 0x1
; GFX10-CU-NEXT:    s_load_dwordx2 s[0:1], s[4:5], 0x0
; GFX10-CU-NEXT:    s_load_dword s2, s[4:5], 0x8
; GFX10-CU-NEXT:    s_waitcnt lgkmcnt(0)
; GFX10-CU-NEXT:    v_lshl_add_u32 v0, v0, 2, s2
; GFX10-CU-NEXT:    s_load_dword s0, s[0:1], 0x0
; GFX10-CU-NEXT:    s_waitcnt lgkmcnt(0)
; GFX10-CU-NEXT:    v_mov_b32_e32 v1, s0
; GFX10-CU-NEXT:    ds_write_b32 v0, v1
; GFX10-CU-NEXT:    s_endpgm
;
; SKIP-CACHE-INV-LABEL: local_volatile_store_1:
; SKIP-CACHE-INV:       ; %bb.0: ; %entry
; SKIP-CACHE-INV-NEXT:    s_load_dwordx2 s[2:3], s[0:1], 0x0
; SKIP-CACHE-INV-NEXT:    s_load_dword s0, s[0:1], 0x2
; SKIP-CACHE-INV-NEXT:    v_lshlrev_b32_e32 v0, 2, v0
; SKIP-CACHE-INV-NEXT:    s_mov_b32 m0, -1
; SKIP-CACHE-INV-NEXT:    s_waitcnt lgkmcnt(0)
; SKIP-CACHE-INV-NEXT:    s_load_dword s1, s[2:3], 0x0
; SKIP-CACHE-INV-NEXT:    v_add_i32_e32 v0, vcc, s0, v0
; SKIP-CACHE-INV-NEXT:    s_waitcnt lgkmcnt(0)
; SKIP-CACHE-INV-NEXT:    v_mov_b32_e32 v1, s1
; SKIP-CACHE-INV-NEXT:    ds_write_b32 v0, v1
; SKIP-CACHE-INV-NEXT:    s_endpgm
;
; GFX11-WGP-LABEL: local_volatile_store_1:
; GFX11-WGP:       ; %bb.0: ; %entry
; GFX11-WGP-NEXT:    s_clause 0x1
; GFX11-WGP-NEXT:    s_load_b64 s[2:3], s[0:1], 0x0
; GFX11-WGP-NEXT:    s_load_b32 s0, s[0:1], 0x8
; GFX11-WGP-NEXT:    s_waitcnt lgkmcnt(0)
; GFX11-WGP-NEXT:    s_load_b32 s1, s[2:3], 0x0
; GFX11-WGP-NEXT:    v_lshl_add_u32 v0, v0, 2, s0
; GFX11-WGP-NEXT:    s_waitcnt lgkmcnt(0)
; GFX11-WGP-NEXT:    v_mov_b32_e32 v1, s1
; GFX11-WGP-NEXT:    ds_store_b32 v0, v1
; GFX11-WGP-NEXT:    s_endpgm
;
; GFX11-CU-LABEL: local_volatile_store_1:
; GFX11-CU:       ; %bb.0: ; %entry
; GFX11-CU-NEXT:    s_clause 0x1
; GFX11-CU-NEXT:    s_load_b64 s[2:3], s[0:1], 0x0
; GFX11-CU-NEXT:    s_load_b32 s0, s[0:1], 0x8
; GFX11-CU-NEXT:    s_waitcnt lgkmcnt(0)
; GFX11-CU-NEXT:    s_load_b32 s1, s[2:3], 0x0
; GFX11-CU-NEXT:    v_lshl_add_u32 v0, v0, 2, s0
; GFX11-CU-NEXT:    s_waitcnt lgkmcnt(0)
; GFX11-CU-NEXT:    v_mov_b32_e32 v1, s1
; GFX11-CU-NEXT:    ds_store_b32 v0, v1
; GFX11-CU-NEXT:    s_endpgm
    ptr addrspace(1) %in, ptr addrspace(3) %out) {
entry:
  %tid = call i32 @llvm.amdgcn.workitem.id.x()
  %val = load i32, ptr addrspace(1) %in, align 4
  %out.gep = getelementptr inbounds i32, ptr addrspace(3) %out, i32 %tid
  store volatile i32 %val, ptr addrspace(3) %out.gep
  ret void
}

define amdgpu_kernel void @local_volatile_workgroup_acquire_load(
; GFX6-LABEL: local_volatile_workgroup_acquire_load:
; GFX6:       ; %bb.0: ; %entry
; GFX6-NEXT:    s_load_dwordx2 s[0:1], s[0:1], 0x9
; GFX6-NEXT:    s_mov_b32 m0, -1
; GFX6-NEXT:    s_waitcnt lgkmcnt(0)
; GFX6-NEXT:    v_mov_b32_e32 v0, s0
; GFX6-NEXT:    ds_read_b32 v0, v0
; GFX6-NEXT:    s_waitcnt lgkmcnt(0)
; GFX6-NEXT:    v_mov_b32_e32 v1, s1
; GFX6-NEXT:    ds_write_b32 v1, v0
; GFX6-NEXT:    s_endpgm
;
; GFX7-LABEL: local_volatile_workgroup_acquire_load:
; GFX7:       ; %bb.0: ; %entry
; GFX7-NEXT:    s_load_dwordx2 s[0:1], s[4:5], 0x0
; GFX7-NEXT:    s_mov_b32 m0, -1
; GFX7-NEXT:    s_waitcnt lgkmcnt(0)
; GFX7-NEXT:    v_mov_b32_e32 v0, s0
; GFX7-NEXT:    ds_read_b32 v0, v0
; GFX7-NEXT:    s_waitcnt lgkmcnt(0)
; GFX7-NEXT:    v_mov_b32_e32 v1, s1
; GFX7-NEXT:    ds_write_b32 v1, v0
; GFX7-NEXT:    s_endpgm
;
; GFX10-WGP-LABEL: local_volatile_workgroup_acquire_load:
; GFX10-WGP:       ; %bb.0: ; %entry
; GFX10-WGP-NEXT:    s_load_dwordx2 s[0:1], s[4:5], 0x0
; GFX10-WGP-NEXT:    s_waitcnt lgkmcnt(0)
; GFX10-WGP-NEXT:    v_mov_b32_e32 v0, s0
; GFX10-WGP-NEXT:    v_mov_b32_e32 v1, s1
; GFX10-WGP-NEXT:    ds_read_b32 v0, v0
; GFX10-WGP-NEXT:    s_waitcnt lgkmcnt(0)
; GFX10-WGP-NEXT:    buffer_gl0_inv
; GFX10-WGP-NEXT:    ds_write_b32 v1, v0
; GFX10-WGP-NEXT:    s_endpgm
;
; GFX10-CU-LABEL: local_volatile_workgroup_acquire_load:
; GFX10-CU:       ; %bb.0: ; %entry
; GFX10-CU-NEXT:    s_load_dwordx2 s[0:1], s[4:5], 0x0
; GFX10-CU-NEXT:    s_waitcnt lgkmcnt(0)
; GFX10-CU-NEXT:    v_mov_b32_e32 v0, s0
; GFX10-CU-NEXT:    v_mov_b32_e32 v1, s1
; GFX10-CU-NEXT:    ds_read_b32 v0, v0
; GFX10-CU-NEXT:    s_waitcnt lgkmcnt(0)
; GFX10-CU-NEXT:    ds_write_b32 v1, v0
; GFX10-CU-NEXT:    s_endpgm
;
; SKIP-CACHE-INV-LABEL: local_volatile_workgroup_acquire_load:
; SKIP-CACHE-INV:       ; %bb.0: ; %entry
; SKIP-CACHE-INV-NEXT:    s_load_dwordx2 s[0:1], s[0:1], 0x0
; SKIP-CACHE-INV-NEXT:    s_mov_b32 m0, -1
; SKIP-CACHE-INV-NEXT:    s_waitcnt lgkmcnt(0)
; SKIP-CACHE-INV-NEXT:    v_mov_b32_e32 v0, s0
; SKIP-CACHE-INV-NEXT:    ds_read_b32 v0, v0
; SKIP-CACHE-INV-NEXT:    s_waitcnt lgkmcnt(0)
; SKIP-CACHE-INV-NEXT:    v_mov_b32_e32 v1, s1
; SKIP-CACHE-INV-NEXT:    ds_write_b32 v1, v0
; SKIP-CACHE-INV-NEXT:    s_endpgm
;
; GFX11-WGP-LABEL: local_volatile_workgroup_acquire_load:
; GFX11-WGP:       ; %bb.0: ; %entry
; GFX11-WGP-NEXT:    s_load_b64 s[0:1], s[0:1], 0x0
; GFX11-WGP-NEXT:    s_waitcnt lgkmcnt(0)
; GFX11-WGP-NEXT:    v_dual_mov_b32 v0, s0 :: v_dual_mov_b32 v1, s1
; GFX11-WGP-NEXT:    ds_load_b32 v0, v0
; GFX11-WGP-NEXT:    s_waitcnt lgkmcnt(0)
; GFX11-WGP-NEXT:    buffer_gl0_inv
; GFX11-WGP-NEXT:    ds_store_b32 v1, v0
; GFX11-WGP-NEXT:    s_endpgm
;
; GFX11-CU-LABEL: local_volatile_workgroup_acquire_load:
; GFX11-CU:       ; %bb.0: ; %entry
; GFX11-CU-NEXT:    s_load_b64 s[0:1], s[0:1], 0x0
; GFX11-CU-NEXT:    s_waitcnt lgkmcnt(0)
; GFX11-CU-NEXT:    v_dual_mov_b32 v0, s0 :: v_dual_mov_b32 v1, s1
; GFX11-CU-NEXT:    ds_load_b32 v0, v0
; GFX11-CU-NEXT:    s_waitcnt lgkmcnt(0)
; GFX11-CU-NEXT:    ds_store_b32 v1, v0
; GFX11-CU-NEXT:    s_endpgm
    ptr addrspace(3) %in, ptr addrspace(3) %out) {
entry:
  %val = load atomic volatile i32, ptr addrspace(3) %in syncscope("workgroup") acquire, align 4
  store i32 %val, ptr addrspace(3) %out
  ret void
}

define amdgpu_kernel void @local_volatile_workgroup_release_store(
; GFX6-LABEL: local_volatile_workgroup_release_store:
; GFX6:       ; %bb.0: ; %entry
; GFX6-NEXT:    s_load_dwordx2 s[0:1], s[0:1], 0x9
; GFX6-NEXT:    s_mov_b32 m0, -1
; GFX6-NEXT:    s_waitcnt lgkmcnt(0)
; GFX6-NEXT:    v_mov_b32_e32 v0, s1
; GFX6-NEXT:    v_mov_b32_e32 v1, s0
; GFX6-NEXT:    ds_write_b32 v0, v1
; GFX6-NEXT:    s_endpgm
;
; GFX7-LABEL: local_volatile_workgroup_release_store:
; GFX7:       ; %bb.0: ; %entry
; GFX7-NEXT:    s_load_dwordx2 s[0:1], s[4:5], 0x0
; GFX7-NEXT:    s_mov_b32 m0, -1
; GFX7-NEXT:    s_waitcnt lgkmcnt(0)
; GFX7-NEXT:    v_mov_b32_e32 v0, s1
; GFX7-NEXT:    v_mov_b32_e32 v1, s0
; GFX7-NEXT:    ds_write_b32 v0, v1
; GFX7-NEXT:    s_endpgm
;
; GFX10-WGP-LABEL: local_volatile_workgroup_release_store:
; GFX10-WGP:       ; %bb.0: ; %entry
; GFX10-WGP-NEXT:    s_load_dwordx2 s[0:1], s[4:5], 0x0
; GFX10-WGP-NEXT:    s_waitcnt lgkmcnt(0)
; GFX10-WGP-NEXT:    v_mov_b32_e32 v0, s1
; GFX10-WGP-NEXT:    v_mov_b32_e32 v1, s0
; GFX10-WGP-NEXT:    ds_write_b32 v0, v1
; GFX10-WGP-NEXT:    s_endpgm
;
; GFX10-CU-LABEL: local_volatile_workgroup_release_store:
; GFX10-CU:       ; %bb.0: ; %entry
; GFX10-CU-NEXT:    s_load_dwordx2 s[0:1], s[4:5], 0x0
; GFX10-CU-NEXT:    s_waitcnt lgkmcnt(0)
; GFX10-CU-NEXT:    v_mov_b32_e32 v0, s1
; GFX10-CU-NEXT:    v_mov_b32_e32 v1, s0
; GFX10-CU-NEXT:    ds_write_b32 v0, v1
; GFX10-CU-NEXT:    s_endpgm
;
; SKIP-CACHE-INV-LABEL: local_volatile_workgroup_release_store:
; SKIP-CACHE-INV:       ; %bb.0: ; %entry
; SKIP-CACHE-INV-NEXT:    s_load_dwordx2 s[0:1], s[0:1], 0x0
; SKIP-CACHE-INV-NEXT:    s_mov_b32 m0, -1
; SKIP-CACHE-INV-NEXT:    s_waitcnt lgkmcnt(0)
; SKIP-CACHE-INV-NEXT:    v_mov_b32_e32 v0, s1
; SKIP-CACHE-INV-NEXT:    v_mov_b32_e32 v1, s0
; SKIP-CACHE-INV-NEXT:    ds_write_b32 v0, v1
; SKIP-CACHE-INV-NEXT:    s_endpgm
;
; GFX11-WGP-LABEL: local_volatile_workgroup_release_store:
; GFX11-WGP:       ; %bb.0: ; %entry
; GFX11-WGP-NEXT:    s_load_b64 s[0:1], s[0:1], 0x0
; GFX11-WGP-NEXT:    s_waitcnt lgkmcnt(0)
; GFX11-WGP-NEXT:    v_dual_mov_b32 v0, s1 :: v_dual_mov_b32 v1, s0
; GFX11-WGP-NEXT:    ds_store_b32 v0, v1
; GFX11-WGP-NEXT:    s_endpgm
;
; GFX11-CU-LABEL: local_volatile_workgroup_release_store:
; GFX11-CU:       ; %bb.0: ; %entry
; GFX11-CU-NEXT:    s_load_b64 s[0:1], s[0:1], 0x0
; GFX11-CU-NEXT:    s_waitcnt lgkmcnt(0)
; GFX11-CU-NEXT:    v_dual_mov_b32 v0, s1 :: v_dual_mov_b32 v1, s0
; GFX11-CU-NEXT:    ds_store_b32 v0, v1
; GFX11-CU-NEXT:    s_endpgm
   i32 %in, ptr addrspace(3) %out) {
entry:
  store atomic volatile i32 %in, ptr addrspace(3) %out syncscope("workgroup") release, align 4
  ret void
}

declare i32 @llvm.amdgcn.workitem.id.x()
