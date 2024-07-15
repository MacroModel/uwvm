#pragma once

#if defined(__DragonFly__) || defined(__FreeBSD__) || defined(__FreeBSD_kernel__) || defined(__NetBSD__) || defined(BSD) || defined(_SYSTYPE_BSD) ||           \
    defined(__OpenBSD__)
    #include <sys/types.h>
    #include <sys/sysctl.h>
    #include <dlfcn.h>
#elif defined(__APPLE__) || defined(__DARWIN_C_LEVEL)
    #include <crt_externs.h>
#endif

#include <fast_io.h>
#include <fast_io_dsal/string.h>
#include <fast_io_dsal/string_view.h>
#include "abi.h"
#include "../../../run/wasm_file.h"
#include "../../../clpara/parsing_result.h"
#include "../memory/memory.h"

namespace uwvm::vm::interpreter::wasi
{
    ::std::int_least32_t args_get(::std::int_least32_t arg0, ::std::int_least32_t arg1) noexcept
    {
        auto& memory{::uwvm::vm::interpreter::memories.front()};
        auto const memory_begin{memory.memory_begin};
        auto const memory_length{memory.memory_length};
        auto const memory_end{memory_begin + memory_length};

        auto argv_begin{memory_begin + static_cast<::std::size_t>(arg0)};

        auto const pr_cend{::uwvm::parsing_result.cend()};

        if(argv_begin + sizeof(::std::uint_least32_t) * static_cast<::std::size_t>(pr_cend - (::uwvm::parsing_result.cbegin() + ::uwvm::wasm_file_ppos)) >=
           memory_end) [[unlikely]]
        {
            return static_cast<::std::int_least32_t>(::uwvm::vm::interpreter::wasi::errno_t::efault);
        }

        using uint_least32_t_may_alias_ptr
#if __has_cpp_attribute(__gnu__::__may_alias__)
            [[__gnu__::__may_alias__]]
#endif
            = ::std::uint_least32_t*;

        auto argv_i32p{reinterpret_cast<uint_least32_t_may_alias_ptr>(argv_begin)};

        using char8_t_may_alias_ptr
#if __has_cpp_attribute(__gnu__::__may_alias__)
            [[__gnu__::__may_alias__]]
#endif
            = char8_t*;

        auto argv_buf_begin{reinterpret_cast<char8_t_may_alias_ptr>(memory_begin + static_cast<::std::size_t>(arg1))};

        for(auto i{::uwvm::parsing_result.cbegin() + ::uwvm::wasm_file_ppos}; i < pr_cend; ++i)
        {
            auto const argv_buf_offset_le32{
                ::fast_io::little_endian(static_cast<::std::uint_least32_t>(argv_buf_begin - reinterpret_cast<char8_t_may_alias_ptr>(memory_begin)))};
            ::fast_io::freestanding::my_memcpy(argv_i32p, __builtin_addressof(argv_buf_offset_le32), sizeof(argv_buf_offset_le32));
            auto const length{i->str.size()};

            if(reinterpret_cast<::std::byte*>(argv_buf_begin) + length >= memory_end) [[unlikely]]
            {
                return static_cast<::std::int_least32_t>(::uwvm::vm::interpreter::wasi::errno_t::efault);
            }

            ::fast_io::freestanding::my_memcpy(argv_buf_begin, i->str.data(), length);

            ++argv_i32p;
            argv_buf_begin += length;
            *argv_buf_begin++ = u8'\0';
        }

        return static_cast<::std::int_least32_t>(::uwvm::vm::interpreter::wasi::errno_t::esuccess);
    }

    ::std::int_least32_t args_sizes_get(::std::int_least32_t arg0, ::std::int_least32_t arg1) noexcept
    {
        auto& memory{::uwvm::vm::interpreter::memories.front()};
        auto const memory_begin{memory.memory_begin};
        auto const memory_length{memory.memory_length};
        auto const memory_end{memory_begin + memory_length};
        auto const pr_cend{::uwvm::parsing_result.cend()};

        // argc begin
        auto const argc_begin{memory_begin + static_cast<::std::size_t>(arg0)};
        if(argc_begin + sizeof(::uwvm::vm::interpreter::wasi::wasi_size_t) >= memory_end) [[unlikely]]
        {
            return static_cast<::std::int_least32_t>(::uwvm::vm::interpreter::wasi::errno_t::efault);
        }

        using wasi_size_t_may_alias_ptr
#if __has_cpp_attribute(__gnu__::__may_alias__)
            [[__gnu__::__may_alias__]]
#endif
            = ::uwvm::vm::interpreter::wasi::wasi_size_t*;

        auto argv_i32p{reinterpret_cast<wasi_size_t_may_alias_ptr>(argc_begin)};

        auto const argv_wasm{static_cast<::uwvm::vm::interpreter::wasi::wasi_size_t>(pr_cend - (::uwvm::parsing_result.cbegin() + ::uwvm::wasm_file_ppos))};

        auto const argv_wasm_le32{::fast_io::little_endian(static_cast<::std::uint_least32_t>(argv_wasm))};

        ::fast_io::freestanding::my_memcpy(argv_i32p, __builtin_addressof(argv_wasm_le32), sizeof(::std::uint_least32_t));

        // buf len
        auto const buf_len_begin{memory_begin + static_cast<::std::size_t>(arg1)};
        if(buf_len_begin + sizeof(::uwvm::vm::interpreter::wasi::wasi_size_t) >= memory_end) [[unlikely]]
        {
            return static_cast<::std::int_least32_t>(::uwvm::vm::interpreter::wasi::errno_t::efault);
        }

        ::std::uint_least32_t buf_len{};

        for(auto i{::uwvm::parsing_result.cbegin() + ::uwvm::wasm_file_ppos}; i < pr_cend; ++i) { buf_len += i->str.size() + 1; }

        auto const buf_len_le32{::fast_io::little_endian(static_cast<::std::uint_least32_t>(buf_len))};

        ::fast_io::freestanding::my_memcpy(buf_len_begin, __builtin_addressof(buf_len), sizeof(::std::uint_least32_t));

        return static_cast<::std::int_least32_t>(::uwvm::vm::interpreter::wasi::errno_t::esuccess);
    }

    ::std::int_least32_t environ_get(::std::int_least32_t arg0, ::std::int_least32_t arg1) noexcept
    {
        auto& memory{::uwvm::vm::interpreter::memories.front()};
        auto const memory_begin{memory.memory_begin};
        auto const memory_length{memory.memory_length};
        auto const memory_end{memory_begin + memory_length};

        auto env_para_begin{memory_begin + static_cast<::std::size_t>(arg0)};

        auto const pr_cend{::uwvm::parsing_result.cend()};

        if(env_para_begin + sizeof(::std::uint_least32_t) * static_cast<::std::size_t>(pr_cend - (::uwvm::parsing_result.cbegin() + ::uwvm::wasm_file_ppos)) >=
           memory_end) [[unlikely]]
        {
            return static_cast<::std::int_least32_t>(::uwvm::vm::interpreter::wasi::errno_t::efault);
        }

        using uint_least32_t_may_alias_ptr
#if __has_cpp_attribute(__gnu__::__may_alias__)
            [[__gnu__::__may_alias__]]
#endif
            = ::std::uint_least32_t*;

        [[maybe_unused]] auto env_para_i32p{reinterpret_cast<uint_least32_t_may_alias_ptr>(env_para_begin)};

        using char8_t_may_alias_ptr
#if __has_cpp_attribute(__gnu__::__may_alias__)
            [[__gnu__::__may_alias__]]
#endif
            = char8_t*;

        [[maybe_unused]] auto env_buf_begin{reinterpret_cast<char8_t_may_alias_ptr>(memory_begin + static_cast<::std::size_t>(arg1))};

#if defined(__linux__)
        ::fast_io::u8native_file envs{u8"/proc/self/environ", ::fast_io::open_mode::in};
        auto const env_buf_end{::fast_io::operations::read_some(envs, env_buf_begin, reinterpret_cast<char8_t_may_alias_ptr>(memory_end))};
        for(; env_buf_begin < env_buf_end;)
        {
            auto const env_buf_offset_le32{
                ::fast_io::little_endian(static_cast<::std::uint_least32_t>(env_buf_begin - reinterpret_cast<char8_t_may_alias_ptr>(memory_begin)))};
            ::fast_io::freestanding::my_memcpy(env_para_i32p, __builtin_addressof(env_buf_offset_le32), sizeof(env_buf_offset_le32));

            auto const pos{::std::find(env_buf_begin, env_buf_end, u8'\0')};

            env_buf_begin = pos + 1;
            if(*env_buf_begin == u8'0') [[unlikely]] { break; }
            ++env_para_i32p;
        }

#elif defined(__DragonFly__) || defined(__FreeBSD__) || defined(__FreeBSD_kernel__) || defined(__NetBSD__) || defined(BSD) || defined(_SYSTYPE_BSD)
    #if defined(__NetBSD__)
        int mib[4]{CTL_KERN, KERN_PROC_ARGS, -1, KERN_PROC_ENV};
    #else
        int mib[4]{CTL_KERN, KERN_PROC, KERN_PROC_ENV, -1};
    #endif
        ::std::size_t size{static_cast<::std::size_t>(memory_end - reinterpret_cast<::std::byte*>(env_buf_begin))};

        if(::fast_io::noexcept_call(::sysctl, mib, 4, env_buf_begin, __builtin_addressof(size), nullptr, 0) != 0) [[unlikely]]
        {
            return static_cast<::std::int_least32_t>(::uwvm::vm::interpreter::wasi::errno_t::efault);
        }

        auto const env_buf_end{env_buf_begin + size};

        for(; env_buf_begin < env_buf_end;)
        {
            auto const env_buf_offset_le32{
                ::fast_io::little_endian(static_cast<::std::uint_least32_t>(env_buf_begin - reinterpret_cast<char8_t_may_alias_ptr>(memory_begin)))};
            ::fast_io::freestanding::my_memcpy(env_para_i32p, __builtin_addressof(env_buf_offset_le32), sizeof(env_buf_offset_le32));

            auto const pos{::std::find(env_buf_begin, env_buf_end, u8'\0')};

            env_buf_begin = pos + 1;
            if(*env_buf_begin == u8'0') [[unlikely]] { break; }
            ++env_para_i32p;
        }

#elif defined(__OpenBSD__)
        int mib[4]{CTL_KERN, KERN_PROC_ARGS, getpid(), KERN_PROC_ENV};

        ::std::size_t size{};

        if(::fast_io::noexcept_call(::sysctl, mib, 4, nullptr, __builtin_addressof(size), nullptr, 0) != 0) [[unlikely]]
        {
            return static_cast<::std::int_least32_t>(::uwvm::vm::interpreter::wasi::errno_t::efault);
        }

        if(size > static_cast<::std::size_t>(memory_end - reinterpret_cast<::std::byte*>(env_buf_begin))) [[unlikely]]
        {
            return static_cast<::std::int_least32_t>(::uwvm::vm::interpreter::wasi::errno_t::efault);
        }

        if(::fast_io::noexcept_call(::sysctl, mib, 4, env_buf_begin, __builtin_addressof(size), nullptr, 0) != 0) [[unlikely]]
        {
            return static_cast<::std::int_least32_t>(::uwvm::vm::interpreter::wasi::errno_t::efault);
        }

        auto const env_buf_end{env_buf_begin + size};

        for(; env_buf_begin < env_buf_end;)
        {
            auto const env_buf_offset_le32{
                ::fast_io::little_endian(static_cast<::std::uint_least32_t>(env_buf_begin - reinterpret_cast<char8_t_may_alias_ptr>(memory_begin)))};
            ::fast_io::freestanding::my_memcpy(env_para_i32p, __builtin_addressof(env_buf_offset_le32), sizeof(env_buf_offset_le32));

            auto const pos{::std::find(env_buf_begin, env_buf_end, u8'\0')};

            env_buf_begin = pos + 1;
            if(*env_buf_begin == u8'0') [[unlikely]] { break; }
            ++env_para_i32p;
        }

#elif defined(__APPLE__) || defined(__DARWIN_C_LEVEL)
        char*** const envs_get{::fast_io::noexcept_call(::_NSGetEnviron)};
        auto envion{*envs_get};

        while(*envion)
        {
            auto const env_buf_offset_le32{
                ::fast_io::little_endian(static_cast<::std::uint_least32_t>(env_buf_begin - reinterpret_cast<char8_t_may_alias_ptr>(memory_begin)))};
            ::fast_io::freestanding::my_memcpy(env_para_i32p, __builtin_addressof(env_buf_offset_le32), sizeof(env_buf_offset_le32));

            auto const env_str{*envion};
            auto const env_str_len{::fast_io::cstr_len(env_str)};

            if(reinterpret_cast<::std::byte*>(env_buf_begin) + env_str_len >= memory_end) [[unlikely]]
            {
                return static_cast<::std::int_least32_t>(::uwvm::vm::interpreter::wasi::errno_t::efault);
            }

            ::fast_io::freestanding::my_memcpy(env_buf_begin, env_str, env_str_len);

            env_buf_begin += env_str_len;
            *env_buf_begin++ = u8'\0';

            ++env_para_i32p;
            ++envion;
        }

#elif defined(_WIN32)
    #if defined(_WIN32_WINDOWS)
        // CreateEnvironmentBlock function
        // Minimum supported client	Windows 2000 Professional [desktop apps only]
        return static_cast<::std::int_least32_t>(::uwvm::vm::interpreter::wasi::errno_t::efault);
    #else
        auto c_peb{::fast_io::win32::nt::nt_get_current_peb()};
        auto const Environment{c_peb->ProcessParameters->Environment};
        auto const EnvironmentSize{c_peb->ProcessParameters->EnvironmentSize};
        decltype(auto) two_zero{u"\0\0"};
        auto const Environment_end{::std::search(Environment, Environment + EnvironmentSize, two_zero, two_zero + 2)};

        ::fast_io::u8string env_str{::fast_io::u8concat_fast_io(::fast_io::mnp::code_cvt(::fast_io::mnp::strvw(Environment, Environment_end)))};

        if(env_str.size() > static_cast<::std::size_t>(memory_end - reinterpret_cast<::std::byte*>(env_buf_begin))) [[unlikely]]
        {
            return static_cast<::std::int_least32_t>(::uwvm::vm::interpreter::wasi::errno_t::efault);
        }

        ::fast_io::freestanding::my_memcpy(env_buf_begin, env_str.data(), env_str.size());

        auto const env_buf_end{env_buf_begin + env_str.size()};

        for(; env_buf_begin < env_buf_end;)
        {
            auto const env_buf_offset_le32{
                ::fast_io::little_endian(static_cast<::std::uint_least32_t>(env_buf_begin - reinterpret_cast<char8_t_may_alias_ptr>(memory_begin)))};
            ::fast_io::freestanding::my_memcpy(env_para_i32p, __builtin_addressof(env_buf_offset_le32), sizeof(env_buf_offset_le32));

            auto const pos{::std::find(env_buf_begin, env_buf_end, u8'\0')};

            env_buf_begin = pos + 1;
            if(*env_buf_begin == u8'0') [[unlikely]] { break; }
            ++env_para_i32p;
        }

    #endif
#else
        return static_cast<::std::int_least32_t>(::uwvm::vm::interpreter::wasi::errno_t::efault);
#endif
        return static_cast<::std::int_least32_t>(::uwvm::vm::interpreter::wasi::errno_t::esuccess);
    }

    ::std::int_least32_t environ_sizes_get(::std::int_least32_t arg0, ::std::int_least32_t arg1) noexcept
    {
        auto& memory{::uwvm::vm::interpreter::memories.front()};
        auto const memory_begin{memory.memory_begin};
        auto const memory_length{memory.memory_length};
        auto const memory_end{memory_begin + memory_length};

        bool success{true};

        ::std::uint_least32_t nenv_wasm{};
        ::std::uint_least32_t nenv_len_wasm{};

#if defined(__linux__)
        ::fast_io::native_file_loader envs{u8"/proc/self/environ"};
        nenv_wasm = static_cast<::std::uint_least32_t>(::std::ranges::count(envs, u8'\0'));
        nenv_len_wasm = static_cast<::std::uint_least32_t>(envs.size());

#elif defined(__DragonFly__) || defined(__FreeBSD__) || defined(__FreeBSD_kernel__) || defined(__NetBSD__) || defined(BSD) || defined(_SYSTYPE_BSD)
    #if defined(__NetBSD__)
        int mib[4]{CTL_KERN, KERN_PROC_ARGS, -1, KERN_PROC_ENV};
    #else
        int mib[4]{CTL_KERN, KERN_PROC, KERN_PROC_ENV, -1};
    #endif

        {
            char buffer[32768];
            ::std::size_t size{32767};
            if(::fast_io::noexcept_call(::sysctl, mib, 4, buffer, __builtin_addressof(size), nullptr, 0) == 0) [[likely]]
            {
                nenv_wasm = static_cast<::std::uint_least32_t>(::std::count(buffer, buffer + size, u8'\0'));
                nenv_len_wasm = static_cast<::std::uint_least32_t>(size);
            }
            else { success = false; }
        }

#elif defined(__OpenBSD__)
        int mib[4]{CTL_KERN, KERN_PROC_ARGS, getpid(), KERN_PROC_ENV};

        ::std::size_t size{};

        if(::fast_io::noexcept_call(::sysctl, mib, 4, nullptr, __builtin_addressof(size), nullptr, 0) == 0) [[likely]]
        {
            if(size < 32767) [[likely]]
            {
                char buffer[32768];
                if(::fast_io::noexcept_call(::sysctl, mib, 4, buffer, __builtin_addressof(size), nullptr, 0) == 0) [[likely]]
                {
                    nenv_wasm = static_cast<::std::uint_least32_t>(::std::count(buffer, buffer + size, u8'\0'));
                    nenv_len_wasm = static_cast<::std::uint_least32_t>(size);
                }
                else { success = false; }
            }
            else { success = false; }
        }
        else { success = false; }

#elif defined(__APPLE__) || defined(__DARWIN_C_LEVEL)
        char*** const envs_get{::fast_io::noexcept_call(::_NSGetEnviron)};
        auto envion{*envs_get};

        while(*envion)
        {
            ++nenv_wasm;

            auto const env_str{*envion};
            auto const env_str_len{::fast_io::cstr_len(env_str)};
            nenv_len_wasm += env_str_len + 1;

            ++envion;
        }

#elif defined(_WIN32)
    #if defined(_WIN32_WINDOWS)
        // CreateEnvironmentBlock function
        // Minimum supported client	Windows 2000 Professional [desktop apps only]
        success = false;
    #else
        auto c_peb{::fast_io::win32::nt::nt_get_current_peb()};
        auto const Environment{c_peb->ProcessParameters->Environment};
        auto const EnvironmentSize{c_peb->ProcessParameters->EnvironmentSize};

        decltype(auto) two_zero{u"\0\0"};

        auto const Environment_end{::std::search(Environment, Environment + EnvironmentSize, two_zero, two_zero + 2)};

        // in order to get u8 environments length 
        ::fast_io::u8string env_str{::fast_io::u8concat_fast_io(::fast_io::mnp::code_cvt(::fast_io::mnp::strvw(Environment, Environment_end)))};

        nenv_wasm = static_cast<::std::uint_least32_t>(::std::ranges::count(env_str, u8'\0'));
        nenv_len_wasm = static_cast<::std::uint_least32_t>(env_str.size());

    #endif
#else
        success = false;
#endif

        auto const nenv_begin{memory_begin + static_cast<::std::size_t>(arg0)};
        if(nenv_begin + sizeof(::uwvm::vm::interpreter::wasi::wasi_size_t) >= memory_end) [[unlikely]]
        {
            return static_cast<::std::int_least32_t>(::uwvm::vm::interpreter::wasi::errno_t::efault);
        }

        using wasi_size_t_may_alias_ptr
#if __has_cpp_attribute(__gnu__::__may_alias__)
            [[__gnu__::__may_alias__]]
#endif
            = ::uwvm::vm::interpreter::wasi::wasi_size_t*;

        auto nenv_i32p{reinterpret_cast<wasi_size_t_may_alias_ptr>(nenv_begin)};

        auto const nenv_wasm_le32{::fast_io::little_endian(static_cast<::std::uint_least32_t>(nenv_wasm))};

        ::fast_io::freestanding::my_memcpy(nenv_i32p, __builtin_addressof(nenv_wasm_le32), sizeof(::std::uint_least32_t));

        // buf len
        auto const nenv_len_wasm_begin{memory_begin + static_cast<::std::size_t>(arg1)};
        if(nenv_len_wasm_begin + sizeof(::uwvm::vm::interpreter::wasi::wasi_size_t) >= memory_end) [[unlikely]]
        {
            return static_cast<::std::int_least32_t>(::uwvm::vm::interpreter::wasi::errno_t::efault);
        }

        auto const nenv_len_le32{::fast_io::little_endian(static_cast<::std::uint_least32_t>(nenv_len_wasm))};
        ::fast_io::freestanding::my_memcpy(nenv_len_wasm_begin, __builtin_addressof(nenv_len_wasm), sizeof(::std::uint_least32_t));

        if(success) [[likely]] { return static_cast<::std::int_least32_t>(::uwvm::vm::interpreter::wasi::errno_t::esuccess); }
        else { return static_cast<::std::int_least32_t>(::uwvm::vm::interpreter::wasi::errno_t::efault); }
    }

    ::std::int_least32_t clock_res_get(::std::int_least32_t arg0, ::std::int_least32_t arg1) noexcept { return {}; }

    ::std::int_least32_t clock_time_get(::std::int_least32_t arg0, ::std::int_least64_t arg1, ::std::int_least32_t arg2) noexcept { return {}; }

    ::std::int_least32_t fd_advise(::std::int_least32_t arg0, ::std::int_least64_t arg1, ::std::int_least64_t arg2, ::std::int_least32_t arg3) noexcept
    {
        return {};
    }

    ::std::int_least32_t fd_allocate(::std::int_least32_t arg0, ::std::int_least64_t arg1, ::std::int_least64_t arg2) noexcept { return {}; }

    ::std::int_least32_t fd_close(::std::int_least32_t arg0) noexcept { return {}; }

    ::std::int_least32_t fd_datasync(::std::int_least32_t arg0) noexcept { return {}; }

    ::std::int_least32_t fd_fdstat_get(::std::int_least32_t arg0, ::std::int_least32_t arg1) noexcept { return {}; }

    ::std::int_least32_t fd_fdstat_set_flags(::std::int_least32_t arg0, ::std::int_least32_t arg1) noexcept { return {}; }

    ::std::int_least32_t fd_fdstat_set_rights(::std::int_least32_t arg0, ::std::int_least64_t arg1, ::std::int_least64_t arg2) noexcept { return {}; }

    ::std::int_least32_t fd_filestat_get(::std::int_least32_t arg0, ::std::int_least32_t arg1) noexcept { return {}; }

    ::std::int_least32_t fd_filestat_set_size(::std::int_least32_t arg0, ::std::int_least64_t arg1) noexcept { return {}; }

    ::std::int_least32_t
        fd_filestat_set_times(::std::int_least32_t arg0, ::std::int_least64_t arg1, ::std::int_least64_t arg2, ::std::int_least32_t arg3) noexcept
    {
        return {};
    }

    ::std::int_least32_t
        fd_pread(::std::int_least32_t arg0, ::std::int_least32_t arg1, ::std::int_least32_t arg2, ::std::int_least64_t arg3, ::std::int_least32_t arg4) noexcept
    {
        return {};
    }

    ::std::int_least32_t fd_prestat_get(::std::int_least32_t arg0, ::std::int_least32_t arg1) noexcept { return {}; }

    ::std::int_least32_t fd_prestat_dir_name(::std::int_least32_t arg0, ::std::int_least32_t arg1, ::std::int_least32_t arg2) noexcept { return {}; }

    ::std::int_least32_t fd_pwrite(::std::int_least32_t arg0,
                                   ::std::int_least32_t arg1,
                                   ::std::int_least32_t arg2,
                                   ::std::int_least64_t arg3,
                                   ::std::int_least32_t arg4) noexcept
    {
        return {};
    }

    ::std::int_least32_t fd_read(::std::int_least32_t arg0, ::std::int_least32_t arg1, ::std::int_least32_t arg2, ::std::int_least32_t arg3) noexcept
    {
        return {};
    }

    ::std::int_least32_t fd_readdir(::std::int_least32_t arg0,
                                    ::std::int_least32_t arg1,
                                    ::std::int_least32_t arg2,
                                    ::std::int_least64_t arg3,
                                    ::std::int_least32_t arg4) noexcept
    {
        return {};
    }

    ::std::int_least32_t fd_renumber(::std::int_least32_t arg0, ::std::int_least32_t arg1) noexcept { return {}; }

    ::std::int_least32_t fd_seek(::std::int_least32_t arg0, ::std::int_least64_t arg1, ::std::int_least32_t arg2, ::std::int_least32_t arg3) noexcept
    {
        return {};
    }

    ::std::int_least32_t fd_sync(::std::int_least32_t arg0) noexcept { return {}; }

    ::std::int_least32_t fd_tell(::std::int_least32_t arg0, ::std::int_least32_t arg1) noexcept { return {}; }

    ::std::int_least32_t fd_write(::std::int_least32_t arg0, ::std::int_least32_t arg1, ::std::int_least32_t arg2, ::std::int_least32_t arg3) noexcept
    {
        // No need to check the memory of wasm
        ::fast_io::posix_io_observer pfd{static_cast<int>(arg0)};

        auto& memory{::uwvm::vm::interpreter::memories.front()};
        auto const memory_begin{memory.memory_begin};
        auto const memory_length{memory.memory_length};
        auto const memory_end{memory_begin + memory_length};

        ::std::byte const* cvt_begin{memory_begin + static_cast<::std::size_t>(arg1)};

        if(cvt_begin + 8 * arg2 >= memory_end) [[unlikely]] { return static_cast<::std::int_least32_t>(::uwvm::vm::interpreter::wasi::errno_t::efault); }

        ::std::size_t all_written_size{};

        for(::std::size_t i{}; i < static_cast<::std::size_t>(arg2); ++i)
        {
            ::uwvm::vm::interpreter::wasi::wasi_void_ptr_t wpt_buf{};
            ::uwvm::vm::interpreter::wasi::wasi_size_t wsz_buf_len{};

            ::std::uint_least32_t le_wpt_buf{};
            ::fast_io::freestanding::my_memcpy(__builtin_addressof(le_wpt_buf), cvt_begin, sizeof(le_wpt_buf));
            wpt_buf = static_cast<decltype(wpt_buf)>(::fast_io::little_endian(le_wpt_buf));
            cvt_begin += 4;

            ::std::uint_least32_t le_wsz_buf_len{};
            ::fast_io::freestanding::my_memcpy(__builtin_addressof(le_wsz_buf_len), cvt_begin, sizeof(le_wsz_buf_len));
            wsz_buf_len = static_cast<decltype(wsz_buf_len)>(::fast_io::little_endian(le_wsz_buf_len));
            cvt_begin += 4;

            auto const cvt_buf_off{static_cast<::std::size_t>(static_cast<::std::uint_least32_t>(wpt_buf))};
            auto const cvt_buf_begin{memory_begin + cvt_buf_off};

            if(cvt_buf_begin + static_cast<::std::size_t>(static_cast<::std::uint_least32_t>(wsz_buf_len)) >= memory_end) [[unlikely]]
            {
                return static_cast<::std::int_least32_t>(::uwvm::vm::interpreter::wasi::errno_t::efault);
            }

#if 0
            if(static_cast<::std::uint_least32_t>(wsz_buf_len) == 0) [[unlikely]]
            {
                return static_cast<::std::int_least32_t>(::uwvm::vm::interpreter::wasi::errno_t::efault);
            }
#endif

            auto const cvt_buf_write_end{
                ::fast_io::operations::write_some_bytes(pfd,
                                                        cvt_buf_begin,
                                                        cvt_buf_begin + static_cast<::std::size_t>(static_cast<::std::uint_least32_t>(wsz_buf_len)))};

            auto const cvt_buf_write_sz{static_cast<::std::size_t>(cvt_buf_write_end - cvt_buf_begin)};

            all_written_size += cvt_buf_write_sz;

            if(cvt_buf_write_sz != static_cast<::std::size_t>(wsz_buf_len)) [[unlikely]]
            {
                return static_cast<::std::int_least32_t>(::uwvm::vm::interpreter::wasi::errno_t::efault);
            }
        }

        ::std::byte* number_begin{memory_begin + static_cast<::std::size_t>(arg3)};
        ::std::uint_least32_t le32{::fast_io::little_endian(static_cast<::std::uint_least32_t>(all_written_size))};
        ::fast_io::freestanding::my_memcpy(number_begin, __builtin_addressof(le32), sizeof(le32));

        return static_cast<::std::int_least32_t>(::uwvm::vm::interpreter::wasi::errno_t::esuccess);
    }

    ::std::int_least32_t path_create_directory(::std::int_least32_t arg0, ::std::int_least32_t arg1, ::std::int_least32_t arg2) noexcept { return {}; }

    ::std::int_least32_t path_filestat_get(::std::int_least32_t arg0,
                                           ::std::int_least32_t arg1,
                                           ::std::int_least32_t arg2,
                                           ::std::int_least32_t arg3,
                                           ::std::int_least32_t arg4) noexcept
    {
        return {};
    }

    ::std::int_least32_t path_filestat_set_times(::std::int_least32_t arg0,
                                                 ::std::int_least32_t arg1,
                                                 ::std::int_least32_t arg2,
                                                 ::std::int_least32_t arg3,
                                                 ::std::int_least64_t arg4,
                                                 ::std::int_least64_t arg5,
                                                 ::std::int_least32_t arg6) noexcept
    {
        return {};
    }

    ::std::int_least32_t path_link(::std::int_least32_t arg0,
                                   ::std::int_least32_t arg1,
                                   ::std::int_least32_t arg2,
                                   ::std::int_least32_t arg3,
                                   ::std::int_least32_t arg4,
                                   ::std::int_least32_t arg5,
                                   ::std::int_least32_t arg6) noexcept
    {
        return {};
    }

    ::std::int_least32_t path_open(::std::int_least32_t arg0,
                                   ::std::int_least32_t arg1,
                                   ::std::int_least32_t arg2,
                                   ::std::int_least32_t arg3,
                                   ::std::int_least32_t arg4,
                                   ::std::int_least64_t arg5,
                                   ::std::int_least64_t arg6,
                                   ::std::int_least32_t arg7,
                                   ::std::int_least32_t arg8) noexcept
    {
        return {};
    }

    ::std::int_least32_t path_readlink(::std::int_least32_t arg0,
                                       ::std::int_least32_t arg1,
                                       ::std::int_least32_t arg2,
                                       ::std::int_least32_t arg3,
                                       ::std::int_least32_t arg4,
                                       ::std::int_least32_t arg5) noexcept
    {
        return {};
    }

    ::std::int_least32_t path_remove_directory(::std::int_least32_t arg0, ::std::int_least32_t arg1, ::std::int_least32_t arg2) noexcept { return {}; }

    ::std::int_least32_t path_rename(::std::int_least32_t arg0,
                                     ::std::int_least32_t arg1,
                                     ::std::int_least32_t arg2,
                                     ::std::int_least32_t arg3,
                                     ::std::int_least32_t arg4,
                                     ::std::int_least32_t arg5) noexcept
    {
        return {};
    }

    ::std::int_least32_t path_symlink(::std::int_least32_t arg0,
                                      ::std::int_least32_t arg1,
                                      ::std::int_least32_t arg2,
                                      ::std::int_least32_t arg3,
                                      ::std::int_least32_t arg4) noexcept
    {
        return {};
    }

    ::std::int_least32_t path_unlink_file(::std::int_least32_t arg0, ::std::int_least32_t arg1, ::std::int_least32_t arg2) noexcept { return {}; }

    ::std::int_least32_t poll_oneoff(::std::int_least32_t arg0, ::std::int_least32_t arg1, ::std::int_least32_t arg2, ::std::int_least32_t arg3) noexcept
    {
        return {};
    }

    void proc_exit(::std::int_least32_t arg0) noexcept { return; }

    ::std::int_least32_t sched_yield() noexcept { return {}; }

    ::std::int_least32_t random_get(::std::int_least32_t arg0, ::std::int_least32_t arg1) noexcept { return {}; }

    ::std::int_least32_t sock_accept(::std::int_least32_t arg0, ::std::int_least32_t arg1, ::std::int_least32_t arg2) noexcept { return {}; }

    ::std::int_least32_t sock_recv(::std::int_least32_t arg0,
                                   ::std::int_least32_t arg1,
                                   ::std::int_least32_t arg2,
                                   ::std::int_least32_t arg3,
                                   ::std::int_least32_t arg4,
                                   ::std::int_least32_t arg5) noexcept
    {
        return {};
    }

    ::std::int_least32_t sock_send(::std::int_least32_t arg0,
                                   ::std::int_least32_t arg1,
                                   ::std::int_least32_t arg2,
                                   ::std::int_least32_t arg3,
                                   ::std::int_least32_t arg4) noexcept
    {
        return {};
    }

    ::std::int_least32_t sock_shutdown(::std::int_least32_t arg0, ::std::int_least32_t arg1) noexcept { return {}; }

}  // namespace uwvm::vm::interpreter::wasi
