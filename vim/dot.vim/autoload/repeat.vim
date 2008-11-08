" repeat - Enable to repeat last change by non built-in commands
" Version: 0.0.0
" Copyright (C) 2008 kana <http://whileimautomaton.net/>
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

let s:CHANGEDTICK_CUSTOM = -3324
let s:CHANGEDTICK_DEFAULT = -2216
let s:CHANGEDTICK_INVALID = -1108

let s:changedtick = s:CHANGEDTICK_INVALID
" let s:count = 0
" let s:keyseq = '...'








" Interface  "{{{1
function! repeat#set(keyseq, ...)  "{{{2
  execute "normal! \"=''\<Return>p"
  let s:changedtick = b:changedtick
  let s:keyseq = a:keyseq
  let s:count = a:0 ? a:1 : 0
  return
endfunction




function! repeat#_do(keyseq, count)  "{{{2
  let keep_p = s:changedtick == b:changedtick

  execute 'normal!' (a:count ? a:count : '').a:keyseq

  if keep_p
    let s:changedtick = b:changedtick
  endif
  return
endfunction




function! repeat#_repeat(count)  "{{{2
  if s:changedtick == b:changedtick
    let c = s:count == -1 ? '' : (a:count ? a:count : (s:count ? s:count : ''))
      " FIXME: When any of 0-9 key is remapped.
    execute 'normal' c . s:keyseq
  else
    execute 'normal!' (a:count ? a:count : '').'.'
  endif
  return
endfunction








" Autocommands  "{{{1

augroup plugin-repeat
  autocmd!

  autocmd BufEnter,BufReadPre,BufWritePre *
  \       let s:changedtick = (s:changedtick == s:CHANGEDTICK_CUSTOM
  \                            ? b:changedtick
  \                            : s:CHANGEDTICK_INVALID)
  autocmd BufLeave,BufReadPost,BufWritePost *
  \       let s:changedtick = (s:changedtick == b:changedtick
  \                            ? s:CHANGEDTICK_CUSTOM
  \                            : s:CHANGEDTICK_DEFAULT)
augroup END








" __END__  "{{{1
" vim: foldmethod=marker
