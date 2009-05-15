" ku source: file
" Version: 0.1.2
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
  \   'open!': 'ku#file#action_open_x',
  \   'open': 'ku#file#action_open',
  \ }
endfunction




function! ku#file#key_table(source_name_ext)  "{{{2
  return {
  \   "\<C-o>": 'open',
  \   'O': 'open!',
  \   'o': 'open',
  \ }
endfunction




function! ku#file#gather_items(source_name_ext, pattern)  "{{{2
  " NB: Here we call items which names start with a dot as 'dotfile'.
  let cache_key = (a:pattern != '' ? a:pattern : "\<Plug>(ku)")
  if has_key(s:cached_items, cache_key)
    return s:cached_items[cache_key]
  endif

  let i = strridx(a:pattern, ku#path_separator())
  let components = split(a:pattern, ku#path_separator(), !0)
  let root_directory_pattern_p = i == 0
  let user_seems_want_dotfiles_p = components[-1][:0] == '.'
    " On Microsoft Windows, glob('{,.}*') doesn't list dotfiles,
    " so that here we have to list dotfiles and other items separately.
  let wildcards = user_seems_want_dotfiles_p ? ['*', '.?*'] : ['*']

    " glob_prefix must be followed by ku#separator() if it is not empty.
  if i < 0  " no path separator
    let glob_prefix = ''
  elseif root_directory_pattern_p
    let glob_prefix = ku#path_separator()
  else  " more than one path separators
    let glob_prefix = ku#make_path(components[:-2]) . ku#path_separator()
  endif

  let _ = []
  for wildcard in wildcards
    for entry in split(glob(glob_prefix . wildcard), "\n")
      call add(_, {
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
    call filter(_, 'v:val.word !=# parent_directory_name')
  endif

  let s:cached_items[cache_key] = _
  return _
endfunction




function! ku#file#acc_valid_p(source_name_ext, item, sep)  "{{{2
  return a:sep ==# ku#path_separator() && isdirectory(a:item.word)
endfunction




function! ku#file#special_char_p(source_name_ext, char)  "{{{2
  return 0 <= stridx(g:ku_component_separators, a:char) || a:char == '.'
endfunction








" Misc.  "{{{1
function! s:open(bang, item)  "{{{2
  " BUGS: ":silent! edit {file with swp owned by another Vim process}" causes
  " some strange behavior - there is no message but Vim waits for a key input.
  " It makes users confusing, so here :silent!/v:errmsg are not used.
  execute 'edit'.a:bang '`=a:item.word`'
  return 0
endfunction




" Actions  "{{{2
function! ku#file#action_open(item)  "{{{3
  return s:open('', a:item)
endfunction


function! ku#file#action_open_x(item)  "{{{3
  return s:open('!', a:item)
endfunction








" __END__  "{{{1
" vim: foldmethod=marker
