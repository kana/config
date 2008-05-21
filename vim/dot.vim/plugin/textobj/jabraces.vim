" textobj-jabraces - Text objects for Japanese braces
" Version: 0.0.0
" Copyright (C) 2008 kana <http://whileimautomaton.net/>
" License: MIT license (see <http://www.opensource.org/licenses/mit-license>)
scriptencoding utf-8  "{{{1

if exists('g:loaded_textobj_jabraces')
  finish
endif








" Interface  "{{{1

for i in ['parens', 'brackets', 'braces', 'angles', 'double-angles',
  \       'kakko', 'double-kakko', 'yama-kakko', 'double-yama-kakko',
  \       'kikkou-kakko', 'sumi-kakko']
  for j in ['i', 'a']
    for k in ['v', 'o']
      execute k.'noremap <silent>'
            \ '<Plug>(textobj-jabraces-'.j.'-'.i.')'
            \ ':<C-u>call <SID>select("'.i.'", "'.j.'", "'.k.'")<Return>'
    endfor
  endfor
endfor
unlet i j




command! -bang -bar -nargs=0 TextobjJabracesDefaultKeyMappings
      \ call s:default_key_mappings('<bang>' == '!')

function! s:default_key_mappings(bangedp)
  let forcedp = (a:bangedp ? '' : '<unique>')

  function! s:Map(forcedp, lhs, rhs)
    execute 'silent! vmap' (a:forcedp ? '' : '<unique>') a:lhs a:rhs
    execute 'silent! omap' (a:forcedp ? '' : '<unique>') a:lhs a:rhs
  endfunction

  call s:Map(forcedp, 'ajb', '<Plug>(textobj-jabraces-a-parens)')
  call s:Map(forcedp, 'aj(', '<Plug>(textobj-jabraces-a-parens)')
  call s:Map(forcedp, 'aj)', '<Plug>(textobj-jabraces-a-parens)')
  call s:Map(forcedp, 'ajB', '<Plug>(textobj-jabraces-a-braces)')
  call s:Map(forcedp, 'aj{', '<Plug>(textobj-jabraces-a-braces)')
  call s:Map(forcedp, 'aj}', '<Plug>(textobj-jabraces-a-braces)')
  call s:Map(forcedp, 'ajr', '<Plug>(textobj-jabraces-a-brackets)')
  call s:Map(forcedp, 'aj[', '<Plug>(textobj-jabraces-a-brackets)')
  call s:Map(forcedp, 'aj]', '<Plug>(textobj-jabraces-a-brackets)')
  call s:Map(forcedp, 'aja', '<Plug>(textobj-jabraces-a-angles)')
  call s:Map(forcedp, 'aj<', '<Plug>(textobj-jabraces-a-angles)')
  call s:Map(forcedp, 'aj>', '<Plug>(textobj-jabraces-a-angles)')
  call s:Map(forcedp, 'ajA', '<Plug>(textobj-jabraces-a-double-angles)')
  call s:Map(forcedp, 'ajk', '<Plug>(textobj-jabraces-a-kakko)')
  call s:Map(forcedp, 'ajK', '<Plug>(textobj-jabraces-a-double-kakko)')
  call s:Map(forcedp, 'ajy', '<Plug>(textobj-jabraces-a-yama-kakko)')
  call s:Map(forcedp, 'ajY', '<Plug>(textobj-jabraces-a-double-yama-kakko)')
  call s:Map(forcedp, 'ajt', '<Plug>(textobj-jabraces-a-kikkou-kakko)')
  call s:Map(forcedp, 'ajs', '<Plug>(textobj-jabraces-a-sumi-kakko)')

  call s:Map(forcedp, 'ijb', '<Plug>(textobj-jabraces-i-parens)')
  call s:Map(forcedp, 'ij(', '<Plug>(textobj-jabraces-i-parens)')
  call s:Map(forcedp, 'ij)', '<Plug>(textobj-jabraces-i-parens)')
  call s:Map(forcedp, 'ijB', '<Plug>(textobj-jabraces-i-braces)')
  call s:Map(forcedp, 'ij{', '<Plug>(textobj-jabraces-i-braces)')
  call s:Map(forcedp, 'ij}', '<Plug>(textobj-jabraces-i-braces)')
  call s:Map(forcedp, 'ijr', '<Plug>(textobj-jabraces-i-brackets)')
  call s:Map(forcedp, 'ij[', '<Plug>(textobj-jabraces-i-brackets)')
  call s:Map(forcedp, 'ij]', '<Plug>(textobj-jabraces-i-brackets)')
  call s:Map(forcedp, 'ija', '<Plug>(textobj-jabraces-i-angles)')
  call s:Map(forcedp, 'ij<', '<Plug>(textobj-jabraces-i-angles)')
  call s:Map(forcedp, 'ij>', '<Plug>(textobj-jabraces-i-angles)')
  call s:Map(forcedp, 'ijA', '<Plug>(textobj-jabraces-i-double-angles)')
  call s:Map(forcedp, 'ijk', '<Plug>(textobj-jabraces-i-kakko)')
  call s:Map(forcedp, 'ijK', '<Plug>(textobj-jabraces-i-double-kakko)')
  call s:Map(forcedp, 'ijy', '<Plug>(textobj-jabraces-i-yama-kakko)')
  call s:Map(forcedp, 'ijY', '<Plug>(textobj-jabraces-i-double-yama-kakko)')
  call s:Map(forcedp, 'ijt', '<Plug>(textobj-jabraces-i-kikkou-kakko)')
  call s:Map(forcedp, 'ijs', '<Plug>(textobj-jabraces-i-sumi-kakko)')

  return
endfunction

if !exists('g:textobj_jabraces_no_default_key_mappings')
  TextobjJabracesDefaultKeyMappings
endif








" Misc.  "{{{1

function! s:select(type, i_or_a, previous_mode)
  return textobj#user#select_pair(s:PATTERNS1[a:type], s:PATTERNS2[a:type],
       \                          a:i_or_a, a:previous_mode)
endfunction




let s:PATTERNS1 = {}
let s:PATTERNS2 = {}

let s:PATTERNS1['parens'] = '（'
let s:PATTERNS2['parens'] = '）'
let s:PATTERNS1['brackets'] = '［'
let s:PATTERNS2['brackets'] = '］'
let s:PATTERNS1['braces'] = '｛'
let s:PATTERNS2['braces'] = '｝'
let s:PATTERNS1['angles'] = '＜'
let s:PATTERNS2['angles'] = '＞'
let s:PATTERNS1['double-angles'] = '≪'
let s:PATTERNS2['double-angles'] = '≫'
let s:PATTERNS1['kakko'] = '「'
let s:PATTERNS2['kakko'] = '」'
let s:PATTERNS1['double-kakko'] = '『'
let s:PATTERNS2['double-kakko'] = '』'
let s:PATTERNS1['yama-kakko'] = '〈'
let s:PATTERNS2['yama-kakko'] = '〉'
let s:PATTERNS1['double-yama-kakko'] = '《'
let s:PATTERNS2['double-yama-kakko'] = '》'
let s:PATTERNS1['kikkou-kakko'] = '〔'
let s:PATTERNS2['kikkou-kakko'] = '〕'
let s:PATTERNS1['sumi-kakko'] = '【'
let s:PATTERNS2['sumi-kakko'] = '】'








" Fin.  "{{{1

let g:loaded_textobj_jabraces = 1








" __END__
" vim: foldmethod=marker
