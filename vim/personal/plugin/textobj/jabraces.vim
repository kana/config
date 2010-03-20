" textobj-jabraces - Text objects for Japanese braces
" Version: 0.1.1
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
scriptencoding utf-8

if exists('g:loaded_textobj_jabraces')
  finish
endif




call textobj#user#plugin('jabraces', {
\      'parens': {
\         '*pattern*': ["\uFF08", "\uFF09"],
\         'select-a': ['ajb', 'aj(', 'aj)'],
\         'select-i': ['ijb', 'ij(', 'ij)']
\      },
\      'brackets': {
\         '*pattern*': ["\uFF3B", "\uFF3D"],
\         'select-a': ['ajr', 'aj[', 'aj]'],
\         'select-i': ['ijr', 'ij[', 'ij]']
\      },
\      'braces': {
\         '*pattern*': ["\uFF5B", "\uFF5D"],
\         'select-a': ['ajB', 'aj{', 'aj}'],
\         'select-i': ['ijB', 'ij{', 'ij}']
\      },
\      'angles': {
\         '*pattern*': ["\uFF1C", "\uFF1E"],
\         'select-a': ['aja', 'aj<', 'aj>'],
\         'select-i': ['ija', 'ij<', 'ij>']
\      },
\      'double-angles': {
\         '*pattern*': ["\u226A", "\u226B"],
\         'select-a': 'ajA',
\         'select-i': 'ijA'
\      },
\      'kakko': {
\         '*pattern*': ["\u300C", "\u300D"],
\         'select-a': 'ajk',
\         'select-i': 'ijk'
\      },
\      'double-kakko': {
\         '*pattern*': ["\u300E", "\u300F"],
\         'select-a': 'ajK',
\         'select-i': 'ijK'
\      },
\      'yama-kakko': {
\         '*pattern*': ["\u3008", "\u3009"],
\         'select-a': 'ajy',
\         'select-i': 'ijy'
\      },
\      'double-yama-kakko': {
\         '*pattern*': ["\u300A", "\u300B"],
\         'select-a': 'ajY',
\         'select-i': 'ijY'
\      },
\      'kikkou-kakko': {
\         '*pattern*': ["\u3014", "\u3015"],
\         'select-a': 'ajt',
\         'select-i': 'ijt'
\      },
\      'sumi-kakko': {
\         '*pattern*': ["\u3010", "\u3011"],
\         'select-a': 'ajs',
\         'select-i': 'ijs'
\      },
\    })




let g:loaded_textobj_jabraces = 1

" __END__
" vim: foldmethod=marker
