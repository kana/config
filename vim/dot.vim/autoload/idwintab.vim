" idwintab - Give unique ID for each window and tab page
" Version: 0.0.1
" Copyright: Copyright (C) 2008 kana <http://whileimautomaton.net/>
" License: MIT license (see <http://www.opensource.org/licenses/mit-license>)

function! idwintab#load()
  " This is just a dummy function to force sourcing this file.
endfunction

let s:next_id_for_window = 0
let s:next_id_for_tabpage = 0

augroup plugin-idwintab
  autocmd!
  autocmd WinEnter *  call s:on_WinEnter()
  autocmd TabEnter *  call s:on_TabEnter()
augroup END




" FIXME: the cases of ID overflow

function! s:on_WinEnter()
  if exists('w:id')
    return
  endif
  let w:id = s:next_id_for_window
  let s:next_id_for_window += 1
  if !(w:id < s:next_id_for_window)
    throw 'idwintab: Window ID overflow'
  endif
endfunction

function! s:on_TabEnter()
  if exists('t:id')
    return
  endif
  let t:id = s:next_id_for_tabpage
  let s:next_id_for_tabpage += 1
  if !(t:id < s:next_id_for_tabpage)
    throw 'idwintab: Tab page ID overflow'
  endif
endfunction




" Ensure that all windows and all tab pages have their own ID.
"
" FIXME: restore the original states on the current windows for each tab page
" and the current tab page.
"
" Note that :tabdo never publish TabEnter event if there is only one tab page,
" so we have to manually publish the event.  :windo and WinEnter have similar
" problem.
tabdo doautocmd plugin-idwintab TabEnter
tabdo windo doautocmd plugin-idwintab WinEnter

" __END__
" vim: foldmethod=marker
