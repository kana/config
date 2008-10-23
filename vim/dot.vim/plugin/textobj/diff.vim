" textobj-diff - Text objects for ouputs of diff(1)
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

if exists('g:loaded_textobj_diff')
  finish
endif




let s:REGEXP_CONTEXT_FILE = '^'
\                         . '\*\*\* [^\t]\+\t.*\n'
\                         . '--- [^\t]\+\t.*\n'
\                         . '\_.\{-}'
\                         . '\ze\%('
\                         .        '\n\*\*\* [^\t]\+\t'
\                         . '\|' . '\%$'
\                         . '\)'
let s:REGEXP_CONTEXT_HUNK = '^\*\{4,}\n'
\                         . '\_.\{-}'
\                         . '\ze\%('
\                         .        '\n\*\{3,}'
\                         . '\|' . '\%$'
\                         . '\)'

let s:REGEXP_GIT_FILE = '^'
\                     . 'diff --git .*\n'
\                     . '\%([a-z].*\n\)\+'
\                     . '--- .*\n'
\                     . '+++ .*\n'
\                     . '\_.\{-}'
\                     . '\ze\%('
\                     .        '\ndiff --git'
\                     . '\|' . '\n--- '
\                     . '\|' . '\%$'
\                     . '\)'
let s:REGEXP_GIT_HUNK = '^@@ [^\t]\+ [^\t]\+ @@.*\n'
\                     . '\_.\{-}'
\                     . '\ze\%('
\                     .        '\n@@ [^\t]\+ [^\t]\+ @@.*\n'
\                     . '\|' . '\ndiff --git'
\                     . '\|' . '\n--- '
\                     . '\|' . '\%$'
\                     . '\)'

let s:REGEXP_UNIFIED_FILE = '^'
\                         . '--- [^\t]\+\t.*\n'
\                         . '+++ [^\t]\+\t.*\n'
\                         . '\_.\{-}'
\                         . '\ze\%('
\                         .        '\n--- [^\t]\+\t'
\                         . '\|' . '\%$'
\                         . '\)'
let s:REGEXP_UNIFIED_HUNK = '^@@ [^\t]\+ [^\t]\+ @@.*\n'
\                         . '\_.\{-}'
\                         . '\ze\%('
\                         .        '\n@@ [^\t]\+ [^\t]\+ @@.*\n'
\                         . '\|' . '\n--- [^\t]\+\t'
\                         . '\|' . '\%$'
\                         . '\)'

let s:REGEXP_AUTO_FILE = '\%('
\                      .        '\%(' . s:REGEXP_CONTEXT_FILE . '\)'
\                      . '\|' . '\%(' . s:REGEXP_GIT_FILE . '\)'
\                      . '\|' . '\%(' . s:REGEXP_UNIFIED_FILE . '\)'
\                      . '\)'
let s:REGEXP_AUTO_HUNK = '\%('
\                      .        '\%(' . s:REGEXP_CONTEXT_HUNK . '\)'
\                      . '\|' . '\%(' . s:REGEXP_GIT_HUNK . '\)'
\                      . '\|' . '\%(' . s:REGEXP_UNIFIED_HUNK . '\)'
\                      . '\)'




call textobj#user#plugin('diff', {
\      'file': {
\        '*pattern*': s:REGEXP_AUTO_FILE,
\        'move-N': '<Leader>dfJ',
\        'move-P': '<Leader>dfK',
\        'move-n': '<Leader>dfj',
\        'move-p': '<Leader>dfk',
\        'select': ['adH', 'adf', 'idH', 'idf'],
\      },
\      'hunk': {
\        '*pattern*': s:REGEXP_AUTO_HUNK,
\        'move-N': '<Leader>dJ',
\        'move-P': '<Leader>dK',
\        'move-n': '<Leader>dj',
\        'move-p': '<Leader>dk',
\        'select': ['adh', 'idh'],
\      },
\    })




let g:loaded_textobj_diff = 1

" __END__
" vim: foldmethod=marker
