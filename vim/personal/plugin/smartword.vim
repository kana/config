" smartword - Smart motions on words
" Version: 0.0.2
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

if exists('g:loaded_smartword')
  finish
endif




nnoremap <silent> <Plug>(smartword-w)  :<C-u>call smartword#move('w','n')<CR>
nnoremap <silent> <Plug>(smartword-b)  :<C-u>call smartword#move('b','n')<CR>
nnoremap <silent> <Plug>(smartword-e)  :<C-u>call smartword#move('e','n')<CR>
nnoremap <silent> <Plug>(smartword-ge)  :<C-u>call smartword#move('ge','n')<CR>

vnoremap <silent> <Plug>(smartword-w)  :<C-u>call smartword#move('w','v')<CR>
vnoremap <silent> <Plug>(smartword-b)  :<C-u>call smartword#move('b','v')<CR>
vnoremap <silent> <Plug>(smartword-e)  :<C-u>call smartword#move('e','v')<CR>
vnoremap <silent> <Plug>(smartword-ge)  :<C-u>call smartword#move('ge','v')<CR>

onoremap <silent> <Plug>(smartword-w)  :<C-u>call smartword#move('w','o')<CR>
onoremap <silent> <Plug>(smartword-b)  :<C-u>call smartword#move('b','o')<CR>
onoremap <silent> <Plug>(smartword-e)  :<C-u>call smartword#move('e','o')<CR>
onoremap <silent> <Plug>(smartword-ge)  :<C-u>call smartword#move('ge','o')<CR>




let g:loaded_smartword = 1

" __END__
" vim: foldmethod=marker
