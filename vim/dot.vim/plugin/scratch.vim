" scratch - Emacs like scratch buffer
" Version: 0.1+
" Copyright (C) 2007 kana <http://whileimautomaton.net/>
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
"{{{1

if exists('g:loaded_scratch')
  finish
endif








" Interfaces  "{{{1

command! -bar -nargs=0 ScratchOpen  call scratch#open()
command! -bar -nargs=0 ScratchClose  call scratch#close()
command! -bang -bar -nargs=0 -range ScratchEvaluate
      \ call scratch#evaluate_linewise(<line1>, <line2>, '<bang>' != '!')


noremap <silent> <Plug>(scratch-open)  :<C-u>ScratchOpen<Return>
noremap <silent> <Plug>(scratch-close)  :<C-u>ScratchClose<Return>
noremap <silent> <Plug>(scratch-evaluate)  :ScratchEvaluate<Return>
noremap <silent> <Plug>(scratch-evaluate!)  :ScratchEvaluate!<Return>








" Variables  "{{{1

if !exists('g:scratch_buffer_name')
  let g:scratch_buffer_name = '*Scratch*'
endif

if !exists('g:scratch_show_command')
  let g:scratch_show_command = 'topleft split | hide buffer'
endif








" Fin.  "{{{1

let g:loaded_scratch = 1








" __END__  "{{{1
" vim: foldmethod=marker
