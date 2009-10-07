" libtest - Utilities to test Vim script
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
if exists('g:loaded_libtest')  "{{{1
  finish
endif








" Interface  "{{{1

command! -complete=expression -nargs=* Assert
\ call s:cmd_Assert(s:split_expressions(<q-args>),
\                   map(s:split_expressions(<q-args>), 'eval(v:val)'))

command! -nargs=0 Test
\ call s:cmd_Test()

command! -complete=command -nargs=* Title
\ call s:cmd_Title(<q-args>) | execute <q-args>








" Misc.  "{{{1
" Variables  "{{{2

let s:INVALID_COUNT = -13

let s:count_group_failures = s:INVALID_COUNT
let s:count_group_tests = s:INVALID_COUNT
let s:count_total_failures = 0
let s:count_total_tests = 0




function! s:cmd_Assert(pair_exprs, pair_vals)  "{{{2
  " expr_{variable} -- A string which represents an expression of Vim script.
  " val_{variable} -- A value which is evaluated from expr_{variable}.
  let [expr_actual, expr_expected] = a:pair_exprs
  let [Val_actual, Val_expected] = a:pair_vals  " must be capital to avoid E704
  let s:count_group_tests += 1
  let s:count_total_tests += 1

  echo 'TEST:' expr_actual '==>' expr_expected '... '
  let succeeded_p = Val_actual ==# Val_expected
  if succeeded_p
    echon 'ok'
    echo
  else
    echon 'FAILED'
    echo '  Actual value:' Val_actual
    echo '  Expected value:' Val_expected
    let s:count_group_failures += 1
    let s:count_total_failures += 1
  endif

  return
endfunction




function! s:cmd_Test()  "{{{2
  redir => function_names
  silent function /
  redir END

  let _ = split(function_names, '\n')
  call map(_, 'matchstr(v:val, ''^function \zs<SNR>\d\+_test_[^(]*\ze('')')
  call filter(_, 'v:val != ""')
  call map(_, 'substitute(v:val, "<SNR>", "\<SNR>", "")')
  call sort(_)

  for function_name in _
    call {function_name}()
    call s:show_result(s:count_group_failures, s:count_group_tests)
    echon "\n"
  endfor

  echo '=====' 'Total'
  call s:show_result(s:count_total_failures, s:count_total_tests)
  echon "\n"

  return
endfunction




function! s:cmd_Title(stmt_test)  "{{{2
  " stmt_{name} -- A string which represents an statement of Vim script.
  echo '=====' a:stmt_test

  let s:count_group_failures = 0
  let s:count_group_tests = 0
endfunction




function! s:show_result(count_failures, count_total)  "{{{2
    echo 'Result:' (a:count_total - a:count_failures) '/' a:count_total
    return
endfunction




function! s:split_expressions(s)  "{{{2
  " FIXME: Error handlings.
  return matchlist(a:s, '\(.\{-}\)==>\(.*\)')[1:2]
endfunction








" Fin.  "{{{1

let g:loaded_libtest = 1








" __END__
" vim: foldmethod=marker
