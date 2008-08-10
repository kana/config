" ku special source: metarw
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

let s:current_scheme = ''








" Interface  "{{{1
function! ku#special#metarw#event_handler(event, ...)  "{{{2
  if a:event ==# 'SourceEnter'
    let s:current_scheme = matchstr(a:1, '-\zs.*$')
  elseif a:event ==# 'SourceLeave'
    " Don't clear - keep the value for BeforeAction.
    " Because SourceLeave is always published before BeforeAction.
    "
    " let s:current_scheme = ''
  elseif a:event ==# 'BeforeAction'
    " See also ku#special#metarw#gather_items().
    let _ = copy(a:1)
    let _.word = s:current_scheme . ':' . _.word
    return _
  else
    return call('ku#default_event_handler', [a:event] + a:000)
  endif
endfunction




function! ku#special#metarw#action_table()  "{{{2
  return ku#file#action_table()
endfunction




function! ku#special#metarw#key_table()  "{{{2
  return ku#file#key_table()
endfunction




function! ku#special#metarw#gather_items(pattern)  "{{{2
  " FIXME: caching - but each scheme may already do caching.
  " a:pattern is not always prefixed with "{scheme}:".
  let _ = s:current_scheme . ':' . a:pattern
  return map(metarw#{s:current_scheme}#complete(_, _, 0)[0],
  \          '{"word": matchstr(v:val, "^" . s:current_scheme . '':\zs.*$'')}')
endfunction








" __END__  "{{{1
" vim: foldmethod=marker
