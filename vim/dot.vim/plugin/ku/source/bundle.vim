" ku source: bundle
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

if exists('g:loaded_ku_source_bundle')
  finish
endif




call ku#define_source({
\   'default_action_table': {
\     'args': function('ku#source#bundle#action_args'),
\     'args_x': function('ku#source#bundle#action_args_x'),
\     'load': function('ku#source#bundle#action_load'),
\     'load_x': function('ku#source#bundle#action_load_x'),
\     'open': function('ku#source#bundle#action_args'),
\     'open_x': function('ku#source#bundle#action_args_x'),
\   },
\   'default_key_table': {
\   },
\   'gather_candidates': function('ku#source#bundle#gather_candidates'),
\   'kinds': [],
\   'name': 'bundle',
\ })




let g:loaded_ku_source_bundle = 1

" __END__
" vim: foldmethod=marker
