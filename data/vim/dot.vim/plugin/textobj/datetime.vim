" textobj-datetime - Text objects for date and time
" Version: 0.3.1
" Copyright (C) 2007-2008 kana <http://whileimautomaton.net/>
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

if exists('g:loaded_textobj_datetime')
  finish
endif




let s:REGEXP__TZ = '\%(Z\|[+-]\d\d:\d\d\)'
let s:REGEXP_TZ = '\%(:\d\d\%(\.\d\+\)\?\)\zs' . s:REGEXP__TZ

let s:REGEXP_TIME = '\d\d:\d\d\%(:\d\d\%(\.\d\+\)\?\)\?'

let s:REGEXP__DATE = '\d\d\d\d-\d\d-\d\d'
let s:REGEXP_DATE = '\d\d\d\d\%(-\d\d\%(-\d\d\)\?\)\?'

let s:REGEXP_FULL = s:REGEXP__DATE . 'T' . s:REGEXP_TIME
\                   . '\%(' . s:REGEXP__TZ . '\)\?'

let s:REGEXP_AUTO = '\%('
\                   .        '\%(' . s:REGEXP_FULL . '\)'
\                   . '\|' . '\%(' . s:REGEXP_DATE . '\)'
\                   . '\|' . '\%(' . s:REGEXP_TIME . '\)'
\                   . '\|' . '\%(' . s:REGEXP_TZ . '\)'
\                   . '\)'




call textobj#user#plugin('datetime', {
\      'auto': {'select': ['ada', 'ida'], '*pattern*': s:REGEXP_AUTO},
\      'full': {'select': ['adf', 'idf'], '*pattern*': s:REGEXP_FULL},
\      'date': {'select': ['add', 'idd'], '*pattern*': s:REGEXP_DATE},
\      'time': {'select': ['adt', 'idt'], '*pattern*': s:REGEXP_TIME},
\      'tz': {'select': ['adz', 'idz'], '*pattern*': s:REGEXP_TZ},
\    })




let g:loaded_textobj_datetime = 1

" __END__
" vim: foldmethod=marker
