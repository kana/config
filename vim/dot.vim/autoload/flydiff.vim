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

let s:TYPE_DIFF_BUFFER = [168]
let s:TYPE_NORMAL_BUFFER = [48]




function! flydiff#toggle(bufnr, state)  "{{{2
  if !bufexists(a:bufnr)
    echoerr 'No such buffer:' a:bufnr
    return 0
  endif

  let b_flydiff_info = s:flydiff_info(a:bufnr, s:TYPE_NORMAL_BUFFER)
  if b_flydiff_info.type isnot s:TYPE_NORMAL_BUFFER
    echo 'Buffer is not a normal one:' a:bufnr string(b_flydiff_info.type)
    return 1
  endif
  let state = a:state ==? 'on' ? s:ON : (a:state ==? 'off' ? s:OFF : s:TOGGLE)
  if state == s:TOGGLE
    let state = b_flydiff_info.state == s:OFF ? s:ON : s:OFF
  endif

  if b_flydiff_info.state == state
    return 1  " nothing to do -- on-the-fly diff is already on or off.
  endif
  if state == s:ON
    if b_flydiff_info.diff_bufnr == s:INVALID_BUFNR
      let b_flydiff_info.diff_bufnr = s:create_diff_buffer_for(a:bufnr)
    endif
    call s:set_flydiff_handlers()
  else  " state == s:OFF
    call s:remove_flydiff_handlers()
  endif

  return 1
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




function! s:flydiff_info(bufnr, type)  "{{{2
  let bufvars = getbufvar(a:bufnr, '')
  if !has_key(bufvars, 'flydiff_info')
    let bufvars.flydiff_info = {
    \     'type': a:type,
    \     'state': s:OFF,
    \     'diff_bufnr': s:INVALID_BUFNR,
    \     'base_bufnr': s:INVALID_BUFNR,
    \   }
  endif
  return bufvars.flydiff_info
endfunction




function! s:flydiff_mode()  "{{{2
  " MEMO: to customize flydiff_mode for each buffer:
  "   return exists('b:flydiff_mode') ? b:flydiff_mode : g:flydiff_mode
  return g:flydiff_mode
endfunction




function! s:perform_flydiff(bufnr)  "{{{2
  let b_flydiff_info = s:flydiff_info(a:bufnr, s:TYPE_NORMAL_BUFFER)

  " CONT: NIY
  echo 'a:bufnr' a:bufnr
  echo 'bufnr()' bufnr('')
  echo 'flydiff_info' string(b_flydiff_info)

  return
endfunction




function! s:remove_flydiff_handlers()  "{{{2
  augroup plugin-flydiff
    autocmd! * <buffer>
  augroup END
  return
endfunction




function! s:set_flydiff_handlers()  "{{{2
  augroup plugin-flydiff
    autocmd BufWritePost <buffer>  call s:perform_flydiff(expand('<abuf>'))
    autocmd CursorHold <buffer>  call s:perform_flydiff(expand('<abuf>'))
    autocmd CursorHoldI <buffer>  call s:perform_flydiff(expand('<abuf>'))
  augroup END
  return
endfunction




"{{{2








" __END__  "{{{1
" vim: foldmethod=marker
