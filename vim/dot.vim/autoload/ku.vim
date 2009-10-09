" ku - Interface for everything
" Version: 0.3.0
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
" Constants  "{{{1

let s:FALSE = 0
let s:TRUE = !s:FALSE


let s:INVALID_BUFNR = -2357


if has('win16') || has('win32') || has('win64')  " on Microsoft Windows
  let s:KU_BUFFER_NAME = '[ku]'
else
  let s:KU_BUFFER_NAME = '*ku*'
endif


let s:LNUM_STATUS = 1
let s:LNUM_INPUT = 2


let s:NULL_KIND = {
\ }


" Note that:
" - Values of all attributes but 'kinds' are used as immutable ones.
" - The value of 'kinds' is just a placeholder and it's not used as is.
let s:NULL_SOURCE = {
\   'default_action_table': {},
\   'default_key_table': {},
\   'filters': [],
\   'kinds': [],
\   'matchers': [function('ku#matcher#default#matches_p')],
\   'sorters': [function('ku#sorter#default#sort')],
\ }


let s:PROMPT = '>'








" Variables  "{{{1

" kind-name => kind-definition
let s:available_kinds = {}

" source-name => source-definition
let s:available_sources = {}

" kind-name => custom-action-table
" custom-action-table = action-table = {action-name => action-function}
let s:custom_kind_action_tables = {}

" kind-name => custom-key-table
" custom-key-table = key-table = {key => action-name}
let s:custom_kind_key_tables = {}

" buffer number of the ku buffer
let s:ku_bufnr = s:INVALID_BUFNR

" Contains the information of a ku session.
" See s:new_session() for the details of content.
let s:session = {}








" Interface  "{{{1
function! ku#custom_action(kind, name, func_or_kind2, ...)  "{{{2
  if a:0 == 0
    let Func = a:func_or_kind2  " E704
    return s:custom_action_1(a:kind, a:name, Func)
  else
    let kind2 = a:func_or_kind2
    let name2 = a:1
    return s:custom_action_2(a:kind, a:name, kind2, name2)
  endif
endfunction




function! ku#custom_key(kind_name, key, action_name)  "{{{2
  let custom_kind_key_table = s:custom_kind_key_table(a:kind_name)
  let old_action_name = get(custom_kind_key_table, a:key, 0)

  " FIXME: How about checking availability of a:action_name?
  let custom_kind_key_table[a:key] = a:action_name

  return old_action_name
endfunction




function! ku#define_default_ui_key_mappings(override_p)  "{{{2
  " Define key mappings for the current buffer.
  let f = {}
  let f.unique = a:override_p ? '' : '<unique>'
  function! f.map(lhs, rhs)
    execute 'silent!' 'nmap' '<buffer>' self.unique a:lhs  a:rhs
    execute 'silent!' 'imap' '<buffer>' self.unique a:lhs  a:rhs
  endfunction

  call f.map('<C-c>', '<Plug>(ku-quit-session)')
  call f.map('<C-c>', '<Plug>(ku-quit-session)')
  call f.map('<C-i>', '<Plug>(ku-choose-and-do-an-action)')
  call f.map('<C-m>', '<Plug>(ku-do-the-default-action)')
  call f.map('<Enter>', '<Plug>(ku-do-the-default-action)')
  call f.map('<Return>', '<Plug>(ku-do-the-default-action)')
  call f.map('<Tab>', '<Plug>(ku-choose-and-do-an-action)')

  return
endfunction




function! ku#define_kind(kind_definition)  "{{{2
  let new_kind = extend(copy(s:NULL_KIND), a:kind_definition, 'force')

  if !(s:TRUE
  \    && s:valid_key_p(new_kind, 'default_action_table', 'dictionary')
  \    && s:valid_key_p(new_kind, 'default_key_table', 'dictionary')
  \    && s:valid_key_p(new_kind, 'name', 'string')
  \  )
    return s:FALSE
  endif

  let s:available_kinds[new_kind['name']] = new_kind

  return s:TRUE
endfunction




function! ku#define_source(definition)  "{{{2
  let new_source = extend(copy(s:NULL_SOURCE), a:definition, 'force')

  if !(s:TRUE
  \    && s:valid_key_p(new_source, 'default_action_table', 'dictionary')
  \    && s:valid_key_p(new_source, 'default_key_table', 'dictionary')
  \    && s:valid_key_p(new_source, 'filters', 'list of functions')
  \    && s:valid_key_p(new_source, 'gather_candidates', 'function')
  \    && s:valid_key_p(new_source, 'kinds', 'list of strings')
  \    && s:valid_key_p(new_source, 'matchers', 'list of functions')
  \    && s:valid_key_p(new_source, 'name', 'string')
  \    && s:valid_key_p(new_source, 'sorters', 'list of functions')
  \  )
    return s:FALSE
  endif

  let new_source.kinds = ([printf('source/%s', new_source.name)]
  \                       + new_source.kinds)
  call ku#define_kind({
  \      'default_action_table': new_source.default_action_table,
  \      'default_key_table': new_source.default_key_table,
  \      'name': new_source.kinds[0],
  \    })

  let s:available_sources[new_source['name']] = new_source

  return s:TRUE
endfunction




function! ku#start(...)  "{{{2
  let source_names = 1<=a:0 && a:1 isnot 0 ? a:1 : ku#available_source_names()
  let initial_pattern = 2 <= a:0 ? a:2 : ''

  for source_name in source_names
    if !ku#available_source_p(source_name)
      echoerr 'Invalid source name:' string(source_name)
      return s:FALSE
    endif
  endfor

  if s:ku_active_p()
    echoerr 'Already active'
    return s:FALSE
  endif

  " Initialze session.
  let s:session = s:new_session(source_names)

  " Open or create the ku buffer.
  let v:errmsg = ''
  execute 'topleft' (bufexists(s:ku_bufnr) ? 'split' : 'new')
  if v:errmsg != ''
    return s:FALSE
  endif
  if bufexists(s:ku_bufnr)
    silent execute s:ku_bufnr 'buffer'
  else
    let s:ku_bufnr = bufnr('')
    call s:initialize_ku_buffer()
  endif
  2 wincmd _

  " Set some options.
  set completeopt=menu,menuone

  " Reset the content of the ku buffer.
  " BUGS: To avoid unexpected behavior caused by automatic completion of the
  "       prompt, append the prompt and {initial-pattern} at this timing.
  "       Automatic completion is implemented by feedkeys() and starting
  "       Insert mode is also implemented by feedkeys().  These feedings must
  "       be done carefully.
  silent % delete _
  call append(1, s:PROMPT . initial_pattern)
  normal! 2G

  " Start Insert mode.
  " BUGS: :startinsert! may not work with append()/setline()/:put.
  "       If the typeahead buffer is empty, ther is no problem.
  "       Otherwise, :startinsert! behaves as '$i', not 'A',
  "       so it is inconvenient.
  let typeahead_buffer = getchar(1) ? s:get_key() : ''
  call feedkeys('A' . typeahead_buffer, 'n')

  return s:TRUE
endfunction








" Misc.  "{{{1
" For tests  "{{{2
function! ku#_local_variables()
  return s:
endfunction


function! ku#_sid_prefix()
  return maparg('<SID>', 'n')
endfunction

nnoremap <SID>  <SID>




function! ku#available_source_p(source_name)  "{{{2
  return has_key(s:available_sources, a:source_name)
endfunction




function! ku#available_source_names()  "{{{2
  return sort(keys(s:available_sources))
endfunction




function! ku#available_sources()  "{{{2
  return s:available_sources
endfunction




function! ku#omnifunc(findstart, base)  "{{{2
  if a:findstart
    return getline('.')[:0] ==# s:PROMPT ? len(s:PROMPT) : 0
  else
    let pattern = a:base  " Assumes that a:base doesn't conntain the prompt.
    let lcandidates = s:candidates_from_pattern(pattern, s:session.sources)
    return lcandidates
  endif
endfunction




function! s:candidates_from_pattern(pattern, sources)  "{{{2
  " FIXME: Cache a result. / Use cache if available.

  let args = {'pattern': a:pattern}
  let all_candidates = []

  for source in a:sources
    let raw_candidates = copy(source.gather_candidates(args))

    let matched_candidates = s:matched_candidates(raw_candidates, args, source)

    let filtered_candidates
    \ = s:filter_candidates(matched_candidates, args, source)

    let sorted_candidates = s:sort_candidates(filtered_candidates,args,source)

    call extend(all_candidates, sorted_candidates)
  endfor

  return all_candidates
endfunction




function! s:custom_action_1(kind, name, func)  "{{{2
  let custom_kind_action_table = s:custom_kind_action_table(a:kind)
  let Old_func = get(custom_kind_action_table, a:name, 0)  " Captal for E704.

  let custom_kind_action_table[a:name] = a:func

  return Old_func
endfunction




function! s:custom_action_2(kind, name, kind2, name2)  "{{{2
  let custom_kind_action_table = s:custom_kind_action_table(a:kind)
  let Old_func = get(custom_kind_action_table, a:name, 0)  " Caps to avoid E704

  let default_kind2_action_table = s:default_kind_action_table(a:kind2)
  if default_kind2_action_table is 0
    echoerr 'Kind' string(a:kind2) 'is not defined.'
    return 0
  endif
  let Func2 = get(default_kind2_action_table, a:name2, 0)  " Caps to avoid E704
  if Func2 is 0
    echoerr 'Action' string(a:name2) 'is not defined for' string(a:kind2).'.'
    return 0
  endif

  let custom_kind_action_table[a:name] = Func2

  return Old_func
endfunction




function! s:custom_kind_action_table(kind_name)  "{{{2
  if !has_key(s:custom_kind_action_tables, a:kind_name)
    let s:custom_kind_action_tables[a:kind_name] = {}
  endif

  return s:custom_kind_action_tables[a:kind_name]
endfunction




function! s:custom_kind_key_table(kind_name)  "{{{2
  if !has_key(s:custom_kind_key_tables, a:kind_name)
    let s:custom_kind_key_tables[a:kind_name] = {}
  endif

  return s:custom_kind_key_tables[a:kind_name]
endfunction




function! s:default_kind_action_table(kind_name)  "{{{2
  if !has_key(s:available_kinds, a:kind_name)
    return 0
  endif

  return s:available_kinds[a:kind_name].default_action_table
endfunction




function! s:filter_candidates(lcandidates, args, source)  "{{{2
  let filtered_candidates = a:lcandidates

  for Filter in a:source.filters
    let filtered_candidates = Filter(filtered_candidates, a:args)
    unlet Filter  " To avoid E705.
  endfor

  return filtered_candidates
endfunction




function! s:find_action(action_name, kinds)  "{{{2
  let l_action_tables = []

  for kind in a:kinds
    call add(l_action_tables, s:custom_kind_action_table(kind.name))
    call add(l_action_tables, s:default_action_table(kind.name))
  endfor
  call add(l_action_tables, s:custom_kind_action_table('common'))
  call add(l_action_tables, s:default_kind_action_table('common'))

  for action_table in l_action_tables
    if has_key(action_table, a:action_name)
      return action_table[a:action_name]
    endif
  endfor

  return 0
endfunction




function! s:get_key()  "{{{2
  " Alternative getchar() to get a logical key such as <F1> and <M-{x}>.
  let k = ''

  let c = getchar()
  while s:TRUE
    let k .= type(c) == type(0) ? nr2char(c) : c
    let c = getchar(0)
    if c is 0
      break
    endif
  endwhile

  return k
endfunction




function! s:initialize_ku_buffer()  "{{{2
  " The current buffer is initialized.

  " Basic settings.
  setlocal bufhidden=hide
  setlocal buftype=nofile
  setlocal nobuflisted
  setlocal noswapfile
  setlocal omnifunc=ku#omnifunc
  silent file `=s:KU_BUFFER_NAME`

  " Autocommands.
  augroup plugin-ku
    autocmd InsertEnter <buffer>  call feedkeys(s:on_InsertEnter(), 'n')
    autocmd CursorMovedI <buffer>  call feedkeys(s:on_CursorMovedI(), 'n')
    autocmd BufLeave <buffer>  call s:quit_session()
    autocmd WinLeave <buffer>  call s:quit_session()
    " autocmd TabLeave <buffer>  call s:quit_session()  " not necessary
  augroup END

  " Key mappings - fundamentals.
  nnoremap <buffer> <silent> <SID>(choose-and-do-an-action)
  \        :<C-u>call <SID>take_action('*choose*')<Return>
  nnoremap <buffer> <silent> <SID>(do-the-default-action)
  \        :<C-u>call <SID>take_action('default')<Return>
  nnoremap <buffer> <silent> <SID>(quit-session)
  \        :<C-u>call <SID>quit_session()<Return>
  inoremap <buffer> <expr> <SID>(accept-completion)
  \        pumvisible() ? '<C-y>' : ''
  inoremap <buffer> <expr> <SID>(cancel-completion)
  \        pumvisible() ? '<C-e>' : ''

  nnoremap <buffer> <script> <Plug>(ku-choose-and-do-an-action)
  \        <SID>(choose-and-do-an-action)
  nnoremap <buffer> <script> <Plug>(ku-do-the-default-action)
  \        <SID>(do-the-default-action)
  nnoremap <buffer> <script> <Plug>(ku-quit-session)
  \        <SID>(quit-session)

  inoremap <buffer> <script> <Plug>(ku-choose-and-do-an-action)
  \        <SID>(accept-completion)<Esc><SID>(choose-and-do-an-action)
  inoremap <buffer> <script> <Plug>(ku-do-the-default-action)
  \        <SID>(accept-completion)<Esc><SID>(do-the-default-action)
  inoremap <buffer> <script> <Plug>(ku-quit-session)
  \        <Esc><SID>(quit-session)

  inoremap <buffer> <expr> <BS>  pumvisible() ? '<C-e><BS>' : '<BS>'
  imap <buffer> <C-h>  <BS>
  " <C-n>/<C-p> ... Vim doesn't expand these keys in Insert mode completion.

  " User's initialization.
  setfiletype ku

  " Key mappings - user interface.
  if !(exists('#FileType#ku') || exists('b:did_ftplugin'))
    call ku#define_default_ui_key_mappings(s:TRUE)
  endif

  return
endfunction




function! s:ku_active_p()  "{{{2
  return bufexists(s:ku_bufnr) && bufwinnr(s:ku_bufnr) != -1
endfunction




function! s:matched_candidates(lcandidates, args, source)  "{{{2
  let matched_candidates = []

  for Matches_p in a:source.matchers
    call extend(matched_candidates,
    \           filter(copy(a:lcandidates), 'Matches_p(v:val, a:args)'))
    unlet Matches_p  " To avoid E705.
  endfor

  return matched_candidates
endfunction




function! s:new_session(source_names)  "{{{2
  " Assumption: All sources in a:source_names are available.
  let session = {}

    " Use list to ensure returning different value for each time.
  let session.id = [localtime()]
  let session.last_completed_candidates = []
  let session.last_pattern = ''
  let session.now_quitting_p = s:FALSE
  let session.original_completeopt = &completeopt
  let session.original_curwinnr = winnr()
  let session.original_winrestcmd = winrestcmd()
  let session.sources = map(a:source_names, 's:available_sources[v:val]')

  return session
endfunction




function! s:on_CursorMovedI()  "{{{2
  " FIXME: NIY: Until automatic completion is implemented.
  return ''
endfunction




function! s:on_InsertEnter()  "{{{2
  " FIXME: NIY: Until automatic completion is implemented.
  return ''
endfunction




function! s:quit_session()  "{{{2
  " Assumption: The current buffer is the ku buffer.

  " We have to check s:session.now_quitting_p to avoid unnecessary
  " :close'ing, because s:quit_session() may be called recursively.
  if s:session.now_quitting_p
    return s:FALSE
  endif

  let s:session.now_quitting_p = s:TRUE
    close

    let &completeopt = s:session.original_completeopt
    execute s:session.original_curwinnr 'wincmd w'
    execute s:session.original_winrestcmd
  let s:session.now_quitting_p = s:FALSE

  return s:TRUE
endfunction




function! s:sort_candidates(lcandidates, args, source)  "{{{2
  let sorted_candidates = a:lcandidates

  for Sort in a:source.sorters
    let sorted_candidates = Sort(sorted_candidates, a:args)
    unlet Sort  " To avoid E705.
  endfor

  return sorted_candidates
endfunction




function! s:take_action(action_name)  "{{{2
  "" Preparation
  let current_pattern = getline(s:LNUM_INPUT)
  if current_pattern !=# s:session.last_pattern
    " current_pattern seems to be inserted by completion.
    for _ in s:session.last_completed_candidates
      if current_pattern ==# _.word
        let selected_candidate = _
        break
      endif
    endfor
    if !exists('selected_candidate')
      echoerr 'Internal error: No match found in the last completed candidates'
      echoerr 'current_pattern' string(current_pattern)
      echoerr 's:session.last_pattern' string(s:session.last_pattern)
      echoerr 's:session.last_completed_candidates'
      \       string(s:session.last_completed_candidates)
      throw 'ku-E1'
    endif
  else
    " current_pattern seems NOT to be inserted by completion, but ...
    if 0 < len(s:session.last_completed_candidates)
      " There are 1 or more candidates:
      " -- User seems to take an action on the 1st one.
      let selected_candidate = s:session.last_completed_candidates[0]
    else
      " There is no candidate:
      " -- User seems to take an action on current_pattern.
      " FIXME: NIY
      let nothing_to_do_p = s:TRUE
    endif
  endif

  if nothing_to_do_p
    " Ignore.
  elseif a:action_name ==# '*choose*'
    let action_name = s:choose_an_action(selected_candidate)
  else
    let action_name = a:action_name
  endif

  " Close the ku window, because some kind of actions does something on the
  " current buffer/window and user expects that such actions do something on
  " the buffer/window which was the current one until the ku buffer became
  " active.
  call s:quit_session()

  "" Do action.
  if nothing_to_do_p
    echo 'Nothing to do, because there is no candidate.'
    return s:FALLSE
  elseif action_name ==# 'nop'
    " Do nothing.
    "
    " 'nop' is a pseudo action and it cannot be overriden.
    " To express this property, bypass the usual process.
  else
    let Action_function = s:find_action(action_name, selected_candidate.kinds)
    if Action_function is 0
      echoerr 'There is no such action:' string(action_name)
      return s:FALSE
    else
    endif
    call Action_function(selected_candidate)
  endif
  return s:TRUE
endfunction




function! s:valid_key_p(definition, key, type)  "{{{2
  let [basic_type, item_type]
  \ = matchlist(a:type, '^\(\S\+\)\%( of \(\S\+\)s\)\?$')[1:2]

  if !has_key(a:definition, a:key)
    echoerr 'Invalild definition: Without key' string(a:key)
    return s:FALSE
  endif

  let TYPES = {
  \     'dictionary': type({}),
  \     'function': type(function('function')),
  \     'list': type([]),
  \     'number': type(0),
  \     'string': type(''),
  \   }
  if type(a:definition[a:key]) != get(TYPES, basic_type, -2009)
    echoerr 'Invalild definition: Key' string(a:key) 'must be' a:type
    \       'but given value is' string(a:definition[a:key])
    return s:FALSE
  endif

  if item_type != ''
    for Item in a:definition[a:key]
      if type(Item) != get(TYPES, item_type, -2009)
        echoerr 'Invalild definition: Key' string(a:key) 'must be' a:type
        \       'but given value is' string(a:definition[a:key])
        \       'and it contains' string(Item)
        return s:FALSE
      endif
    endfor
  endif

  return s:TRUE
endfunction








" __END__  "{{{1
" vim: foldmethod=marker
