" ku source: mru
" Version: 0.0.0
" Copyright (C) 2016 Kana Natsuno <http://whileimautomaton.net/>
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
" Variables  "{{{1

let s:cached_items = []








" Interface  "{{{1
function! ku#mru#available_sources()  "{{{2
  return ['mru']
endfunction




function! ku#mru#on_source_enter(source_name_ext)  "{{{2
  let s:cached_items = map(
  \   copy(mru#list()),
  \   '{"word": fnamemodify(v:val, ":~:.")}'
  \ )
endfunction




function! ku#mru#action_table(source_name_ext)  "{{{2
  return {
  \   'default': 'ku#mru#action_open',
  \   'open!': 'ku#mru#action_open_x',
  \   'open': 'ku#mru#action_open',
  \ }
endfunction




function! ku#mru#key_table(source_name_ext)  "{{{2
  return {
  \   "\<C-o>": 'open',
  \   'O': 'open!',
  \   'o': 'open',
  \ }
endfunction




function! ku#mru#gather_items(source_name_ext, pattern)  "{{{2
  return s:cached_items
endfunction




function! ku#mru#special_char_p(source_name_ext, char)  "{{{2
  return 0
endfunction








" Misc.  "{{{1
function! s:open(bang, item)  "{{{2
  execute 'edit'.a:bang '`=a:item.word`'
endfunction




" Actions  "{{{2
function! ku#mru#action_open(item)  "{{{3
  return s:open('', a:item)
endfunction


function! ku#mru#action_open_x(item)  "{{{3
  return s:open('!', a:item)
endfunction








" __END__  "{{{1
" vim: foldmethod=marker
