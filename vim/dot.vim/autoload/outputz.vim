" outputz - outputz interface for Vim
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
" Interface  "{{{1
function! outputz#default_uri_function()  "{{{2
  return 'vim://filetype.' . &l:filetype
endfunction




function! outputz#init()  "{{{2
  let b:outputz_count = s:number_of_bytes_of_the_current_buffer()
endfunction




function! outputz#send(range_check_p)  "{{{2
  if a:range_check_p && !s:whole_range_p()
    " A part of the current buffer is being written to a file.
    " We don't count this case.
    return
  endif

  let current_count = s:number_of_bytes_of_the_current_buffer()
  let difference = (current_count
  \                 - (exists('b:outputz_count') ? b:outputz_count : 0))
  if 0 < difference
    call s:send(difference)
  endif
  let b:outputz_count = current_count
endfunction








" Misc.  "{{{1
function! s:send(n)  "{{{2
  if !exists('g:outputz_secret_key')
    echoerr 'g:outputz_secret_key is not defined'
    return
  endif

  silent! execute printf('!curl --form-string key=%s --form-string uri=%s --form-string "size=%d" http://outputz.com/api/post',
  \ fnameescape(g:outputz_secret_key),
  \ fnameescape({g:outputz_uri_function}()),
  \ a:n)
endfunction




function! s:whole_range_p()  "{{{2
  return line("'[") == 1 && line("']") == line('$')
endfunction




function! s:number_of_bytes_of_the_current_buffer()  "{{{2
  return line2byte(line('$') + 1) - 1
endfunction








" __END__  "{{{1
" vim: foldmethod=marker
