" regcopy - Quick and easy way to copy text between registers
" Version: 0.0.0
" Copyright (C) 2010 kana <http://whileimautomaton.net/>
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
function! regcopy#_map()
  if v:register == ''
    return '"'
  else
    let c = s:getchar()
    if c =~# '[[:print:]]'
      " BUGS: Invalid register name may be accepted, but it's a bit hard to
      " determine whether given name is valid for a register or not.
      let reg_from = v:register
      let reg_to = c
      execute printf('let @%s = @%s', reg_from, reg_to)
      return "\<Esc>"
    else
      " Invalid register name - ignore it.
      echoerr 'Invalid register name:' string(c)
      return "\<Esc>"
    endif
  endif
endfunction








" Misc.  "{{{1
function! s:getchar()
  let c_or_n = getchar()
  if type(c_or_n) == type(0)
    return nr2char(c_or_n)
  else
    return c_or_n
  endif
endfunction








" __END__  "{{{1
" vim: foldmethod=marker
