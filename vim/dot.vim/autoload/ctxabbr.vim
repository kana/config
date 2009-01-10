" ctxabbr - Context-sensitive abbreviations
" Version: 0.0.1
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

let s:db = {}  " lhs -> [Dict, ...] -- see s:register() for the details.








" Interface  "{{{1
function! ctxabbr#clear(lhs)  "{{{2
  let s:db[a:lhs] = []
endfunction




function! ctxabbr#define(lhs, rhs, condition)  "{{{2
  call s:register(a:lhs, a:rhs, a:condition)
  execute 'inoreabbrev <expr>' a:lhs  '<SID>expand(' string(a:lhs) ')'
endfunction




function! ctxabbr#dump(...)  "{{{2
  let lhss = 1 <= a:0 ? a:000 : sort(keys(s:db))
  for lhs in lhss
    echo 'lhs' string(lhs)
    for _ in get(s:db, lhs, [])
      echo '  rhs' string(_.rhs) 'condition' string(_.condition)
    endfor
  endfor
endfunction








" Misc.  "{{{1
function! s:expand(lhs)  "{{{2
  let entries = get(s:db, a:lhs, [])
  for _ in filter(copy(entries), 'v:val.condition[0] != "!"')
    if s:met_p(_.condition, a:lhs)
      return _.rhs
    endif
  endfor

  let entries = filter(copy(entries), 'v:val.condition[0] == "!"')
  if 0 < len(entries)
    return entries[0].rhs
  endif

  return a:lhs
endfunction




function! s:met_p(condition, lhs)  "{{{2
  let type = a:condition[0]
  let rest = a:condition[1:]

  if type == '<'
    let type = '?'
    let rest = '\V' . s:regexp_WORDs(rest . ' ' . a:lhs) . '\s\*\%#'
  elseif type == '>'
    let type = '/'
    let rest = '\V' . '\%#\s\*' . s:regexp_WORDs(rest)
  endif

  if type == '/'
    return search(rest, 'cnW')
  elseif type == '?'
    return search(rest, 'bcnW')
  else
    echoerr 'Invalid condition:' string(a:condition)
    return 0
  endif
endfunction




function! s:regexp_WORDs(WORDs)  "{{{2
  " returns a regular expression for \V.
  return join(map(split(substitute(a:WORDs, ' \+', ' ', 'g')),
  \               'escape(v:val, ''\'')'),
  \           '\s\+')
endfunction




function! s:register(lhs, rhs, condition)  "{{{2
  let s:db[a:lhs] = insert(get(s:db, a:lhs, []),
  \                        {'condition': a:condition,
  \                         'rhs': a:rhs},
  \                        0)
endfunction








" __END__  "{{{1
" vim: foldmethod=marker
