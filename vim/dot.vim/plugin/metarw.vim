" metarw - a framework to read/write a fake:file
" Version: 0.0.0
" Copyright (C) 2008 kana <http://whileimautomaton.net/>
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

if exists('g:loaded_metarw')
  finish
endif




command! -bang -bar -complete=custom,metarw#complete -nargs=? Edit
\ call metarw#edit(<q-args>)

command! -bang -bar -complete=custom,metarw#complete -nargs=? New
\ call metarw#new(<q-args>)

command! -bang -bar -complete=custom,metarw#complete -nargs=? Read
\ call metarw#read(<q-args>)

command! -bang -bar -complete=custom,metarw#complete -nargs=? Source
\ call metarw#write(<q-args>)

command! -bang -bar -complete=custom,metarw#complete -nargs=? -range=% Write
\ <line1>,<line2>call metarw#write(<q-args>)




let g:loaded_metarw = 1

" __END__
" vim: foldmethod=marker
