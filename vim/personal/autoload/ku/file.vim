" ku source: file
" Version: 0.1.4
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

  " FIXME: more smart caching
  " BUGS: assumes that the current working directory is not changed in
  "       a single ku session.
let s:cached_items = {}  " pattern -> [item, ...]








" Interface  "{{{1
function! ku#file#available_sources()  "{{{2
  return ['file']
endfunction




function! ku#file#on_source_enter(source_name_ext)  "{{{2
  let s:cached_items = {}
endfunction




function! ku#file#action_table(source_name_ext)  "{{{2
  return {
  \   'default': 'ku#file#action_open',
  \   'extract-asis': 'ku#file#action_extract_asis',
  \   'extract-smartly': 'ku#file#action_extract_smartly',
  \   'extract-solely': 'ku#file#action_extract_solely',
  \   'open!': 'ku#file#action_open_x',
  \   'open': 'ku#file#action_open',
  \ }
endfunction




function! ku#file#key_table(source_name_ext)  "{{{2
  return {
  \   "\<C-e>": 'extract-smartly',
  \   "\<C-o>": 'open',
  \   "\<Esc>e": 'extract-solely',
  \   "\<M-e>": 'extract-solely',
  \   'E': 'extract-asis',
  \   'O': 'open!',
  \   'e': 'extract-smartly',
  \   'o': 'open',
  \ }
endfunction




function! ku#file#gather_items(source_name_ext, pattern)  "{{{2
  " NB: Here we call items which names start with a dot as 'dotfile'.
  let cache_key = (a:pattern != '' ? a:pattern : "\<Plug>(ku)")
  if has_key(s:cached_items, cache_key)
    return s:cached_items[cache_key]
  endif

  let _ = s:parse_pattern(a:pattern)

  if _.type ==# 'directory'
    let items = s:gather_items_from_directory(_)
  elseif _.type ==# 'archive'
    let items = s:gather_items_from_archive(_)
  else
    throw printf('ku:file:e1: Unexpected _.type: _ = %s / a: = %s',
    \            string(_), string(a:))
  endif

  let s:cached_items[cache_key] = items
  return items
endfunction




function! ku#file#acc_valid_p(source_name_ext, item, sep)  "{{{2
  return a:sep ==# ku#path_separator()
  \      && (isdirectory(a:item.word)
  \          || s:archive_type(a:item.word) !=# s:ARCHIVE_TYPE_INVALID)
endfunction




function! ku#file#special_char_p(source_name_ext, char)  "{{{2
  return 0 <= stridx(g:ku_component_separators, a:char) || a:char == '.'
endfunction








" Misc.  "{{{1
" For tests  "{{{2
function! ku#file#_local_variables()
  return s:
endfunction


function! s:SID_PREFIX()
  return matchstr(expand('<sfile>'), '\%(^\|\.\.\)\zs<SNR>\d\+_')
endfunction

function! ku#file#_sid_prefix()
  return s:SID_PREFIX()
endfunction




function! s:archive_basename(path)  "{{{2
  " FIXME: Same as s:archive_type()
  return matchstr(a:path, '\C^.\{-}\ze\(\.zip\)\?$')
endfunction




function! s:archive_type(path)  "{{{2
  " FIXME: Should "learn" the correspondences of archive formats and their
  "        standard extensions.
  " FIXME: Support other archive formats.
  " FIXME: Support "recursive archives", but how?

  " Is it a file with a standard extension, not a directory?
  if a:path =~# '\.zip$' && filereadable(a:path)
    return s:ARCHIVE_TYPE_ZIP
  else
    return s:ARCHIVE_TYPE_INVALID
  endif
endfunction

let s:ARCHIVE_TYPE_ZIP = 'zip'
let s:ARCHIVE_TYPE_INVALID = '*invalid*'




function! s:command_unzip(...)  "{{{2
  " FIXME: If the "unzip" command is renamed.
  " BUGS: Don't check executable('unzip') because system() also fails
  "       if unzip is not available.
  return system('unzip ' . join(a:000))
endfunction




function! s:command_unzip_list(archive_path)  "{{{2
  let output = s:command_unzip('-l', '--', shellescape(a:archive_path))
  if v:shell_error != 0  " FIXME: test
    echoerr 'ku: file: Failed to list the content of a zip archive:'
    echoerr '--' output
    return []
  endif

  " FIXME: Is this parsing good enough?
  "
  " $ unzip -l vim-ku-0.2.3.zip
  " Archive:  foo.zip
  "   Length     Date   Time    Name
  "  --------    ----   ----    ----
  "     60535  05-22-09 22:09   vim-ku-0.2.3/autoload/ku.vim
  "     49435  05-22-09 22:09   vim-ku-0.2.3/doc/ku.txt
  "      1582  05-22-09 22:09   vim-ku-0.2.3/plugin/ku.vim
  "      2449  05-22-09 22:09   vim-ku-0.2.3/syntax/ku.vim
  "      3731  05-22-09 02:02   vim-ku-0.2.3/autoload/ku/buffer.vim
  "      4079  05-16-09 01:48   vim-ku-0.2.3/doc/ku-buffer.txt
  "      4718  05-22-09 02:02   vim-ku-0.2.3/autoload/ku/file.vim
  "      4985  05-22-09 00:57   vim-ku-0.2.3/doc/ku-file.txt
  "      3310  05-22-09 02:02   vim-ku-0.2.3/autoload/ku/history.vim
  "      3895  05-16-09 01:48   vim-ku-0.2.3/doc/ku-history.txt
  "      2893  05-22-09 22:09   vim-ku-0.2.3/autoload/ku/source.vim
  "      3722  05-22-09 22:09   vim-ku-0.2.3/doc/ku-source.txt
  "  --------                   -------
  "    145334                   12 files
  let lines = split(output, '\n')
  call map(lines,
  \        'matchstr(v:val, ''^\s*\d\+\s\+[0-9-]\+\s\+[0-9:]\+\s\+\zs.*$'')')
  call filter(lines, 'v:val != ""')
  return lines  " ['vim-ku-0.2.3/autoload/ku.vim', ...]
endfunction




function! s:extract_zip_archive_asis(archive_path)  "{{{2
  let output = s:command_unzip('--', shellescape(a:archive_path))
  if v:shell_error != 0  " FIXME: test
    return 'ku: file: Failed to extract all content of a zip archive: '
    \      . output
  endif
  return 0
endfunction




function! s:extract_zip_archive_smartly(archive_path)  "{{{2
  let archive_basename = s:archive_basename(a:archive_path)
  let smart_archive_p = !0
  let paths = s:command_unzip_list(a:archive_path)
  for path in paths
    let first_directory = s:first_directory(path)
    if first_directory !=# archive_basename
      let smart_archive_p = 0
      break
    endif
  endfor

  let output = s:command_unzip(
  \              '-d',
  \              shellescape(smart_archive_p ? '.' : archive_basename),
  \              '--',
  \              shellescape(a:archive_path)
  \            )
  if v:shell_error != 0  " FIXME: test
    return 'ku: file: Failed to extract an item in a zip archive: '
    \      . output
  endif
  return 0
endfunction




function! s:extract_zip_content_asis(archive_path, content_path)  "{{{2
  let output = s:command_unzip(
  \              '--',
  \              shellescape(a:archive_path),
  \              shellescape(a:content_path)
  \            )
  if v:shell_error != 0  " FIXME: test
    return 'ku: file: Failed to extract an item in a zip archive: '
    \      . output
  endif
  return 0
endfunction




function! s:extract_zip_content_smartly(archive_path, content_path)  "{{{2
  let archive_basename = s:archive_basename(a:archive_path)
  let first_directory = s:first_directory(a:content_path)
  let output = s:command_unzip(
  \              '-d',
  \              shellescape(first_directory ==# archive_basename
  \                          ? '.'
  \                          : archive_basename),
  \              '--',
  \              shellescape(a:archive_path),
  \              shellescape(a:content_path)
  \            )
  if v:shell_error != 0  " FIXME: test
    return 'ku: file: Failed to extract an item in a zip archive: '
    \      . output
  endif
  return 0
endfunction




function! s:extract_zip_content_solely(archive_path, content_path)  "{{{2
  let path_to_extract = fnamemodify(a:content_path, ':t')
  let output = s:command_unzip(
  \              '-p', '--', shellescape(a:archive_path),
  \              shellescape(a:content_path),
  \              '>', shellescape(path_to_extract)
  \            )
  if v:shell_error != 0  " FIXME: test
      " Because this file is already created by redirection.
    call delete(path_to_extract)
    return 'ku: file: Failed to extract an item of a zip archive: '
    \      . output
  endif
  return 0
endfunction




function! s:first_directory(path)  "{{{2
  " a:path ==> 'foo/bar/baz'
  let components = split(a:path, ku#path_separator())  " ==> ['foo', ...]
  if len(components) <= 1  " a:path without any directory
    return ''
  endif

  let heads = components[:1]  " ==> ['foo', 'bar']
  let partial_path = join(heads, ku#path_separator())  " ==> 'foo/bar'
  return fnamemodify(partial_path, ':h')  " ==> 'foo'
endfunction




function! s:gather_items_from_directory(_)  "{{{2
  let _ = a:_

    " On Microsoft Windows, glob('{,.}*') doesn't list dotfiles,
    " so that here we have to list dotfiles and other items separately.
  let wildcards = _.user_seems_want_dotfiles_p ? ['*', '.?*'] : ['*']
    " glob_prefix must be followed by ku#separator() if it is not empty.
  if len(_.components) == 1  " no path separator
    let glob_prefix = ''
  elseif _.root_directory_pattern_p
    let glob_prefix = ku#path_separator()
  else  " more than one path separators
    let glob_prefix = ku#make_path(_.components[:-2]) . ku#path_separator()
  endif

  let items = []
  for wildcard in wildcards
    for entry in split(glob(glob_prefix . wildcard), "\n")
      call add(items, {
      \      'word': entry,
      \      'abbr': entry . (isdirectory(entry) ? ku#path_separator() : ''),
      \      'menu': (isdirectory(entry) ? 'dir' : 'file'),
      \    })
    endfor
  endfor
    " Remove the '..' item if user seems to find files under the root
    " directory, because it is strange for such situation.
    " FIXME: Drive letter and other cases on Microsoft Windows.  E.g. 'C:\'.
  if fnamemodify(glob_prefix, ':p') == ku#path_separator()  " root directory?
    let parent_directory_name = glob_prefix . '..'
    call filter(items, 'v:val.word !=# parent_directory_name')
  endif

  return items
endfunction




function! s:gather_items_from_archive(_)  "{{{2
  if has_key(s:cached_items, a:_.leading_part)
    return s:cached_items[a:_.leading_part]
  endif

  if a:_.archive_format ==# 'zip'
    let items = s:command_unzip_list(a:_.leading_part)
    call map(items, '{
    \   "word": ku#make_path(a:_.leading_part, v:val),
    \   "menu": "in archive",
    \   "ku_file_archive_format": a:_.archive_format,
    \   "ku_file_archive_path": a:_.leading_part,
    \   "ku_file_archive_content_path": v:val,
    \ }')
  else  " FIXME: test, but how?
    throw printf('ku:file:e2: Unexpected archive format: %s / a: = %s',
    \            string(a:_.archive_format), string(a:))
  endif

  return items
endfunction




function! s:open(bang, item)  "{{{2
  " BUGS: ":silent! edit {file with swp owned by another Vim process}" causes
  " some strange behavior - there is no message but Vim waits for a key input.
  " It makes users confusing, so here :silent!/v:errmsg are not used.

  if has_key(a:item, 'ku_file_archive_content_path')
    call s:open_{a:item.ku_file_archive_format}_content(
    \      a:bang,
    \      a:item.ku_file_archive_path,
    \      a:item.ku_file_archive_content_path
    \    )
  else  " Ordinary file or directory.
    execute 'edit'.a:bang '`=a:item.word`'
  endif

  return 0
endfunction




function! s:open_zip_content(bang, archive_path, content_path)  "{{{2
  execute 'edit'.a:bang '`=printf("zipfile:%s::%s",
  \                               fnamemodify(a:archive_path, ":p"),
  \                               a:content_path)`'
  filetype detect
endfunction




function! s:parse_pattern(pattern)  "{{{2
  " FIXME: Support "recursive archives".
  let _ = {}
  let _.components = split(a:pattern, ku#path_separator(), !0)

  for i in range(len(_.components) - 1)
    let leading_part = ku#make_path(_.components[:i])
    let archive_type = s:archive_type(leading_part)
    if archive_type !=# s:ARCHIVE_TYPE_INVALID
      let _.type = 'archive'
      let _.archive_format = archive_type
      let _.leading_part = leading_part
      return _
    endif
  endfor

  let _.type = 'directory'
  let _.root_directory_pattern_p = strridx(a:pattern, ku#path_separator()) == 0
  let _.user_seems_want_dotfiles_p = _.components[-1][:0] == '.'
  return _
endfunction




" Actions  "{{{2
function! ku#file#action_extract_asis(item)  "{{{3
  if has_key(a:item, 'ku_file_archive_content_path')
    return s:extract_{a:item.ku_file_archive_format}_content_asis(
    \        a:item.ku_file_archive_path,
    \        a:item.ku_file_archive_content_path
    \      )
  else
    let archive_type = s:archive_type(a:item.word)
    if archive_type ==# s:ARCHIVE_TYPE_INVALID
      return 'extract-asis: Not available for this item: '
      \      . string(a:item.word)
    endif

    return s:extract_{archive_type}_archive_asis(a:item.word)
  endif
endfunction


function! ku#file#action_extract_smartly(item)  "{{{3
  if has_key(a:item, 'ku_file_archive_content_path')
    return s:extract_{a:item.ku_file_archive_format}_content_smartly(
    \        a:item.ku_file_archive_path,
    \        a:item.ku_file_archive_content_path
    \      )
  else
    let archive_type = s:archive_type(a:item.word)
    if archive_type ==# s:ARCHIVE_TYPE_INVALID
      return 'extract-smartly: Not available for this item: '
      \      . string(a:item.word)
    endif

    return s:extract_{archive_type}_archive_smartly(a:item.word)
  endif
endfunction


function! ku#file#action_extract_solely(item)  "{{{3
  if has_key(a:item, 'ku_file_archive_content_path')
    return s:extract_{a:item.ku_file_archive_format}_content_solely(
    \        a:item.ku_file_archive_path,
    \        a:item.ku_file_archive_content_path
    \      )
  else
    return 'extract-solely: Not available for this item: '
    \      . string(a:item.word)
  endif
endfunction


function! ku#file#action_open(item)  "{{{3
  return s:open('', a:item)
endfunction


function! ku#file#action_open_x(item)  "{{{3
  return s:open('!', a:item)
endfunction








" __END__  "{{{1
" vim: foldmethod=marker
