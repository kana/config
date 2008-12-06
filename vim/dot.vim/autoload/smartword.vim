" smartword - Smart motions on words
" Version: 0.0.1
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
    execute "normal! \<Esc>'>"
    if getpos("'<") == getpos("'>")  " no movement - select empty area.
      " FIXME: But how to select nothing?  Because o_v was given, so at least
      " 1 character will be the target of the pending operator.
    else
      let original_whichwrap = &whichwrap
        set whichwrap=h
        normal! h
        if col('.') == col('$')  " FIXME: 'virtualedit' with onemore
          normal! h
        endif
      let &whichwrap = original_whichwrap
    endif
  endif
endfunction








" Misc.  "{{{1
function! s:current_char(pos)  "{{{2
  return getline(a:pos[1])[a:pos[2] - 1]
endfunction




function! s:parse_iskeyword(iskeyword)  "{{{2
  let chars = repeat([0], 256)

  let parts = split(a:iskeyword, ',', !0)
  let i = 0
  while i < len(parts)
    let part = parts[i]

    if part =~ '^\^[^\^].*'
      let part = part[1:]
      let v = !!0
    else
      let v = !0
    endif

    let _ = split(part, '-')
    if len(_) == 2
      for j in range(s:part2nr(_[0]), s:part2nr(_[1]))
        let chars[j] = v
      endfor
    elseif part == ''
      if i + 1 < len(parts)
        if parts[i+1] == ''  " '...,,,...'
          let chars[char2nr(',')] = !0
          let i += 1
        else  " '...,,X,...' (undefined case)
          " ignore.
        endif
      else  " '...,' (undefined case)
        " ignore.
      endif
    elseif part == '^'
      if i + 1 < len(parts)
        if parts[i+1] == ''  " '...,^,,...'
          let chars[char2nr(',')] = !!0
          let i += 1
        else " '...,^,X,...'
          let chars[char2nr('^')] = !0
        endif
      else  " '...,^'
        let chars[char2nr('^')] = !0
      endif
    elseif part == '@'
      " FIXME: '@' means all characters where isalpha() returns TRUE.
      for j in range(char2nr('A'), char2nr('Z'))
        let chars[j] = v
      endfor
      for j in range(char2nr('a'), char2nr('z'))
        let chars[j] = v
      endfor
    else
      let chars[s:part2nr(part)] = v
    endif

    let i += 1
  endwhile

  return filter(map(range(len(chars)), 'chars[v:val] ? nr2char(v:val) : 0'),
  \             'v:val isnot 0')
endfunction




function! s:letter_p(char)  "{{{2
  if !(exists('b:smartword_iskeyword') && b:smartword_iskeyword==#&l:iskeyword)
    let b:smartword_iskeyword = &l:iskeyword
    let b:smartword_parsed_iskeyword = s:parse_iskeyword(&l:iskeyword)
  endif
  let chars = b:smartword_parsed_iskeyword

  let pattern = '[' . escape(join(chars, ''), '\[]-^:') . ']'
  return a:char =~# pattern
endfunction




function! s:move(motion_command, times)  "{{{2
  for i in range(v:count1)
    let curpos = []  " dummy
    let newpos = []  " dummy
    while !0
      let curpos = newpos
      execute 'normal!' a:motion_command
      let newpos = getpos('.')

      if s:letter_p(s:current_char(newpos))
        break
      endif
      if curpos == newpos  " No more word - stop.
        return
      endif
    endwhile
  endfor
  return
endfunction




function! s:part2nr(s)  "{{{2
  if a:s =~ '^\d\+$'
    return str2nr(a:s)
  else
    return char2nr(a:s)
  endif
endfunction








" __END__  "{{{1
" vim: foldmethod=marker
