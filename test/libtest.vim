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

command! -complete=command -nargs=* Title
\ call s:cmd_Title(<q-args>) | execute <q-args>








" Misc.  "{{{1
function! s:cmd_Assert(pair_exprs, pair_vals)  "{{{2
  " expr_{variable} -- A string which represents an expression of Vim script.
  " val_{variable} -- A value which is evaluated from expr_{variable}.
  let [expr_actual, expr_expected] = a:pair_exprs
  let [val_actual, val_expected] = a:pair_vals

  echo 'TEST:' expr_actual '==>' expr_expected '... '
  let succeeded_p = val_actual ==# val_expected
  if succeeded_p
    echon 'ok'
    echo
  else
    echon 'FAILED'
    echo '  Actual value:' val_actual
    echo '  Expected value:' val_expected
  endif

  return
endfunction




function! s:cmd_Title(stmt_test)  "{{{2
  " stmt_{name} -- A string which represents an statement of Vim script.
  echon "\n"
  echo '=====' a:stmt_test
endfunction




function! s:split_expressions(s)  "{{{2
  " FIXME: Error handlings.
  return matchlist(a:s, '\(.\{-}\)==>\(.*\)')[1:2]
endfunction








" Fin.  "{{{1

let g:loaded_libtest = 1








" __END__
" vim: foldmethod=marker
