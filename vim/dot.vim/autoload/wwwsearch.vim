" wwwsearch - Search WWW easily from Vim
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
" Notes  "{{{1
"
" Naming conventions:
"
" search_engine_name
"   The name of a search engine.
"
" n_search_engine_name
"   Normalized search_engine_name.
"
" u_search_engine_name
"   Unnormalized search_engine_name.








" Interface  "{{{1
function! wwwsearch#add(u_search_engine_name, uri_template)  "{{{2
  let n_search_engine_name
  \   = s:normalize_search_engine_name(a:u_search_engine_name)

  let old_uri_template = get(s:search_engines, n_search_engine_name, '')
  let s:search_engines[n_search_engine_name] = a:uri_template

  return old_uri_template
endfunction




function! wwwsearch#remove(u_search_engine_name)  "{{{2
  let n_search_engine_name
  \   = s:normalize_search_engine_name(a:u_search_engine_name)

  if has_key(s:search_engines, n_search_engine_name)
    return remove(s:search_engines, n_search_engine_name)
  else
    return ''
  endif
endfunction




function! wwwsearch#search(keyword, ...)  "{{{2
  let u_search_engine_name = 1 <= a:0 ? a:1 : '-default'
  let n_search_engine_name
  \ = s:normalize_search_engine_name(u_search_engine_name)

  if !exists('g:wwwsearch_command_to_open_uri')
    let g:wwwsearch_command_to_open_uri = s:default_command_to_open_uri()
  endif
  if g:wwwsearch_command_to_open_uri == ''
    echomsg 'You have to set g:wwwsearch_command_to_open_uri.'
    echomsg 'See :help g:wwwsearch_command_to_open_uri for the details'
    return 0
  endif

  execute 'silent !' substitute(
  \             g:wwwsearch_command_to_open_uri,
  \             '{uri}',
  \             escape(shellescape(s:uri_to_search(a:keyword,
  \                                                n_search_engine_name),
  \                                !0),
  \                    '\'),
  \             ''
  \           )
  redraw!
  return !0
endfunction








" Misc.  "{{{1
" Variables  "{{{2

let s:search_engines = {}  " search-engine-name => uri-template




function! wwwsearch#cmd_Wwwsearch(args)  "{{{2
  if a:args[0][:0] == '-'
    return wwwsearch#search(join(a:args[1:]), a:args[0])
  else
    return wwwsearch#search(join(a:args))
  endif
endfunction




function! wwwsearch#cmd_Wwwsearch_complete(arglead, cmdline, cursorpos)  "{{{2
  " FIXME: context-aware completion
  return map(sort(keys(s:search_engines)), '"-" . v:val')
endfunction




function! wwwsearch#operator_default(motion_wise)  "{{{2
  let v = operator#user#visual_command_from_wise_name(a:motion_wise)

  let [original_U_content, original_U_type] = [@", getregtype('"')]
    execute 'normal!' '`['.v.'`]y'
    let keyword = @"
  call setreg('"', original_U_content, original_U_type)

  return wwwsearch#search(keyword)
endfunction




function! wwwsearch#_sid_prefix()  "{{{2
  return s:SID_PREFIX()
endfunction

function! s:SID_PREFIX()  
  return matchstr(expand('<sfile>'), '\%(^\|\.\.\)\zs<SNR>\d\+_')
endfunction




function! s:default_command_to_open_uri()  "{{{2
  if has('mac') || has('macunix') || system('uname') =~? '^darwin'
    return 'open {uri}'
  elseif has('win32') || has('win64')
    return 'start {uri}'
  else
    return ''
  endif
endfunction




function! s:normalize_search_engine_name(s)  "{{{2
  return substitute(a:s, '^-', '', '')
endfunction




function! s:uri_escape(s)  "{{{2
  if s:safe_map is 0
    let safe_chars = ('ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    \                 . 'abcdefghijklmnopqrstuvwxyz'
    \                 . '0123456789'
    \                 . '_.-'
    \                 . '/')
    unlet s:safe_map
    let s:safe_map = {}
    for i in range(256)
      let c = nr2char(i)
      let s:safe_map[i] = 0 <= stridx(safe_chars, c) ? c : printf('%%%02X', i)
    endfor
  endif
  return join(map(range(len(a:s)), 's:safe_map[char2nr(a:s[v:val])]'), '')
endfunction

let s:safe_map = 0




function! s:uri_to_search(keyword, n_search_engine_name)  "{{{2
  let uri_template = get(s:search_engines, a:n_search_engine_name, '')
  let uri_escaped_keyword = s:uri_escape(a:keyword)
  return substitute(uri_template, '{keyword}', uri_escaped_keyword, 'g')
endfunction




" Default set of search engines  "{{{2

" BUGS: To ensure that any other stuffs are available,
"       this section must be written at the end of this file.

" FIXME: Add more search engines.

call wwwsearch#add('default', 'http://www.google.com/search?q={keyword}')
call wwwsearch#add('google', 'http://www.google.com/search?q={keyword}')
" call wwwsearch#add('vim', '...')
" call wwwsearch#add('wikipedia', '...')
" ...








" __END__  "{{{1
" vim: foldmethod=marker
