" ku source: buffer
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
function! ku#buffer#on_start_session()  "{{{2
  echomsg 'on_start_session'
endfunction




function! ku#buffer#on_end_session()  "{{{2
  echomsg 'on_end_session'
endfunction




function! ku#buffer#action_table()  "{{{2
  return {'*default*': 'ku#buffer#_action_switch',
  \       'switch': 'ku#buffer#_action_switch'}
endfunction




function! ku#buffer#key_table()  "{{{2
  return {}
endfunction




function! ku#buffer#gather_items()  "{{{2
  return []
endfunction








" Misc.  "{{{1
function! ku#buffer#_action_switch(item)  "{{{2
  " FIXME: NIY
  echomsg 'buffer' string(a:item)
endfunction








" __END__  "{{{1
" vim: foldmethod=marker
