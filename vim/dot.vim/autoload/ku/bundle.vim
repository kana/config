" ku source: bundle
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
" Variables  "{{{1

let s:available_bundles = []
let s:cached_bundles = []
let s:cached_paths = []
let s:current_bundle_name = ''

let s:windows = 0
let s:tabpages = 0








" Interface  "{{{1
function! ku#bundle#event_handler(source_name_ext, event, ...)  "{{{2
  if a:event ==# 'SourceEnter'
    let s:available_bundles = bundle#available_bundles()
    let s:cached_bundles = map(copy(s:available_bundles), '{"word": v:val}')
    let s:cached_paths = []
    let s:current_bundle_name = ''

    let s:windows = winnr('$') - 1
    let s:tabpages = tabpagenr('$')

    return
  else
    return call('ku#default_event_handler', [a:event] + a:000)
  endif
endfunction




function! ku#bundle#action_table(source_name_ext)  "{{{2
  return {
  \   'args!': 'ku#bundle#action_args_x',
  \   'args': 'ku#bundle#action_args',
  \   'default': 'ku#bundle#action_args',
  \   'load!': 'ku#bundle#action_load_x',
  \   'load': 'ku#bundle#action_load',
  \   'load-or-args': 'ku#bundle#action_load_or_args',
  \ }
endfunction




function! ku#bundle#key_table(source_name_ext)  "{{{2
  return {
  \   "\<C-a>": 'args',
  \   "\<C-o>": 'load',
  \   'A': 'args!',
  \   'O': 'load!',
  \   'a': 'args',
  \   'o': 'load',
  \ }
endfunction




function! ku#bundle#gather_items(source_name_ext, pattern)  "{{{2
  let i = match(a:pattern, s:separator_regexp())
  if 0 <= i  " {bundle}/{path}
    let bundle_name = a:pattern[:i-1]
    if bundle_name ==# s:current_bundle_name
      return s:cached_paths
    else
      let j = index(s:available_bundles, bundle_name)
      let s:current_bundle_name = bundle_name
      let s:cached_paths = map(
      \     (0 <= j ? copy(bundle#files(bundle_name)) : []),
      \     '{"word": bundle_name.a:pattern[i].v:val, "ku_bundle_path": v:val}'
      \   )
      return s:cached_paths
    endif
  else  " {bundle}
    return s:cached_bundles
  endif
endfunction




function! ku#bundle#acc_valid_p(source_name_ext, item, sep)  "{{{2
  return !has_key(a:item, 'ku_bundle_path')
endfunction








" Misc.  "{{{1
function! s:separator_regexp()  "{{{2
  let _ = (exists('g:ku_bundle_path_separators')
  \        ? g:ku_bundle_path_separators
  \        : g:ku_component_separators)
  return '[' . substitute(_, '\ze[^A-Za-z0-9]', '\\', 'g') . ']'
endfunction




function! s:open_by_source_file(bang, item)  "{{{2
  let _ = copy(a:item)
  let _.word = _.ku_bundle_path

  if a:bang == '!'
    call ku#file#action_open_x(_)
  else
    call ku#file#action_open(_)
  endif
  return
endfunction




function! ku#bundle#action_args(item)  "{{{2
  if has_key(a:item, 'ku_bundle_path')
    call s:open_by_source_file('', a:item)
  else
    execute 'ArgsBundle' a:item.word
  endif
  return
endfunction




function! ku#bundle#action_args_x(item)  "{{{2
  if has_key(a:item, 'ku_bundle_path')
    call s:open_by_source_file('!', a:item)
  else
    execute 'ArgsBundle!' a:item.word
  endif
  return
endfunction




function! ku#bundle#action_load(item)  "{{{2
  if has_key(a:item, 'ku_bundle_path')
    call s:open_by_source_file('', a:item)
  else
    execute 'LoadBundle' a:item.word
  endif
  return
endfunction




function! ku#bundle#action_load_x(item)  "{{{2
  if has_key(a:item, 'ku_bundle_path')
    call s:open_by_source_file('!', a:item)
  else
    execute 'LoadBundle!' a:item.word
  endif
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
