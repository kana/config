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

let s:CACHE_CONSTANT = 'constant'
let s:CACHE_GEL = 'gel'
let s:CACHE_PATTERN = 'pattern'
let s:CACHE_VOLATILE = 'volatile'

let s:VALID_CACHE_TYPES = [
\     s:CACHE_CONSTANT,
\     s:CACHE_GEL,
\     s:CACHE_PATTERN,
\     s:CACHE_VOLATILE,
\   ]


let s:DEFAULT_SPECIAL_CHARS = ''


let s:FALSE = 0
let s:TRUE = !s:FALSE


let s:INVALID_BUFNR = -2357
let s:INVALID_COLUMN = -20091017


let s:LNUM_STATUS = 1
let s:LNUM_PATTERN = 2


let s:KEYS_TO_START_COMPLETION = "\<C-x>\<C-o>\<C-p>"


if has('win16') || has('win32') || has('win64')  " on Microsoft Windows
  let s:KU_BUFFER_NAME = '[ku]'
else
  let s:KU_BUFFER_NAME = '*ku*'
endif


let s:NO_CACHE = ['NO CACHE']


let s:NULL_KIND = {
\ }


" Default values of optional attributes of source.  Note that:
" - Attributes in s:NULL_SOURCE are treated as optional ones,
"   so don't include required attributes in s:NULL_SOURCE.
" - Values of all attributes but 'kinds' are used as immutable ones.
" - The value of 'kinds' is just a placeholder and it's not used as is.
"   See also ku#define_source().
let s:NULL_SOURCE = {
\   'cache_type': s:CACHE_PATTERN,
\   'default_action_table': {},
\   'default_key_table': {},
\   'filters': [],
\   'kinds': [],
\   'matchers': [function('ku#matcher#default#matches_p')],
\   'on_action': function('ku#default_on_action'),
\   'sorters': [function('ku#sorter#default#sort')],
\   'special_chars': s:DEFAULT_SPECIAL_CHARS,
\   'valid_for_acc_p': function('ku#default_valid_for_acc_p'),
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

" Special characters to activate automatic component completion.
if !exists('g:ku_component_separators')
  let g:ku_component_separators = '/\:'
endif

" Contains the information of a ku session.
" See s:new_session() for the details of content.
let s:session = {}








" Interface  "{{{1
function! ku#available_kind_names()  "{{{2
  return sort(keys(s:available_kinds))
endfunction




function! ku#available_kind_p(kind_name)  "{{{2
  return has_key(s:available_kinds, a:kind_name)
endfunction




function! ku#available_kinds()  "{{{2
  return s:available_kinds
endfunction




function! ku#available_source_names()  "{{{2
  return sort(keys(s:available_sources))
endfunction




function! ku#available_source_p(source_name)  "{{{2
  return has_key(s:available_sources, a:source_name)
endfunction




function! ku#available_sources()  "{{{2
  return s:available_sources
endfunction




function! ku#custom_action(kind_name,action_name,func_or_kind2_name,...)  "{{{2
  if a:0 == 0
    let Func = a:func_or_kind2_name  " E704
    return s:custom_action_1(a:kind_name, a:action_name, Func)
  else
    let kind2_name = a:func_or_kind2_name
    let action2_name = a:1
    return s:custom_action_2(a:kind_name,a:action_name,kind2_name,action2_name)
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
  function! f.map(modes, lhs, rhs)
    for i in range(len(a:modes))
      execute 'silent!' a:modes[i].'map' '<buffer>' self.unique a:lhs  a:rhs
    endfor
  endfunction

  call f.map('ni', '<C-c>', '<Plug>(ku-quit-session)')
  call f.map('ni', '<C-c>', '<Plug>(ku-quit-session)')
  call f.map('ni', '<C-i>', '<Plug>(ku-choose-action)')
  call f.map('ni', '<C-m>', '<Plug>(ku-do-default-action)')
  call f.map('ni', '<Enter>', '<Plug>(ku-do-default-action)')
  call f.map('ni', '<Return>', '<Plug>(ku-do-default-action)')
  call f.map('ni', '<Tab>', '<Plug>(ku-choose-action)')

  call f.map('i', '<BS>', '<Plug>(ku-delete-backward-char)')
  call f.map('i', '<C-h>', '<Plug>(ku-delete-backward-char)')
  call f.map('i', '<C-w>', '<Plug>(ku-delete-backward-component)')

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
  \    && s:valid_key_p(new_source, 'cache_type', 'string')
  \    && s:valid_key_p(new_source, 'default_action_table', 'dictionary')
  \    && s:valid_key_p(new_source, 'default_key_table', 'dictionary')
  \    && s:valid_key_p(new_source, 'filters', 'list of functions')
  \    && s:valid_key_p(new_source, 'gather_candidates', 'function')
  \    && s:valid_key_p(new_source, 'kinds', 'list of strings')
  \    && s:valid_key_p(new_source, 'matchers', 'list of functions')
  \    && s:valid_key_p(new_source, 'name', 'string')
  \    && s:valid_key_p(new_source, 'on_action', 'function')
  \    && s:valid_key_p(new_source, 'sorters', 'list of functions')
  \    && s:valid_key_p(new_source, 'special_chars', 'string')
  \    && s:valid_key_p(new_source, 'valid_for_acc_p', 'function')
  \  )
    return s:FALSE
  endif

  if !(0 <= index(s:VALID_CACHE_TYPES, new_source.cache_type))
    echoerr 'Invalild definition:'
    \       'Key' string('cache_type') 'must be one of the following values'
    \       string(s:VALID_CACHE_TYPES)
    \       'but given value is' string(new_source.cache_type)
    return s:FALSE
  endif

  let new_kind_name = printf('source/%s', new_source.name)
  call ku#define_kind({
  \      'default_action_table': new_source.default_action_table,
  \      'default_key_table': new_source.default_key_table,
  \      'name': new_kind_name,
  \    })
  let new_source.kind_names = [new_kind_name] + new_source.kinds + ['common']
  unlet new_source.kinds

  let s:available_sources[new_source['name']] = new_source

  return s:TRUE
endfunction




function! ku#make_path(...)  "{{{2
  if a:0 == 1 && type(a:1) is type([])
    return join(a:1, ku#path_separator())
  else
    return join(a:000, ku#path_separator())
  endif
endfunction




function! ku#path_separator()  "{{{2
  return (exists('+shellslash') && !&shellslash) ? '\' : '/'
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
    " Ensure to allow backspacing after ACC, etc.  These features move the
    " cursor in Insert mode and such operation starts new Insert mode, so that
    " backspacing may not work after ACC, etc if the value of 'backspace' is
    " not properly set.
  set backspace=eol,indent,start
    " Ensure to show ins-completion-menu while automatic completion.
  set completeopt=menu,menuone

  " Reset the content of the ku buffer.
  " BUGS: To avoid unexpected behavior caused by automatic completion of the
  "       prompt, append the prompt and {initial-pattern} at this timing.
  "       Automatic completion is implemented by feedkeys() and starting
  "       Insert mode is also implemented by feedkeys().  These feedings must
  "       be done carefully.
  silent % delete _
  normal! o
  call setline(s:LNUM_STATUS, 'Sources: ' . join(source_names, ', '))
  call setline(s:LNUM_PATTERN, s:PROMPT . initial_pattern)
  execute 'normal!' s:LNUM_PATTERN . 'G'

  " Start Insert mode.
  " BUGS: :startinsert! may not work with append()/setline()/:put.
  "       If the typeahead buffer is empty, ther is no problem.
  "       Otherwise, :startinsert! behaves as '$i', not 'A',
  "       so it is inconvenient.
  " BUGS: It's not possible to emulate the same input by
  "       s:consume_typeahead_buffer() and feedkeys().  Because there is no
  "       way to get information on the source of an input character, for
  "       example, typed character, mapped character, etc.
  let typeahead_buffer = s:consume_typeahead_buffer()
  call feedkeys('A' . typeahead_buffer, 'n')

  return s:TRUE
endfunction




function! ku#take_action(action_name, ...)  "{{{2
  " Return TRUE for success.
  " Return FALSE for failure.

  let candidate = a:0 == 0 ? s:guess_candidate() : a:1

  if candidate is 0
    " Ignore.  Assumes that error message is already displayed by caller.
  elseif a:action_name ==# '*choose*'
    let action_name = s:choose_action(candidate)
  else
    let action_name = a:action_name
  endif

  " Close the ku window, because some kind of actions does something on the
  " current buffer/window and user expects that such actions do something on
  " the buffer/window which was the current one until the ku buffer became
  " active.
  call s:quit_session()

  if candidate is 0 || action_name is 0
    " In these cases, error messages are already noticed by other functions.
    return s:FALSE
  else
    return ku#_take_action(action_name, candidate) is 0
  endif
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




function! ku#default_on_action(candidate)  "{{{2
  return a:candidate
endfunction




function! ku#default_valid_for_acc_p(candidate)  "{{{2
  return s:TRUE  " Treat any candidate is valid for ACC.
endfunction




function! ku#omnifunc(findstart, base)  "{{{2
  if a:findstart
    " FIXME: For in-line completion.

    let s:session.last_lcandidates = []

    " To determine whether the content of the current line is inserted by
    " Vim's completion or not, return 0 to remove the prompt by completion.
    return 0
  else
    let pattern = s:remove_prompt(a:base)
    let s:session.last_lcandidates
    \   = s:lcandidates_from_pattern(pattern, s:session)
    return s:session.last_lcandidates
  endif
endfunction




function! ku#_take_action(action_name, candidate)  "{{{2
  " Return 0 for success.
  " Return a string (= error message) for failure.

  if a:action_name ==# 'nop'
    " Do nothing.
    "
    " 'nop' is a pseudo action and it cannot be overriden.
    " To express this property, bypass the usual process.
    return 0
  else
    let A = s:find_action(a:action_name, s:kinds_from_candidate(a:candidate))
    if A is 0
      let _ = printf('There is no such action: %s', string(a:action_name))
      echoerr _
      return _
    endif

    let processed_candidate = a:candidate.ku__source.on_action(a:candidate)
    let _ = A(processed_candidate)
    if _ isnot 0
      echohl ErrorMsg
      echomsg _
      echohl NONE
      return _
    endif

    return 0
  endif
endfunction




function! s:acc_text(line, lcandidates)  "{{{2
  " ACC = Automatic Component Completion

  " Note that a:line always ends with a special character which is one of
  " g:ku_component_separators,  because this function is always called by
  " typing a special character.  So there are at least 2 components in a:line.
  let SEP = a:line[-1:]

  let user_input_raw = s:remove_prompt(a:line)
  let line_components = split(user_input_raw, SEP, s:TRUE)

  " Find a candidate which has the same components but the last 2 ones of
  " line_components.  Because line_components[-1] is always empty and
  " line_components[-2] is almost imperfect name of a component.
  "
  " Example:
  "
  " (a) a:line ==# 'usr/share/m/',
  "     line_components ==# ['usr', 'share', 'm', '']
  "
  "     The 1st candidate prefixed with 'usr/share/' will be used for ACC.
  "     If 'usr/share/man/man1/' is found in this way,
  "     the completed text will be 'usr/share/man'.
  "
  " (b) a:line ==# 'u/'
  "     line_components ==# ['u', '']
  "
  "     The 1st candidate is alaways used for ACC.
  "     If 'usr/share/man/man1/' is found in this way,
  "     the completion text will be 'usr'.
  "
  " (c) a:line ==# 'm/'
  "     line_components ==# ['m', '']
  "
  "     The 1st candidate is alaways used for ACC.
  "     If 'usr/share/man/man1/' is found in this way,
  "     the completion text will be 'usr/share/man'.
  "     Because user seems to want to complete till the component which
  "     matches to 'm'.
  for candidate in a:lcandidates
    let candidate_components = split(candidate.word, SEP, s:TRUE)

    if len(line_components) < 2
      echoerr 'ku:e2: Assumption on ACC is failed: ' . string(line_components)
      continue
    elseif len(line_components) == 2
      " OK - the case (b) or (c)
    elseif len(line_components) - 2 <= len(candidate_components)
      for i in range(len(line_components) - 2)
        if line_components[i] != candidate_components[i]
          break
        endif
      endfor
      if line_components[i] != candidate_components[i]
        continue
      endif
      " OK - the case (a)
    else
      continue
    endif

    if !candidate.ku__source.valid_for_acc_p(candidate)
      continue
    endif

    " Find the index of the last component to be completed.
    "
    " For example, with candidate ==# 'usr/share/man/man1':
    "   If line_components ==# ['u', '']:
    "     c == 2 - 2
    "     i == 0
    "     t ==# 'usr/share/man/man1'
    "            ^
    "   If line_components ==# ['m', '']:
    "     c == 2 - 2
    "     i == 10
    "     t ==# 'usr/share/man/man1'
    "                      ^
    "   If line_components ==# ['usr', 'share', 'm', '']:
    "     c == 4 - 2
    "     i == 0
    "     t ==# 'man/man1'
    "            ^
      " Count of 'prefix' components in line_components.
      " 'prefix' components are all of line_components but the last two ones.
    let c = len(line_components) - 2
      " Pattern for the partially typed component = line_components[-2].
    let p = '\c' . s:make_skip_regexp(line_components[-2])
      " Tail of candidate.word without 'prefix' component in line_components.
    let t = join(candidate_components[(c):], SEP)

    let i = matchend(t, p)
    if i < 0  " Partially typed component doesn't match for this candidate.
      continue  " Try next one.
    endif
    let j = stridx(t, SEP, i)
    if 0 <= j
      " Several candidate_components are matched for ACC.
      let index_to_preceding_char_to_SEP = -(len(t) - j + 1)
      let index_to_the_tail_of_completed_text = index_to_preceding_char_to_SEP
      let result = candidate.word[:index_to_the_tail_of_completed_text]
    else
      " All of candidate_components are matched for ACC.
      let result = join(candidate_components, SEP)
    endif

    return result
  endfor

  return ''  " No proper candidate found
endfunction




function! s:cache_key(pattern)  "{{{2
  " We can't use empty string as a key of Dictionary because of E713.
  return '#' . a:pattern
endfunction




function! s:cache_lcandidates(session, lcandidates, args)  "{{{2
  " FIXME: NIY
  return
endfunction




function! s:choose_action(candidate)  "{{{2
  " Prompt      Candidate Source
  "    |          |         |
  "   _^_______  _^______  _^__
  "   Candidate: Makefile (file)
  "   ^C cancel      ^O open        ...
  "   What action?   ~~ ~~~~
  "   ~~~~~~~~~~~~    |   |
  "         |         |   |
  "      Message     Key  Action
  "
  " Here "Prompt" is highlighted with kuChoosePrompt,
  " "Candidate" is highlighted with kuChooseCandidate, and so forth.
  let KEY_TABLE
  \ = s:composite_key_table_from_kinds(s:kinds_from_candidate(a:candidate))
  call filter(KEY_TABLE, 'v:val !=# "nop"')
  let ACTION_TABLE
  \ = s:composite_action_table_from_kinds(s:kinds_from_candidate(a:candidate))

  " "Candidate: {candidate} ({source})"
  echohl NONE
  echo ''
  echohl kuChoosePrompt
  echon 'Candidate'
  echohl NONE
  echon ': '
  echohl kuChooseCandidate
  echon a:candidate.word
  echohl NONE
  echon ' ('
  echohl kuChooseSource
  echon a:candidate.ku__source.name
  echohl NONE
  echon ')'
  call s:list_key_bindings_sorted_by_action_name(KEY_TABLE)
  echohl kuChooseMessage
  echo 'What action? '
  echohl NONE

  " Take user input.
  let k = s:get_key()
  redraw  " clear the menu message lines to avoid hit-enter prompt.

  " Return the action bound to the key k.
  if has_key(KEY_TABLE, k)
    return KEY_TABLE[k]
  else
    " FIXME: loop to rechoose?
    echo 'The key' string(k) 'is not associated with any action'
    \    '-- nothing happened.'
    return 0
  endif
endfunction


function! s:list_key_bindings_sorted_by_action_name(key_table)  "{{{3
  " ACTIONS => {
  "   'keys': [[key_value, key_repr], ...],
  "   'label': label
  " }
  let ACTIONS = {}
  for [key, action] in items(a:key_table)
    if !has_key(ACTIONS, action)
      let ACTIONS[action] = {'keys': []}
    endif
    call add(ACTIONS[action].keys, [key, strtrans(key)])
  endfor
  for _ in values(ACTIONS)
    call sort(_.keys)
    let _.label = join(map(copy(_.keys), 'v:val[1]'), ' ')
  endfor
  silent! unlet _

  " key  action
  " ---  ------
  "  ^H  left  
  " -----------
  "   cell
  let ACTION_NAMES = sort(keys(ACTIONS), 's:compare_ignorecase')
  let MAX_ACTION_NAME_WIDTH = max(map(keys(ACTIONS), 'len(v:val)'))
  let MAX_LABEL_WIDTH = max(map(values(ACTIONS), 'len(v:val.label)'))
  let MAX_CELL_WIDTH = MAX_ACTION_NAME_WIDTH + 1 + MAX_LABEL_WIDTH
  let SPACER = '   '
  let COLUMNS = (&columns + len(SPACER) - 1) / (MAX_CELL_WIDTH + len(SPACER))
  let COLUMNS = max([COLUMNS, 1])
  let N = len(ACTIONS)
  let ROWS = N / COLUMNS + (N % COLUMNS != 0)

  for row in range(ROWS)
    for column in range(COLUMNS)
      let i = column * ROWS + row
      if !(i < N)
        continue
      endif

      echon column == 0 ? "\n" : SPACER

      echohl kuChooseAction
      let _ = ACTION_NAMES[i]
      echon _
      echohl NONE
      echon repeat(' ', MAX_ACTION_NAME_WIDTH - len(_))

      echohl kuChooseKey
      echon ' '
      let _ = ACTIONS[ACTION_NAMES[i]].label
      echon _
      echohl NONE
      echon repeat(' ', MAX_LABEL_WIDTH - len(_))
    endfor
  endfor

  return
endfunction




function! s:compare_ignorecase(x, y)  "{{{2
  " Comparing function for sort() to do consistently case-insensitive sort.
  "
  " sort(list, 1) does case-insensitive sort,
  " but its result may not be in a consistent order.
  " For example,
  " sort(['b', 'a', 'B', 'A'], 1) may return ['a', 'A', 'b', 'B'],
  " sort(['b', 'A', 'B', 'a'], 1) may return ['A', 'a', 'b', 'B'],
  " and so forth.
  "
  " With this function, sort() always return ['A', 'a', 'B', 'b'].
  return a:x <? a:y ? -1
  \    : (a:x >? a:y ? 1
  \    : (a:x <# a:y ? -1
  \    : (a:x ># a:y ? 1
  \    : 0)))
endfunction




function! s:complete_the_prompt()  "{{{2
  call setline('.', s:PROMPT . getline('.'))
  return
endfunction




function! s:composite_action_table_from_kinds(kinds)  "{{{2
  let composite_action_table = {}

  for action_table in s:list_action_tables(a:kinds)
    call extend(composite_action_table, action_table, 'keep')
  endfor

  return composite_action_table
endfunction




function! s:composite_key_table_from_kinds(kinds)  "{{{2
  let composite_key_table = {}

  for key_table in s:list_key_tables(a:kinds)
    call extend(composite_key_table, key_table, 'keep')
  endfor

  return composite_key_table
endfunction




function! s:consume_typeahead_buffer()  "{{{2
  let buffer = ''

  while s:TRUE
    let c = getchar(0)
    if c is 0
      break
    endif
    let buffer .= type(c) == type(0) ? nr2char(c) : c
  endwhile

  return buffer
endfunction




function! s:contains_the_prompt_p(s)  "{{{2
  return len(s:PROMPT) <= len(a:s) && a:s[:len(s:PROMPT) - 1] ==# s:PROMPT
endfunction




function! s:custom_action_1(kind_name, action_name, func)  "{{{2
  let custom_kind_action_table = s:custom_kind_action_table(a:kind_name)
  let Old_func = get(custom_kind_action_table, a:action_name, 0)  " E704

  let custom_kind_action_table[a:action_name] = a:func

  return Old_func
endfunction




function! s:custom_action_2(kind_name,action_name,kind2_name,action2_name)"{{{2
  let custom_kind_action_table = s:custom_kind_action_table(a:kind_name)
  let Old_func = get(custom_kind_action_table, a:action_name, 0)  " E704

  let default_kind2_action_table = s:default_kind_action_table(a:kind2_name)
  let Func2 = get(default_kind2_action_table, a:action2_name, 0)  " E704
  if Func2 is 0
    echoerr 'Action' string(a:action2_name) 'is not defined'
    \       'for' string(a:kind2_name).'.'
    return 0
  endif

  let custom_kind_action_table[a:action_name] = Func2

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
    return {}
  endif

  return s:available_kinds[a:kind_name].default_action_table
endfunction




function! s:default_kind_key_table(kind_name)  "{{{2
  if !has_key(s:available_kinds, a:kind_name)
    return {}
  endif

  return s:available_kinds[a:kind_name].default_key_table
endfunction




function! s:filter_lcandidates(lcandidates, args, source)  "{{{2
  let filtered_lcandidates = a:lcandidates

  for Filter in a:source.filters
    let filtered_lcandidates = Filter(filtered_lcandidates, a:args)
    unlet Filter  " To avoid E705.
  endfor

  return filtered_lcandidates
endfunction




function! s:find_action(action_name, kinds)  "{{{2
  for action_table in s:list_action_tables(a:kinds)
    if has_key(action_table, a:action_name)
      return action_table[a:action_name]
    endif
  endfor

  return 0
endfunction




function! s:get_cached_lcandidates(session, args)  "{{{2
  " FIXME: NIY
  return s:NO_CACHE
endfunction




function! s:get_char(...)  "{{{2
  " Rich version of getchar()

  let n = call('getchar', a:000)
  let _ = {}

  " Normalized result of getchar()
  let _.s = type(n) == type(0) ? nr2char(n) : n

  " Characters in s
  let _.cs = map(range(len(_.s)), '_.s[v:val]')

  " Bytes corresponding to cs
  let _.bs = map(copy(_.cs), 'char2nr(v:val)')

  return _
endfunction




function! s:get_key()  "{{{2
  " Alternative getchar() to get a logical key such as <F1> and <M-{x}>.

  let k1 = s:get_char()

  if k1.s ==# "\<Esc>"
    let k2 = s:get_char(0)
    return k1.s . k2.s
  else
    return k1.s
  endif
endfunction




function! s:guess_candidate()  "{{{2
  let current_pattern_raw = getline(s:LNUM_PATTERN)

  if current_pattern_raw !=# s:session.last_pattern_raw
    " current_pattern_raw seems to be inserted by Vim's completion,
    " so user seemed to select a candidate by Vim's completion.
    for _ in s:session.last_lcandidates
      if current_pattern_raw ==# _.word
        let candidate = _
        break
      endif
    endfor
    if !exists('candidate')
      echoerr 'ku:e1: No match found in s:session.last_lcandidates'
      echoerr '  current_pattern_raw' string(current_pattern_raw)
      echoerr '  s:session.last_pattern_raw'
      \          string(s:session.last_pattern_raw)
      echoerr '  s:session.last_lcandidates'
      \          string(s:session.last_lcandidates)
      let candidate = 0
    endif
  else
    " current_pattern_raw seems NOT to be inserted by Vim's completion, but ...
    if 0 < len(s:session.last_lcandidates)
      " There are 1 or more candidates -- user seems to want to take action on
      " the first one.
      let candidate = s:session.last_lcandidates[0]
    else
      " There is no candidate -- user seems to want to take action on
      " current_pattern_raw with fake sources.
      " FIXME: Specification of fake sources is not written yet.
      let candidate = 0
      echoerr 'There is no candidate to choose'
    endif
  endif

  return candidate
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
  nnoremap <buffer> <silent> <SID>(choose-action)
  \        :<C-u>call ku#take_action('*choose*')<Return>
  nnoremap <buffer> <silent> <SID>(do-default-action)
  \        :<C-u>call ku#take_action('default')<Return>
  nnoremap <buffer> <silent> <SID>(quit-session)
  \        :<C-u>call <SID>quit_session()<Return>
  inoremap <buffer> <expr> <SID>(accept-completion)
  \        pumvisible() ? '<C-y>' : ''
  inoremap <buffer> <expr> <SID>(cancel-completion)
  \        pumvisible() ? '<C-e>' : ''
  inoremap <buffer> <expr> <SID>(delete-backward-char)
  \        pumvisible() ? '<C-e><BS>' : '<BS>'
  inoremap <buffer> <expr> <SID>(delete-backward-component)
  \ (pumvisible() ? '<C-e>' : '')
  \ . <SID>keys_to_delete_backward_component()

  nnoremap <buffer> <script> <Plug>(ku-choose-action)
  \        <SID>(choose-action)
  nnoremap <buffer> <script> <Plug>(ku-do-default-action)
  \        <SID>(do-default-action)
  nnoremap <buffer> <script> <Plug>(ku-quit-session)
  \        <SID>(quit-session)

  inoremap <buffer> <script> <Plug>(ku-choose-action)
  \        <SID>(accept-completion)<Esc><SID>(choose-action)
  inoremap <buffer> <script> <Plug>(ku-do-default-action)
  \        <SID>(accept-completion)<Esc><SID>(do-default-action)
  inoremap <buffer> <script> <Plug>(ku-quit-session)
  \        <Esc><SID>(quit-session)

  inoremap <buffer> <script> <Plug>(ku-delete-backward-char)
  \        <SID>(delete-backward-char)
  inoremap <buffer> <script> <Plug>(ku-delete-backward-component)
  \        <SID>(delete-backward-component)
  " <C-n>/<C-p> ... Vim doesn't expand these keys in Insert mode completion.

  " User's initialization.
  setfiletype ku

  " Key mappings - user interface.
  if !(exists('#FileType#ku') || exists('b:did_ftplugin'))
    call ku#define_default_ui_key_mappings(s:TRUE)
  endif

  return
endfunction




function! s:keys_to_delete_backward_component()  "{{{2
  " In the following figures,
  " '|' means the cursor position, and
  " '^' means characters to delete:
  "
  "   >/usr/local/b|
  "               ^
  "
  "   >/usr/local/|
  "         ^^^^^^
  "
  "   >/usr/|
  "     ^^^^

  let line = getline('.')
  if len(line) < col('.')
    let i = matchend(line,
    \                ('\V\.\*\['
    \                 . escape(g:ku_component_separators, '\')
    \                 . ']\ze\.'))
    if 0 <= i
      return repeat("\<BS>", len(line) - i)
    else
      " No component separator - delete everything.
      return "\<C-u>"
    endif
  else
    " Don't consider cases that the cursor doesn't point the end of the
    " current line.
    return "\<C-w>"
  endif
endfunction




function! s:kinds_from_candidate(candidate)  "{{{2
  return s:kinds_from_kind_names(has_key(a:candidate, 'ku__kinds')
  \                              ? a:candidate.ku__kinds
  \                              : a:candidate.ku__source.kind_names)
endfunction




function! s:kinds_from_kind_names(kind_names)  "{{{2
  return map(copy(a:kind_names), 's:available_kinds[v:val]')
endfunction




function! s:ku_active_p()  "{{{2
  return bufexists(s:ku_bufnr) && bufwinnr(s:ku_bufnr) != -1
endfunction




function! s:lcandidates_from_pattern(pattern, session)  "{{{2
  let args = {'pattern': a:pattern}
  let all_lcandidates = []

  for source in a:session.sources
    let args.source = source

    let lcandidates = s:get_cached_lcandidates(a:session, args)
    if lcandidates is s:NO_CACHE
      let lcandidates = s:make_lcandidates_for_a_source(args)
      call s:cache_lcandidates(a:session, lcandidates, args)
    endif

    call extend(all_lcandidates, lcandidates)
  endfor

  return all_lcandidates
endfunction




function! s:list_action_tables(kinds)  "{{{2
  " NB: perf-dyn
  let l_action_tables = []

  for kind in a:kinds
    call add(l_action_tables, s:custom_kind_action_table(kind.name))
    call add(l_action_tables, s:default_kind_action_table(kind.name))
  endfor
  " source.kinds is normalized by ku#define_source(),
  " so that it's not necessary to check tables for implicit kinds.

  return l_action_tables
endfunction




function! s:list_key_tables(kinds)  "{{{2
  " NB: perf-dyn
  let l_key_tables = []

  for kind in a:kinds
    call add(l_key_tables, s:custom_kind_key_table(kind.name))
    call add(l_key_tables, s:default_kind_key_table(kind.name))
  endfor
  " source.kinds is normalized by ku#define_source(),
  " so that it's not necessary to check tables for implicit kinds.

  return l_key_tables
endfunction




function! s:make_lcandidates_for_a_source(args)  "{{{2
  let source = a:args.source

  let raw_lcandidates = s:raw_lcandidates(a:args)

  let matched_lcandidates
  \   = s:matched_lcandidates(raw_lcandidates, a:args, source)

  let filtered_lcandidates
  \   = s:filter_lcandidates(matched_lcandidates, a:args, source)

  let sorted_lcandidates
  \   = s:sort_lcandidates(filtered_lcandidates, a:args, source)

  let normalized_lcandidates
  \   = map(sorted_lcandidates, 's:normalize_candidate(v:val, source)')

  return normalized_lcandidates
endfunction




function! s:make_skip_regexp(s)  "{{{2
  " 'abc' ==> '\Va*b*c'
  " '\!/' ==> '\V\\*!*/'
  " Here '*' means '\.\{-}'
  let [xs, last] = [a:s[:-2], a:s[-1:]]
  return ('\V'
  \       . substitute(escape(xs, '\'), '\%(\\\\\|[^\\]\)\zs', '\\.\\{-}', 'g')
  \       . escape(last, '\'))
endfunction




function! s:matched_lcandidates(lcandidates, args, source)  "{{{2
  let matched_lcandidates = []

  for Matches_p in a:source.matchers
    call extend(matched_lcandidates,
    \           filter(copy(a:lcandidates), 'Matches_p(v:val, a:args)'))
    unlet Matches_p  " To avoid E705.
  endfor

  return matched_lcandidates
endfunction




function! s:new_session(source_names)  "{{{2
  " Assumption: All sources in a:source_names are available.
  let session = {}

    " Use list to ensure returning different value for each time.
  let session.id = [localtime()]
    " source-name => {pattern: cached-lcandidates}
  let session.cached_lcandidates = {}
  let session.inserted_by_acc_p = s:FALSE
  let session.last_column = s:INVALID_COLUMN
  let session.last_lcandidates = []
  let session.last_pattern_raw = ''
  let session.now_quitting_p = s:FALSE
  let session.original_backspace = &backspace
  let session.original_completeopt = &completeopt
  let session.original_curwinnr = winnr()
  let session.original_winrestcmd = winrestcmd()
  let session.sources = map(copy(a:source_names), 's:available_sources[v:val]')

  return session
endfunction




function! s:normalize_candidate(candidate, source)  "{{{2
  let a:candidate.dup = s:TRUE
  let a:candidate.ku__source = a:source
  let a:candidate.menu = a:source.name

  return a:candidate
endfunction




function! s:on_CursorMovedI()  "{{{2
  let cursor_column = col('.')
  let line = getline('.')

  " The order of the following conditions are important.
  if !s:contains_the_prompt_p(line)
    " Complete the prompt if it doesn't exist for some reasons.
    let keys = repeat("\<Right>", len(s:PROMPT))
    call s:complete_the_prompt()
  elseif cursor_column <= len(s:PROMPT)
    " Move the cursor out of the prompt if it is in the prompt.
    let keys = repeat("\<Right>", len(s:PROMPT) - cursor_column + 1)
  elseif len(line) < cursor_column && cursor_column != s:session.last_column
    " New character is inserted.  Let's complete automatically.
    if (!s:session.inserted_by_acc_p)
    \  && 0 <= stridx(g:ku_component_separators, line[-1:])
    \  && len(s:PROMPT) + 2 <= len(line)
      " (1) The last inserted character is not inserted by ACC.
      " (2) It is a special character in g:ku_component_separators.
      " (3) It seems not to be the 1st one in line.
      "
      " The (3) is necessary to input a special character as the 1st character
      " in line.  For example, without this condition, user cannot input the
      " 1st '/' of an absolute path like '/usr/local/bin' if '/' is a special
      " character.
      "
      " FIXME: Is s:session.last_lcandidates reliable?  If user types several
      "        characters quickely, Vim doesn't call 'omnifunc' for all but
      "        the last character.  So here we have to ensure that
      "        s:session.last_lcandidates contains reliable value,
      "        by calling 'omnifunc' appropriately.
      "
      " FIXME: But what should we do if user quickely types two or more
      "        special character?  It's hard to make
      "        s:session.last_lcandidates reliable, isn't it?
      "        At this moment, we simply ignore such case.
      let text = s:acc_text(line, s:session.last_lcandidates)
      let s:session.inserted_by_acc_p = s:TRUE
      if text != ''
        " The last special character must be inserted in this way to forcedly
        " show the completion menu.
          " FIXME: Should we update l:line for s:session.last_pattern_raw?
        call setline('.', text)
        let keys = "\<End>" . line[-1:]
        let s:session.inserted_by_acc_p = s:TRUE
      else
        let keys = s:KEYS_TO_START_COMPLETION
        let s:session.inserted_by_acc_p = s:FALSE
      endif
    else
      let keys = s:KEYS_TO_START_COMPLETION
      let s:session.inserted_by_acc_p = s:FALSE
    endif
  else
    let keys = ''
  endif

  let s:session.last_column = cursor_column
  let s:session.last_pattern_raw = line
  return keys
endfunction




function! s:on_InsertEnter()  "{{{2
  let s:session.inserted_by_acc_p = s:FALSE
  let s:session.last_column = s:INVALID_COLUMN
  let s:session.last_pattern_raw = ''
  return s:on_CursorMovedI()
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

    let &backspace = s:session.original_backspace
    let &completeopt = s:session.original_completeopt
    execute s:session.original_curwinnr 'wincmd w'
    execute s:session.original_winrestcmd
  let s:session.now_quitting_p = s:FALSE

  return s:TRUE
endfunction




function! s:raw_lcandidates(args)  "{{{2
  let source = a:args.source

  if source.cache_type ==# s:CACHE_CONSTANT
    " FIXME: NIY
    let raw_lcandidates = copy(source.gather_candidates(a:args))
  elseif source.cache_type ==# s:CACHE_GEL
    " FIXME: NIY
    let raw_lcandidates = copy(source.gather_candidates(a:args))
  elseif source.cache_type ==# s:CACHE_PATTERN
    " FIXME: NIY
    let raw_lcandidates = copy(source.gather_candidates(a:args))
  elseif source.cache_type ==# s:CACHE_VOLATILE
    let raw_lcandidates = copy(source.gather_candidates(a:args))
  else
    echoerr 'ku:e3: Invalid source.cache_type:'
    \       'Source' string(source.name)
    \       'with cache_type' string(source.cache_type)
    let raw_lcandidates = copy(source.gather_candidates(a:args))
  endif

  return raw_lcandidates
endfunction




function! s:remove_prompt(s)  "{{{2
  return s:contains_the_prompt_p(a:s) ? a:s[len(s:PROMPT):] : a:s
endfunction




function! s:sort_lcandidates(lcandidates, args, source)  "{{{2
  let sorted_lcandidates = a:lcandidates

  for Sort in a:source.sorters
    let sorted_lcandidates = Sort(sorted_lcandidates, a:args)
    unlet Sort  " To avoid E705.
  endfor

  return sorted_lcandidates
endfunction




function! s:valid_key_p(definition, key, type)  "{{{2
  let [basic_type, item_type]
  \ = matchlist(a:type, '^\(\S\+\)\%( of \(\S\+\)s\)\?$')[1:2]

  if !has_key(a:definition, a:key)
    echoerr 'Invalild definition: Without key' string(a:key)
    return s:FALSE
  endif

  let TYPES = {
  \     'boolean': type(0),
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
