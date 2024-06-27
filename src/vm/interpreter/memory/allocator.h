﻿#pragma once
#include <fast_io.h>
#include <io_device.h>
#include "../../../wasm/memlimit.h"
#include "../../../run/wasm_file.h"

namespace uwvm::vm::interpreter::memory
{

    struct memory_t
    {
        using Alloc = ::fast_io::native_global_allocator;

        ::std::byte* memory_begin{};
        ::std::size_t memory_length{};

        inline static ::fast_io::native_mutex mutex{};
        inline static constexpr ::std::size_t page_size{::uwvm::wasm::num_bytes_per_page};
        inline static constexpr ::std::size_t system_page_size{page_size};

        void init_by_memory_type(::uwvm::wasm::memory_type const& msec) noexcept
        {
            mutex.lock();
            memory_length = msec.limits.min * system_page_size;
            memory_begin = reinterpret_cast<::std::byte*>(Alloc::allocate(memory_length));
            mutex.unlock();
        }

        void grow_by_memory_type(::uwvm::wasm::memory_type const& msec, ::std::size_t sz) noexcept
        {
            if(sz == 0) [[unlikely]] { return; }

            if(memory_begin == nullptr) [[unlikely]]
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
                                u8"memory_begin == nullptr."
                                u8"\n"
                                u8"\033[0m"
                                u8"Terminate.\n\n");
                ::fast_io::fast_terminate();
            }
            else
            {
                auto const max_generate = [&msec]() noexcept -> ::std::size_t
                {
                    // do sth
                    return msec.limits.max;
                };

                static auto const max{max_generate()};

                if(sz <= max && memory_length / system_page_size <= max - sz) [[likely]]
                {
                    mutex.lock();

                    [[maybe_unused]] auto const old_length{memory_length};

                    memory_length += sz * system_page_size;

                    if constexpr(Alloc::has_reallocate_zero)
                    {
                        memory_begin = reinterpret_cast<::std::byte*>(Alloc::reallocate_zero(memory_begin, memory_length));
                    }
                    else if constexpr(Alloc::has_reallocate)
                    {
                        memory_begin = reinterpret_cast<::std::byte*>(Alloc::reallocate(memory_begin, memory_length));
                        ::fast_io::freestanding::bytes_clear_n(memory_begin + old_length, memory_length - old_length);
                    }
                    else
                    {
                        auto const new_mem{reinterpret_cast<::std::byte*>(Alloc::allocate(memory_length))};
                        ::fast_io::freestanding::my_memcpy(new_mem, memory_begin, old_length);
                        ::fast_io::freestanding::bytes_clear_n(new_mem + old_length, memory_length - old_length);
                        Alloc::deallocate_n(memory_begin, old_length);
                        memory_begin = new_mem;
                    }
                    mutex.unlock();
                }
                else
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
                                u8"Memory allocation has reached its maximum limit."
                                u8"\n"
                                u8"\033[0m"
                                u8"Terminate.\n\n");
                    ::fast_io::fast_terminate();
                }
            }
        }

        memory_t(memory_t const& other) noexcept
        {
            memory_length = other.memory_length;
            memory_begin = reinterpret_cast<::std::byte*>(Alloc::allocate(memory_length));
            ::fast_io::freestanding::non_overlapped_copy_n(other.memory_begin, memory_length, memory_begin);
        }

        memory_t& operator= (memory_t const& other) noexcept
        {
            clean();
            memory_length = other.memory_length;
            memory_begin = reinterpret_cast<::std::byte*>(Alloc::allocate(memory_length));
            ::fast_io::freestanding::non_overlapped_copy_n(other.memory_begin, memory_length, memory_begin);
            return *this;
        }

        memory_t(memory_t&& other) noexcept
        {
            memory_length = other.memory_length;
            memory_begin = other.memory_begin;
            other.memory_length = 0;
            other.memory_begin = nullptr;
        }

        memory_t& operator= (memory_t&& other) noexcept
        {
            clean();
            memory_length = other.memory_length;
            memory_begin = other.memory_begin;
            other.memory_length = 0;
            other.memory_begin = nullptr;
            return *this;
        }

        void clean() noexcept
        {
            if(memory_begin) [[likely]]
            {
                Alloc::deallocate_n(memory_begin, memory_length);
                memory_length = 0;
                memory_begin = nullptr;
            }
        }

        ~memory_t() { clean(); }
    };

}  // namespace uwvm::vm::interpreter::memory

namespace fast_io::freestanding
{
    template <>
    struct is_trivially_relocatable<::uwvm::vm::interpreter::memory::memory_t>
    {
        inline static constexpr bool value = true;
    };

    template <>
    struct is_zero_default_constructible<::uwvm::vm::interpreter::memory::memory_t>
    {
        inline static constexpr bool value = true;
    };

}  // namespace fast_io::freestanding
