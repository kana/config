" altkwprg - Alternative 'keywordprg' with :help-like window
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

if exists('g:loaded_altkwprg')
  finish
endif




nnoremap <silent> <Plug>(altkwprg-look)
\        :<C-u>call altkwprg#look(expand('<cword>'))<Return>
vnoremap <silent> <Plug>(altkwprg-look)
\        :<C-u>call altkwprg#look(0)<Return>




command! -bang -bar -nargs=0 AltkwprgDefaultKeyMappings
\ call s:cmd_AltkwprgDefaultKeyMappings('<bang>' == '!')
function! s:cmd_AltkwprgDefaultKeyMappings(banged_p)
  let _ = a:banged_p ? '' : '<unique>'
  silent! execute 'nmap' _ 'K  <Plug>(altkwprg-look)'
  silent! execute 'vmap' _ 'K  <Plug>(altkwprg-look)'
endfunction

if !exists('g:altkwprg_no_default_key_mappings')
  AltkwprgDefaultKeyMappings
endif




if &g:keywordprg ==# 'man' || &g:keywordprg ==# 'man -s'
  let g:keywordprg = '{ man <count> <keyword> | col -b; }'
endif




let g:loaded_altkwprg = 1

" __END__
" vim: foldmethod=marker
