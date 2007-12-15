" narrow - Emulate Emacs' narrowing feature
" Version: 0.0
" Copyright (C) 2007 kana <http://nicht.s8.xrea.com/>
" License: MIT license (see <http://www.opensource.org/licenses/mit-license>)
" $Id$
" Interfaces  "{{{1
" MEMO: narrow-to-motion: v{motion}:Narrow<Return>

function! narrow#Narrow(line1, line2)
  " Note that if you want to modify more options, don't forget to update
  " s:save_the_state_of_buffer() and s:load_the_state_of_buffer().
  if exists('b:narrow_original_state')
    echo 'The buffer is already narrowed.'
    return 0
  endif

  let b:narrow_original_state = s:save_the_state_of_buffer()
  setlocal foldmethod=manual
  setlocal foldtext=''
  call s:adjust_cursor_if_invoked_via_visual_mode(a:line1, a:line2)
  let pos = getpos('.')
    call s:clear_all_folds()
    call s:fold_before(a:line1)
    call s:fold_after(a:line2)
  call setpos('.', pos)
  echo mode()
  return 1
endfunction




function! narrow#Widen()
  if !exists('b:narrow_original_state')
    echo 'The buffer is not narrowed.'
    return 0
  endif

  call s:clear_all_folds()
  call s:load_the_state_of_buffer(b:narrow_original_state)
  unlet b:narrow_original_state
  return 1
endfunction








" Misc.  "{{{1
function! s:adjust_cursor_if_invoked_via_visual_mode(line1, line2)  "{{{2
  " Without this adjustment, the cursor is always positioned at '<.
  " BUGS: this discriminant isn't perfect but sufficient.
  if ((line('.') == a:line1 || line('.') == a:line2)
   \  && (line("'<") == a:line1)
   \  && (line("'>") == a:line2))
    execute 'normal!' "gv\<Esc>"
  endif
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




" view options  "{{{2
function! s:set_view_options()
  let s:original_viewdir = &viewdir
  let &viewdir = s:original_viewdir . '/narrow'
  let s:original_viewoptions = &viewoptions
  let &viewoptions = 'folds'
endfunction

function! s:restore_view_options()
  let &viewdir = s:original_viewdir
  let &viewoptions = s:original_viewoptions
endfunction




function! s:save_the_state_of_buffer()  "{{{2
  call s:set_view_options()
    " BUGS: :mkview doesn't create intermediate directories.
    if !isdirectory(&viewdir)
      call mkdir(&viewdir, 'p', 0700)
    endif
    " BUGS: :mkview doesn't save folds info when &l:buftype isn't ''.
    let original_buftype = &l:buftype
    let &l:buftype = ''
      mkview
    let &l:buftype = original_buftype
  call s:restore_view_options()

  let original_state = {}
  let original_state.foldmethod = &l:foldmethod
  let original_state.foldtext = &l:foldtext
  return original_state
endfunction




function! s:load_the_state_of_buffer(original_state)  "{{{2
  call s:set_view_options()
  loadview
  call s:restore_view_options()

  let &l:foldmethod = a:original_state.foldmethod
  let &l:foldtext = a:original_state.foldtext
endfunction








" __END__  "{{{1
" vim: foldmethod=marker
