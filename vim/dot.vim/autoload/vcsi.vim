" vcsi - Version Control System Interface
" Version: 0.1.0
" Copyright (C) 2007-2008 kana <http://whileimautomaton.net/>
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
" Conventions for arguments  "{{{1
"
" args
"     Dictionary which contains various information.
"     At least, "command" and "targets" keys exist.
"
" command
"     String which represents the name of a vcsi command.
"
" count
"     Number which represents the last given count.
"
" targets
"     List of a string which represents the targets of a vcsi command.
"     If the length of targets is 0, it is called as unnormalized targets.
"     If targets is returned by s:normalize_targets(), it is called as
"     normalized targets.








" Interfaces  "{{{1
function! vcsi#add(...)  "{{{2
  " args = unnormalized-target*
  return s:execute_vcs_command({
  \        'command': 'add',
  \        'targets': s:normalize_targets(a:000),
  \      })
endfunction




function! vcsi#commit(...)  "{{{2
  " args = unnormalized-target*
  return s:open_command_buffer({
  \        'command': 'commit',
  \        'targets': s:normalize_targets(a:000),
  \      })
endfunction




function! vcsi#diff(count, ...)  "{{{2
  " args = unnormalized-target*
  return s:open_command_buffer({
  \        'command': 'diff',
  \        'count': a:count,
  \        'targets': s:normalize_targets(a:000),
  \      })
endfunction




function! vcsi#log(...)  "{{{2
  " args = unnormalized-target*
  return s:open_command_buffer({
  \        'command': 'log',
  \        'targets': s:normalize_targets(a:000),
  \      })
endfunction




function! vcsi#remove(banged_p, ...)  "{{{2
  " args = unnormalized-target*
  return s:execute_vcs_command({
  \        'banged_p': a:banged_p,
  \        'command': 'remove',
  \        'targets': s:normalize_targets(a:000),
  \      })
endfunction




function! vcsi#revert(...)  "{{{2
  " args = unnormalized-target*
  return s:execute_vcs_command({
  \        'command': 'revert',
  \        'targets': s:normalize_targets(a:000),
  \      })
endfunction




function! vcsi#status(...)  "{{{2
  " args = unnormalized-target*
  return s:open_command_buffer({
  \        'command': 'status',
  \        'targets': s:normalize_targets(a:000),
  \      })
endfunction








" Misc.  "{{{1
" Constants  "{{{2

let s:FALSE = 0
let s:TRUE = !s:FALSE




function! s:execute_vcs_command(args)  "{{{2
  let autowrite = &autowrite
  set noautowrite  " to avoid E676 for s:finish_commit().

  let script = s:make_vcs_command_script(a:args, s:TRUE)
  if script == ''
    return s:FALSE
  endif
  execute '!' script
  let succeeded_p = v:shell_error == 0

  let &autowrite = autowrite
  return succeeded_p
endfunction




function! s:finish_commit()  "{{{2
  " Assumption: the current buffer is created by s:initialize_commit_buffer().
  let commit_log_file = tempname()

  goto 1  " goto the 1st byte of the current buffer.
  let log_tail_line = searchpos('^=== [^=]* ===$', 'cW')[0] - 1
  if writefile(getbufline('', 1, log_tail_line), commit_log_file)
    return  " error message is already published by writefile().
  endif

  let succeeded_p = s:execute_vcs_command({
  \                   'command': 'commit',
  \                   'commit_log_file': commit_log_file,
  \                   'targets': b:vcsi_targets,
  \                 })
  if succeeded_p
    " FIXME: Here should we restore the previous state like the
    "        s:open_command_buffer()?  But window layout and other states can
    "        be changed since s:open_command_buffer() is done.
    " FIXME: If this function is called by :wquit, one more window is closed.
    bwipeout!
  endif

  if delete(commit_log_file)
    echoerr 'vcsi: Failed to delete temporary file' string(commit_log_file)
  endif
endfunction




" s:initialize_{command}_buffer()  "{{{2
function! s:initialize_commit_buffer(args)  "{{{3
    " BUGS: Don't forget to update message filtering in s:finish_commit().
  1 put ='=== This and the following lines will be removed. ==='
  if g:vcsi_use_native_message_p
    silent execute 'read !'
    \ 'EDITOR=cat' s:make_vcs_command_script(a:args, s:FALSE) '2>/dev/null'
  endif
  if g:vcsi_status_in_commit_buffer_p
    call s:read_vcs_command_result('$', {
    \      'command': 'status',
    \      'targets': a:args.targets,
    \    })
  endif
  if g:vcsi_diff_in_commit_buffer_p
    call s:read_vcs_command_result('$', {
    \      'count': 0,
    \      'command': 'diff',
    \      'targets': a:args.targets,
    \    })
  endif

  goto 1  " goto the 1st byte of the current buffer.
  setlocal buftype=acwrite filetype=diff.vcsi nomodified
  autocmd BufWriteCmd <buffer>  call s:finish_commit()

  return s:TRUE
endfunction


function! s:initialize_diff_buffer(args)  "{{{3
  if !s:read_vcs_command_result('$', a:args, s:TRUE)
    return s:FALSE
  endif
  if line('$') == 1
    echomsg 'vcsi: No difference'
    return s:FALSE
  endif
  1 delete _

  filetype detect
  return s:TRUE
endfunction


function! s:initialize_log_buffer(args)  "{{{3
  if !s:read_vcs_command_result('$', a:args, s:TRUE)
    return s:FALSE
  endif
  1 delete _

  " FIXME: "more" feature.
  return s:TRUE
endfunction


function! s:initialize_status_buffer(args)  "{{{3
  if !s:read_vcs_command_result('$', a:args, s:TRUE)
    return s:FALSE
  endif
  1 delete _

  return s:TRUE
endfunction




function! s:make_command_buffer_name(args)  "{{{2
  let i = 0
  while s:TRUE
    let bufname = printf('*vcsi* [%s] %s - %s%s',
    \                    s:vcs_type(a:args.targets),
    \                    a:args.command,
    \                    join(a:args.targets, ', '),
    \                    (i == 0 ? '' : ' (' . i . ')'))
    if !bufexists(bufname)
      return bufname
    endif
    let i += 1
  endwhile
endfunction




" s:make_vcs_command_script() and others  "{{{2
" Return a shell script to execute the given command.
" Return empty string if the given command is not supported or other reasons.
function! s:make_vcs_command_script(args, show_error_p)  "{{{3
  let script = s:make_{s:vcs_type(a:args.targets)}_command_script(a:args)
  let script = substitute(script, ' \{2,}', ' ', 'g')
  if script == ''
    if a:show_error_p
      echomsg printf('vcsi: %s: Not supported command: %s',
      \              s:vcs_type(a:args.targets),
      \              a:args.command)
    endif
    return ''
  endif

  if exists('g:vcsi_echo_script_p') && g:vcsi_echo_script_p
    echomsg 'vcsi:' script
  endif
  return script
endfunction


function! s:make_git_command_script(args)  "{{{3
  let _ = ['git']

  if a:args.command ==# 'add'
    call add(_, 'add')
    call add(_, '--')
  elseif a:args.command ==# 'commit'
    call add(_, 'commit')
    if has_key(a:args, 'commit_log_file')
      call add(_, '--file')
      call add(_, a:args.commit_log_file)
    endif
  elseif a:args.command ==# 'diff'
    call add(_, 'diff')
    call add(_, 'HEAD' . (0 < a:args.count ? '~' . a:args.count : ''))
    call add(_, '--')
  elseif a:args.command ==# 'log'
    call add(_, a:args.command)
  elseif a:args.command ==# 'remove'
    call add(_, 'rm')
    if a:args.banged_p
      call add(_, '-f')
    endif
    call add(_, '--')
  elseif a:args.command ==# 'revert'
    call add(_, 'checkout')
    call add(_, '--')
  elseif a:args.command ==# 'status'
    call add(_, a:args.command)
  else
    return ''  " Not supported command.
  endif

  call extend(_, map(copy(a:args.targets), '"''" . v:val . "''"'))
  return join(_)
endfunction


function! s:make_svk_command_script(args)  "{{{3
  " FIXME: ad hoc.
  if has(a:args, 'count')
    echomsg 'vcsi: ' . s:vcs_type(a:args.targets) . ': Count is not supported.'
  endif
  return join([s:vcs_type(a:args.targets),
  \            a:args.command,
  \            (a:args.command ==# 'revert'
  \             ? '--recursive'
  \             : ''),
  \            (has_key(a:args, 'commit_log_file')
  \             ? '--file ' . a:args.commit_log_file
  \             : ''),
  \            (has_key(a:args, 'banged_p') && a:args.banged_p
  \             ? '--force'
  \             : ''),
  \            "'" . join(a:args.targets, "' '") . "'"])
endfunction


function! s:make_svn_command_script(args)  "{{{3
  " FIXME: ad hoc.
  return s:make_svk_command_script(a:args)
endfunction


function! s:make_unknown_command_script(args)  "{{{3
  return ''  " This is dummy so always fail.
endfunction




function! s:normalize_targets(unnormalized_targets)  "{{{2
  if 0 < len(a:unnormalized_targets)
    " Here we must copy a:unnormalized_targets, because it may be a:000 given
    " to a function, and a:000 cannot be used after the function is returned.
    " If a:000 is used so, Vim will crash.
    return copy(a:unnormalized_targets)
  endif

  if exists('b:vcsi_targets')
    return b:vcsi_targets
  endif

  if &l:buftype != ''
    throw 'vcsi: Special buffer cannot be a target of a vcsi command.'
  endif

  return [bufname('')]
endfunction




function! s:open_command_buffer(args)  "{{{2
  " Assumption: args.targets must be normalized one.

  " Memoize the information to restore the current state for some errors in
  " the following steps.
  let curbufnr = bufnr('%')
  let curtabpagenr = tabpagenr()
  let tabpagenr = tabpagenr('$')
  let winnr = winnr('$')
  let winrestcmd = winrestcmd()

  " Create a new buffer for the given command.
  let v:errmsg = ''
  silent! execute (exists('g:vcsi_open_command_{a:args.command}')
  \                ? g:vcsi_open_command_{a:args.command}
  \                : g:vcsi_open_command)
  if v:errmsg != ''
    " Error message is already showed.
    return s:FALSE
  endif

  " Initialize the command buffer (common part).
  setlocal bufhidden=wipe buftype=nofile noswapfile
  let b:vcsi_targets = a:args.targets
  silent file `=s:make_command_buffer_name(a:args)`

  " Initialize the command buffer (command-specific part).
  try
    let succeeded_p = s:initialize_{a:args.command}_buffer(a:args)
  catch
    echoerr v:exception 'in' v:throwpoint
    let succeeded_p = s:FALSE
  endtry
  if !succeeded_p
    " Restore the previous state.
    if tabpagenr != tabpagenr('$')  " new tabpage is opened.
      tabclose
      execute 'tabnext' curtabpagenr
    elseif winnr != winnr('$')  " new window is opened
      close
    elseif bufexists(curbufnr)  " new buffer is created in the same window.
      execute 'keepalt' curbufnr 'buffer'
    else
      echoerr 'vcsi: unknown case.'
    endif
    execute winrestcmd
    return s:FALSE
  endif

  return s:TRUE
endfunction




function! s:read_vcs_command_result(line, args, ...)  "{{{2
  let script = s:make_vcs_command_script(a:args, (0 < a:0 ? a:1 : s:FALSE))
  if script == ''
    return s:FALSE
  endif

  silent execute a:line 'read !' script
  return s:TRUE
endfunction




function! s:vcs_type(targets)  "{{{2
  " FIXME: directory separator on non-*nix platforms.
  let prefix = fnamemodify(a:targets[0], ':p:h')
  let path = prefix . ';/'

  let _ = finddir('.git', path)
  if _ != ''
    return 'git'
  endif

  let _ = finddir('.svn', path)
  if _ != ''
    return 'svn'
  endif

  if isdirectory(expand('~/.svk/local', ':p'))
    return 'svk'
  endif

  return 'unknown'  " dummy vcs name
endfunction








" __END__  "{{{1
" vim: foldmethod=marker
