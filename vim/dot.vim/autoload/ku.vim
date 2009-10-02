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


let s:NULL_SOURCE = {}


let s:PROMPT = '>'








" Variables  "{{{1

" source-name => source-definition
let s:available_sources = {}

" buffer number of the ku buffer
let s:ku_bufnr = s:INVALID_BUFNR

" Contains the information of a ku session.
" See s:new_session() for the details of content.
let s:session = {}








" Interface  "{{{1
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




function! ku#define_source(definition)  "{{{2
  let new_source = extend(copy(s:NULL_SOURCE), a:definition, 'keep')
  let _ = s:TRUE

  let _ = _ && s:valid_key_p(new_source, 'gather-items', 'function')
  let _ = _ && s:valid_key_p(new_source, 'name', 'string')
  if !_
    return s:FALSE
  endif

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




function! s:ku_active_p()  "{{{2
  return bufexists(s:ku_bufnr) && bufwinnr(s:ku_bufnr) != -1
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
  nnoremap <buffer> <silent> <SID>(choose-an-action)
  \        :<C-u>call <SID>chose_and_do_an_action()<Return>
  nnoremap <buffer> <silent> <SID>(ku-do-the-default-action)
  \        :<C-u>call <SID>do_the_default_action()<Return>
  nnoremap <buffer> <silent> <SID>(ku-quit-session)
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




function! s:new_session(source_names)  "{{{2
  " Assumption: All sources in a:source_names are available.
  let session = {}

    " Use list to ensure returning different value for each time.
  let session.id = [localtime()]
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




function! s:valid_key_p(source, key, type)  "{{{2
  if !has_key(a:source, a:key)
    echoerr 'Invalild source: Without key' string(a:key)
    return s:FALSE
  endif

  let TYPES = {
  \     'dictionary': type({}),
  \     'function': type(function('function')),
  \     'string': type(''),
  \   }
  if type(a:source[a:key]) != get(TYPES, a:type, -2009)
    echoerr 'Invalild source: Key' string(a:key) 'must be' a:type
    \       'but given value is' type(a:source[a:key])
    return s:FALSE
  endif

  return s:TRUE
endfunction








" __END__  "{{{1
" vim: foldmethod=marker
