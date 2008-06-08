" textobj-datetime - Text objects for date and time.
" Version: 0.3
" Copyright (C) 2007-2008 kana <http://whileimautomaton.net/>
" License: MIT license (see <http://www.opensource.org/licenses/mit-license>)

if exists('g:loaded_textobj_datetime')
  finish
endif




let s:REGEXP__TZ = '\%(Z\|[+-]\d\d:\d\d\)'
let s:REGEXP_TZ = '\%(:\d\d\%(\.\d\+\)\?\)\zs' . s:REGEXP__TZ

let s:REGEXP_TIME = '\d\d:\d\d\%(:\d\d\%(\.\d\+\)\?\)\?'

let s:REGEXP__DATE = '\d\d\d\d-\d\d-\d\d'
let s:REGEXP_DATE = '\d\d\d\d\%(-\d\d\%(-\d\d\)\?\)\?'

let s:REGEXP_FULL = s:REGEXP__DATE . 'T' . s:REGEXP_TIME
\                   . '\%(' . s:REGEXP__TZ . '\)\?'

let s:REGEXP_AUTO = '\%('
\                   .        '\%(' . s:REGEXP_FULL . '\)'
\                   . '\|' . '\%(' . s:REGEXP_DATE . '\)'
\                   . '\|' . '\%(' . s:REGEXP_TIME . '\)'
\                   . '\|' . '\%(' . s:REGEXP_TZ . '\)'
\                   . '\)'




call textobj#user#plugin('datetime', {
\      'auto': {'select': ['ada', 'ida'], 'pattern': s:REGEXP_AUTO},
\      'full': {'select': ['adf', 'idf'], 'pattern': s:REGEXP_FULL},
\      'date': {'select': ['add', 'idd'], 'pattern': s:REGEXP_DATE},
\      'time': {'select': ['adt', 'idt'], 'pattern': s:REGEXP_TIME},
\      'tz': {'select': ['adz', 'idz'], 'pattern': s:REGEXP_TZ},
\    })

if !exists('g:textobj_datetime_no_default_key_mappings')
  TextobjDatetimeDefaultKeyMappings
endif




let g:loaded_textobj_datetime = 1

" __END__
