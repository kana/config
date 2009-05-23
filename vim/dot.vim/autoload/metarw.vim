" metarw - a framework to read/write a fake:path
" Version: 0.0.4
" Copyright (C) 2008-2009 kana <http://whileimautomaton.net/>
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
" Variables  "{{{1

let s:FALSE = 0
let s:TRUE = !s:FALSE








" Interface  "{{{1
function! metarw#complete(arglead, cmdline, cursorpos)  "{{{2
  let scheme = s:scheme_of(a:arglead)
  if scheme != ''
    if s:available_scheme_p(scheme)
      let [_, head_part, tail_part] =
      \     metarw#{scheme}#complete(a:arglead, a:cmdline, a:cursorpos)
        " FIXME: support wildcard like -complete=file to filter candidates
      let _ = filter(copy(_),
      \              'stridx(v:val,tail_part,len(head_part))==len(head_part)')
    else
      echoerr 'No such scheme:' string(scheme)
      let _ = []
    endif
  elseif a:arglead == ':'  " experimental
    let _ = map(s:available_schemes(), 'v:val . ":"')
  else
    let _ = split(glob(a:arglead . (a:arglead[-1:] == '*' ? '' : '*')), "\n")
    call map(_, 'v:val . (isdirectory(v:val) ? "/" : "")')
    if a:arglead == ''
      call extend(_, map(s:available_schemes(), 'v:val . ":"'))
    endif
  endif
  return _
endfunction




function! metarw#define_wrapper_commands(override_p)  "{{{2
  let _ = a:override_p ? '!' : ''

  silent! execute 'command'._
  \       '-bang -bar -complete=customlist,metarw#complete -nargs=*'
  \       'Edit  edit<bang> <args>'

  silent! execute 'command'._
  \       '-bar -complete=customlist,metarw#complete -nargs=*'
  \       'Read  read <args>'

  silent! execute 'command'._
  \       '-bang -bar -complete=customlist,metarw#complete -nargs=1'
  \       'Source  source<bang> <args>'

  silent! execute 'command'._
  \       '-bang -bar -complete=customlist,metarw#complete -nargs=* -range=%'
  \       'Write  <line1>,<line2>write<bang> <args>'

  return
endfunction




function! metarw#_event_handler(event_name)  "{{{2
  let fakepath = expand('<afile>')
  let scheme = s:scheme_of(fakepath)
  if s:already_hooked_p(a:event_name, scheme) || !s:available_scheme_p(scheme)
    return s:FALSE
  endif

  let _ = s:on_{a:event_name}(scheme, fakepath)
  if _[0] ==# 'error'
    echoerr _[1].':' fakepath
  endif
  return _[0] !=# 'error'
endfunction








" Misc.  "{{{1
" Event Handlers  "{{{2
function! s:on_BufReadCmd(scheme, fakepath)  "{{{3
  " BufReadCmd is published by :edit or other commands.
  silent let _ = metarw#{a:scheme}#read(a:fakepath)

  if _[0] ==# 'browse'
    let result = s:set_up_content_browser_buffer(a:fakepath, _[1])
  else
    " The current, newly created, buffer should be treated as a special one,
    " so some options must be set even if metarw#{a:scheme}#read() is failed.
    if _[0] ==# 'read'
      call s:read(_[1])
    endif
    1 delete _
    filetype detect
    setlocal buftype=acwrite
    setlocal noswapfile
    let result = _
  endif

  return result
endfunction


function! s:on_BufWriteCmd(scheme, fakepath)  "{{{3
  " BufWriteCmd is published by :write or other commands with 1,$ range.
  return s:write(a:scheme, a:fakepath, 1, line('$'), 'BufWriteCmd')
endfunction


function! s:on_FileAppendCmd(scheme, fakepath)  "{{{3
  " FileAppendCmd is published by :write or other commands with >>.
  return s:write(a:scheme, a:fakepath, line("'["), line("']"), 'FileAppendCmd')
endfunction


function! s:on_FileReadCmd(scheme, fakepath)  "{{{3
  " FileReadCmd is published by :read.
  " FIXME: range must be treated at here.  e.g. 0 read fake:path
  silent let _ = metarw#{a:scheme}#read(a:fakepath)
  if _[0] ==# 'browse'
    call append(line('.'), map(_[1], 'v:val.fakepath'))
  elseif _[0] ==# 'read'
    call s:read(_[1])
  else
    " ignore
  endif
  return _
endfunction


function! s:on_FileWriteCmd(scheme, fakepath)  "{{{3
  " FileWriteCmd is published by :write or other commands with partial range
  " such as 1,2 where 2 < line('$').
  return s:write(a:scheme, a:fakepath, line("'["), line("']"), 'FileWriteCmd')
endfunction


function! s:on_SourceCmd(scheme, fakepath)  "{{{3
  " SourceCmd is published by :source.
  let tmp = tempname()
  let tabpagenr = tabpagenr()
  silent tabnew `=tmp`
    let _ = s:on_BufReadCmd(a:scheme, a:fakepath)
    if _[0] !=# 'error'
      " FIXME: Update "_" if an error is happened in this clause.
      silent write
      execute 'source'.(v:cmdbang ? '!' : '') '%'
    endif
  tabclose
  call delete(tmp)
  execute 'tabnext' tabpagenr

  return _
endfunction




function! s:already_hooked_p(event_name, scheme)  "{{{2
  for _ in ['://*', ':*', ':*/*', '::*', '::*/*']
    if exists(printf('#%s#%s%s', a:event_name, a:scheme, _))
      return s:TRUE
    endif
  endfor

  return s:FALSE
endfunction




function! s:available_scheme_p(scheme)  "{{{2
  return 0 <= index(s:available_schemes(), a:scheme)
endfunction




function! s:available_schemes()  "{{{2
  return sort(map(
  \        split(globpath(&runtimepath, 'autoload/metarw/*.vim'), "\n"),
  \        'substitute(v:val, ''^.*/\([^/]*\)\.vim$'', ''\1'', '''')'
  \      ))
endfunction




function! s:read(arg)  "{{{2
  execute 'read' v:cmdarg a:arg
  return
endfunction




function! s:scheme_of(s)  "{{{2
  return matchstr(a:s, '^[a-z]\+\ze:')
endfunction




function! s:set_up_content_browser_buffer(fakepath, items)  "{{{2
  setlocal buftype=nofile
  setlocal bufhidden=delete
  setlocal nonumber
  setlocal noswapfile
  setlocal nowrap
  let b:metarw_items = copy(a:items)

  setlocal modifiable  " to re:edit
    1
    put ='metarw content browser'
    put =a:fakepath
    put =''
    let b:metarw_base_linenr = line('.')
    call append(b:metarw_base_linenr, map(copy(b:metarw_items), 'v:val.label'))
    1 delete _
    call cursor(b:metarw_base_linenr, 0)
  setlocal nomodifiable

  setfiletype metarw

  if !exists('g:metarw_no_default_key_mappings')
    nmap <buffer> <Return>  <Plug>(metarw-open-here)
    nmap <buffer> <C-m>  <Plug>(metarw-open-here)
    nmap <buffer> o  <Plug>(metarw-open-split)
    nmap <buffer> v  <Plug>(metarw-open-vsplit)
    nmap <buffer> -  <Plug>(metarw-go-to-parent)
  endif

  return [s:TRUE, 0]
endfunction


nnoremap <silent> <Plug>(metarw-open-here)
\ :<C-u>call <SID>open_item('')<Return>
nnoremap <silent> <Plug>(metarw-open-split)
\ :<C-u>call <SID>open_item('split')<Return>
nnoremap <silent> <Plug>(metarw-open-vsplit)
\ :<C-u>call <SID>open_item('vsplit')<Return>
nnoremap <silent> <Plug>(metarw-go-to-parent)
\ :<C-u><C-r>=b:metarw_base_linenr<Return> call <SID>open_item('')<Return>


function! s:open_item(split_command)
  let i = line('.') - b:metarw_base_linenr
  if !(0 <= i && i < len(b:metarw_items))
    return
  endif

  if a:split_command != ''
    execute a:split_command
  endif

  edit `=b:metarw_items[i].fakepath`
  return
endfunction




function! s:write(scheme, fakepath, line1, line2, event_name)  "{{{2
  let _ = metarw#{a:scheme}#write(a:fakepath, a:line1, a:line2,
  \                               a:event_name ==# 'FileAppendCmd')
  if _[0] ==# 'write'
    let v:errmsg = ''
    execute a:line1 ',' a:line2 'write' v:cmdarg _[1]
    if v:shell_error != 0
      let _ = ['error', 'Failed to :write !{cmd}']
    endif
    if v:errmsg != ''
      let _ = ['error', 'Failed to write: ' . v:errmsg]
    endif

    if _[0] != 'error' && 3 <= len(_)
      execute _[2]
    endif
  endif
  if _[0] !=# 'error'
  \  && a:event_name ==# 'BufWriteCmd' && a:fakepath ==# bufname('')
    " The whole buffer has been saved to the current fakepath, so 'modified'
    " should be reset.
    setlocal nomodified
  endif
  return _
endfunction








" __END__  "{{{1
" vim: foldmethod=marker
