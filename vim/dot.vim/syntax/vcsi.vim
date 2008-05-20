" vcsi.vim - Version Control System Interface
" Version: 0.0.7
" Copyright: Copyright (C) 2007-2008 kana <http://whileimautomaton.net/>
" License: MIT license (see <http://www.opensource.org/licenses/mit-license>)

if version < 600
  syntax clear
elseif exists('b:current_syntax') && b:current_syntax =~# '\<vcsi\>'
  finish
endif




syntax region vcsiLog keepend start=/^\%^/ end=/^=== .* ===$/me=s-1
syntax match vcsiSeparator /^=== .* ===$/

highlight default link vcsiLog Normal
highlight default link vcsiSeparator Delimiter




if !exists('b:current_syntax')
  let b:current_syntax = 'vcsi'
else
  let b:current_syntax .= '.vcsi'
endif

" __END__
