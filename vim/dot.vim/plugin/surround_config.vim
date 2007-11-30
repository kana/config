" $Id$
"
" This file is to define user-defined surrounding objects, especially for the
" objects which contain multibyte characters.  Originally I put these
" definitions in ~/.vimrc, but multibyte strings will be broken whenever
" 'encoding' is changed.  So I moved the definitions into this file.

if exists('g:loaded_surround') && exists('*SurroundRegister')
  call SurroundRegister('g', 'js', "「\r」")
  call SurroundRegister('g', 'jd', "『\r』")
endif

" __END__
