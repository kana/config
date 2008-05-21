" ku - Support to do something
" Version: 0.0.0
" Copyright: Copyright (C) 2008 kana <http://nicht.s8.xrea.com/>
" License: MIT license (see <http://www.opensource.org/licenses/mit-license>)
"{{{1

if exists('g:loaded_ku')
  finish
endif








" Interfaces  "{{{1

command! -bang -bar -nargs=* Ku  call ku#start('<bang>', '<args>')








" Fin.  "{{{1

let g:loaded_ku = 1








" __END__  "{{{1
" vim: foldmethod=marker
