" ku source: metarw
" Version: 0.2.0
" Copyright (C) 2008-2009 kana <http://whileimautomaton.net/>
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
" Interface  "{{{1
function! ku#source#metarw#gather_candidates(args)  "{{{2
  " FIXME: caching - but each scheme may already do caching.
  " a:args.pattern is not always prefixed with "{scheme}:".
  let scheme_name = s:scheme_name_from_source_name(a:args.source.name)
  let _ = scheme_name . ':' . a:args.pattern
  return map(metarw#{scheme_name}#complete(_, _, 0)[0],
  \          '{"word": matchstr(v:val, "^" . scheme_name . '':\zs.*$'')}')
endfunction




function! ku#source#metarw#on_action(candidate)  "{{{2
  " See also ku#source#metarw#gather_candidates().
  let scheme_name = s:scheme_name_from_source_name(a:candidate.ku__source.name)

  let _ = copy(a:candidate)
  let _.word = scheme_name . ':' . a:candidate.word
  return _
endfunction








" Misc.  "{{{1
function! ku#source#metarw#_sid_prefix()  "{{{2
  nnoremap <SID>  <SID>
  return maparg('<SID>', 'n')
endfunction




function! s:scheme_name_from_source_name(source_name)  "{{{2
  return matchstr(a:source_name, '^metarw/\zs[a-z]\+\ze$')
endfunction








" __END__  "{{{1
" vim: foldmethod=marker
