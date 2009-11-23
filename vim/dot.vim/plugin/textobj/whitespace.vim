" textobj-whitespace - Text objects to trim whitespaces
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

if exists('g:loaded_textobj_whitespace')
  finish
endif




call textobj#user#plugin('whitespace', {
\      '-': {
\        '*sfile*': expand('<sfile>:p'),
\        'select-a': 'a_',  '*select-a-function*': 's:select_a',
\        'select-i': 'i_',  '*select-i-function*': 's:select_i'
\      }
\    })


function! s:select_a()
  return s:select(1)
endfunction

function! s:select_i()
  return s:select(0)
endfunction

function! s:select(include_newline_p)
  let pattern_e = a:include_newline_p ? '\_s\+\ze\_s' : '\s\+\ze\s'
  let pattern_b = a:include_newline_p ? '\_s\+' : '\s\+'

  if search(pattern_e, 'ceW') == 0
    return 0
  endif
  let end_position = getpos('.')

  if search(pattern_b, 'bc') == 0
    return 0
  endif
  let start_position = getpos('.')

  return ['v', start_position, end_position]
endfunction




let g:loaded_textobj_whitespace = 1

" __END__
" vim: foldmethod=marker
