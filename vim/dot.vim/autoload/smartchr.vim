" smartchr - Insert several candidates with a single key
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




function! smartchr#loop(...)
  return call('smartchr#one_of', a:000 + [(a:1)])
endfunction

function! smartchr#one_of(...)
  " Support function to insert one of the given arguments like
  " ess-smart-underscore of Emacs Speaks Statistics.
  "
  " For example, the following setting emulates ess-smart-underscore:
  "
  "   inoremap <expr> _  <SID>smart_char(' <- ', '_')
  "
  " With the above setting, when user types "_" key, " <- " is inserted for
  " the first time.  When user types "_" key again, the previously inserted
  " " <- " is replaced by "_".
  "
  " More generally, this function returns the key sequence to:
  " - Insert a:1 for the first time.
  " - Delete a:1 then insert a:2 for the second time.
  " - Delete a:{N-1} then insert a:{N} for the Nth time.

  for i in range(len(a:000) - 1, 1, -1)
    let literal1 = a:000[i]
    let literal2 = a:000[i-1]

    if search('\V' . escape(literal2, '\') . '\%#', 'bcn')
      return (pumvisible() ? "\<C-e>" : '')
           \ . repeat("\<BS>", len(literal2))
           \ . literal1
    endif
  endfor

  return a:1
endfunction




" __END__
" vim: foldmethod=marker
