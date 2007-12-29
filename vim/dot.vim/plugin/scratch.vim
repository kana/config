" scratch.vim - Emacs like scratch buffer.
" Version: 0.1+
" Copyright: Copyright (C) 2007 kana <http://nicht.s8.xrea.com/>
" License: MIT license (see <http://www.opensource.org/licenses/mit-license>)
" $Id$  "{{{1

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








" __END__
" vim: foldmethod=marker
