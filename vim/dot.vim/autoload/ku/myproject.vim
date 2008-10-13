" ku source: myproject
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
" Variables  "{{{1

  " BUGS: assumes that the current working directory is not changed in
  "       a single ku session.
let s:cached_items = []  " [path, ...]








" Interface  "{{{1
function! ku#myproject#event_handler(event, ...)  "{{{2
  if a:event ==# 'SourceEnter'
    let s:cached_items = map(split(glob('~/working/*/'), '\n'), '{
    \                      "word": fnamemodify(v:val, ":h:t"),
    \                      "_myproject_path": fnamemodify(v:val, ":p:h")
    \                    }')
    return
  else
    return call('ku#default_event_handler', [a:event] + a:000)
  endif
endfunction




function! ku#myproject#action_table()  "{{{2
  return {
  \   'Bottom': 'nop',
  \   'Left': 'nop',
  \   'Right': 'nop',
  \   'Top': 'nop',
  \   'above': 'nop',
  \   'below': 'nop',
  \   'default': 'ku#myproject#action_open',
  \   'left': 'nop',
  \   'open': 'ku#myproject#action_open',
  \   'right': 'nop',
  \ }
endfunction




function! ku#myproject#key_table()  "{{{2
  return {
  \   "\<C-h>": 'tab-right',
  \   "\<C-l>": 'tab-left',
  \   "\<C-o>": 'open',
  \   'H': 'tab-Left',
  \   'L': 'tab-Right',
  \   'h': 'tab-left',
  \   'l': 'tab-right',
  \   'o': 'open',
  \ }
endfunction




function! ku#myproject#gather_items(pattern)  "{{{2
  return s:cached_items
endfunction




function! ku#myproject#acc_valid_p(item, sep)  "{{{2
  return 0
endfunction








" Misc.  "{{{1
" Actions  "{{{2
function! ku#myproject#action_open(item)  "{{{3
  execute 'CD' a:item._myproject_path
  Ku file
  return
endfunction








" __END__  "{{{1
" vim: foldmethod=marker
