" smarttill - Smart motions, till before/after a punctuation
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
function! smarttill#after(mode)  "{{{2
  echoerr 'FIXME: Not implemented yet'
endfunction




function! smarttill#before(mode)  "{{{2
  " t, the original command, is inclusive motion.
  " But user-defined motion based on a function is always exclusive.
  " So that the following strategy is used to emulate t-like motion:
  " - In Operator-pending mode, move to the target character.
  "   The motion is exclusive, so the text to be operated is the same as t.
  " - In Normal mode and Visual mode, move to the target character then move
  "   1 character to the left.
  " FIXME: Support o_v and others.

  " Visual mode is canceled to invoke this function,
  " so that the last selection must be restored first.
  if a:mode == 'v'
    normal! gv
  endif

  " Move the cursor to [count]'th occurrence of any punctuation.
  for i in range(v:count1)
    call search('.\&\(\k\|\_s\)\@!', 'W')
  endfor

  " Adjust the cursor position to emulate the t motion.
  if a:mode ==# 'n' || a:mode ==# 'v'
    " FIXME: edge case - if the cursor is not moved at the previous step?
    normal! h
  endif
endfunction








" __END__  "{{{1
" vim: foldmethod=marker
