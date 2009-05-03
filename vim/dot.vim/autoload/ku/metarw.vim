" ku source: metarw
" Version: 0.1.1
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
function! ku#metarw#available_sources()  "{{{2
  return map(split(globpath(&runtimepath, 'autoload/metarw/*.vim'), '\n'),
  \          '"metarw/" . fnamemodify(v:val, ":t:r")')
endfunction




function! ku#metarw#on_before_action(source_name_ext, item)  "{{{2
  " See also ku#metarw#gather_items().
  let _ = copy(a:item)
  let _.word = a:source_name_ext . ':' . _.word
  return _
endfunction




function! ku#metarw#action_table(source_name_ext)  "{{{2
  return ku#file#action_table('')
endfunction




function! ku#metarw#key_table(source_name_ext)  "{{{2
  return ku#file#key_table('')
endfunction




function! ku#metarw#gather_items(source_name_ext, pattern)  "{{{2
  " FIXME: caching - but each scheme may already do caching.
  " a:pattern is not always prefixed with "{scheme}:".
  let scheme = a:source_name_ext
  let _ = scheme . ':' . a:pattern
  return map(metarw#{scheme}#complete(_, _, 0)[0],
  \          '{"word": matchstr(v:val, "^" . scheme . '':\zs.*$'')}')
endfunction








" __END__  "{{{1
" vim: foldmethod=marker
