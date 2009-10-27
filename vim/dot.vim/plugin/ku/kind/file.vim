" ku kind: file
" Version: 0.2.0
" Copyright (C) 2008-2009 kana <http://whileimautomaton.net/>
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

if exists('g:loaded_ku_kind_file')
  finish
endif




call ku#define_kind({
\   'default_action_table': {
\     'extract-asis': function('ku#action#file#extract_asis'),
\     'extract-smartly': function('ku#action#file#extract_smartly'),
\     'extract-solely': function('ku#action#file#extract_solely'),
\     'open!': function('ku#action#file#open_x'),
\     'open': function('ku#action#file#open'),
\    },
\   'default_key_table': {
\     "\<C-e>": 'extract-smartly',
\     "\<Esc>e": 'extract-solely',
\     'E': 'extract-asis',
\     'e': 'extract-smartly',
\    },
\   'name': 'file',
\ })




let g:loaded_ku_kind_file = 1

" __END__
" vim: foldmethod=marker
