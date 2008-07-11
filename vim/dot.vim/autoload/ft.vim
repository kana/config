" ft - Support to write ftplugin/synatx/indent scripts
" Version: 0.0.0
" Copyright (C) 2008 kana <http://whileimautomaton.net/>
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
function! ft#loaded_p(sfile)  "{{{2
  let sinfo = s:caller_script_info(a:sfile)

  if exists(sinfo.additional_marker_varname)
  \  && index({sinfo.additional_marker_varname}, sinfo.marker_value) != -1
    return 1
  endif

  return sinfo.load_type ==# 'normal'
  \      && exists(sinfo.normal_marker_varname)
  \      && '.'.{sinfo.normal_marker_varname}.'.' =~# '\.' . sinfo.filetype . '\.'
endfunction




function! ft#mark_as_loaded(sfile)  "{{{2
  let sinfo = s:caller_script_info(a:sfile)

  if !exists(sinfo.additional_marker_varname)
    let {sinfo.additional_marker_varname} = []
  endif
  call add({sinfo.additional_marker_varname}, sinfo.marker_value)

  if sinfo.load_type ==# 'normal'
    let i = match('.' . &l:filetype . '.', '\.' . sinfo.filetype . '\.')
    if i < 0
      throw printf('Internal error: i < 0 for &l:filetype %s and sinfo %s',
      \            string(&l:filetype), string(sinfo))
    endif
    let {sinfo.normal_marker_varname} = &l:filetype[:i-1]
  endif

  return
endfunction








" Misc.  "{{{1
function! s:caller_script_info(sfile)  "{{{2
  let sfile = s:normalize_sfile(a:sfile)
  let sinfo = {}
  let _ = matchlist(
  \   sfile,
  \   '\v%(/(after))?/(ftplugin|syntax|indent)/([^/_]+)([/_]%([^/_]+))?.vim$'
  \ )
  if len(_) == 0
    throw 'Invalid type of script to use ft: ' . string(a:sfile)
  endif

  let sinfo.load_type = _[1] == '' ? 'normal' : 'after'
  let sinfo.script_type = _[2]  " 'ftplugin' or 'syntax' or 'indent'
  let sinfo.filetype = _[3]
  let sinfo.feature = _[4]
  let sinfo.marker_value = sinfo.filetype . sinfo.feature

  if sinfo.script_type ==# 'syntax'
    let sinfo.normal_marker_varname = 'b:current_syntax'
  else
    let sinfo.normal_marker_varname = 'b:did_' . sinfo.script_type
  endif
  let sinfo.additional_marker_varname = 'b:ft_' . sinfo.script_type

  return sinfo
endfunction




function! s:normalize_sfile(sfile)  "{{{2
  return substitute(a:sfile, '[/:\\]', '/', 'g')
endfunction








" __END__  "{{{1
" vim: foldmethod=marker
