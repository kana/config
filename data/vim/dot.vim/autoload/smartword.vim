" smartword - Smart motions on words
" Version: 0.0.2
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
" Interface  "{{{1
function! smartword#move(motion_command, mode)  "{{{2
  let exclusive_adjustment_p = 0
  if a:mode ==# 'o' && (a:motion_command ==# 'e' || a:motion_command ==# 'ge')
    if exists('v:motion_force')  " if it's possible to check o_v and others:
      if v:motion_force == ''
        " inclusive
        normal! v
      elseif v:motion_force ==# 'v'
        " User-defined motion is always exclusive and o_v forces it inclusve.
        " So here use Visual mode to behave this motion as an exclusive one.
        normal! v
        let exclusive_adjustment_p = !0
      else  " v:motion_force ==# 'V' || v:motion_force ==# "\<C-v>"
        " linewise or blockwise
        " -- do nothing because o_V or o_CTRL-V will override the motion type.
      endif
    else  " if it's not possible:
      " inclusive -- the same as the default style of "e" and "ge".
      " BUGS: o_v and others are ignored.
      normal! v
    endif
  endif
  if a:mode == 'v'
    normal! gv
  endif

  call s:move(a:motion_command, v:count1)

  if exclusive_adjustment_p
    execute "normal! \<Esc>"
    if getpos("'<") == getpos("'>")  " no movement - select empty area.
      " FIXME: But how to select nothing?  Because o_v was given, so at least
      " 1 character will be the target of the pending operator.
    else
      let original_whichwrap = &whichwrap
        set whichwrap=h
        normal! `>
        normal! h
        if col('.') == col('$')  " FIXME: 'virtualedit' with onemore
          normal! h
        endif
        if a:motion_command ==# 'ge'
          " 'ge' is backward motion,
          " so that it's necessary to specify the target text in this way.
          normal! v`<
        endif
      let &whichwrap = original_whichwrap
    endif
  endif
endfunction








" Misc.  "{{{1
function! s:current_char(pos)  "{{{2
  return getline(a:pos[1])[a:pos[2] - 1]
endfunction




function! s:move(motion_command, times)  "{{{2
  for i in range(v:count1)
    let curpos = []  " dummy
    let newpos = []  " dummy
    while !0
      let curpos = newpos
      execute 'normal!' a:motion_command
      let newpos = getpos('.')

      if s:current_char(newpos) =~# '\k'
        break
      endif
      if curpos == newpos  " No more word - stop.
        return
      endif
    endwhile
  endfor
  return
endfunction








" __END__  "{{{1
" vim: foldmethod=marker
