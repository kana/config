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
" Variables  "{{{1

let s:FALSE = 0
let s:TRUE = !s:FALSE


let s:NULL_SOURCE = {}


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




" Misc.  "{{{1
" For tests  "{{{2
function! ku#_local_variables()
  return s:
endfunction


function! ku#_sid_prefix()
  return maparg('<SID>', 'n')
endfunction

nnoremap <SID>  <SID>




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
