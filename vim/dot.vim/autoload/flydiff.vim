" flydiff - on-the-fly diff
" Version: 0.0.1
" Copyright (C) 2008 kana <http://whileimautomaton.net/>
" License: MIT license (see <http://www.opensource.org/licenses/mit-license>)
" Constants  "{{{1

let s:FALSE = 0
let s:TRUE = !s:FALSE

let s:ON = 1
let s:OFF = 0
let s:TOGGLE = -773

let s:INVALID_BUFNR = -1  " same as bufnr('no such buffer')
let s:INVALID_WINNR = -1  " same as bufwinnr('no such buffer')
let s:INVALID_CHANGEDTICK = -3846

let s:TYPE_DIFF_BUFFER = ['diff buffer']
let s:TYPE_NORMAL_BUFFER = ['normal buffer']








" Interface  "{{{1
function! flydiff#toggle(bufnr, state)  "{{{2
  if !bufexists(a:bufnr)
    echoerr 'No such buffer:' a:bufnr
    return s:FALSE
  endif

  let b_flydiff_info = s:flydiff_info(a:bufnr, s:TYPE_NORMAL_BUFFER)
  if b_flydiff_info.type isnot s:TYPE_NORMAL_BUFFER
    echoerr 'Flydiff is only performed for normal buffers:' a:bufnr
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
  setlocal bufhidden=hide nobuflisted buftype=nofile nomodifiable noswapfile
  execute 'setfiletype' g:flydiff_filetype
  silent file `=printf('*flydiff* (%d) %s',
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




function! s:empty_buffer_p(bufnr)  "{{{2
  return line('$') == 1 && getline(1) == ''
endfunction




function! s:flydiff_info(bufnr, ...)  "{{{2
  let bufvars = getbufvar(a:bufnr, '')
  if !has_key(bufvars, 'flydiff_info')
    if a:0 == 0
      throw 'Internal error: buffer ' . a:bufnr . ' is not related to flydiff'
    endif

    let bufvars.flydiff_info = {'type': a:1}
    if a:1 is s:TYPE_NORMAL_BUFFER
      let bufvars.flydiff_info.state = s:OFF
      let bufvars.flydiff_info.diff_bufnr = s:INVALID_BUFNR
    elseif a:1 is s:TYPE_DIFF_BUFFER
      let bufvars.flydiff_info.base_bufnr = s:INVALID_BUFNR
      let bufvars.flydiff_info.not_performed_p = s:TRUE
    else
      throw printf('Internal error: Invalid type %s for %d',
      \            string(a:1), a:bufnr)
    endif
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




function! s:open_diff_buffer_window(bufnr)  "{{{2
  let diff_winnr = bufwinnr(a:bufnr)
  if diff_winnr != s:INVALID_WINNR
    return diff_winnr
  endif

  let v:errmsg = ''
  execute s:flydiff_direction() 'split'
  if v:errmsg != ''
    return s:INVALID_WINNR
  endif

  silent execute a:bufnr 'buffer'
  let diff_winnr = winnr()
  wincmd p
  return diff_winnr
endfunction




function! s:perform_flydiff(timing)  "{{{2
  " Use <abuf>, because the current buffer may not be same as <abuf>.
  let base_bufnr = str2nr(expand('<abuf>'))  " bufnr must be a number.
  let b_flydiff_info = s:flydiff_info(base_bufnr)

  if !bufexists(b_flydiff_info.diff_bufnr)
    let b_flydiff_info.diff_bufnr = s:create_diff_buffer_for(base_bufnr)
    if !bufexists(b_flydiff_info.diff_bufnr)
      echoerr 'Unable to create a diff buffer for' base_bufnr
      return s:FALSE
    endif
  endif

  let diff_winnr = s:open_diff_buffer_window(b_flydiff_info.diff_bufnr)
  if diff_winnr == s:INVALID_WINNR
    echoerr 'Unable to open a window for diff buffer for' base_bufnr
    return s:FALSE
  endif

  " There is another method which checks b:changedtick to determine whether
  " the buffer is modified or not.  This method is more accurate than the
  " method which checks &l:modified, because &l:modified may be unset when
  " user does work quickly in 'updatetime'.
  "
  " But b:changedtick is a special variable and it cannot be accessed via
  " getbufvar(), so another method cannot be used for the case of this plugin.
  let diff_b_flydiff_info = s:flydiff_info(b_flydiff_info.diff_bufnr)
  if diff_b_flydiff_info.not_performed_p
  \ || a:timing ==# 'written'
  \ || getbufvar(base_bufnr, '&modified')
    let diff_b_flydiff_info.not_performed_p = s:FALSE

    silent update
    let base_buffer_linenr = line('.')
    execute diff_winnr 'wincmd w'
      setlocal modifiable
        silent % delete _  " suppress '--No lines in buffer--' message.
        silent execute 'read !' s:vcs_diff_script(base_bufnr)
        1 delete _

        call s:_adjust_cursor(base_buffer_linenr)
        if s:empty_buffer_p(b_flydiff_info.diff_bufnr)  " == bufnr('')
          call setline(1, '=== No difference ===')
        endif
      setlocal nomodifiable
    wincmd p
  endif
  return s:TRUE
endfunction


function! s:_adjust_cursor(base_line)  "{{{3
  " Adjust the cursor in a diff buffer to point the line which is equivalent
  " to a:base_line in the corresponding base buffer.  This adjustment is
  " useful when there are many differences and they cannot be showed in the
  " diff buffer window at once.
  "
  " Assumptions:
  " - The current buffer is a diff buffer.
  " - The content of the diff buffer is diff --unified.

  let diff_header_lines = []
  silent global/^@@ .* @@/call add(diff_header_lines, line('.'))

  let following_diff_block_head = 0
  for diff_header_line in diff_header_lines
    let _ = substitute(getline(diff_header_line),
    \                  '^@@ -\d\+,\d\+ +\(\d\+\),\(\d\+\) @@.*$',
    \                  '\1,\2',
    \                  '')
    let [d_line1, d_lineN] = split(_, ',')
    let d_line2 = d_line1 + d_lineN - 1

    if a:base_line < d_line1  " this is a following diff block.
      let following_diff_block_head = diff_header_line
      break  " rest of diff blocks never includes a:base_line.
    elseif d_line2 < a:base_line  " this is a preceding diff block.
      " ignore
    else  " if d_line1 <= a:base_line && a:base_line <= d_line2
      let delta = 0
      for i in range(1 + a:base_line - d_line1)
        let delta += 1
        " skip lines with "deleted" marker "-".
        while getline(diff_header_line + delta)[0] == '-'
          let delta += 1
        endwhile
      endfor

      call cursor(diff_header_line + delta, 0)
      normal! zz
      return
    endif
  endfor

  " If there is no diff block which contains a:base_line.
  call cursor((following_diff_block_head
  \            ? following_diff_block_head
  \            : line('$')),
  \           0)
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
