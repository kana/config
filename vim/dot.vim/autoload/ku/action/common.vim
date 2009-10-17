" ku-action-common - Common actions for all sources
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
function! ku#action#common#Bottom(candidate)  "{{{2
  return s:open_with_split('botright', a:candidate)
endfunction




function! ku#action#common#Left(candidate)  "{{{2
  return s:open_with_split('topleft vertical', a:candidate)
endfunction




function! ku#action#common#Right(candidate)  "{{{2
  return s:open_with_split('botright vertical', a:candidate)
endfunction




function! ku#action#common#Top(candidate)  "{{{2
  return s:open_with_split('topleft', a:candidate)
endfunction




function! ku#action#common#above(candidate)  "{{{2
  return s:open_with_split('leftabove', a:candidate)
endfunction




function! ku#action#common#below(candidate)  "{{{2
  return s:open_with_split('belowright', a:candidate)
endfunction




function! ku#action#common#cancel(candidate)  "{{{2
  " Cancel to take actioin - nothing to do.
  return 0
endfunction




function! ku#action#common#cd(candidate)  "{{{2
  let v:errmsg = ''
  silent! cd `=fnamemodify(a:candidate.word, ':p:h')`
  return v:errmsg == '' ? 0 : v:errmsg
endfunction




function! ku#action#common#default(candidate)  "{{{2
  return ku#action#common#open(a:candidate)
endfunction




function! ku#action#common#ex(candidate)  "{{{2
  " Resultl is ':| {candidate}', here '|' means the cursor position.
  call feedkeys(printf(": %s\<C-b>", fnameescape(a:candidate.word)), 'n')
  return 0
endfunction




function! ku#action#common#lcd(candidate)  "{{{2
  let v:errmsg = ''
  silent! lcd `=fnamemodify(a:candidate.word, ':p:h')`
  return v:errmsg == '' ? 0 : v:errmsg
endfunction




function! ku#action#common#left(candidate)  "{{{2
  return s:open_with_split('leftabove vertical', a:candidate)
endfunction




function! ku#action#common#open(candidate)  "{{{2
  return ('Action "open" is not defined for this candidate: '
  \       . string(a:candidate))
endfunction




function! ku#action#common#right(candidate)  "{{{2
  return s:open_with_split('belowright vertical', a:candidate)
endfunction




function! ku#action#common#select(candidate)  "{{{2
  call ku#restart()
  return 0
endfunction




function! ku#action#common#tab_Left(candidate)  "{{{2
  return s:open_with_split('0 tab', a:candidate)
endfunction




function! ku#action#common#tab_Right(candidate)  "{{{2
  return s:open_with_split(tabpagenr('$') . ' tab', a:candidate)
endfunction




function! ku#action#common#tab_left(candidate)  "{{{2
  return s:open_with_split((tabpagenr() - 1) . ' tab', a:candidate)
endfunction




function! ku#action#common#tab_right(candidate)  "{{{2
  return s:open_with_split('tab', a:candidate)
endfunction








" Misc.  "{{{1
function! s:open_with_split(direction, candidate)  "{{{2
  let original_tabpagenr = tabpagenr()
  let original_curwinnr = winnr()
  let original_winrestcmd = winrestcmd()

  let v:errmsg = ''
  silent! execute a:direction 'split'
  if v:errmsg != ''
    return v:errmsg
  endif

  let _ = ku#_take_action('open', a:candidate)

  if _ is 0
    return 0
  else
    " Undo the last :split.
    close
    execute 'tabnext' original_tabpagenr
    execute original_curwinnr 'wincmd w'
    execute original_winrestcmd
    return _
  endif
endfunction








" __END__  "{{{1
" vim: foldmethod=marker
