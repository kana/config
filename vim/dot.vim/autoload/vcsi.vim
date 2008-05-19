" vcsi.vim - Version Control System Interface
" Version: 0.0.7
" Copyright: Copyright (C) 2007-2008 kana <http://whileimautomaton.net/>
" License: MIT license (see <http://www.opensource.org/licenses/mit-license>)
" Interfaces  "{{{1
" Notes:
" For each vcsi#*() which is called by user:
" - it must returns true on success or false on failure;
" - it must check whether the current s:vcs_type() supports the command itself.
function! vcsi#commit(...)  "{{{2
  " args = item*
  return s:create_new_buffer('commit') &&
       \ s:initialize_commit_log_buffer({
       \   'command': 'commit',
       \   'items': s:normalize_items(a:000),
       \ })
endfunction




function! vcsi#commit_finish()  "{{{2
  " Assumption: the current buffer is created by
  " s:initialize_commit_log_buffer().
  let commit_log_file = tempname()

  call cursor(line('$'), 0)
  let log_tail_line = searchpos('^=== [^=]* ===$', 'bcW')[0] - 1
  if writefile(getbufline('', 1, log_tail_line), commit_log_file)
    return  " error message is already published by writefile().
  endif

  let succeededp = s:execute_vcs_command({
    \                'command': 'commit',
    \                'items': b:vcsi_target_items,
    \                'commit_log_file': commit_log_file
    \              })
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
  return s:create_new_buffer('diff') &&
       \ s:initialize_vcs_command_result_buffer({
       \   'command': 'diff',
       \   'items': s:normalize_items(a:000),
       \   'revision': (2 <= a:0 ? a:2 : ''),
       \   'filetype': 'diff'
       \ })
endfunction




function! vcsi#info(...)  "{{{2
  " args = item*
  return s:create_new_buffer('info') &&
       \ s:initialize_vcs_command_result_buffer({
       \   'command': 'info',
       \   'items': s:normalize_items(a:000)
       \ })
endfunction




function! vcsi#log(...)  "{{{2
  " args = (item revision?)?
  return s:create_new_buffer('log') &&
       \ s:initialize_vcs_command_result_buffer({
       \   'command': 'log',
       \   'items': s:normalize_items(a:000),
       \   'revision': 'HEAD:' . (2 <= a:0 ? a:2 : '1')
       \ })
endfunction




function! vcsi#propedit(...)  "{{{2
  " args = ???
  let vcs_type = s:vcs_type(s:normalize_items(a:000))
  if !(vcs_type ==# 'svk' || vcs_type ==# 'svn')
    throw 'Not supported VCS: ' . vcs_type
  endif
  throw 'FIXME: Not implemented yet.'
endfunction




function! vcsi#revert(...)  "{{{2
  " args = item*
  return s:execute_vcs_command({
    \      'command': 'revert',
    \      'items': s:normalize_items(a:000, 'no-new-window')
    \    })
endfunction




function! vcsi#status(...)  "{{{2
  " args = item*
  return s:create_new_buffer('status') &&
       \ s:initialize_vcs_command_result_buffer({
       \   'command': 'status',
       \   'items': s:normalize_items(a:000)
       \ })
endfunction








" Misc.  "{{{1
function! s:create_new_buffer(vcs_command_name)  "{{{2
  let v:errmsg = ''
  execute (exists('g:vcsi_open_command_{a:vcs_command_name}')
        \  ? g:vcsi_open_command_{a:vcs_command_name}
        \  : g:vcsi_open_command)
  return v:errmsg == ''
endfunction




function! s:execute_vcs_command(args)  "{{{2
  let autowrite = &autowrite
  set noautowrite  " to avoid E676 for vcsi#commit_finish().

    " FIXME: error cases.
  execute '!' s:make_vcs_command_script(a:args)

  let &autowrite = autowrite
  return v:shell_error == 0
endfunction




function! s:initialize_commit_log_buffer(args)  "{{{2
  " args = command:'commit' items:normalized-items
  call s:initialize_temporary_buffer()

  silent file `=s:make_buffer_name(a:args)`

    " BUGS: Don't forget to update message filtering in vcsi#commit_finish().
  put ='=== Targets to be commited (this message will be removed). ==='
  if g:vcsi_status_in_commit_logp
    silent execute '$read !' s:make_vcs_command_script({
         \                     'command': 'status',
         \                     'items': a:args.items
         \                   })
  else
    call append(line('$'), a:args.items)
  endif
  if g:vcsi_diff_in_commit_logp
    silent execute '$read !' s:make_vcs_command_script({
         \                     'command': 'diff',
         \                     'items': a:args.items
         \                   })
  endif
  call cursor(1, 0)
  let b:vcsi_target_items = a:args.items
  setlocal buftype=acwrite nomodified filetype=diff.vcsicommit
  autocmd BufWriteCmd <buffer>  call vcsi#commit_finish()

  return 1
endfunction




function! s:initialize_temporary_buffer()  "{{{2
  setlocal bufhidden=wipe buflisted buftype=nofile noswapfile
  return 1
endfunction




function! s:initialize_vcs_command_result_buffer(args)  "{{{2
  " args = {same as s:make_vcs_command_script()} + filetype:filetype?
  call s:initialize_temporary_buffer()

  silent file `=s:make_buffer_name(a:args)`
  let b:vcsi_target_items = a:args.items

    " FIXME: error cases.
  silent execute '1 read !' s:make_vcs_command_script(a:args)
  if 1 < line('$')
    1 delete _
    if (v:shell_error == 0) && has_key(a:args, 'filetype')
      let &l:filetype = a:args.filetype
    endif
    setlocal nomodified
    return 1
  else
    bwipeout!
    " redraw then echomsg to avoid the message being overriden by other
    " messages and/or commands.
    redraw
      " FIXME: more better message
    echomsg 'No output from' a:args.command join(a:args.items)
    return 0
  endif
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
  let script = s:make_{s:vcs_type(a:args.items)}_command_script(a:args)
  let script = substitute(script, ' \{2,}', ' ', 'g')
  if exists('g:vcsi_echo_scriptp') && g:vcsi_echo_scriptp
    echomsg 'vcsi:' script
  endif
  return script
endfunction


function! s:make_git_command_script(args)  "{{{3
  let ss = ['git']
  let items = map(copy(a:args.items), '"''" . v:val . "''"')
  if a:args.command ==# 'commit'
    call add(ss, 'commit')
    call add(ss, '-F')
    call add(ss, a:args.commit_log_file)
  elseif a:args.command ==# 'diff'
    call add(ss, 'diff')
    call add(ss, '--')
    call extend(ss, items)
    call add(ss, ';')
    call add(ss, ss[0])
    call add(ss, 'diff')
    call add(ss, '--cached')
    call add(ss, '--')
  elseif a:args.command ==# 'info'
    return 'echo "git does not support this command: ' . a:args.command . '"'
  elseif a:args.command ==# 'revert'
    call add(ss, 'checkout')
    call add(ss, '--')  " to express the next arg is not the name of a branch.
  else
    call add(ss, a:args.command)
  endif
  call extend(ss, items)
  return join(ss)
endfunction


function! s:make_svk_command_script(args)  "{{{3
  let script = join([s:vcs_type(a:args.items), a:args.command,
    \               (a:args.command ==# 'revert'
    \                ? '--recursive' : ''),
    \               (len(get(a:args, 'revision', ''))
    \                ? '-r '.a:args.revision : ''),
    \               (has_key(a:args, 'commit_log_file')
    \                ? '--file '.a:args.commit_log_file : ''),
    \               "'" . join(a:args.items, "' '") . "'"])
  return script
endfunction


function! s:make_svn_command_script(args)  "{{{3
  " FIXME: ad hoc.
  return s:make_svk_command_script(a:args)
endfunction




function! s:normalize_items(unnormalized_items, ...)  "{{{2
  let no_new_window_p = a:0 && a:1 ==# 'no-new-window'
  let items = []
  for item in (len(a:unnormalized_items) ? a:unnormalized_items : ['-'])
    if item ==# 'all'
      call add(items, '.')
    elseif item ==# '' || item ==# '-'
      let b_vcsi_target_items = getbufvar(no_new_window_p ? '' : '#',
        \                                 'vcsi_target_items')
      if 0 < len(b_vcsi_target_items)
        call extend(items, b_vcsi_target_items)
      else
        call add(items, bufname(no_new_window_p ? '' : '#'))
      endif
    else
      call add(items, item)
    endif
  endfor
  return items
endfunction




function! s:vcs_type(items)  "{{{2
  " FIXME: directory separator on non-*nix platforms.
  let prefix = fnamemodify(a:items[0], ':p:h')

  if isdirectory(prefix . '/.svn')
    return 'svn'
  " elseif isdirectory(prefix . '/CVS')
  "   return 'cvs'
  endif

  while prefix != '/'
    if isdirectory(prefix . '/.git')
      return 'git'
    endif
    let prefix = fnamemodify(prefix, ':h')
  endwhile

  return 'svk'  " fallback, although it maybe incorrect.
endfunction








" __END__  "{{{1
" vim: foldmethod=marker
