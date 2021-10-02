" Vim additional syntax: gitcommit

" Highlight the title line as warning if it is longer than 50 characters.
" Highlight the title line as error if it is longer than 72 characters.
syntax match gitcommitOverflow          ".*\%<73v." contained nextgroup=gitcommitOverflowTooMuch contains=@Spell
syntax match gitcommitOverflowTooMuch   ".*" contained contains=@Spell
highlight link gitcommitOverflow        WarningMsg
highlight link gitcommitOverflowTooMuch Error

" __END__
" vim: foldmethod=marker
