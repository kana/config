" flydiff - on-the-fly diff
" Version: 0.0
" Copyright (C) 2008 kana <http://whileimautomaton.net/>
" License: MIT license (see <http://www.opensource.org/licenses/mit-license>)
" Constants  "{{{1

let s:FALSE = 0
let s:TRUE = !s:FALSE

let s:ON = 1
let s:OFF = 0
let s:TOGGLE = -773

let s:INVALID_BUFNR = -775
let s:INVALID_WINNR = -1
let s:INVALID_CHANGEDTICK = -3846

let s:TYPE_DIFF_BUFFER = [168]
let s:TYPE_NORMAL_BUFFER = [48]








" Interface  "{{{1
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
  let b_flydiff_info.state = state

  return s:TRUE
endfunction








" Misc.  "{{{1
function! s:create_diff_buffer_for(bufnr)  "{{{2
  " Create diff buffer for a:bufnr and set up misc. options.
  let original_bufnr = bufnr('')
  let original_bufhidden = &l:bufhidden
  let &l:bufhidden = 'hide'
  hide enew
  setlocal bufhidden=hide buflisted buftype=nofile nomodifiable noswapfile
  execute 'setfiletype' g:flydiff_filetype
  silent file `=printf('[flydiff - (%d) %s]',
  \                    original_bufnr, bufname(original_bufnr))`

  " Set base_bufnr.
  let diff_bufnr = bufnr('')
  let b_flydiff_info = s:flydiff_info(diff_bufnr, s:TYPE_DIFF_BUFFER)
  let b_flydiff_info.base_bufnr = a:bufnr

  " Restore to the original buffer original_bufnr.
  " Note that original_bufnr may not be equal to a:bufnr.
  silent execute original_bufnr 'buffer'
  let &l:bufhidden = original_bufhidden

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




function! s:flydiff_direction()  "{{{2
  return g:flydiff_direction
endfunction




function! s:open_diff_buffer(bufnr)  "{{{2
  let diff_winnr = bufwinnr(a:bufnr)
  if diff_winnr != s:INVALID_WINNR
    return diff_winnr
  endif

  let v:errmsg = ''
  execute s:flydiff_direction() 'new'
  if v:errmsg != ''
    return s:INVALID_WINNR
  endif

  silent execute a:bufnr 'buffer'
  let diff_winnr = winnr()
  wincmd p
  return diff_winnr
endfunction




function! s:perform_flydiff(timing)  "{{{2
  let base_bufnr = str2nr(expand('<abuf>'))  " bufnr must be a number.
  let b_flydiff_info = s:flydiff_info(base_bufnr)

  let diff_winnr = s:open_diff_buffer(b_flydiff_info.diff_bufnr)
  if diff_winnr == s:INVALID_WINNR
    echoerr 'Unable to open a window for diff buffer'
    return s:FALSE
  endif

  " There is another method which checks b:changedtick to determine whether
  " the buffer is modified or not.  This method is more accurate than the
  " method which checks &l:modified, because &l:modified may be unset when
  " user does work quickly in 'updatetime'.
  "
  " But b:changedtick is a special variable and it cannot be accessed via
  " getbufvar(), so another method cannot be used for the case of this plugin.
  if a:timing ==# 'written' || getbufvar(base_bufnr, '&modified')
    update
    execute diff_winnr 'wincmd w'
      setlocal modifiable
        silent % delete _  " suppress '--No lines in buffer--' message.
        silent execute 'read !' s:vcs_diff_script(base_bufnr)
        1 delete _
      setlocal nomodifiable
    wincmd p
  endif
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
    \ |   call s:perform_flydiff('written')
    \ | endif
    autocmd CursorHold <buffer>
    \   if s:flydiff_timing() =~# '\<realtime\>'
    \ |   call s:perform_flydiff('realtime')
    \ | endif
    autocmd CursorHoldI <buffer>
    \   if s:flydiff_timing() =~# '\<realtime\>'
    \ |   call s:perform_flydiff('realtime')
    \ | endif
  augroup END
  return
endfunction




function! s:vcs_diff_script(bufnr)  "{{{2
  " Return a string of the shell script to get difference between the
  " currently edited a:bufnr and the latest version of a:bufnr with
  " appropriate version control system.
  "
  " FIXME: Support version control systems other than git.
  " FIXME: Support shells other than ordinary ones for *nix.

  let full_path = fnamemodify(bufname(a:bufnr), ':p')
  let working_directory = fnamemodify(full_path, ':h')
  return printf('cd %s; git-diff -- %s',
  \             fnameescape(working_directory),
  \             fnameescape(full_path))
endfunction








" __END__  "{{{1
" vim: foldmethod=marker
