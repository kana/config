" smarttill - Smart motions, till before/after a punctuation
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

if exists('g:loaded_smarttill')
  finish
endif




nnoremap <silent> <Plug>(smarttill-t)  :<C-u>call smarttill#before('n')<CR>
nnoremap <silent> <Plug>(smarttill-T)  :<C-u>call smarttill#after('n')<CR>

vnoremap <silent> <Plug>(smarttill-t)  :<C-u>call smarttill#before('v')<CR>
vnoremap <silent> <Plug>(smarttill-T)  :<C-u>call smarttill#after('v')<CR>

onoremap <silent> <Plug>(smarttill-t)  :<C-u>call smarttill#before('o')<CR>
onoremap <silent> <Plug>(smarttill-T)  :<C-u>call smarttill#after('o')<CR>




let g:loaded_smarttill = 1

" __END__
" vim: foldmethod=marker
