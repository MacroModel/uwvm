﻿#pragma once
#include <cstddef>
#include <fast_io.h>
#include <fast_io_dsal/string_view.h>
#ifdef UWVM_TIMER
    #include <fast_io_driver/timer.h>
#endif
#include <io_device.h>

#include "../check_index.h"
#include "../module.h"
#include "scan_section.h"
#include "check_module.h"

namespace uwvm::wasm
{
    inline
#if defined(__has_builtin)
    #if __has_builtin(__builtin_memcmp)
        constexpr
    #endif
#endif
        bool
        is_wasm_file_unchecked(::std::byte const* curr) noexcept
    {
        return ::fast_io::freestanding::my_memcmp(curr, u8"\0asm", 4u * sizeof(char8_t)) == 0;
    }

    inline
#if defined(__has_builtin)
    #if __has_builtin(__builtin_memcpy)
        constexpr
    #endif
#endif
        ::std::uint_least32_t
        detect_wasm_version_unchecked(::std::byte const* curr) noexcept
    {
        ::std::uint_least32_t temp{};
        ::fast_io::freestanding::my_memcpy(__builtin_addressof(temp), curr, sizeof(::std::uint_least32_t));
        return ::fast_io::little_endian(temp);
    }

    inline void scan_wasm_module(::uwvm::wasm::wasm_module& wasmmod, ::fast_io::u8string_view name, ::std::byte const* begin, ::std::byte const* end) noexcept
    {
#ifdef UWVM_TIMER
        ::fast_io::timer scan_timer{u8"uwvm: [timer] scan module"};
#endif
        // alias def
        using char8_t_may_alias_ptr
#if __has_cpp_attribute(__gnu__::__may_alias__)
            [[__gnu__::__may_alias__]]
#endif
            = char8_t*;
        using char8_t_const_may_alias_ptr
#if __has_cpp_attribute(__gnu__::__may_alias__)
            [[__gnu__::__may_alias__]]
#endif
            = char8_t const*;

        // wasm information
        wasmmod.module_begin = begin;
        wasmmod.module_end = end;
        wasmmod.module_name = name;

        // curr
        auto curr{begin};

        // min size of wasm file format = 4 + 4
        // check wasm magic number
        if(static_cast<::std::size_t>(end - curr) < 8U || !is_wasm_file_unchecked(curr)) [[unlikely]]
        {
            ::fast_io::io::perr(::uwvm::u8err,
                                u8"\033[0m"
#ifdef __MSDOS__
                                u8"\033[37m"
#else
                                u8"\033[97m"
#endif
                                u8"uwvm: "
                                u8"\033[31m"
                                u8"[fatal] "
                                u8"\033[0m"
#ifdef __MSDOS__
                                u8"\033[37m"
#else
                                u8"\033[97m"
#endif
                                u8"(offset=",
                                ::fast_io::mnp::addrvw(curr - begin),
                                u8") "
                                u8"Illegal WASM file format.\n"
                                u8"\033[0m"
                                u8"Terminate.\n\n");
            ::fast_io::fast_terminate();
        }

        // get wasm version
        curr += 4U;
        wasmmod.wasm_version = detect_wasm_version_unchecked(curr);

        // get first section
        curr += 4U;

        if(static_cast<::std::size_t>(end - curr) < 2U || curr > end) [[unlikely]]
        {
            ::fast_io::io::perr(::uwvm::u8err,
                                u8"\033[0m"
#ifdef __MSDOS__
                                u8"\033[37m"
#else
                                u8"\033[97m"
#endif
                                u8"uwvm: "
                                u8"\033[31m"
                                u8"[fatal] "
                                u8"\033[0m"
#ifdef __MSDOS__
                                u8"\033[37m"
#else
                                u8"\033[97m"
#endif
                                u8"(offset=",
                                ::fast_io::mnp::addrvw(curr - begin),
                                u8") "
                                u8"No WASM sections found.\n"
                                u8"\033[0m"
                                u8"Terminate.\n\n");
            ::fast_io::fast_terminate();
        }

        // objdump
        for(;;)
        {
            // get section type
            ::std::uint_fast8_t sec_num{};
            ::fast_io::freestanding::my_memcpy(__builtin_addressof(sec_num), curr, sizeof(::std::uint_fast8_t));

            // get section length
            ++curr;
            ::std::size_t sec_len{};
            auto const [next, err]{::fast_io::parse_by_scan(reinterpret_cast<char8_t_const_may_alias_ptr>(curr),
                                                            reinterpret_cast<char8_t_const_may_alias_ptr>(end),
                                                            ::fast_io::mnp::leb128_get(sec_len))};
            switch(err)
            {
                case ::fast_io::parse_code::ok: break;
                default:
                    [[unlikely]]
                    {
                        ::fast_io::io::perr(::uwvm::u8err,
                                u8"\033[0m"
#ifdef __MSDOS__
                                u8"\033[37m"
#else
                                u8"\033[97m"
#endif
                                u8"uwvm: "
                                u8"\033[31m"
                                u8"[fatal] "
                                u8"\033[0m"
#ifdef __MSDOS__
                                u8"\033[37m"
#else
                                u8"\033[97m"
#endif
                                u8"(offset=",
                                ::fast_io::mnp::addrvw(curr - begin),
                                u8") "
                                u8"Invalid section length."
                                u8"\n"
                                u8"\033[0m"
                                u8"Terminate.\n\n");
                        ::fast_io::fast_terminate();
                    }
            }

            // check 64-bit indexes
            ::uwvm::wasm::check_index(sec_len);

            // set curr to next
            curr = reinterpret_cast<::std::byte const*>(next);

            // check length
            if(static_cast<::std::size_t>(end - curr) < sec_len || curr > end) [[unlikely]]
            {
                ::fast_io::io::perr(::uwvm::u8err,
                                u8"\033[0m"
#ifdef __MSDOS__
                                u8"\033[37m"
#else
                                u8"\033[97m"
#endif
                                u8"uwvm: "
                                u8"\033[31m"
                                u8"[fatal] "
                                u8"\033[0m"
#ifdef __MSDOS__
                                u8"\033[37m"
#else
                                u8"\033[97m"
#endif
                                u8"(offset=",
                                ::fast_io::mnp::addrvw(curr - begin),
                                u8") "
                                u8"Invalid section length."
                                u8"\n"
                                u8"\033[0m"
                                u8"Terminate.\n\n");
                ::fast_io::fast_terminate();
            }

            // sec end
            auto const sec_end{curr + sec_len};

            // check
            auto const sec_type{static_cast<::uwvm::wasm::section_type>(sec_num)};
            switch(sec_type)
            {
                case ::uwvm::wasm::section_type::custom_sec:
                {
                    ::uwvm::wasm::scan_custom_section(wasmmod, curr, sec_end);
                    break;
                }
                case ::uwvm::wasm::section_type::type_sec:
                {
                    ::uwvm::wasm::scan_type_section(wasmmod, curr, sec_end);
                    break;
                }
                case ::uwvm::wasm::section_type::import_sec:
                {
                    ::uwvm::wasm::scan_import_section(wasmmod, curr, sec_end);
                    break;
                }
                case ::uwvm::wasm::section_type::function_sec:
                {
                    ::uwvm::wasm::scan_function_section(wasmmod, curr, sec_end);
                    break;
                }
                case ::uwvm::wasm::section_type::table_sec:
                {
                    ::uwvm::wasm::scan_table_section(wasmmod, curr, sec_end);
                    break;
                }
                case ::uwvm::wasm::section_type::memory_sec:
                {
                    ::uwvm::wasm::scan_memory_section(wasmmod, curr, sec_end);
                    break;
                }
                case ::uwvm::wasm::section_type::global_sec:
                {
                    ::uwvm::wasm::scan_global_section(wasmmod, curr, sec_end);
                    break;
                }
                case ::uwvm::wasm::section_type::export_sec:
                {
                    ::uwvm::wasm::scan_export_section(wasmmod, curr, sec_end);
                    break;
                }
                case ::uwvm::wasm::section_type::start_sec:
                {
                    ::uwvm::wasm::scan_start_section(wasmmod, curr, sec_end);
                    break;
                }
                case ::uwvm::wasm::section_type::element_sec:
                {
                    ::uwvm::wasm::scan_element_section(wasmmod, curr, sec_end);
                    break;
                }
                case ::uwvm::wasm::section_type::code_sec:
                {
                    ::uwvm::wasm::scan_code_section(wasmmod, curr, sec_end);
                    break;
                }
                case ::uwvm::wasm::section_type::data_sec:
                {
                    ::uwvm::wasm::scan_data_section(wasmmod, curr, sec_end);
                    break;
                }
                case ::uwvm::wasm::section_type::data_count_sec: break;
                case ::uwvm::wasm::section_type::tag_sec: break;
                default:
                    [[unlikely]]
                    {
                        ::fast_io::io::perr(::uwvm::u8err,
                                u8"\033[0m"
#ifdef __MSDOS__
                                u8"\033[37m"
#else
                                u8"\033[97m"
#endif
                                u8"uwvm: "
                                u8"\033[31m"
                                u8"[fatal] "
                                u8"\033[0m"
#ifdef __MSDOS__
                                u8"\033[37m"
#else
                                u8"\033[97m"
#endif
                                u8"(offset=",
                                ::fast_io::mnp::addrvw(curr - begin),
                                u8") "
                                u8"Unknown WASM section: ",
                                ::fast_io::mnp::hex0x<true>(sec_num),
                                u8"\n"
                                u8"\033[0m"
                                u8"Terminate.\n\n");
                        ::fast_io::fast_terminate();
                    }
            } 

            // set curr
            curr = sec_end;

            // check next section
            if(auto const dif{static_cast<::std::size_t>(end - curr)}; dif == 0U) { break; }
            else if(dif < 2U || curr > end) [[unlikely]]
            {
                ::fast_io::io::perr(::uwvm::u8err,
                                u8"\033[0m"
#ifdef __MSDOS__
                                u8"\033[37m"
#else
                                u8"\033[97m"
#endif
                                u8"uwvm: "
                                u8"\033[31m"
                                u8"[fatal] "
                                u8"\033[0m"
#ifdef __MSDOS__
                                u8"\033[37m"
#else
                                u8"\033[97m"
#endif
                                u8"(offset=",
                                ::fast_io::mnp::addrvw(curr - begin),
                                u8") "
                                u8"Unable to read leb128."
                                u8"\n"
                                u8"\033[0m"
                                u8"Terminate.\n\n");
                ::fast_io::fast_terminate();
            }
        }

        // check
        ::uwvm::wasm::check_wasm_module(wasmmod);
    }
}  // namespace uwvm
