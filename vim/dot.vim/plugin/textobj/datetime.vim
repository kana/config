" textobj-datetime - Text objects for date and time.
" Version: 0.2
" Copyright (C) 2007-2008 kana <http://nicht.s8.xrea.com/>
" License: MIT license (see <http://www.opensource.org/licenses/mit-license>)
" $Id$  "{{{1

if exists('g:loaded_textobj_datetime')
  finish
endif








" Interface  "{{{1

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




command! -bang -bar -nargs=0 TextobjDatetimeDefaultKeyMappings
      \ call s:default_key_mappings('<bang>' == '!')

function! s:default_key_mappings(bangedp)
  let forcedp = (a:bangedp ? '' : '<unique>')

  function! s:Map(forcedp, lhs, rhs)
    execute 'vmap' (a:forcedp ? '' : '<unique>') a:lhs a:rhs
    execute 'omap' (a:forcedp ? '' : '<unique>') a:lhs a:rhs
  endfunction

  call s:Map(forcedp, 'ada', '<Plug>textobj#datetime#auto')
  call s:Map(forcedp, 'adf', '<Plug>textobj#datetime#full')
  call s:Map(forcedp, 'add', '<Plug>textobj#datetime#date')
  call s:Map(forcedp, 'adt', '<Plug>textobj#datetime#time')
  call s:Map(forcedp, 'adz', '<Plug>textobj#datetime#tz')

  call s:Map(forcedp, 'ida', '<Plug>textobj#datetime#auto')
  call s:Map(forcedp, 'idf', '<Plug>textobj#datetime#full')
  call s:Map(forcedp, 'idd', '<Plug>textobj#datetime#date')
  call s:Map(forcedp, 'idt', '<Plug>textobj#datetime#time')
  call s:Map(forcedp, 'idz', '<Plug>textobj#datetime#tz')
  return
endfunction

if !exists('g:textobj_datetime_no_default_key_mappings')
  TextobjDatetimeDefaultKeyMappings
endif








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








" Fin.  "{{{1

let g:loaded_textobj_datetime = 1








" __END__
" vim: foldmethod=marker
