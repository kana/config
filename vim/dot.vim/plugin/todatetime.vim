" todatetime - Text objects for date and time.
" Version: 0.0
" Copyright (C) 2007 kana <http://nicht.s8.xrea.com/>
" License: MIT license (see <http://www.opensource.org/licenses/mit-license>)
" $Id$  "{{{1

if exists('g:loaded_todatetime')
  finish
endif








" Key Mappings  "{{{1

vnoremap <silent> <Plug>TODateTime_Auto  :<C-u>call TODateTime('auto', 'v')<CR>
vnoremap <silent> <Plug>TODateTime_Full  :<C-u>call TODateTime('full', 'v')<CR>
vnoremap <silent> <Plug>TODateTime_Date  :<C-u>call TODateTime('date', 'v')<CR>
vnoremap <silent> <Plug>TODateTime_Time  :<C-u>call TODateTime('time', 'v')<CR>
vnoremap <silent> <Plug>TODateTime_TZ    :<C-u>call TODateTime('tz', 'v')<CR>

onoremap <silent> <Plug>TODateTime_Auto  :<C-u>call TODateTime('auto', 'o')<CR>
onoremap <silent> <Plug>TODateTime_Full  :<C-u>call TODateTime('full', 'o')<CR>
onoremap <silent> <Plug>TODateTime_Date  :<C-u>call TODateTime('date', 'o')<CR>
onoremap <silent> <Plug>TODateTime_Time  :<C-u>call TODateTime('time', 'o')<CR>
onoremap <silent> <Plug>TODateTime_TZ    :<C-u>call TODateTime('tz', 'o')<CR>




function! TODateTime_DefaultKeymappings(...)
  let forcep = (a:0 ? a:1 : 0)

  function! s:Map(forcep, lhs, rhs)
    execute 'vmap' (a:forcep ? '' : '<unique>') a:lhs a:rhs
    execute 'omap' (a:forcep ? '' : '<unique>') a:lhs a:rhs
  endfunction

  call s:Map(forcep, 'ada', '<Plug>TODateTime_Auto')
  call s:Map(forcep, 'adf', '<Plug>TODateTime_Full')
  call s:Map(forcep, 'add', '<Plug>TODateTime_Date')
  call s:Map(forcep, 'adt', '<Plug>TODateTime_Time')
  call s:Map(forcep, 'adz', '<Plug>TODateTime_TZ')

  call s:Map(forcep, 'ida', '<Plug>TODateTime_Auto')
  call s:Map(forcep, 'idf', '<Plug>TODateTime_Full')
  call s:Map(forcep, 'idd', '<Plug>TODateTime_Date')
  call s:Map(forcep, 'idt', '<Plug>TODateTime_Time')
  call s:Map(forcep, 'idz', '<Plug>TODateTime_TZ')
endfunction








" Details  "{{{1

function! TODateTime(type, mode)
  let pos = getpos('.')
  call search(s:PATTERNS[a:type], 'ecW')
  call search(s:PATTERNS[a:type], 'bcW')
  execute 'normal!' (a:mode == 'v' ? visualmode() : 'v')
  call search(s:PATTERNS[a:type], 'ecW')
endfunction




let s:PATTERNS = {}

let s:PATTERNS._tz = '\%(Z\|[+-]\d\d:\d\d\)'
let s:PATTERNS.tz = '\%(:\d\d\)\zs' . s:PATTERNS._tz

let s:PATTERNS.time = '\d\d:\d\d\%(:\d\d\)\?'

let s:PATTERNS._date = '\d\d\d\d-\d\d-\d\d'
let s:PATTERNS.date = '\d\d\d\d\%(-\d\d\%(-\d\d\)\?\)\?'

let s:PATTERNS.full = s:PATTERNS._date . 'T' . s:PATTERNS.time
                  \ . '\%(' . s:PATTERNS._tz . '\)\?'

let s:PATTERNS.auto = '\%('
                  \ .        '\%(' . s:PATTERNS.full . '\)'
                  \ . '\|' . '\%(' . s:PATTERNS.date . '\)'
                  \ . '\|' . '\%(' . s:PATTERNS.time . '\)'
                  \ . '\|' . '\%(' . s:PATTERNS.tz . '\)'
                  \ . '\)'








" Etc  "{{{1

let g:loaded_todatetime = 1

" __END__
" vim: foldmethod=marker
