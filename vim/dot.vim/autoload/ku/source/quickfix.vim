" ku source: quickfix
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
function! ku#source#quickfix#action_open(candidate)  "{{{2
  return s:open('', a:candidate)
endfunction




function! ku#source#quickfix#action_open_x(candidate)  "{{{2
  return s:open('!', a:candidate)
endfunction




function! ku#source#quickfix#gather_candidates(quickfix)  "{{{2
  let qflist = getqflist()
  let bq = {}  " buffer number -> error number (smallest one for the buffer)
  for i in range(len(qflist) - 1, 0, -1)
    if qflist[i].valid
      let bq[qflist[i].bufnr] = i + 1
    endif
  endfor

  return map(items(bq), '{
  \   "ku_buffer_nr": v:val[0] + 0,
  \   "ku_quickfix_nr": v:val[1],
  \   "word": bufname(v:val[0] + 0),
  \ }')
endfunction








" Misc.  {{{1
function! s:open(bang, candidate)  "{{{2
  let v:errmsg = ''

  let original_switchbuf = &switchbuf
    let &switchbuf = ''
    execute 'cc'.a:bang a:candidate.ku_quickfix_nr
  let &switchbuf = original_switchbuf

  return v:errmsg == '' ? 0 : v:errmsg
endfunction








" __END__  "{{{1
" vim: foldmethod=marker
