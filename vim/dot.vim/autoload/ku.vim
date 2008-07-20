" ku - Support to do something
" Version: 0.1.0
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

" Misc.
let s:FALSE = 0
let s:TRUE = !s:FALSE


" The buffer number of ku.
let s:INVALID_BUFNR = -1
if exists('s:bufnr') && bufexists(s:bufnr)
  execute s:bufnr 'bwipeout'
endif
let s:bufnr = s:INVALID_BUFNR


" The name of the current source given to ku#start() or :Ku.
let s:INVALID_SOURCE = '*invalid*'
let s:current_source = s:INVALID_SOURCE


" All available sources.
if !exists('s:available_sources')
  let s:available_sources = []  " [source-name, ...]
endif


" For automatic completion.
let s:KEYS_TO_START_COMPLETION = "\<C-x>\<C-o>\<C-p>"
let s:PROMPT = '>'  " must be a single character.

let s:INVALID_COL = -3339
let s:last_col = s:INVALID_COL

let s:auto_directory_completion_done_p = s:FALSE


" To take action on the appropriate item.
let s:last_completed_items = []
let s:last_user_input = ''


" Values to be restored after the ku window is closed.
let s:completeopt = ''
let s:curwinnr = 0
let s:ignorecase = ''
let s:winrestcmd = ''


" User defined action tables and key tables for sources.
if !exists('s:custom_action_tables')
  let s:custom_action_tables = {}  " source -> action-table
endif
if !exists('s:custom_key_tables')
  let s:custom_key_tables = {}  " source -> key-table
endif


" Junk patterns.
if !exists('g:ku_common_junk_pattern')
  let g:ku_common_junk_pattern = ''
endif

" There may be g:ku_{source}_junk_pattern.








" Interface  "{{{1
function! ku#custom_action(source, action, function)  "{{{2
  if !has_key(s:custom_action_tables, a:source)
    let s:custom_action_tables[a:source] = {}
  endif

  let s:custom_action_tables[a:source][a:action] = a:function
endfunction




function! ku#custom_key(source, key, action)  "{{{2
  if !has_key(s:custom_key_tables, a:source)
    let s:custom_key_tables[a:source] = {}
  endif

  let s:custom_key_tables[a:source][a:key] = a:action
endfunction




function! ku#default_key_mappings(override_p)  "{{{2
  let _ = a:override_p ? '' : '<unique>'
  call s:ni_map(_, '<buffer> <C-c>', '<Plug>(ku-cancel)')
  call s:ni_map(_, '<buffer> <Return>', '<Plug>(ku-do-the-default-action)')
  call s:ni_map(_, '<buffer> <C-m>', '<Plug>(ku-do-the-default-action)')
  call s:ni_map(_, '<buffer> <Tab>', '<Plug>(ku-choose-an-action)')
  call s:ni_map(_, '<buffer> <C-i>', '<Plug>(ku-choose-an-action)')
  call s:ni_map(_, '<buffer> <C-j>', '<Plug>(ku-next-source)')
  call s:ni_map(_, '<buffer> <C-k>', '<Plug>(ku-previous-source)')
  return
endfunction




function! ku#start(source)  "{{{2
  if !s:available_source_p(a:source)
    echoerr 'ku: Not a valid source name:' string(a:source)
    return s:FALSE
  endif
  let s:current_source = a:source

  " Save some values to restore the original state.
  let s:completeopt = &completeopt
  let s:ignorecase = &ignorecase
  let s:curwinnr = winnr()
  let s:winrestcmd = winrestcmd()

  " Open or create the ku buffer.
  let v:errmsg = ''
  if bufexists(s:bufnr)
    topleft split
    if v:errmsg != ''
      return s:FALSE
    endif
    silent execute s:bufnr 'buffer'
  else
    topleft new
    if v:errmsg != ''
      return s:FALSE
    endif
    let s:bufnr = bufnr('')
    call s:initialize_ku_buffer()
  endif
  2 wincmd _
  call ku#{s:current_source}#on_start_session()

  " Set some options
  set completeopt=menu,menuone
  set ignorecase

  " Reset the content of the ku buffer
  silent % delete _
  call append(1, '')
  normal! 2G

  " Start Insert mode.
  call feedkeys('i', 'n')

  return s:TRUE
endfunction








" Core  "{{{1
function! ku#_omnifunc(findstart, base)  "{{{2
  " FIXME: caching
  " items = a list of items
  " item = a dictionary as described in :help complete-items.
  "        '^_ku_.*$' - additional keys used by ku.
  "        '^_{source}_.*$' - additional keys used by {source}.
  if a:findstart
    let s:last_completed_items = []
    return 0
  else
    let pattern = (s:contains_the_prompt_p(a:base)
      \            ? a:base[len(s:PROMPT):]
      \            : a:base)
    let asis_regexp = s:make_asis_regexp(pattern)
    let skip_regexp = s:make_skip_regexp(pattern)

    let s:last_completed_items
    \   = copy(ku#{s:current_source}#gather_items(pattern))
    for _ in s:last_completed_items
      let _['_ku_completed_p'] = s:TRUE
      let _['_ku_source'] = s:current_source
      let _['_ku_sort_priority']
        \ = [
        \     _.word =~# g:ku_common_junk_pattern,
        \     (exists('g:ku_{s:current_source}_junk_pattern')
        \      && _.word =~# g:ku_{s:current_source}_junk_pattern),
        \     s:match(_.word, '\C' . asis_regexp),
        \     s:matchend(_.word, '\C' . asis_regexp),
        \     s:match(_.word, '\c' . asis_regexp),
        \     s:matchend(_.word, '\c' . asis_regexp),
        \     match(_.word, '\C' . skip_regexp),
        \     matchend(_.word, '\C' . skip_regexp),
        \     match(_.word, '\c' . skip_regexp),
        \     matchend(_.word, '\c' . skip_regexp),
        \     _.word,
        \   ]
    endfor

      " Remove items not matched to case-insensitive skip_regexp, because user
      " doesn't want such items to be completed.
      " BUGS: Don't forget to update the index for the matched position of
      "       case-insensitive skip_regexp.
    call filter(s:last_completed_items, '0 <= v:val._ku_sort_priority[-3]')
    call sort(s:last_completed_items, function('s:_compare_items'))
    return s:last_completed_items
  endif
endfunction


function! s:_compare_items(a, b)
  return s:_compare_lists(a:a._ku_sort_priority, a:b._ku_sort_priority)
endfunction

function! s:_compare_lists(a, b)
  " Assumption: len(a:a) == len(a:b)
  for i in range(len(a:a))
    if a:a[i] < a:b[i]
      return -1
    elseif a:a[i] > a:b[i]
      return 1
    endif
  endfor
  return 0
endfunction




function! s:do(choose_p)  "{{{2
  let current_user_input = getline(2)
  if current_user_input !=# s:last_user_input
    " current_user_input seems to be inserted by completion.
    for _ in s:last_completed_items
      if current_user_input ==# _.word
        let item = _
        break
      endif
    endfor
    if !exists('item')
      echomsg 'Internal error: No match found in s:last_completed_items'
      echomsg 'current_user_input' string(current_user_input)
      echomsg 's:last_user_input' string(s:last_user_input)
      throw 'ku:e1'
    endif
  else
    " current_user_input seems NOT to be inserted by completion, but ...
    if 0 < len(s:last_completed_items)
      " there are 1 or more items -- user seems to take action on the 1st one.
      let item = s:last_completed_items[0]
    else
      " there is no item -- user seems to take action on current_user_input.
      if s:contains_the_prompt_p(current_user_input)
        " remove the prompt.
        let current_user_input = current_user_input[len(s:PROMPT):]
      endif
      let item = {'word': current_user_input, '_ku_completed_p': s:FALSE}
    endif
  endif

  if a:choose_p
    let action = s:choose_action()
  else
    let action = 'default'
  endif

  " To avoid doing some actions on this buffer and/or this window, close the
  " ku window.
  call s:end()

  call s:do_action(action, item)
  return
endfunction




function! s:end()  "{{{2
  if s:_end_locked_p
    return s:FALSE
  endif
  let s:_end_locked_p = s:TRUE

  call ku#{s:current_source}#on_end_session()
  close

  let &completeopt = s:completeopt
  let &ignorecase = s:ignorecase
  execute s:curwinnr 'wincmd w'
  execute s:winrestcmd

  let s:_end_locked_p = s:FALSE
  return s:TRUE
endfunction
let s:_end_locked_p = s:FALSE




function! s:initialize_ku_buffer()  "{{{2
  " Basic settings.
  setlocal bufhidden=hide
  setlocal buftype=nofile
  setlocal nobuflisted
  setlocal noswapfile
  setlocal omnifunc=ku#_omnifunc
  silent file `='*ku*'`

  " Autocommands.
  autocmd InsertEnter <buffer>  call feedkeys(s:on_InsertEnter(), 'n')
  autocmd CursorMovedI <buffer>  call feedkeys(s:on_CursorMovedI(), 'n')
  autocmd BufLeave <buffer>  call s:end()
  autocmd WinLeave <buffer>  call s:end()
  " autocmd TabLeave <buffer>  call s:end()  " not necessary

  " Key mappings.
  nnoremap <buffer> <silent> <Plug>(ku-cancel)
  \        :<C-u>call <SID>end()<Return>
  nnoremap <buffer> <silent> <Plug>(ku-do-the-default-action)
  \        :<C-u>call <SID>do(0)<Return>
  nnoremap <buffer> <silent> <Plug>(ku-choose-an-action)
  \        :<C-u>call <SID>do(1)<Return>
  nnoremap <buffer> <silent> <Plug>(ku-next-source)
  \        :<C-u>call <SID>switch_current_source(1)<Return>
  nnoremap <buffer> <silent> <Plug>(ku-previous-source)
  \        :<C-u>call <SID>switch_current_source(-1)<Return>

  nnoremap <buffer> <Plug>(ku-%-enter-insert-mode)  a
  inoremap <buffer> <Plug>(ku-%-leave-insert-mode)  <Esc>
  inoremap <buffer> <expr> <Plug>(ku-%-accept-completion)
  \        pumvisible() ? '<C-y>' : ''
  inoremap <buffer> <expr> <Plug>(ku-%-cancel-completion)
  \        pumvisible() ? '<C-e>' : ''

  imap <buffer> <silent> <Plug>(ku-cancel)
  \    <Plug>(ku-%-leave-insert-mode)
  \<Plug>(ku-cancel)
  imap <buffer> <silent> <Plug>(ku-do-the-default-action)
  \    <Plug>(ku-%-accept-completion)
  \<Plug>(ku-%-leave-insert-mode)
  \<Plug>(ku-do-the-default-action)
  imap <buffer> <silent> <Plug>(ku-choose-an-action)
  \    <Plug>(ku-%-accept-completion)
  \<Plug>(ku-%-leave-insert-mode)
  \<Plug>(ku-choose-an-action)
  imap <buffer> <silent> <Plug>(ku-next-source)
  \    <Plug>(ku-%-cancel-completion)
  \<Plug>(ku-%-leave-insert-mode)
  \<Plug>(ku-next-source)
  \<Plug>(ku-%-enter-insert-mode)
  imap <buffer> <silent> <Plug>(ku-previous-source)
  \    <Plug>(ku-%-cancel-completion)
  \<Plug>(ku-%-leave-insert-mode)
  \<Plug>(ku-previous-source)
  \<Plug>(ku-%-enter-insert-mode)

  inoremap <buffer> <expr> <BS>  pumvisible() ? '<C-e><BS>' : '<BS>'
  imap <buffer> <C-h>  <BS>
  " <C-n>/<C-p> ... Vim doesn't expand these keys in Insert mode completion.

  " User's initialization.
  silent doautocmd User plugin-ku-buffer-initialize
  if !exists('#User#plugin-ku-buffer-initialize')
    call ku#default_key_mappings(s:FALSE)
  endif

  return
endfunction




function! s:on_CursorMovedI()  "{{{2
  " Calling setline() has a side effect to the cursor.  If the cursor beyond
  " the end of line (i.e. getline('.') < col('.')), the cursor will be move at
  " the last character of the current line after calling setline().
  let c0 = col('.')
  call setline(1, '')
  let c1 = col('.')
  call setline(1, 'Source: ' . s:current_source)

  " The order of these conditions are important.
  let line = getline('.')
  if !s:contains_the_prompt_p(line)
    " Complete the prompt if it doesn't exist for some reasons.
    let keys = repeat("\<Right>", len(s:PROMPT))
    call s:complete_the_prompt()
  elseif col('.') <= len(s:PROMPT)
    " Move the cursor out of the prompt if it is in the prompt.
    let keys = repeat("\<Right>", len(s:PROMPT) - col('.') + 1)
  elseif len(line) < col('.') && col('.') != s:last_col
    " New character is inserted.  Let's complete automatically.
    " FIXME: path separator assumption
    if (!s:auto_directory_completion_done_p)
    \  && line[-1:] == '/'
    \  && len(s:PROMPT) + 2 <= len(line)
      " The last inserted character is not inserted by automatic directory
      " completion, it is a '/', and it seems not to be the 1st '/' of the
      " root directory.
      let text = s:text_by_auto_directory_completion(line)
      if text != ''
        call setline('.', text)
          " The last slash must be inserted in this way to forcedly show the
          " completion menu.
        let keys = "\<End>/"
        let s:auto_directory_completion_done_p = s:TRUE
      else
        let keys = s:KEYS_TO_START_COMPLETION
        let s:auto_directory_completion_done_p = s:FALSE
      endif
    else
      let keys = s:KEYS_TO_START_COMPLETION
      let s:auto_directory_completion_done_p = s:FALSE
    endif
  else
    let keys = ''
  endif

  let s:last_col = col('.')
  let s:last_user_input = line
  return (c0 != c1 ? "\<Right>" : '') . keys
endfunction




function! s:on_InsertEnter()  "{{{2
  let s:last_col = s:INVALID_COL
  let s:last_user_input = ''
  let s:auto_directory_completion_done_p = s:FALSE
  return s:on_CursorMovedI()
endfunction




function! s:switch_current_source(shift_delta)  "{{{2
  let o = index(s:available_sources, s:current_source)
  let n = (o + a:shift_delta) % len(s:available_sources)
  if n < 0
    let n += s:available_source_p
  endif

  if o == n
    return s:FALSE
  endif

  call ku#{s:available_sources[o]}#on_end_session()
  call ku#{s:available_sources[n]}#on_start_session()

  let s:current_source = s:available_sources[n]
  return s:TRUE
endfunction








" Misc.  "{{{1
" Automatic completion  "{{{2
function! s:complete_the_prompt()  "{{{3
  call setline('.', s:PROMPT . getline('.'))
  return
endfunction


function! s:contains_the_prompt_p(s)  "{{{3
  return len(s:PROMPT) <= len(a:s) && a:s[:len(s:PROMPT) - 1] ==# s:PROMPT
endfunction


function! s:text_by_auto_directory_completion(line)  "{{{3
  " Note that a:line always ends with '/', because this function is always
  " called by typing '/'.  So there are at least 2 components in a:line.
  " FIXME: path separator assumption.
  let line_components = split(a:line[len(s:PROMPT):], '/', s:TRUE)

  " Find an item which has the same components but the last 2 ones of
  " line_components.  Because line_components[-1] is always empty and
  " line_components[-2] is almost imperfect directory name, so the
  " 2 components are useless and must not be used for this search.
  " But line_components[-2] is already used to filter the completed items.
  "
  " Example:
  " (a) If a:line ==# 'usr/share/m/',
  "     line_components == ['usr', 'share', 'm', ''].
  "     So the 1st item which is prefixed with 'usr/share/' is selected and it
  "     is used for this automatic directory completion.  If
  "     'usr/share/man/man1/' is found in this way, the completed text will be
  "     'usr/share/man'.
  " (b) If a:line ==# 'u/',
  "     line_components == ['u', ''].
  "     So the 1st item is alaways selected for this automatic directory
  "     completion.  If 'usr/share/man/man1/' is found in this way, the
  "     completion text will be 'usr'.
  for item in ku#_omnifunc(s:FALSE, a:line[:-2])  " without the last '/'
    let item_components = split(item.word, '/', s:TRUE)

    if len(line_components) < 2
      echoerr 'Assumption is failed in auto directory completion'
      throw 'ku:e2'
    elseif len(line_components) == 2
      " OK - the case (b)
    elseif len(line_components) - 2 <= len(item_components)
      for i in range(len(line_components) - 2)
        if line_components[i] != item_components[i]
          break
        endif
      endfor
      if line_components[i] != item_components[i]
        continue
      endif
      " OK - the case (a)
    else
      continue
    endif

    return join(item_components[:len(line_components) - 2], '/')
  endfor
  return ''
endfunction




" Action-related stuffs  "{{{2
function! s:choose_action()  "{{{3
  let key_table = {}
  for _ in [s:default_key_table(),
  \         s:custom_key_table('common'),
  \         ku#{s:current_source}#key_table(),
  \         s:custom_key_table(s:current_source)]
    call extend(key_table, _)
  endfor

  " FIXME: listing like ls
  let FORMAT = '%-16s  %s'
  echo printf(FORMAT, 'Key', 'Action')
  for key in sort(keys(key_table))
    if key_table[key] !=# 'nop'  " don't list a diabled key.
      echo printf(FORMAT, strtrans(key), key_table[key])
    endif
  endfor
  echo 'What action?'

  let c = nr2char(getchar())  " FIXME: support <Esc>{x} typed by <M-{x}>
  redraw  " clear the menu message lines to avoid hit-enter prompt.

  if has_key(key_table, c) && key_table[c] !=# 'nop'
    return key_table[c]
  else
    " FIXME: loop to rechoose?
    echo 'The key' string(c) 'is not associated with any action'
    \    '-- nothing happened.'
    return 'nop'
  endif
endfunction


function! s:do_action(action, item)  "{{{3
  call function(s:get_action_function(a:action))(a:item)
  return s:TRUE
endfunction


function! s:get_action_function(action)  "{{{3
  for _ in [s:custom_action_table(s:current_source),
  \         ku#{s:current_source}#action_table(),
  \         s:custom_action_table('common'),
  \         s:default_action_table()]
    if has_key(_, a:action)
      return _[a:action]
    endif
  endfor

  echoerr printf('No such action for source %s: %s',
  \              string(s:current_source),
  \              string(a:action))
  return s:get_action_function('nop')
endfunction




" Default actions  "{{{2
function! s:_default_action_cd(item)  "{{{3
  cd `=fnamemodify(a:item.word, ':p:h')`
  return
endfunction


function! s:_default_action_ex(item)  "{{{3
  " Support to execute an Ex command on a:item.word (as path).
  call feedkeys(printf(": %s\<C-b>", fnameescape(a:item.word)), 'n')
  return
endfunction


function! s:_default_action_lcd(item)  "{{{3
  lcd `=fnamemodify(a:item.word, ':p:h')`
  return
endfunction


function! s:_default_action_nop(item)  "{{{3
  " NOP
  return
endfunction




" Action table  "{{{2
function! s:custom_action_table(source)  "{{{3
  return get(s:custom_action_tables, a:source, {})
endfunction


function! s:default_action_table()  "{{{3
  return {
  \   'cd': 's:_default_action_cd',
  \   'ex': 's:_default_action_ex',
  \   'lcd': 's:_default_action_lcd',
  \   'nop': 's:_default_action_nop',
  \ }
endfunction




" Key table  "{{{2
function! s:custom_key_table(source)  "{{{3
  return get(s:custom_key_tables, a:source, {})
endfunction


function! s:default_key_table()  "{{{3
  return {
  \   "\<Return>": 'default',
  \   '/': 'cd',
  \   ':': 'ex',
  \   ';': 'ex',
  \   '?': 'lcd',
  \ }
endfunction




function! s:available_source_p(source)  "{{{2
  if len(s:available_sources) == 0
    let s:available_sources = sort(map(
    \     split(globpath(&runtimepath, 'autoload/ku/*.vim'), "\n"),
    \     'substitute(v:val, ''^.*/\([^/]*\)\.vim$'', ''\1'', '''')'
    \   ))
  endif

  return 0 <= index(s:available_sources, a:source)
endfunction




function! s:make_asis_regexp(s)  "{{{2
  return '\V' . escape(a:s, '\')
endfunction




function! s:make_skip_regexp(s)  "{{{2
  " FIXME: path separator assumption
  let p_asis = s:make_asis_regexp(substitute(a:s, '/', ' / ', 'g'))
  return substitute(p_asis, '\s\+', '\\.\\{-}', 'g')
endfunction




function! s:match(s, pattern)  "{{{2
  " Like match(), but return a very big number (POINT_AT_INFINITY) to express
  " that a:s is not matched to a:pattern.  This returning value is very useful
  " to sort with matched positions.
  let POINT_AT_INFINITY = 2147483647  " FIXME: valid value.
  let i = match(a:s, a:pattern)
  return 0 <= i ? i : POINT_AT_INFINITY
endfunction




function! s:matchend(s, pattern)  "{{{2
  " Like s:match(), but the meaning of returning value is same as matchend().
  let POINT_AT_INFINITY = 2147483647  " FIXME: valid value.
  let i = matchend(a:s, a:pattern)
  return 0 <= i ? i : POINT_AT_INFINITY
endfunction




function! s:ni_map(...)  "{{{2
  for _ in ['n', 'i']
    silent! execute _.'map' join(a:000)
  endfor
  return
endfunction








" __END__  "{{{1
" vim: foldmethod=marker
