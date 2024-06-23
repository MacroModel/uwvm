#pragma once
#include <back_trace.h>
#include "ast.h"
#include "aststorge.h"

namespace uwvm::vm::interpreter
{
    inline thread_local ::uwvm::vm::interpreter::stack_machine s{};

    inline void run_ast(ast const& a) noexcept
    {
        if(!a.operators.empty()) [[likely]]
        {
            // prepare
            auto const begin_op{::std::to_address(a.operators.begin())};
            auto const end_op{::std::to_address(a.operators.end())};
            s.begin_op = begin_op;
            s.end_op = end_op;

            // check stack
            auto const& func_type{*a.ft};
            auto const func_type_para_size{static_cast<::std::size_t>(func_type.parameter_end - func_type.parameter_begin)};
            auto const func_type_result_size{static_cast<::std::size_t>(func_type.result_end - func_type.result_begin)};

            if(s.stack.size() - func_type_para_size < s.stack_top) [[unlikely]]
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
                                ::fast_io::mnp::addrvw(reinterpret_cast<::std::byte const*>(func_type.parameter_begin) - global_wasm_module.module_begin),
                                u8") "
                                u8"The data stack is empty."
                                u8"\n"
                                u8"\033[0m"
                                u8"Terminate.\n\n");
                ::uwvm::backtrace();
                ::fast_io::fast_terminate();
            }

            auto curr_st{s.stack.get_container().cend()};
            for(auto curr{func_type.parameter_end}; curr != func_type.parameter_begin; --curr)
            {
                auto const curr_vt{*curr};
                auto const curr_st_vt{curr_st->vt};
                if(curr_vt != curr_st_vt) [[unlikely]]
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
                                ::fast_io::mnp::addrvw(reinterpret_cast<::std::byte const*>(func_type.parameter_begin) - global_wasm_module.module_begin),
                                u8") "
                                u8"Value type not match."
                                u8"\n"
                                u8"\033[0m"
                                u8"Terminate.\n\n");
                    ::uwvm::backtrace();
                    ::fast_io::fast_terminate();
                }
                --curr_st;
            }

            // stack top
            auto const last_stack_top{s.stack_top};
            s.stack_top = s.stack.size() - func_type_para_size;

            // run
            for(s.curr_op = begin_op; s.curr_op != end_op;)
            {
                if(s.curr_op->int_func) [[likely]] { s.curr_op->int_func(s.curr_op->code_begin, s); }
                else { ++s.curr_op; }
            }

            // check stack
            if(s.stack.size() - func_type_result_size < s.stack_top) [[unlikely]]
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
                                ::fast_io::mnp::addrvw(reinterpret_cast<::std::byte const*>(func_type.parameter_begin) - global_wasm_module.module_begin),
                                u8") "
                                u8"The data stack is empty."
                                u8"\n"
                                u8"\033[0m"
                                u8"Terminate.\n\n");
                ::uwvm::backtrace();
                ::fast_io::fast_terminate();
            }

            curr_st = s.stack.get_container().cend();
            for(auto curr{func_type.result_end}; curr != func_type.result_begin; --curr)
            {
                auto const curr_vt{*curr};
                auto const curr_st_vt{curr_st->vt};
                if(curr_vt != curr_st_vt) [[unlikely]]
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
                                ::fast_io::mnp::addrvw(reinterpret_cast<::std::byte const*>(func_type.parameter_begin) - global_wasm_module.module_begin),
                                u8") "
                                u8"Value type not match."
                                u8"\n"
                                u8"\033[0m"
                                u8"Terminate.\n\n");
                    ::uwvm::backtrace();
                    ::fast_io::fast_terminate();
                }
                --curr_st;
            }

            s.stack_top = last_stack_top;
        }
    }
}  // namespace uwvm::vm::interpreter
