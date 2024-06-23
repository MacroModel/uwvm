#pragma once
#include <fast_io.h>
#include <fast_io_dsal/deque.h>
#include <fast_io_dsal/stack.h>
#include "../../wasm/module.h"

namespace uwvm::vm::interpreter
{
    struct stack_t
    {
        union
        {
            ::uwvm::wasm::wasm_i32 i32;
            ::uwvm::wasm::wasm_i64 i64;
            ::uwvm::wasm::wasm_f32 f32;
            ::uwvm::wasm::wasm_f64 f64;
            ::uwvm::wasm::wasm_v128 v128;
        };

        ::uwvm::wasm::value_type vt{};
    };

    enum class flow_control_t : ::std::uint_fast8_t
    {
        block,
        loop,
        if_,
        else_,
        end,
        try_,
        catch_,
        delegate_,
        catch_all,
    };

    struct flow_t
    {
        ::std::byte const* flow_p{};
        flow_control_t flow_e{};
    };

    struct operator_t;

    struct local_storage
    {
        using Alloc = ::fast_io::native_typed_thread_local_allocator<stack_t>;
        stack_t* locals{};
        ::std::size_t local_size{};

        constexpr local_storage() noexcept = default;

        constexpr local_storage(::std::size_t sz) noexcept : local_size{sz} { locals = Alloc::allocate(sz); }

        constexpr void init(::std::size_t sz) noexcept
        {
            if(locals == nullptr)
            {
                local_size = sz;
                locals = Alloc::allocate(sz);
            }
        }

        constexpr local_storage(local_storage const& other) noexcept
        {
            local_size = other.local_size;
            locals = Alloc::allocate(local_size);
            ::fast_io::freestanding::non_overlapped_copy_n(other.locals, local_size, locals);
        }

        constexpr local_storage& operator= (local_storage const& other) noexcept
        {
            clean();
            local_size = other.local_size;
            locals = Alloc::allocate(local_size);
            ::fast_io::freestanding::non_overlapped_copy_n(other.locals, local_size, locals);
            return *this;
        }

        constexpr local_storage(local_storage&& other) noexcept
        {
            local_size = other.local_size;
            locals = other.locals;
            other.local_size = 0;
            other.locals = nullptr;
        }

        constexpr local_storage& operator= (local_storage&& other) noexcept
        {
            clean();
            local_size = other.local_size;
            locals = other.locals;
            other.local_size = 0;
            other.locals = nullptr;
            return *this;
        }

        constexpr void clean() noexcept
        {
            if(locals) [[likely]]
            {
                Alloc::deallocate_n(locals, local_size);
                local_size = 0;
                locals = nullptr;
            }
        }

        constexpr ~local_storage() { clean(); }
    };

    struct stack_machine
    {
        ::fast_io::tlc::stack<stack_t, ::fast_io::tlc::vector<stack_t>> stack{};
        ::fast_io::tlc::stack<local_storage> ls{};
#if 0
        ::fast_io::tlc::stack<flow_t, ::fast_io::tlc::vector<flow_t>> flow{};
#endif
        operator_t const* begin_op{};
        operator_t const* curr_op{};
        operator_t const* end_op{};

        ::std::size_t stack_top{};  // Prevent stack expansion
        local_storage* ls_p{};

        inline static ::std::size_t default_int_stack_size{static_cast<::std::size_t>(1) * 1024 * 1024};

        constexpr stack_machine() noexcept
        {
            stack.reserve(default_int_stack_size);
            stack.reserve(::uwvm::global_wasm_module.functionsec.function_count);
#if 0
            flow.reserve(static_cast<::std::size_t>(2) * 1024);
#endif
        }
    };

    using int_func_t = void (*)(::std::byte const*, stack_machine&);

    struct ext_t
    {
        operator_t const* end{};
        operator_t const* branch{};
    };

    struct operator_t
    {
        ::std::byte const* code_begin{};
        int_func_t int_func{};
        ext_t ext{};  // extra info
    };

    struct ast
    {
        ::fast_io::deque<operator_t> operators{};
        ::uwvm::wasm::function_type const* ft{};
        ::uwvm::wasm::func_body const* fb{};
        ::std::size_t local_size{};
    };

}  // namespace uwvm::vm::interpreter

namespace fast_io::freestanding
{
    template <>
    struct is_trivially_relocatable<::uwvm::vm::interpreter::stack_machine>
    {
        inline static constexpr bool value = true;
    };

    template <>
    struct is_zero_default_constructible<::uwvm::vm::interpreter::stack_machine>
    {
        inline static constexpr bool value = true;
    };

    template <>
    struct is_trivially_relocatable<::uwvm::vm::interpreter::ast>
    {
        inline static constexpr bool value = true;
    };

    template <>
    struct is_zero_default_constructible<::uwvm::vm::interpreter::ast>
    {
        inline static constexpr bool value = true;
    };
}  // namespace fast_io::freestanding
