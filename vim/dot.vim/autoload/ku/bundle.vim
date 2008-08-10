" ku source: bundle
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

let s:windows = 0
let s:tabpages = 0








" Interface  "{{{1
function! ku#bundle#event_handler(event, ...)  "{{{2
  if a:event ==# 'SourceEnter'
    let s:cached_items = map(bundle#available_bundles(), '{"word": v:val}')

    let s:windows = winnr('$') - 1
    let s:tabpages = tabpagenr('$')

    return
  else
    return call('ku#default_event_handler', [a:event] + a:000)
  endif
endfunction




function! ku#bundle#action_table()  "{{{2
  return {
  \   'args!': 'ku#bundle#action_args_x',
  \   'args': 'ku#bundle#action_args',
  \   'default': 'ku#bundle#action_load_or_args',
  \   'load!': 'ku#bundle#action_load_x',
  \   'load': 'ku#bundle#action_load',
  \   'load-or-args': 'ku#bundle#action_load_or_args',
  \ }
endfunction




function! ku#bundle#key_table()  "{{{2
  return {
  \   "\<C-a>": 'args',
  \   "\<C-o>": 'load',
  \   'A': 'args!',
  \   'O': 'load!',
  \   'a': 'args',
  \   'o': 'load',
  \ }
endfunction




function! ku#bundle#gather_items(pattern)  "{{{2
  return s:cached_items
endfunction








" Misc.  "{{{1
function! ku#bundle#action_args(item)  "{{{2
  execute 'ArgsBundle' a:item.word
  return
endfunction




function! ku#bundle#action_args_x(item)  "{{{2
  execute 'ArgsBundle!' a:item.word
  return
endfunction




function! ku#bundle#action_load(item)  "{{{2
  execute 'LoadBundle' a:item.word
  return
endfunction




function! ku#bundle#action_load_x(item)  "{{{2
  execute 'LoadBundle!' a:item.word
  return
endfunction




function! ku#bundle#action_load_or_args(item)  "{{{2
  if s:tabpages != tabpagenr('$') || s:windows != winnr('$')
    return ku#bundle#action_args(a:item)
  else
    return ku#bundle#action_load(a:item)
  endif
endfunction








" __END__  "{{{1
" vim: foldmethod=marker
