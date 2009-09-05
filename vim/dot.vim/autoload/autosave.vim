" autosave - You still save buffers manually each time?
" Version: 0.0.0
" Copyright (C) 2009 kana <http://whileimautomaton.net/>
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
" Interface  "{{{1
function! autosave#disable()  "{{{2
  if !s:autosave_enabled_p
    echo 'You are already despaired.'
    return
  endif

  let &g:autowrite = s:original_autowrite
  let &g:autowriteall = s:original_autowriteall

  augroup plugin-autosave
    autocmd!
  augroup END

  let s:autosave_enabled_p = 0
endfunction




function! autosave#enable()  "{{{2
  if s:autosave_enabled_p
    echo 'You are already saved.'
    return
  endif

  let s:original_autowrite = &g:autowrite
  let s:original_autowriteall = &g:autowriteall

  setglobal autowrite
  setglobal autowriteall

  augroup plugin-autosave
    autocmd!
    autocmd CursorHold *  call autosave#save_the_world()
    autocmd CursorHoldI *  call autosave#save_the_world()
  augroup END

  let s:autosave_enabled_p = !0
endfunction




function! autosave#save_the_world()  "{{{2
  " FIXME: NIY
  " save state
  " for b in not saved and not disabled and not dangerous buffers
  "   open buffer
  "   silent write
  " endfor
  " restore state
  wall
endfunction








" Misc.  "{{{1
" Variables  "{{{2

let s:autosave_enabled_p = 0
" let s:original_autowrite = &g:autowrite
" let s:original_autowriteall = &g:autowriteall








" __END__  "{{{1
" vim: foldmethod=marker
