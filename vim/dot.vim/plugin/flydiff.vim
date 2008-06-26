" flydiff - on-the-fly diff
" Version: 0.0
" Copyright (C) 2008 kana <http://whileimautomaton.net/>
" License: MIT license (see <http://www.opensource.org/licenses/mit-license>)

if exists('g:loaded_flydiff')
  finish
endif




command -bar -nargs=? Flydiff  call flydiff#toggle(bufnr(''), <q-args>)


if !exists('g:flydiff_timing')
  let g:flydiff_timing = 'realtime'
endif
if !exists('g:flydiff_direction')
  let g:flydiff_direction = 'vertical rightbelow'
endif
if !exists('g:flydiff_filetype')
  let g:flydiff_filetype = 'diff'
endif




let g:loaded_flydiff = 1

" __END__
" vim: foldmethod=marker
