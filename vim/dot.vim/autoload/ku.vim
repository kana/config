" ku - Support to do something
" Version: 0.0.0
" Copyright: Copyright (C) 2008 kana <http://nicht.s8.xrea.com/>
" License: MIT license (see <http://www.opensource.org/licenses/mit-license>)
" $Id$  "{{{1
" FIXME: Translate the following FIXMEs in English.
"
" FIXME: ドキュメント更新。
"
" FIXME: s:do(): どのitemにもマッチしない入力であってもactionに渡す。
"   例えば今の状況ではtype fileで新規ファイルを開けないので、
"   このような処理は必要である。
"
"   ただし、これをするならばどのtypeのactionを使うかが問題。
"   s:preferred_typeが定義されている場合に限定か。
"
" FIXME: より「賢い」ソーティング (優先順位: 低)
"   - パスっぽいものは最後のコンポーネントを重視するのはどうか?
"   - type buffer: フルパスと相対パスのどちらを使うべきか?
"   - パスっぽいものは相対パス優先の方がいい?
"     '/'の値は若い以上、今のままでは自動的に相対パスが軽視されることになる。
"
" FIXME: strtrans()の代替作成。<Left>等を正しく変換するように。
"
" FIXME: type file - stub.
" FIXME: type directory - NIY.
"
" FIXME: 各種比較でのcase sensitivityの統一・見直し。
"
" FIXME: 実装方法の選択
"   (A) ins-completion-menuを利用(Omni completion)
"       + Insert modeの基本的な操作体系を利用可能。
"       - 一部キーをmappingできないため、細かい情報を取れない。
"         * 特に問題な点は
"           「どの項目が選択されているか」と
"           「選択状況が変化したか」を
"           知ることができないこと。
"           * このために
"             「actionを<Tab>で選んで実行」というI/Fや、
"             「利用可能なactionを適宜表示」ということができない。
"       - CursorMovedIのフックを利用しての検出のため、カオス過ぎる。
"         特にs:PROMPTはひどい発明。
"
"   (B) getchar()で自力管理
"       + キー入力を全て把握できるため、ins-completion-menuの問題はない。
"       - キー入力を自力で管理する以上、
"         基本的な操作体系も含めて実装しなければならない。
"       * itemsの一覧表示はins-completion-menu以外の方法が取れる。
"         例えばtype毎に並べたitemsのうち、
"         preferred以外はfoldする等。
"
"   buffuzzy/zapitの経験から(A)を利用していたが、
"   itemsの表示はバッファを使ってどうとでもできるので、
"   (B)も一考の価値はある。
"
"   ただ、(A)でもある程度の問題は解決してしまったため、一先ずは(A)で行く。
"   (B)には(B)で魅力的なメリットがあるので、落ち着いたらそちらも考える。
"
" Variables and Constants  "{{{1

let s:FALSE = 0
let s:TRUE = !s:FALSE

let s:TYPE_NUMBER = type(0)
let s:TYPE_STRING = type('')
let s:TYPE_FUNCTION = type(function('function'))
let s:TYPE_LIST = type([])
let s:TYPE_DICTONARY = type({})


" Flag which indicates whether the ku window is opened with bang (:Ku!).
" Possible values are '' or '!'.
let s:bang = ''

" The buffer number of the ku buffer.
let s:INVALID_BUFNR = -3339
  " to be reloadable (for debugging)
if exists('s:bufnr') && s:bufnr != s:INVALID_BUFNR
  execute s:bufnr 'bwipeout'
endif
let s:bufnr = s:INVALID_BUFNR

" Preferred type of items.
let s:INVALID_TYPE = '*all*'
let s:preferred_type = s:INVALID_TYPE

" Key sequence to start (omni) completion
" without auto-selecting the first match.
let s:KEYS_TO_START_COMPLETION = "\<C-x>\<C-o>\<C-p>"

" The last column of the cursor.
let s:INVALID_COL = -3338
let s:last_col = s:INVALID_COL

" Items gathered by the last completion.
let s:last_items = []

" All available types.
if !exists('s:types')
  let s:types = {}
endif

" The prompt for user input.
" This is necessary to publish CursorMovedI event for each typing.
" Note that the length should be 1 to avoid some problems.
let s:PROMPT = '>'

" Misc. values to restore the original state.
let s:completeopt = ''
let s:ignorecase = ''
let s:winrestcmd = ''

" Flag for debugging.
if !exists('g:ku_debug_p')
  let g:ku_debug_p = s:FALSE
endif

" Flag to use the type of items for sorting without s:preferred_type.
if !exists('g:ku_sort_by_type_first_p')
  let g:ku_sort_by_type_first_p = s:TRUE
endif








" Interfaces  "{{{1
function! ku#start(bang, type) abort  "{{{2
  " Save/Set up several values.
  let s:bang = a:bang
  let s:preferred_type = s:valid_type_name_p(a:type) ? a:type : s:INVALID_TYPE

  let s:completeopt = &completeopt
  set completeopt+=menuone
  let s:ignorecase = &ignorecase
  set ignorecase
  let s:winrestcmd = winrestcmd()

  " Open a new window and switch to the ku buffer.
  if !s:ku_buffer_exists_p()
    topleft new
    call s:initialize_ku_buffer()
    let s:bufnr = bufnr('')
  else
    execute 'topleft' s:bufnr 'sbuffer'
  endif
  2 wincmd _

  " Start Insert mode.
  % delete _
  call append(1, '')
  normal! 2G
  call feedkeys('i', 'n')
endfunction




function! ku#default_key_mappings()  "{{{2
  call s:remap('<C-c>', '<Plug>(ku-cancel)')
  call s:remap('<C-m>', '<Plug>(ku-do-default)')
  call s:remap('<C-i>', '<Plug>(ku-choose-action)')
  call s:remap('<C-j>', '<Plug>(ku-next-type)')
  call s:remap('<C-k>', '<Plug>(ku-previous-type)')
endfunction




function! ku#register_type(args)  "{{{2
  " See s:valid_type_definition_p() for the detail of a:args.
  if !s:valid_type_definition_p(a:args)
    echohl ErrorMsg
    echomsg 'Invalid type definition:' strtrans(a:args)
    echohl None
    return s:FALSE
  endif

  let s:types[a:args.name] = a:args

  return s:TRUE
endfunction




function! ku#unregister_type(name)  "{{{2
  if has_key(s:types, a:name)
    call remove(s:types, a:name)
  endif
  return s:TRUE
endfunction




function! ku#bang()  "{{{2
  return s:bang
endfunction








" Core  "{{{1
function! s:end()  "{{{2
  if s:end_locked_p
    return
  endif
  let s:end_locked_p = s:TRUE

  let n = winnr('#') - 1

  close

  let &completeopt = s:completeopt
  let &ignorecase = s:ignorecase
  execute n 'wincmd w'
  execute s:winrestcmd

  let s:end_locked_p = s:FALSE
endfunction
let s:end_locked_p = s:FALSE




function! s:complete(findstart, base)  "{{{2
  " items = a list of items
  " item = a dictionary as described in :help complete-items.
  "        '^_ku_.*$' - additional keys used by ku.
  "        '^_{type}_.*$' - additional keys used by type {type}.
  if a:findstart
    let s:last_items = []
    return 0
  else
    let s:last_items = []
    let pattern = (s:contains_the_prompt_p(a:base)
      \            ? a:base[len(s:PROMPT):]
      \            : a:base)
    for type_name in (s:preferred_type ==# s:INVALID_TYPE
      \               ? keys(s:types) : [s:preferred_type])
      let new_items = s:types[type_name].gather(pattern)
      for new_item in new_items
        let new_item['_ku_type'] = s:types[type_name]
        let new_item['_ku_sort_priority']
          \ = [
          \     (g:ku_sort_by_type_first_p ? type_name : 0),
          \     s:match(new_item.word, s:make_asis_regexp(pattern)),
          \     match(new_item.word, s:make_skip_regexp(pattern)),
          \     new_item.word,
          \     (!g:ku_sort_by_type_first_p ? type_name : 0),
          \   ]
      endfor
      call extend(s:last_items, new_items)
    endfor

    call filter(s:last_items, '0 <= v:val._ku_sort_priority[2]')
    call sort(s:last_items, function('s:compare_items'))
    return s:last_items
  endif
endfunction


function! s:compare_items(a, b)
  return s:compare_lists(a:a._ku_sort_priority, a:b._ku_sort_priority)
endfunction

function! s:compare_lists(a, b)
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
  let item = s:guess_the_appropriate_item()

  " To avoid doing some actions on this buffer and/or this window, close the
  " ku window.
  call s:end()

  " Do the specified aciton.
  if type(item) == s:TYPE_DICTONARY
    let ActionFunction = (a:choose_p
      \                   ? s:choose_action(item._ku_type.actions)
      \                   : item._ku_type.actions[0].function)
    call ActionFunction(item)
  endif
endfunction




function! s:switch_preferred_type(d)  "{{{2
  let type_names = sort(keys(s:types))
  call insert(type_names, s:INVALID_TYPE, 0)

  let s:preferred_type = type_names[
    \   (index(type_names, s:preferred_type) + a:d + len(type_names))
    \   % len(type_names)
    \ ]
endfunction




function! s:on_InsertEnter()  "{{{2
  let s:last_col = s:INVALID_COL
  return s:on_CursorMovedI()
endfunction




function! s:on_CursorMovedI()  "{{{2
  " Calling setline() has a side effect to the cursor.  If the cursor beyond
  " the end of line (i.e. getline('.') < col('.')), the cursor will be move at
  " the last character of the current line after calling setline().
  let c0 = col('.')
  call setline(1, '')  " dummy setting to know whether the cursor is moved.
  let c1 = col('.')
  call setline(1, printf('type=%s', s:preferred_type))

  " The order of these conditions are important.
  if !s:contains_the_prompt_p(getline('.'))
    let keys = repeat("\<Right>", len(s:PROMPT))
    call s:complete_the_prompt()
  elseif col('.') <= len(s:PROMPT)
    " The cursor is inside the prompt.
    let keys = repeat("\<Right>", len(s:PROMPT) - col('.') + 1)
  elseif len(getline('.')) < col('.') && col('.') != s:last_col
    " New character is inserted.
    let keys = s:KEYS_TO_START_COMPLETION
  else
    let keys = ''
  endif

  let s:last_col = col('.')
  return (c0 != c1 ? "\<Right>" : '') . keys
endfunction








" Misc.  "{{{1
function! s:SID_PREFIX()  "{{{2
  return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction




function! s:nop(...)  "{{{2
  return
endfunction




function! s:initialize_ku_buffer()  "{{{2
  " The current buffer is the ku buffer which is not initialized yet.

  " Basic settings.
  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal noswapfile
  setlocal nobuflisted
  let &l:omnifunc = s:SID_PREFIX() . 'complete'
  silent file `='*ku*'`

  " Autocommands.
  autocmd InsertEnter <buffer>  call feedkeys(<SID>on_InsertEnter(), 'n')
  autocmd CursorMovedI <buffer>  call feedkeys(<SID>on_CursorMovedI(), 'n')
  autocmd BufLeave <buffer>  call <SID>end()
  autocmd WinLeave <buffer>  call <SID>end()
  autocmd TabLeave <buffer>  call <SID>end()

  " Mappings.
  nnoremap <buffer> <silent> <Plug>(ku-cancel)
         \ :<C-u>call <SID>end()<Return>
  nnoremap <buffer> <silent> <Plug>(ku-do-default)
         \ :<C-u>call <SID>do(0)<Return>
  nnoremap <buffer> <silent> <Plug>(ku-choose-action)
         \ :<C-u>call <SID>do(1)<Return>
  nnoremap <buffer> <silent> <Plug>(ku-next-type)
         \ :<C-u>call <SID>switch_preferred_type(1)<Return>
  nnoremap <buffer> <silent> <Plug>(ku-previous-type)
         \ :<C-u>call <SID>switch_preferred_type(-1)<Return>

  nnoremap <buffer> <silent> <Plug>(ku-%-enter-insert)  a
  inoremap <buffer> <silent> <Plug>(ku-%-leave-insert)  <Esc>
  inoremap <buffer> <silent> <Plug>(ku-%-accept-completion)  <C-y>
  inoremap <buffer> <silent> <Plug>(ku-%-cancel-completion)  <C-e>

  imap <buffer> <silent> <Plug>(ku-cancel)
     \ <Plug>(ku-%-leave-insert)<Plug>(ku-cancel)
  imap <buffer> <silent> <Plug>(ku-do-default)
     \ <Plug>(ku-%-accept-completion)
     \<Plug>(ku-%-leave-insert)
     \<Plug>(ku-do-default)
  imap <buffer> <silent> <Plug>(ku-choose-action)
     \ <Plug>(ku-%-accept-completion)
     \<Plug>(ku-%-leave-insert)
     \<Plug>(ku-choose-action)
  imap <buffer> <silent> <Plug>(ku-next-type)
     \ <Plug>(ku-%-cancel-completion)
     \<Plug>(ku-%-leave-insert)
     \<Plug>(ku-next-type)
     \<Plug>(ku-%-enter-insert)
  imap <buffer> <silent> <Plug>(ku-previous-type)
     \ <Plug>(ku-%-cancel-completion)
     \<Plug>(ku-%-leave-insert)
     \<Plug>(ku-previous-type)
     \<Plug>(ku-%-enter-insert)

  inoremap <buffer> <expr> <BS>  pumvisible() ? "\<C-e>\<BS>" : "\<BS>"
  imap <buffer> <C-h>  <BS>
  " <C-n>/<C-p> ... Vim doesn't expand these keys in Insert mode completion.

  " User initialization.
  silent doautocmd User KuBufferInitialize
  if !exists('#User#KuBufferInitialize')
    call ku#default_key_mappings()
  endif
endfunction




function! s:ku_buffer_exists_p()  "{{{2
  return (s:bufnr != s:INVALID_BUFNR) && bufexists(s:bufnr)
endfunction




function! s:map(re_p, lhs, rhs)  "{{{2
  for mode in ['n', 'i']  " FIXME: should include other modes?
    execute mode.(a:re_p ? 'map' : 'noremap') '<buffer> <silent>' a:lhs a:rhs
  endfor
endfunction


function! s:remap(lhs, rhs)
  return s:map(s:TRUE, a:lhs, a:rhs)
endfunction


function! s:noremap(lhs, rhs)
  return s:map(s:FALSE, a:lhs, a:rhs)
endfunction




function! s:match(s, pattern)  "{{{2
  let NUM_MAX = 2147483647  " FIXME: valid value.
  let i = match(a:s, a:pattern)
  return 0 <= i ? i : NUM_MAX
endfunction




function! s:make_asis_regexp(s)  "{{{2
  " FIXME: case sensitivity
  return '\c\V' . substitute(a:s, '\', '\\', 'g')
endfunction




function! s:make_skip_regexp(s)  "{{{2
  " FIXME: case sensitivity
  return substitute(s:make_asis_regexp(a:s), '\s', '\\.\\*', 'g')
endfunction




function! s:complete_the_prompt()  "{{{2
  call setline('.', s:PROMPT . getline('.'))
endfunction




function! s:contains_the_prompt_p(s)  "{{{2
  return len(s:PROMPT) <= len(a:s) && a:s[:len(s:PROMPT) - 1] ==# s:PROMPT
endfunction




function! s:guess_the_appropriate_item()  "{{{2
  " If there are two or more items which have the same 'word', the first item
  " appeared in s:last_item will be choosen.  Because it's not possible to
  " know which item was selected in ins-completion-menu.  (It's possible if
  " some keys (<C-n>, <C-p> and others) are mapped when pumvisible(), but Vim
  " doesn't expand such mappings).
  "
  " But the types of such items are usually different, and s:preferred_type can
  " be used to avoid this problem.
  "
  " Another idea is merging actions of same 'word' items.
  " But it seems to be dirty.

  let line = getline('.')
  if len(s:last_items) == 0
    " There is no item which matches to the user input pattern.
    " So return the user input pattern instead of any item.
    let item = line
  elseif s:contains_the_prompt_p(line)
    " User seems to choose the first item in the completion list.
    let item = s:last_items[0]
  else
    " User seems to choose an item in the completion list, and the line is
    " altered by the completion list.
    for i in s:last_items
      if line ==# i.word
        break
      endif
    endfor
    let item = (line ==# i.word ? i : 0)
  endif

  return item
endfunction




function! s:choose_action(actions)  "{{{2
  " FIXME: style of the menu message.
  echo 'Available actions are:'
  for action in a:actions
    echo printf('%s :: %s', strtrans(action.key), action.name)
  endfor
  echo ''

  let c = nr2char(getchar())
  redraw  " clear the menu message lines to avoid hit-enter prompt.

  for action in a:actions
    if c ==# action.key
      return action.function
    endif
  endfor

  echo 'The key' strtrans(c) 'is not associated with any action'
     \ '-- nothing happened.'
  return function('s:nop')
endfunction




function! s:valid_type_name_p(name)  "{{{2
  for type_name in keys(s:types)
    if a:name ==# type_name
      return s:TRUE
    endif
  endfor
  return s:FALSE
endfunction




function! s:valid_type_definition_p(args)  "{{{2
  if type(a:args) != s:TYPE_DICTONARY
    return s:FALSE
  endif

  " -- The name of this type.
  if !s:has_valid_entry(a:args, 'name', s:TYPE_STRING) | return s:FALSE | endif
  if !(a:args.name =~# '^[a-z]\+$') | return s:FALSE | endif

  " -- Available actions for this type of items.
  " This is a list of definitions of actions.
  " It must contain at least 1 definition.
  " The 1st definition is the default action.
  " 
  " Each definition is a dictionary with 3 entries:
  " 'key'       The key to choose this action in <Plug>(ku-choose-action).
  " 'name'      The name of the action.
  " 'function'  The function of the action.  It is called with one parameter,
  "             the selected item (as described in :help complete-items).
  if !s:has_valid_entry(a:args,'actions',s:TYPE_LIST) | return s:FALSE | endif
  if !(1 <= len(a:args.actions)) | return s:FALSE | endif
  for v in a:args.actions
    if !s:has_valid_entry(v, 'key', s:TYPE_STRING) | return s:FALSE | endif
    if !s:has_valid_entry(v, 'name', s:TYPE_STRING) | return s:FALSE | endif
    if !s:has_valid_entry(v,'function',s:TYPE_FUNCTION) | return s:FALSE |endif
  endfor

  " -- Function to gather items which match to the given pattern.
  " It takes 1 argument (user input pattern).
  " It returns a list of items.  Each item is a string.
  if !s:has_valid_entry(a:args,'gather',s:TYPE_FUNCTION) |return s:FALSE |endif

  " FIXME: other entries.
  return s:TRUE
endfunction




function! s:has_valid_entry(dict, key, type)  "{{{2
  return has_key(a:dict, a:key) && type(a:dict[a:key]) == a:type
endfunction








" Built-in Types  "{{{1
" buffer  "{{{2
let s:_type_buffer_cached_items = []
let s:_type_buffer_last_bufnr = s:INVALID_BUFNR
function! s:_type_buffer_gather(pattern)
  if s:_type_buffer_last_bufnr != bufnr('$')
    let s:_type_buffer_cached_items = []
    let format = 'buffer %' . len(bufnr('$')) . 'd'
    for i in range(1, bufnr('$'))
      if bufexists(i) && buflisted(i)
        call add(s:_type_buffer_cached_items,
           \     {
           \       'word': bufname(i),
           \       'menu': printf(format, i),
           \       'dup': s:TRUE,
           \       '_buffer_number': i,
           \     })
      endif
    endfor
    let s:_type_buffer_last_bufnr = bufnr('$')
  endif
  return s:_type_buffer_cached_items
endfunction


function! s:_type_buffer_action_open(item)
  execute a:item._buffer_number 'buffer'.ku#bang()
endfunction
function! s:_type_buffer_action_split_open(item)
  execute a:item._buffer_number 'sbuffer'
endfunction
function! s:_type_buffer_action_vsplit_open(item)
  execute 'vertical' a:item._buffer_number 'sbuffer'
endfunction


" FIXME: other variants: hjkl HJKL.
call ku#register_type({
   \   'name': 'buffer',
   \   'actions': [
   \     {'key': 'o',
   \      'name': 'open',
   \      'function': function('s:_type_buffer_action_open')},
   \     {'key': 's',
   \      'name': 'split open',
   \      'function': function('s:_type_buffer_action_split_open')},
   \     {'key': 'v',
   \      'name': 'vsplit open',
   \      'function': function('s:_type_buffer_action_vsplit_open')},
   \   ],
   \   'gather': function('s:_type_buffer_gather'),
   \ })




" file  "{{{2
" FIXME: stub.
let s:_type_file_cached_items = []
let s:_type_file_last_bufnr = s:INVALID_BUFNR
function! s:_type_file_gather(pattern)
  if s:_type_file_last_bufnr != bufnr('$')
    let s:_type_file_cached_items = []
    for i in range(1, bufnr('$'))
      if bufexists(i) && buflisted(i) && getbufvar(i, '&buftype') == ''
        call add(s:_type_file_cached_items,
           \     {
           \       'word': bufname(i),
           \       'menu': 'file',
           \       'dup': s:TRUE,
           \     })
      endif
    endfor
    let s:_type_file_last_bufnr = bufnr('$')
  endif
  return s:_type_file_cached_items
endfunction


function! s:_type_file_action_open(item)
  execute 'edit'.ku#bang() a:item.word
endfunction
function! s:_type_file_action_split_open(item)
  execute 'split' a:item.word
endfunction
function! s:_type_file_action_vsplit_open(item)
  execute 'vsplit' a:item.word
endfunction


call ku#register_type({
   \   'name': 'file',
   \   'actions': [
   \     {'key': 'o',
   \      'name': 'open',
   \      'function': function('s:_type_file_action_open')},
   \     {'key': 's',
   \      'name': 'split open',
   \      'function': function('s:_type_file_action_split_open')},
   \     {'key': 'v',
   \      'name': 'vsplit open',
   \      'function': function('s:_type_file_action_vsplit_open')},
   \   ],
   \   'gather': function('s:_type_file_gather'),
   \ })








" directory  "{{{2
" FIXME: not written yet.








" __END__  "{{{1
" vim: foldmethod=marker
