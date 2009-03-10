" dontedit - Safety net for files not to be edited manually
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

if exists('g:loaded_dontedit')
  finish
endif




if !exists('g:dontedit_content_patterns')
  let g:dontedit_content_patterns = [
  \     '\c\<\%(do not\|don''t\) edit this file manually\>'
  \   ]
endif


augroup plugin-dontedit
  autocmd!
  autocmd BufReadPost *  call s:check()
augroup END


function! s:check()
  for pattern in g:dontedit_content_patterns
    if 0 < search(pattern, 'cnw')
      call s:configure()
      return
    endif
  endfor
  return
endfunction

function! s:configure()
  setlocal readonly
  setlocal nomodifiable  " This should be turned off or not?
endfunction




let g:loaded_dontedit = 1

" __END__
" vim: foldmethod=marker
