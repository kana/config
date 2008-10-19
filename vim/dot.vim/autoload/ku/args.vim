" ku source: args
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

let s:cached_items = []








" Interface  "{{{1
function! ku#args#event_handler(event, ...)  "{{{2
  if a:event ==# 'SourceEnter'
    let s:cached_items = map(argv(), '{"word": v:val}')
    if 0 < argc()
      let s:cached_items[argidx()].menu = '*'
    endif
    return
  else
    return call('ku#default_event_handler', [a:event] + a:000)
  endif
endfunction




function! ku#args#action_table()  "{{{2
  " TODO: more argument-list specific actions - e.g., :all.
  return s:action_table
endfunction

let s:action_table = extend({
\    'argdelete': 'ku#args#action_argdelete',
\  },
\  ku#buffer#action_table(),
\  'keep')




function! ku#args#key_table()  "{{{2
  return s:key_table
endfunction

let s:key_table = extend({
\    'R': 'argdelete',
\  },
\  ku#buffer#key_table(),
\  'keep')




function! ku#args#gather_items(pattern)  "{{{2
  return s:cached_items
endfunction








" Misc.  "{{{1
" Actions  "{{{2
function! ku#args#action_argdelete(item)  "{{{3
  execute 'argdelete' fnameescape(a:item.word)
  return
endfunction








" __END__  "{{{1
" vim: foldmethod=marker
