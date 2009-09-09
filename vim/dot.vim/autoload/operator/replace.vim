" operator-replace - Operator to replace text with register content
" Version: 0.0.0
" Copyright (C) 2009 kana <http://whileimautomaton.net/>
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
" Interface  "{{{1
function! operator#replace#do(motion_wise)  "{{{2
  let visual_command = s:visual_command_from_wise_name(a:motion_wise)
    " v:register will be overwritten by "_d, so that the current value of
    " v:register must be saved before deletion.  Without saving, it's not
    " possible to what "{register} user gives.
  let register = v:register

  execute 'normal!' '`['.visual_command.'`]"_d'
  if register == ''
    normal! P
  else
    execute 'normal!' '"'.register.'P'
  endif
  return
endfunction








" Misc.  "{{{1
function! s:visual_command_from_wise_name(wise_name)  "{{{2()
  if a:wise_name ==# 'char'
    return 'v'
  elseif a:wise_name ==# 'line'
    return 'V'
  elseif a:wise_name ==# 'block'
    return "\<C-v>"
  else
    echoerr 'E1: Invalid wise name:' string(a:wise_name)
    return 'v'  " fallback
  endif
endfunction








" __END__  "{{{1
" vim: foldmethod=marker
