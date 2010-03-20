" repeat - Enable to repeat last change by non built-in commands
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

if exists('g:loaded_repeat')
  finish
endif




nnoremap <silent> <Plug>(repeat-.)  :<C-u>call repeat#_repeat(v:count)<Return>
nnoremap <silent> <Plug>(repeat-u)  :<C-u>call repeat#_do('u', v:count)<Return>
nnoremap <silent> <Plug>(repeat-U)  :<C-u>call repeat#_do('U', v:count)<Return>
nnoremap <silent> <Plug>(repeat-<C-r>)
\        :<C-u>call repeat#_do("\<LT>C-r>", v:count)<Return>
nnoremap <silent> <Plug>(repeat-g-)
\        :<C-u>call repeat#_do('g-', v:count)<Return>
nnoremap <silent> <Plug>(repeat-g+)
\        :<C-u>call repeat#_do('g+', v:count)<Return>


command! -bang -bar -nargs=0 RepeatDefaultKeyMappings
\ call s:cmd_RepeatDefaultKeyMappings('<bang>' == '!')
function! s:cmd_RepeatDefaultKeyMappings(bang_p)
  let opt = a:bang_p ? '' : '<unique>'

  for i in ['.', 'u', 'U', '<C-r>', 'g-', 'g+']
    silent! execute 'nmap' opt i  '<Plug>(repeat-'.i.')'
  endfor
endfunction

if !exists('g:repeat_no_default_key_mappings')
  RepeatDefaultKeyMappings
endif




let g:loaded_repeat = 1

" __END__
" vim: foldmethod=marker
