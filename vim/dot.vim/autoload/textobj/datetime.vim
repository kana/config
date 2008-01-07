" textobj-datetime - Text objects for date and time.
" Version: 0.1
" Copyright (C) 2007 kana <http://nicht.s8.xrea.com/>
" License: MIT license (see <http://www.opensource.org/licenses/mit-license>)
" $Id$
" Interfaces  "{{{1

vnoremap <silent> <Plug>textobj#datetime#auto
       \          :<C-u>call <SID>select('auto', 'v')<Return>
vnoremap <silent> <Plug>textobj#datetime#full
       \          :<C-u>call <SID>select('full', 'v')<Return>
vnoremap <silent> <Plug>textobj#datetime#date
       \          :<C-u>call <SID>select('date', 'v')<Return>
vnoremap <silent> <Plug>textobj#datetime#time
       \          :<C-u>call <SID>select('time', 'v')<Return>
vnoremap <silent> <Plug>textobj#datetime#tz
       \          :<C-u>call <SID>select('tz', 'v')<Return>

onoremap <silent> <Plug>textobj#datetime#auto
       \          :<C-u>call <SID>select('auto', 'o')<Return>
onoremap <silent> <Plug>textobj#datetime#full
       \          :<C-u>call <SID>select('full', 'o')<Return>
onoremap <silent> <Plug>textobj#datetime#date
       \          :<C-u>call <SID>select('date', 'o')<Return>
onoremap <silent> <Plug>textobj#datetime#time
       \          :<C-u>call <SID>select('time', 'o')<Return>
onoremap <silent> <Plug>textobj#datetime#tz
       \          :<C-u>call <SID>select('tz', 'o')<Return>




function! textobj#datetime#default_mappings(...)
  let forcep = (a:0 ? a:1 : 0)

  function! s:Map(forcep, lhs, rhs)
    execute 'vmap' (a:forcep ? '' : '<unique>') a:lhs a:rhs
    execute 'omap' (a:forcep ? '' : '<unique>') a:lhs a:rhs
  endfunction

  call s:Map(forcep, 'ada', '<Plug>textobj#datetime#auto')
  call s:Map(forcep, 'adf', '<Plug>textobj#datetime#full')
  call s:Map(forcep, 'add', '<Plug>textobj#datetime#date')
  call s:Map(forcep, 'adt', '<Plug>textobj#datetime#time')
  call s:Map(forcep, 'adz', '<Plug>textobj#datetime#tz')

  call s:Map(forcep, 'ida', '<Plug>textobj#datetime#auto')
  call s:Map(forcep, 'idf', '<Plug>textobj#datetime#full')
  call s:Map(forcep, 'idd', '<Plug>textobj#datetime#date')
  call s:Map(forcep, 'idt', '<Plug>textobj#datetime#time')
  call s:Map(forcep, 'idz', '<Plug>textobj#datetime#tz')
endfunction








" Misc.  "{{{1

function! s:select(type, previous_mode)
  return textobj#user#select(s:PATTERNS[a:type], '', a:previous_mode)
endfunction




let s:PATTERNS = {}

let s:PATTERNS._tz = '\%(Z\|[+-]\d\d:\d\d\)'
let s:PATTERNS.tz = '\%(:\d\d\%(\.\d\+\)\?\)\zs' . s:PATTERNS._tz

let s:PATTERNS.time = '\d\d:\d\d\%(:\d\d\%(\.\d\+\)\?\)\?'

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








" __END__  "{{{1
" vim: foldmethod=marker
