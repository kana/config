" flydiff - on-the-fly diff
" Version: 0.0
" Copyright (C) 2008 kana <http://whileimautomaton.net/>
" License: MIT license (see <http://www.opensource.org/licenses/mit-license>)
" Interface  "{{{1
" Constants  "{{{2

let s:FALSE = 0
let s:TRUE = !s:FALSE

let s:ON = 1
let s:OFF = 0
let s:TOGGLE = -773

let s:INVALID_BUFNR = -775
let s:INVALID_WINNR = -1

let s:TYPE_DIFF_BUFFER = [168]
let s:TYPE_NORMAL_BUFFER = [48]




function! flydiff#toggle(bufnr, state)  "{{{2
  if !bufexists(a:bufnr)
    echoerr 'No such buffer:' a:bufnr
    return s:FALSE
  endif

  let b_flydiff_info = s:flydiff_info(a:bufnr, s:TYPE_NORMAL_BUFFER)
  if b_flydiff_info.type isnot s:TYPE_NORMAL_BUFFER
    echoerr 'Buffer is not a normal one:' a:bufnr string(b_flydiff_info.type)
    return s:TRUE
  endif
  let state = a:state ==? 'on' ? s:ON : (a:state ==? 'off' ? s:OFF : s:TOGGLE)
  if state == s:TOGGLE
    let state = b_flydiff_info.state == s:OFF ? s:ON : s:OFF
  endif

  if b_flydiff_info.state == state
    return s:TRUE  " nothing to do -- on-the-fly diff is already on or off.
  endif
  if state == s:ON
    if b_flydiff_info.diff_bufnr == s:INVALID_BUFNR
      let b_flydiff_info.diff_bufnr = s:create_diff_buffer_for(a:bufnr)
    endif
    call s:set_flydiff_handlers()
  else  " state == s:OFF
    call s:remove_flydiff_handlers()
  endif

  return s:TRUE
endfunction




"{{{2








" Misc.  "{{{1
function! s:create_diff_buffer_for(bufnr)  "{{{2
  let original_bufnr = bufnr('')
  " CONT: create diff buffer for a:bufnr

  let diff_bufnr = bufnr('')
  let b_flydiff_info = s:flydiff_info(diff_bufnr, s:TYPE_DIFF_BUFFER)
  let b_flydiff_info.base_bufnr = a:bufnr

  " CONT: restore to the original buffer original_bufnr
  return diff_bufnr
endfunction




function! s:flydiff_info(bufnr, ...)  "{{{2
  let bufvars = getbufvar(a:bufnr, '')
  if !has_key(bufvars, 'flydiff_info')
    if a:0 == 0
      throw 'Internal error: buffer ' . a:bufnr . ' is not related to flydiff'
    endif
    let bufvars.flydiff_info = {
    \     'type': a:1,
    \     'state': s:OFF,
    \     'diff_bufnr': s:INVALID_BUFNR,
    \     'base_bufnr': s:INVALID_BUFNR,
    \   }
  endif
  return bufvars.flydiff_info
endfunction




function! s:flydiff_timing()  "{{{2
  " MEMO: to customize flydiff_timing for each buffer:
  "   return exists('b:flydiff_timing') ? b:flydiff_timing : g:flydiff_timing
  return g:flydiff_timing
endfunction




function! s:open_diff_buffer(flydiff_info)  "{{{2
  " CONT: NIY
  return diff_winnr
endfunction




function! s:perform_flydiff()  "{{{2
  let bufnr = str2nr(expand('<abuf>'))  " because expand() returns a string
  let b_flydiff_info = s:flydiff_info(bufnr)
  if b_flydiff_info.base_bufnr != bufnr
    throw printf('Internal error: <abuf> is %d, but base_bufnr is %d',
    \            bufnr, b_flydiff_info.base_bufnr)
  endif

  let diff_winnr = s:open_diff_buffer(b_flydiff_info)
  if diff_winnr == s:INVALID_WINNR
    echoerr 'Unable to open a window for diff buffer'
    return s:FALSE
  endif

  update
  execute diff_winnr 'wincmd w'
    % delete _
    execute 'read !' s:vcs_diff_script(b_flydiff_info.base_bufnr)
    1 delete _
  wincmd p

  return s:TRUE
endfunction




function! s:remove_flydiff_handlers()  "{{{2
  augroup plugin-flydiff
    autocmd! * <buffer>
  augroup END
  return
endfunction




function! s:set_flydiff_handlers()  "{{{2
  augroup plugin-flydiff
    autocmd BufWritePost <buffer>
    \   if s:flydiff_timing() =~# '\<written\>'
    \ |   call s:perform_flydiff()
    \ | endif
    autocmd CursorHold <buffer>
    \   if s:flydiff_timing() =~# '\<realtime\>'
    \ |   call s:perform_flydiff()
    \ | endif
    autocmd CursorHoldI <buffer>
    \   if s:flydiff_timing() =~# '\<realtime\>'
    \ |   call s:perform_flydiff()
    \ | endif
  augroup END
  return
endfunction




function! s:vcs_diff_script(bufnr)  "{{{2
  " Return a string of the shell script to get difference between the
  " currently edited a:bufnr and the latest version of a:bufnr with
  " appropriate version control system.

  " CONT: NIY
  return shell_script
endfunction




"{{{2








" __END__  "{{{1
" vim: foldmethod=marker
