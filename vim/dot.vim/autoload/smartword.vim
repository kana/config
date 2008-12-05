" smartword - Smart motions on words
" Version: 0.0.0
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
function! smartword#move(motion_command)  "{{{2
  for i in range(v:count1)
    let curpos = []  " dummy
    let newpos = []  " dummy
    while !0
      let curpos = newpos
      execute 'normal!' a:motion_command
      let newpos = getpos('.')

      if s:letter_p(s:current_char(newpos))
        break
      endif
      if curpos == newpos  " No more word - stop.
        return
      endif
    endwhile
  endfor
endfunction








" Misc.  "{{{1
function! s:current_char(pos)  "{{{2
  return getline(a:pos[1])[a:pos[2] - 1]
endfunction




function! s:parse_iskeyword(iskeyword)  "{{{2
  " FIXME: NIY
  return split('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz', '\ze.')
endfunction




function! s:letter_p(char)  "{{{2
  let chars = s:parse_iskeyword(&l:iskeyword)
  let pattern = '[' . escape(join(chars, ''), '\[]-^:') . ']'
  return a:char =~# pattern
endfunction








" __END__  "{{{1
" vim: foldmethod=marker
