" ku action: file - Default actions for kind "file"
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
function! ku#action#file#extract_asis(candidate)  "{{{2
  return 'Not implemented yet'
endfunction




function! ku#action#file#extract_smartly(candidate)  "{{{2
  return 'Not implemented yet'
endfunction




function! ku#action#file#extract_solely(candidate)  "{{{2
  return 'Not implemented yet'
endfunction




function! ku#action#file#open(candidate)  "{{{2
  return s:open('', a:candidate)
endfunction




function! ku#action#file#open_x(candidate)  "{{{2
  return s:open('!', a:candidate)
endfunction








" Misc.  "{{{1
function! ku#action#file#_sid_prefix()  "{{{2
  nnoremap <SID>  <SID>
  return maparg('<SID>',  'n')
endfunction




function! s:open(bang, candidate)  "{{{2
  let v:errmsg = ''

  let bufnr = bufnr(fnameescape(s:path_from_candidate(a:candidate)))
  if 1 <= bufnr
    execute bufnr 'buffer'.a:bang
  else
    execute 'edit'.a:bang '`=s:path_from_candidate(a:candidate)`'
  endif

  return v:errmsg == '' ? 0 : v:errmsg
endfunction




function! s:path_from_candidate(candidate)  "{{{2
  return (has_key(a:candidate, 'ku_file_path')
  \       ? a:candidate.ku_file_path
  \       : a:candidate.word)
endfunction








" __END__  "{{{1
" vim: foldmethod=marker
