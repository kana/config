" advice - alter the behavior of a command in modular way
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
" Variables  "{{{1

" {
"   '{cmd_name}': {
"     '{mode}': {
"       'cmd_keyseq': '{cmd_keyseq}',
"       'need_remap_p': '{need_remap_p}',
"       'cmd_specs': 'cmd_specs',
"       'before': [[{ad_name}, {func_name}, {enabled_p}], ...],
"       'after': [[{ad_name}, {func_name}, {enabled_p}], ...],
"     },
"     ...
"   },
"   ...
" }
"
" PLAN: {priority} to control the order of advices.
let s:_ = {}

let s:I_AD_NAME = 0
let s:I_FUNC_NAME = 1
let s:I_ENABLED_P = 2








" Interface  "{{{1
function! advice#add(cmd_name, modes, class, ad_name, func_name)  "{{{2
  for mode in s:each_char(a:modes)
    let cmd_specs = s:cmd_entry_of(a:cmd_name, mode)['cmd_specs']
    if cmd_specs =~# '\v<(char|insert|line)>' && a:class ==# 'after'
      throw 'after advices are not supported with non-empty {cmd-specs}: '
      \     . string(cmd_specs)
    endif

    let advices = s:advices_of(a:cmd_name, mode, a:class)
    let i = s:index_of_advice(a:ad_name, advices)
    if i == -1
      call insert(advices, [a:ad_name, a:func_name, !0])
    else
      let advices[i][s:I_FUNC_NAME] = a:func_name
    endif
  endfor
endfunction




function! advice#define(cmd_name, modes, cmd_keyseq, need_remap_p, cmd_specs)  "{{{2
  call s:define_interface_mapping_in(a:modes, a:cmd_name)

  for mode in s:each_char(a:modes)
    let cmd_entry = s:cmd_entry_of(a:cmd_name, mode)
    let cmd_entry['cmd_keyseq'] = a:cmd_keyseq
    let cmd_entry['need_remap_p'] = a:need_remap_p
    let cmd_entry['cmd_specs'] = a:cmd_specs
  endfor
endfunction




function! advice#disable(cmd_name, modes, class, ad_name)  "{{{2
  call s:set_enabled_flag(a:cmd_name, a:modes, a:class, a:ad_name, !!0)
endfunction




function! advice#disable_all(cmd_name, modes, class)  "{{{2
  call s:set_enabled_flag_all(a:cmd_name, a:modes, a:class, !!0)
endfunction




function! advice#disable_pattern(pattern)  "{{{2
  throw 'NIY'
endfunction




function! advice#enable(cmd_name, modes, class, ad_name)  "{{{2
  call s:set_enabled_flag(a:cmd_name, a:modes, a:class, a:ad_name, !0)
endfunction




function! advice#enable_all(cmd_name, modes, class)  "{{{2
  call s:set_enabled_flag_all(a:cmd_name, a:modes, a:class, !0)
endfunction




function! advice#enable_pattern(pattern)  "{{{2
  throw 'NIY'
endfunction




function! advice#remove(cmd_name, modes, class, ad_name)  "{{{2
  for mode in s:each_char(a:modes)
    let advices = s:advices_of(a:cmd_name, mode, a:class)
    let i = s:index_of_advice(a:ad_name, advices)
    if i == -1
      echoerr 'No such advice'
    else
      call remove(advices, i)
    endif
  endfor
endfunction




function! advice#remove_all(cmd_name, modes, class)  "{{{2
  for mode in s:each_char(a:modes)
    let advices = s:advices_of(a:cmd_name, mode, a:class)
    call remove(advices, 0, -1)
  endfor
endfunction




function! advice#remove_pattern(pattern)  "{{{2
  throw 'NIY'
endfunction








" Misc.  "{{{1
function! advice#_dump()  "{{{2
  echo string(s:_)
endfunction




function! s:advices_of(cmd_name, mode, class)  "{{{2
  return s:cmd_entry_of(a:cmd_name, a:mode)[a:class]
endfunction




function! s:cmd_entry_of(cmd_name, mode)  "{{{2
  call s:ensure_cmd_entry(a:cmd_name, a:mode)
  return s:_[a:cmd_name][a:mode]
endfunction




function! s:define_interface_mapping_in(modes, cmd_name)  "{{{2
  for mode in s:each_char(a:modes)
    execute printf(
    \   '%snoremap <expr> <Plug>(adviced-%s-before)  <SID>do_adviced_command_before(%s, "%s")',
    \   mode,
    \   a:cmd_name,
    \   string(a:cmd_name),
    \   mode
    \ )
    execute printf(
    \   '%snoremap <expr> <Plug>(adviced-%s-original)  <SID>do_adviced_command_original(%s, "%s")',
    \   mode,
    \   a:cmd_name,
    \   string(a:cmd_name),
    \   mode
    \ )
    execute printf(
    \   '%smap <Plug>(adviced-%s)  <Plug>(adviced-%s-before)<Plug>(adviced-%s-original)<Plug>(adviced-%s-after)',
    \   mode,
    \   a:cmd_name,
    \   a:cmd_name,
    \   a:cmd_name,
    \   a:cmd_name
    \ )
  endfor
  for mode in s:each_char('nvoci')
    execute printf(
    \   '%snoremap <expr> <Plug>(adviced-%s-after)  <SID>do_adviced_command_after(%s)',
    \   mode,
    \   a:cmd_name,
    \   string(a:cmd_name)
    \ )
  endfor
endfunction




function! s:do_adviced_command_after(cmd_name)  "{{{2
  " After <Plug>(adviced-{cmd}-original), the mode may be chaned.  For
  " example, if <Plug>(adviced-{cmd}-original) is executed in Visual mode, the
  " following <Plug>(adviced-{cmd}-after) will be interpreted as a key mapping
  " defined in Normal mode.  So <Plug>(adviced-{cmd}-after) defined in Visual
  " mode will not be used.  This is a problem.
  "
  " To avoid the problem, we have to:
  " - define <Plug>(adviced-{cmd}-after) in all modes,
  " - memoize the mode of the previous <Plug>(adviced-{cmd}-original),
  " - and use the memoized mode here.
  " The mode is saved in s:previous_mode.
  if s:original_operator != ''
    " In the middle of operator execution - skip.
    return ''
  endif

  let keyseq = ''

  let after_advices = s:advices_of(a:cmd_name, s:previous_mode, 'after')
  for advice in after_advices
    if advice[s:I_ENABLED_P]
      let keyseq .= {advice[s:I_FUNC_NAME]}()
    endif
  endfor

  return keyseq
endfunction




function! s:do_adviced_command_before(cmd_name, mode)  "{{{2
  let keyseq = ''

  let before_advices = s:advices_of(a:cmd_name, a:mode, 'before')
  for advice in before_advices
    if advice[s:I_ENABLED_P]
      let keyseq .= {advice[s:I_FUNC_NAME]}()
    endif
  endfor

  return keyseq
endfunction




function! s:do_adviced_command_original(cmd_name, mode)  "{{{2
  let _ = s:cmd_entry_of(a:cmd_name, a:mode)
  let cmd_keyseq = _['cmd_keyseq']
  let need_remap_p = _['need_remap_p']
  let cmd_specs = _['cmd_specs']

  " CONT: cmd_specs
  " CONT: need_remap_p
  let s:previous_cmd_specs = cmd_specs
  if cmd_specs =~# '\<operator\>'
    set operatorfunc=advice#_operator
    let s:original_operator = cmd_keyseq
    let s:original_cmd_name = a:cmd_name
    let cmd_keyseq = 'g@'
  else
    let s:original_operator = ''
  endif

  let s:previous_mode = a:mode
  return cmd_keyseq
endfunction

function! advice#_operator(wise)
  normal! `[
  if a:wise ==# 'line'
    normal! V
  elseif a:wise ==# 'char'
    normal! v
  elseif a:wise ==# 'block'
    execute 'normal!' "\<C-v>"
  else
    throw 'Unexpected value of a:wise: ' . string(a:wise)
  endif
  normal! `]

  execute 'normal!' s:original_operator
  let s:original_operator = ''
  call s:do_adviced_command_after(s:original_cmd_name)
  return
endfunction




function! s:each_char(s)  "{{{2
  " for c in s:each_char('abc') ==> for c in ['a', 'b', 'c']
  let _ = split(a:s, '.\zs', !0)
  call remove(_, -1)
  return _
endfunction




function! s:ensure_cmd_entry(cmd_name, mode)  "{{{2
  if !has_key(s:_, a:cmd_name)
    let s:_[a:cmd_name] = {}
  endif

  if !has_key(s:_[a:cmd_name], a:mode)
    let s:_[a:cmd_name][a:mode] = {
    \     'after': [],
    \     'before': [],
    \     'cmd_keyseq': '',
    \     'cmd_specs': '',
    \     'need_remap_p': '',
    \   }
  endif
endfunction




function! s:index_of_advice(ad_name, advices)  "{{{2
  let i = 0
  for entry in a:advices
    let [ad_name, func_name, enabed_p] = entry
    if a:ad_name ==# ad_name
      return i
    endif
    let i += 1
  endfor
  return -1
endfunction




function! s:set_enabled_flag(cmd_name, modes, class, ad_name, value)  "{{{2
  for mode in s:each_char(a:modes)
    let advices = s:advices_of(a:cmd_name, mode, a:class)
    let i = s:index_of_advice(a:ad_name, advices)
    if i == -1
      echoerr 'No such advice'
    else
      let advices[i][s:I_ENABLED_P] = a:value
    endif
  endfor
endfunction




function! s:set_enabled_flag_all(cmd_name, modes, class, value)  "{{{2
  for mode in s:each_char(a:modes)
    let advices = s:advices_of(a:cmd_name, mode, a:class)
    for _ in advices
      let _[s:I_ENABLED_P] = !0
    endfor
  endfor
endfunction








" __END__  "{{{1
" vim: foldmethod=marker
