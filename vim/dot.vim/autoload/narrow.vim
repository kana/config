" narrow - Emulate Emacs' narrowing feature
" Version: 0.2.1
" Copyright (C) 2007 kana <http://whileimautomaton.net/>
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
" Interfaces  "{{{1
" MEMO: narrow-to-motion: v{motion}:Narrow<Return>

function! narrow#Narrow(line1, line2)
  " Note that if you want to modify more options, don't forget to update
  " s:save_the_state_of_buffer() and s:load_the_state_of_buffer().
  if exists('b:narrow_original_state')
    if !s:allow_overridingp()
      echo 'The buffer is already narrowed.'
      return 0
    endif
  else
    let b:narrow_original_state = s:save_the_state_of_buffer()
  endif

  let line1 = s:normalize_line(a:line1, 'head')
  let line2 = s:normalize_line(a:line2, 'tail')

  setlocal foldenable
  setlocal foldmethod=manual
  setlocal foldminlines=0  " to completely hide non-narrowed lines
  setlocal foldtext=''
  call s:adjust_cursor_if_invoked_via_visual_mode(line1, line2)
  let pos = getpos('.')
    call s:clear_all_folds()
    call s:fold_before(line1)
    call s:fold_after(line2)
  call setpos('.', pos)
  normal! zz
  return 1
endfunction




function! narrow#Widen()
  if !exists('b:narrow_original_state')
    echo 'The buffer is not narrowed.'
    return 0
  endif

  let pos = getpos('.')
    call s:clear_all_folds()
    call s:load_the_state_of_buffer(b:narrow_original_state)
    unlet b:narrow_original_state
  call setpos('.', pos)
  normal! zz
  return 1
endfunction








" Misc.  "{{{1
function! s:allow_overridingp()  "{{{2
  return exists('g:narrow_allow_overridingp') && g:narrow_allow_overridingp
endfunction




function! s:adjust_cursor_if_invoked_via_visual_mode(line1, line2)  "{{{2
  " Without this adjustment, the cursor is always positioned at '<.
  " BUGS: this discriminant isn't perfect but sufficient.
  if ((line('.') == a:line1 || line('.') == a:line2)
   \  && (line("'<") == a:line1)
   \  && (line("'>") == a:line2))
    execute 'normal!' "gv\<Esc>"
  endif
endfunction




function! s:normalize_line(line, mode)  "{{{2
  " Return the first/last line number of a closed fold if a:line is contained
  " the fold, otherwise return a:line as is.
  let pline = (a:mode ==# 'head' ? foldclosed(a:line) : foldclosedend(a:line))
  return 0 < pline ? pline : a:line
endfunction




function! s:fold_before(line)  "{{{2
  if 1 < a:line
    execute '1,' (a:line - 1) 'fold'
  endif
endfunction




function! s:fold_after(line)  "{{{2
  if a:line < line('$')
    execute (a:line + 1) ',$' 'fold'
  endif
endfunction




function! s:clear_all_folds()  "{{{2
  if &l:foldmethod != 'manual'
    throw '&l:foldmethod must be "manual", but ' . string(&l:foldmethod)
  endif

  normal! zE
endfunction




function! s:save_the_state_of_buffer()  "{{{2
  let original_state = {}
  let original_state.foldenable = &l:foldenable
  let original_state.foldmethod = &l:foldmethod
  let original_state.foldminlines = &l:foldminlines
  let original_state.foldtext = &l:foldtext

  " save folds
  let original_state.foldstate = []
  let original_pos = getpos('.')
  let line = 1
  while line <= line('$')
    if 0 < foldclosed(line)  " is the first line of a fold?
      call add(original_state.foldstate, line)
      let line = foldclosedend(line) + 1
    else
      let previous_line = line
      call cursor(previous_line, 0)
      normal! zj
      let line = line('.')
      if line == previous_line
        break  " no more folds.
      endif
    endif
  endwhile
  call setpos('.', original_pos)

  return original_state
endfunction




function! s:load_the_state_of_buffer(original_state)  "{{{2
  let &l:foldenable = a:original_state.foldenable
  let &l:foldmethod = a:original_state.foldmethod
  let &l:foldminlines = a:original_state.foldminlines
  let &l:foldtext = a:original_state.foldtext

  " restore folds.
  if 0 < len(a:original_state.foldstate)
    %foldopen!  " This raises an error if there is no fold to open.
    for line in a:original_state.foldstate
      call cursor(line, 0)
      foldclose
    endfor
  endif
endfunction








" __END__  "{{{1
" vim: foldmethod=marker
