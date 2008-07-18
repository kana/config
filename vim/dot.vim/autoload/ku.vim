" ku - Support to do something
" Version: 0.1.0
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
function! ku#custom_action(source, action, funcrec)  "{{{2
  throw 'FIXME: Not impelemented yet'
endfunction




function! ku#custom_key(source, key, action)  "{{{2
  throw 'FIXME: Not impelemented yet'
endfunction




function! ku#default_key_mappings(override_p)  "{{{2
  let _ = a:override_p ? '' : '<unique>'
  call s:ni_noremap('<buffer> <C-c>', _, '<Plug>(ku-cancel)')
  call s:ni_noremap('<buffer> <Return>', _, '<Plug>(ku-do-the-default-action)')
  call s:ni_noremap('<buffer> <C-m>', _, '<Plug>(ku-do-the-default-action)')
  call s:ni_noremap('<buffer> <Tab>', _, '<Plug>(ku-choose-an-action)')
  call s:ni_noremap('<buffer> <C-i>', _, '<Plug>(ku-choose-an-action)')
  call s:ni_noremap('<buffer> <C-j>', _, '<Plug>(ku-next-source)')
  call s:ni_noremap('<buffer> <C-k>', _, '<Plug>(ku-previous-source)')
  return
endfunction




function! ku#start(source)  "{{{2
  throw 'FIXME: Not impelemented yet'
endfunction








" Misc.  "{{{1
function! s:ni_noremap(...)  "{{{2
  for _ in ['n', 'i']
    execute _.'noremap' join(a:000)
  endfor
  return
endfunction








" __END__  "{{{1
" vim: foldmethod=marker
