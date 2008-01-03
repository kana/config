" vcsi.vim - Version Control System Interface
" Version: 0.0
" Copyright: Copyright (C) 2007 kana <http://nicht.s8.xrea.com/>
" License: MIT license (see <http://www.opensource.org/licenses/mit-license>)
" $Id$
" Constants  "{{{1

let s:TRUE = (0 == 0)
let s:FALSE = !s:TRUE

let s:INVALID_BUFNR = -1








" Interfaces  "{{{1
" Notes:
" - vcsi#*() returns true on success or false on failure.
function! vcsi#commit(...)  "{{{2
  " args = item*
  let bufnr = s:create_commit_log_buffer({
    \           'command': 'commit',
    \           'items': s:normalize_items(a:000),
    \         })
  return s:open_buffer(bufnr, 'commit')
endfunction




function! vcsi#commit_finish()  "{{{2
  " Assumption: the current buffer is created by s:create_commit_log_buffer().
  let commit_log_file = tempname()

  call cursor(line('$'), 0)
  let log_tail_line = searchpos('^=== [^=]* ===$', 'bcW')[0] - 1
  if writefile(getbufline('', 1, log_tail_line), commit_log_file)
    return  " error message is already published by writefile().
  endif

  let succeededp = s:execute_vcs_command({
     \               'command': 'commit',
     \               'items': b:vcsi_target_items,
     \               'commit_log_file': commit_log_file
     \             })
  if succeededp
    bwipeout!
  endif

  if delete(commit_log_file)
    echohl ErrorMsg
    echomsg 'Failed to delete temporary file' string(commit_log_file)
    echohl None
  endif
endfunction




function! vcsi#diff(...)  "{{{2
  " args = (item revision?)?
  let bufnr = s:create_vcs_command_result_buffer({
    \           'command': 'diff',
    \           'items': s:normalize_items([1 <= a:0 ? a:1 : '-']),
    \           'revision': (2 <= a:0 ? a:2 : ''),
    \           'filetype': 'diff'
    \         })
  return s:open_buffer(bufnr, 'diff')
endfunction




function! vcsi#info(...)  "{{{2
  " args = item*
  let bufnr = s:create_vcs_command_result_buffer({
    \           'command': 'info',
    \           'items': s:normalize_items(a:000)
    \         })
  return s:open_buffer(bufnr, 'info')
endfunction




function! vcsi#log(...)  "{{{2
  " args = (item revision?)?
  let bufnr = s:create_vcs_command_result_buffer({
    \           'command': 'log',
    \           'items': s:normalize_items([1 <= a:0 ? a:1 : '-']),
    \           'revision': 'HEAD:' . (2 <= a:0 ? a:2 : '1')
    \         })
  return s:open_buffer(bufnr, 'log')
endfunction




function! vcsi#propedit(...)  "{{{2
  " args = ???
  throw 'FIXME: Not implemented yet.'
endfunction




function! vcsi#revert(...)  "{{{2
  " args = item*
  return s:execute_vcs_command({
    \      'command': 'revert',
    \      'items': s:normalize_items(a:000)
    \    })
endfunction




function! vcsi#status(...)  "{{{2
  " args = item*
  let bufnr = s:create_vcs_command_result_buffer({
    \           'command': 'status',
    \           'items': s:normalize_items(a:000)
    \         })
  return s:open_buffer(bufnr, 'status')
endfunction








" Misc.  "{{{1
" Notes:
" - s:create_*_buffer() just creates a new buffer then returns its number,
"   or returns s:INVALID_BUFNR on failure.
function! s:create_commit_log_buffer(args)  "{{{2
  " args = command:'commit' items:normalized-items
  let bufnr = s:create_temporary_buffer()
  let state = s:switch_to_buffer(bufnr)

  silent file `=s:make_buffer_name(a:args)`

    " BUGS: Don't forget to update message filtering in vcsi#commit_finish().
  put ='=== Targets to be commited (this message will be removed). ==='
  execute 'read !' s:make_vcs_command_script({
        \            'command': 'status',
        \            'items': a:args.items
        \          })
  call cursor(1, 0)
  let b:vcsi_target_items = a:args.items
  setlocal buftype=acwrite nomodified
  autocmd BufWriteCmd <buffer>  call vcsi#commit_finish()

  silent call s:switch_back_buffer(state)
  return bufnr
endfunction




function! s:create_temporary_buffer()  "{{{2
  " Note: 'bufhidden' of temporary buffer is set to "hide" to hide it.
  "       Don't forget to set appropriate value later.
  let original_bufnr = bufnr('')
  let original_bufhidden = &l:bufhidden
  let &l:bufhidden = 'hide'

  hide enew
  setlocal bufhidden=hide buflisted buftype=nofile noswapfile
  let new_bufnr = bufnr('')

  " Switch back to the original buffer.
  if original_bufnr != new_bufnr
    execute original_bufnr 'buffer'
    let &l:bufhidden = original_bufhidden
  else
    " Or create new empty (= unnamed and not modified) buffer.
    " Because ":hide enew" doesn't create new empty buffer
    " when the current buffer is an empty buffer.
    enew
  endif

  return new_bufnr
endfunction




function! s:create_vcs_command_result_buffer(args)  "{{{2
  " args = {same as s:make_vcs_command_script()} + filetype:filetype?
  let bufnr = s:create_temporary_buffer()
  let state = s:switch_to_buffer(bufnr)

  silent file `=s:make_buffer_name(a:args)`
  let b:vcsi_target_items = a:args.items

    " FIXME: error cases.
  execute '1 read !' s:make_vcs_command_script(a:args)
  if 1 < line('$')
    1 delete _
    if (v:shell_error == 0) && has_key(a:args, 'filetype')
      let &l:filetype = a:args.filetype
    endif
  else
    setlocal bufhidden=wipe  " to bwipeout on s:switch_back_buffer().
    let bufnr = s:INVALID_BUFNR
  endif

  silent call s:switch_back_buffer(state)
  if bufnr == s:INVALID_BUFNR
    " redraw and echomsg must be done here to avoid the message being
    " overriden by other messages and/or commands.
    redraw
      " FIXME: more better message
    echomsg 'No output from' a:args.command join(a:args.items)
  endif
  return bufnr
endfunction




function! s:execute_vcs_command(args)  "{{{2
    " FIXME: error cases.
  execute '!' s:make_vcs_command_script(a:args)
  return v:shell_error == 0
endfunction




function! s:make_buffer_name(args)  "{{{2
  " args = {same as s:make_vcs_command_script()}
  let base_name = 'vcsi:' . s:vcs_type(a:args.items)
    \             . ' - ' . a:args.command
    \             . ' - ' . join(a:args.items)
  let name = base_name
  let i = 0
  while bufexists(name)
    let i += 1
    let name = base_name . ' (' . i . ')'
  endwhile
  return name
endfunction




function! s:make_vcs_command_script(args)  "{{{2
  " args = command:vcs-command-name
  "        items:normalized-items
  "        commit_log_file:commit_log_file?
  "        revision:revision?
  " FIXME: support other vcs (currently svk and Subversion only, ad hoc)
  " FIXME: custom command name (e.g. use my-svk instead svk)
  let script = join([s:vcs_type(a:args.items), a:args.command,
    \               (a:args.command ==# 'revert'
    \                ? '--recursive' : ''),
    \               (len(get(a:args, 'revision', ''))
    \                ? '-r '.a:args.revision : ''),
    \               (has_key(a:args, 'commit_log_file')
    \                ? '--file '.a:args.commit_log_file : ''),
    \               join(map(a:args.items, "\"'\" . v:val . \"'\""))])
  let script = substitute(script, ' \{2,}', ' ', 'g')
  if exists('g:vcsi_echo_scriptp') && g:vcsi_echo_scriptp
    echomsg 'vcsi:' script
  endif
  return script
endfunction




function! s:normalize_items(unnormalized_items)  "{{{2
  let items = []
  for item in (len(a:unnormalized_items) ? a:unnormalized_items : ['-'])
    if item ==# 'all'
      call add(items, '.')
    elseif item ==# '' || item ==# '-'
      if exists('b:vcsi_target_items')
        call extend(items, b:vcsi_target_items)
      else
        call add(items, bufname(''))
      endif
    else
      call add(items, item)
    endif
  endfor
  return items
endfunction




function! s:open_buffer(bufnr, vcs_command_name)  "{{{2
  if bufexists(a:bufnr)
    execute (exists('g:vcsi_open_command_{a:vcs_command_name}')
         \          ? g:vcsi_open_command_{a:vcs_command_name}
         \          : g:vcsi_open_command)
         \         a:bufnr
    call setbufvar(a:bufnr, '&bufhidden', 'wipe')
  endif
  return bufnr('') == a:bufnr
endfunction




function! s:switch_back_buffer(state)  "{{{2
  execute a:state.bufnr 'buffer'
  call setbufvar(a:state.bufnr, '&bufhidden', a:state.bufhidden)
  return  bufnr('') == a:state.bufnr
endfunction




function! s:switch_to_buffer(bufnr)  "{{{2
  let state = {}
  let state.bufnr = bufnr('')
  let state.bufhidden = &l:bufhidden

  let &l:bufhidden = 'hide'
  execute 'hide' a:bufnr 'buffer'

  return state  " to switch back the original buffer.
endfunction




function! s:vcs_type(items)  "{{{2
  " FIXME: directory separator on non-*nix platforms.
  let prefix = fnamemodify(a:items[0], ':p:h') . '/'

  if isdirectory(prefix . '.svn')
    return 'svn'
  " elseif isdirectory(prefix . 'CVS')
  "   return 'cvs'
  else
    return 'svk'
  endif
endfunction








" __END__  "{{{1
" vim: foldmethod=marker
