" ku source: file
" Version: 0.2.0
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
" Interface  "{{{1
function! ku#source#file#gather_candidates(args)  "{{{2
  " NB: Here we call any candidate which basename starts with a dot "dotfile".
  let _ = s:parse_pattern(a:args.pattern)

  if _.type ==# 'directory'
    let candidates = s:candidates_from_directory(_)
  elseif _.type ==# 'archive'
    let candidates = s:candidates_from_archive(_)
  else
    throw printf('ku:file:e1: Unexpected _.type: _ = %s / a: = %s',
    \            string(_), string(a:))
  endif

  return candidates
endfunction








" Misc.  "{{{1
function! ku#source#file#_sid_prefix()  "{{{2
  nnoremap <SID>  <SID>
  return maparg('<SID>', 'n')
endfunction




function! s:candidates_from_archive(pattern_info)  "{{{2
  return []  " FIXME: NIY
endfunction




function! s:candidates_from_directory(pattern_info)  "{{{2
  " Assumption: pattern_info.components[:-2] don't contain any wildcard.
  " FIXME: path separator normalization
  let _ = a:pattern_info

    " On Microsoft Windows, glob('{,.}*') doesn't list dotfiles,
    " so that here we have to list dotfiles and other items separately.
  let wildcards = _.user_seems_want_dotfiles_p ? ['*', '.?*'] : ['*']
    " glob_prefix must be followed by ku#path_separator()
    " to list content of a directory.
  if len(_.components) == 1  " no path separator
    let glob_prefix = ''
  elseif _.root_directory_pattern_p
    let glob_prefix = ku#path_separator()
  else  " more than one path separators
    let glob_prefix = s:make_path(_.components[:-2]) . ku#path_separator()
  endif

  let candidates = []
  for wildcard in wildcards
    for entry in split(glob(glob_prefix . wildcard), "\n")
      call add(candidates, {
      \      'word': entry,
      \      'abbr': entry . (isdirectory(entry) ? ku#path_separator() : ''),
      \    })
    endfor
  endfor

    " Remove the '..' item if user seems to find files under the root
    " directory, because it is strange for such situation.
    " FIXME: Drive letter and other cases on Microsoft Windows.  E.g. 'C:\'.
  if fnamemodify(glob_prefix, ':p') == ku#path_separator()  " root directory?
    let parent_directory_name = glob_prefix . '..'
    call filter(candidates, 'v:val.word !=# parent_directory_name')
  endif

  return candidates
endfunction




function! s:make_path(...)  "{{{2
  if a:0 == 1 && type(a:1) is type([])
    return join(a:1, ku#path_separator())
  else
    return join(a:000, ku#path_separator())
  endif
endfunction




function! s:parse_pattern(pattern)  "{{{2
  " FIXME: Support "recursive archives".
  let _ = {}
  let _.components = split(a:pattern, ku#path_separator(), !0)

  let _.type = 'directory'
  let _.root_directory_pattern_p = strridx(a:pattern, ku#path_separator()) == 0
  let _.user_seems_want_dotfiles_p = _.components[-1][:0] == '.'
  return _
endfunction








" __END__  "{{{1
" vim: foldmethod=marker
