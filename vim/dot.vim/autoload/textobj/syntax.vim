" textobj-syntax - Text objects for syntax highlighted items
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
function! textobj#syntax#select_a()  "{{{2
  " FIXME: Currently this acts the same as "iy", but it'll be changed.
  return textobj#syntax#select_i()
endfunction




function! textobj#syntax#select_i()  "{{{2
  let current_position = getpos('.')
  let synstack = synstack(current_position[1], current_position[2])

  if empty(synstack)   " The character under the cursor is not highlighted.
    return 0
  endif

  let original_whichwrap = &g:whichwrap
    setglobal whichwrap=h,l
    while !0
      let start_position = getpos('.')
      normal! h
      let _ = getpos('.')
      if synstack(_[1], _[2])[:len(synstack)-1] != synstack
      \  || start_position == _
        break
      endif
    endwhile

    call setpos('.', current_position)
    while !0
      let end_position = getpos('.')
      normal! l
      let _ = getpos('.')
      if synstack(_[1], _[2])[:len(synstack)-1] != synstack
      \  || end_position == _
        break
      endif
    endwhile
  let &g:whichwrap = original_whichwrap
  return ['v', start_position, end_position]
endfunction








" Misc.  "{{{1








" __END__  "{{{1
" vim: foldmethod=marker
