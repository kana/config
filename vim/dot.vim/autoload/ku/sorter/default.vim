" ku-sorter-default - The default sorter
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
" Interface  "{{{1
function! ku#sorter#default#sort(candidates, args)  "{{{2
  let sorted_candidates = a:candidates

  for Sort in s:sorters
    let sorted_candidates = Sort(sorted_candidates, a:args)
    unlet Sort  " To avoid E705.
  endfor

  return sorted_candidates
endfunction




function! ku#sorter#default#use(sorters)  "{{{2
  " FIXME: Validate a:sorters.
  let old_sorters = s:sorters
  let s:sorters = a:sorters
  return old_sorters
endfunction








" Misc.  "{{{1

let s:sorters = [function('ku#sorter#smart#sort')]








" __END__  "{{{1
" vim: foldmethod=marker
