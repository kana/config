" flydiff - on-the-fly diff
" Version: 0.0
" Copyright (C) 2008 kana <http://whileimautomaton.net/>
" License: MIT license (see <http://www.opensource.org/licenses/mit-license>)

if exists('g:loaded_flydiff')
  finish
endif




command -bar -nargs=? Flydiff  call flydiff#toggle(bufnr(''), <q-args>)


if !exists('g:flydiff_mode')
  let g:flydiff_mode = 'on-the-fly'
endif




let g:loaded_flydiff = 1

" __END__
" vim: foldmethod=marker
