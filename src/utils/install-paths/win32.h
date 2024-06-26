﻿#pragma once

#include <stdlib.h>

#include <fast_io.h>
#include <fast_io_device.h>

namespace uwvm::path
{
    /*
     * for win9x
     */
#if __has_cpp_attribute(__gnu__::__cold__)
    [[__gnu__::__cold__]]
#endif
    inline void
        get_module_install_path() noexcept
    {
        char* pgmptr{};
        if(::fast_io::noexcept_call(::_get_pgmptr, __builtin_addressof(pgmptr))) { return; }
        /* Will be affected by regional encoding settings, and _get_wpgmptr may not succeed, so only use on windows 9x */
        ::uwvm::path::module_path = ::fast_io::u8concat_fast_io(::fast_io::mnp::code_cvt_os_c_str(pgmptr));
        auto const begin{strlike_begin(::fast_io::io_strlike_type<char8_t, ::fast_io::u8string>, ::uwvm::path::module_path)};
        auto curr{strlike_curr(::fast_io::io_strlike_type<char8_t, ::fast_io::u8string>, ::uwvm::path::module_path)};
        for(; curr != begin; curr--)  // calculate dos path
        {
            if(auto const c{*curr}; c == u8'\\' || c == u8':' /* || c == u8'/'*/)
            {
                curr++;
                break;
            }
        }
        ::uwvm::path::module_install_path = ::fast_io::u8string{begin, curr};
        ::uwvm::path::module_install_path_df = ::fast_io::dir_file{::uwvm::path::module_install_path};
    }
}  // namespace uwvm::path
