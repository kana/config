" ku-kind-common - The common kind for all sources
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

if exists('g:loaded_ku_kind_common')
  finish
endif




call ku#define_kind({
\   'default_action_table': {
\     'Bottom': function('ku#action#common#Bottom'),
\     'Left': function('ku#action#common#Left'),
\     'Right': function('ku#action#common#Right'),
\     'Top': function('ku#action#common#Top'),
\     'above': function('ku#action#common#above'),
\     'below': function('ku#action#common#below'),
\     'cancel': function('ku#action#common#cancel'),
\     'cd': function('ku#action#common#cd'),
\     'default': function('ku#action#common#default'),
\     'ex': function('ku#action#common#ex'),
\     'lcd': function('ku#action#common#lcd'),
\     'left': function('ku#action#common#left'),
\     'nop': function('ku#action#common#nop'),
\     'open': function('ku#action#common#open'),
\     'right': function('ku#action#common#right'),
\     'select': function('ku#action#common#select'),
\     'tab-Left': function('ku#action#common#tab_Left'),
\     'tab-Right': function('ku#action#common#tab_Right'),
\     'tab-left': function('ku#action#common#tab_left'),
\     'tab-right': function('ku#action#common#tab_right'),
\   },
\   'default_key_table': {
\     '/': 'cd',
\     ':': 'ex',
\     ';': 'ex',
\     '<C-c>': 'cancel',
\     '<C-h>': 'left',
\     '<C-j>': 'below',
\     '<C-k>': 'above',
\     '<C-l>': 'right',
\     '<C-m>': 'default',
\     '<C-r>': 'select',
\     '<C-t>': 'tab-Right',
\     '<Esc>': 'cancel',
\     '<Return>': 'default',
\     '?': 'lcd',
\     'H': 'Left',
\     'J': 'Bottom',
\     'K': 'Top',
\     'L': 'Right',
\     'h': 'left',
\     'j': 'below',
\     'k': 'above',
\     'l': 'right',
\     't': 'tab-Right',
\   },
\   'name': 'common',
\ })




let g:loaded_ku_kind_common = 1

" __END__
" vim: foldmethod=marker
