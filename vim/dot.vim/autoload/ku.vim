" ku - Interface for everything
" Version: 0.3.0
" Copyright (C) 2008-2009 kana <http://whileimautomaton.net/>
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
" Constants  "{{{1

let s:FALSE = 0
let s:TRUE = !s:FALSE


if has('win16') || has('win32') || has('win64')  " on Microsoft Windows
  let s:KU_BUFFER_NAME = '[ku]'
else
  let s:KU_BUFFER_NAME = '*ku*'
endif


let s:NULL_SOURCE = {}


let s:PROMPT = '>'








" Variables  "{{{1

let s:available_sources = {}  " source-name => source-definition








" Interface  "{{{1
function! ku#define_source(definition)  "{{{2
  let new_source = extend(copy(s:NULL_SOURCE), a:definition, 'keep')
  let _ = s:TRUE

  let _ = _ && s:valid_key_p(new_source, 'gather-items', 'function')
  let _ = _ && s:valid_key_p(new_source, 'name', 'string')
  if !_
    return s:FALSE
  endif

  let s:available_sources[new_source['name']] = new_source

  return s:TRUE
endfunction




function! ku#start(...)  "{{{2
  let source_names = 1<=a:0 && a:1 isnot 0 ? a:1 : ku#available_source_names()
  let initial_pattern = 2 <= a:0 ? a:2 : ''

  for source_name in source_names
    if !ku#available_source_name_p(source_name)
      echoerr 'Invalid source name:' string(a:source_name)
      return s:FALSE
    endif
  endfor

  if s:ku_active_p()
    echoerr 'Already active'
    return s:FALSE
  endif

  " Initialze session.
  let s:session = {}
  let s:session.id = localtime()
  let s:session.original_completeopt = &completeopt
  let s:session.original_curwinnr = winnr()
  let s:session.original_winrestcmd = winrestcmd()
  let s:session.sources = map(source_names, 's:source_from_source_name(v:val)')

  " Open or create the ku buffer.
  let v:errmsg = ''
  topleft split
  if v:errmsg != ''
    return s:FALSE
  endif
  if bufexists(s:bufnr)
    silent execute s:bufnr 'buffer'
  else
    enew
    let s:bufnr = bufnr('')
    call s:initialize_ku_buffer()
  endif
  2 wincmd _

  " Set some options.
  set completeopt=menu,menuone

  " Reset the content of the ku buffer.
  " BUGS: To avoid unexpected behavior caused by automatic completion of the
  "       prompt, append the prompt and {initial-pattern} at this timing.
  "       Automatic completion is implemented by feedkeys() and starting
  "       Insert mode is also implemented by feedkeys().  These feedings must
  "       be done carefully.
  silent % delete _
  call append(1, s:PROMPT . initial_pattern)
  normal! 2G

  " Start Insert mode.
  " BUGS: :startinsert! may not work with append()/setline()/:put.
  "       If the typeahead buffer is empty, ther is no problem.
  "       Otherwise, :startinsert! behaves as '$i', not 'A',
  "       so it is inconvenient.
  let typeahead_buffer = getchar(1) ? s:get_key() : ''
  call feedkeys('A' . typeahead_buffer, 'n')

  return s:TRUE
endfunction








" Misc.  "{{{1
" For tests  "{{{2
function! ku#_local_variables()
  return s:
endfunction


function! ku#_sid_prefix()
  return maparg('<SID>', 'n')
endfunction

nnoremap <SID>  <SID>




function! ku#available_source_name_p()  "{{{2
  " FIXME: NIY
endfunction




function! ku#available_source_names()  "{{{2
  " FIXME: NIY
endfunction




function! ku#available_sources()  "{{{2
  " FIXME: NIY
endfunction




function! s:ku_active_p()  "{{{2
  " FIXME: NIY
endfunction




function! s:get_key()  "{{{2
  " Alternative getchar() to get a logical key such as <F1> and <M-{x}>.
  let k = ''

  let c = getchar()
  while s:TRUE
    let k .= type(c) == type(0) ? nr2char(c) : c
    let c = getchar(0)
    if c is 0
      break
    endif
  endwhile

  return k
endfunction




function! s:initialize_ku_buffer()  "{{{2
  " FIXME: NIY
endfunction




function! s:valid_key_p(source, key, type)  "{{{2
  if !has_key(a:source, a:key)
    echoerr 'Invalild source: Without key' string(a:key)
    return s:FALSE
  endif

  let TYPES = {
  \     'dictionary': type({}),
  \     'function': type(function('function')),
  \     'string': type(''),
  \   }
  if type(a:source[a:key]) != get(TYPES, a:type, -2009)
    echoerr 'Invalild source: Key' string(a:key) 'must be' a:type
    \       'but given value is' type(a:source[a:key])
    return s:FALSE
  endif

  return s:TRUE
endfunction








" __END__  "{{{1
" vim: foldmethod=marker
