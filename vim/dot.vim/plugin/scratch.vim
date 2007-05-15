" scratch.vim - Emacs like scratch buffer.
" Author: kana <http://nicht.s8.xrea.com/>
" License: MIT license (see <http://www.opensource.org/licenses/mit-license>)
" $Id$  "{{{1

if exists('g:loaded_scratch')
  finish
endif




" VARIABLES  "{{{1

" Name of the scratch buffer.
if !exists('g:scratch_buffer_name')
  let g:scratch_buffer_name = '*Scratch*'
endif

" Command to show the scratch buffer.
" Buffer number will be appended to the end of this variable.
if !exists('g:scratch_show_command')
  let g:scratch_show_command = 'topleft split | hide buffer'
endif




" FUNCTIONS  "{{{1

function! s:Open()  " Create, show, or focus the scratch buffer.
  let bufno = bufnr(s:EscapeWildcards(g:scratch_buffer_name))

  if bufno == -1  " The scratch buffer does not exists.
    " Create the scratch buffer.
    " To avoid E303, we must process in the following order:
    " (1) create unnamed buffer,
    " (2) set 'noswapfile',
    " (3) name as specified by g:scratch_buffer_name.
    let orig_bufnr = bufnr('%')
    hide enew
    setlocal bufhidden=hide buflisted buftype=nofile noswapfile
    file `=g:scratch_buffer_name`
    let scratch_bufnr = bufnr('%')

    " Set up some useful settings.
    if exists('#Scratch#User#Initialize')
      doautocmd Scratch User Initialize
    endif
    call s:InitializeWithDefaultSettings()

    " Re-open with the specified command.
    if orig_bufnr == scratch_bufnr && tabpagewinnr(tabpagenr(), '$') == 1
      " If the following conditions:
      " - there is only one window in the current tab page,
      " - there is no buffer except the scratch buffer,
      " - and g:scratch_show_command contains a command to create new window
      " are satisfied, the scratch buffer will be showed in two windows.
      " To avoid such situation, do nothing here
      " because the scratch buffer is already shown at this phase.
    else
      execute 'buffer' orig_bufnr
      execute g:scratch_show_command scratch_bufnr
    endif
  else
    let winno = bufwinnr(bufno)
    if winno == -1  " The scratch buffer is not visible.
      execute g:scratch_show_command bufno
    else
      execute winno 'wincmd w'
    endif
  endif
endfunction


function! s:ExecuteLine()
  execute getline('.')
  call s:AddLastLineIfNecessary()
endfunction

function! s:ExecuteSelection()
  let reg_old = @@
  normal! gvy
  execute @@
  let @@ = reg_old
  normal! '>
  call s:AddLastLineIfNecessary()
endfunction


function! s:AddLastLineIfNecessary()
  if line('.') == line('$')
    put =''
  else
    normal! +
  endif
endfunction

function! s:EscapeWildcards(string)
  return escape(a:string, '*? ,{}[]\')
endfunction

function! s:InitializeWithDefaultSettings()
  if &l:filetype == ''
    setlocal filetype=vim
  endif

  if &l:filetype == 'vim'
    0 put ='\" This buffer is for notes you don''t want to save,'
    put ='\" and for Vim script evaluation.'
    put ='\"'
    put ='\" In normal mode, <C-m> or <C-j> will evaluate the current line.'
    put ='\" In visual mode, <C-m> or <C-j> will evaluate the selected text.'
    put =''
    $
  endif

  if !hasmapto('<Plug>Scratch_ExecuteLine')
    silent! nmap <buffer> <unique> <CR>  <Plug>Scratch_ExecuteLine
    silent! nmap <buffer> <unique> <C-j>  <CR>
  endif
  if !hasmapto('<Plug>Scratch_ExecuteSelection')
    silent! vmap <buffer> <unique> <CR>  <Plug>Scratch_ExecuteSelection
    silent! vmap <buffer> <unique> <C-j>  <CR>
  endif
endfunction




" KEY MAPPINGS  "{{{1

noremap <script> <unique> <Plug>Scratch_Open  <SID>Open
noremap <script> <unique> <Plug>Scratch_ExecuteLine  <SID>ExecuteLine
noremap <script> <unique> <Plug>Scratch_ExecuteSelection  <SID>ExecuteSelection

noremap <silent> <SID>Open  :<C-u>call <SID>Open()<CR>
noremap <silent> <SID>ExecuteLine  :<C-u>call <SID>ExecuteLine()<CR>
noremap <silent> <SID>ExecuteSelection  :<C-u>call <SID>ExecuteSelection()<CR>

if !hasmapto('<Plug>Scratch_Open')
  silent! nmap <unique> <Leader>s  <Plug>Scratch_Open
endif




" ETC  "{{{1

let g:loaded_scratch = 1

" |/
" vim: foldmethod=marker
