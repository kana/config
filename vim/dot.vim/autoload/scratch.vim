" scratch - Emacs like scratch buffer
" Version: 0.1+
" Copyright (C) 2007 kana <http://whileimautomaton.net/>
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

let s:bufnr = 0  " The buffer number of the scratch buffer








" Interfaces  "{{{1
function! scratch#open()  "{{{2
  if !(s:bufnr && bufexists(s:bufnr))  " The scratch buffer does not exist.
    " Create the scratch buffer.
    " To avoid E303, we must process in the following order:
    " (1) create unnamed buffer,
    " (2) set 'noswapfile',
    " (3) name as specified by g:scratch_buffer_name.
    let original_bufnr = bufnr('%')
    let original_bufhidden = &l:bufhidden
    let &l:bufhidden = 'hide'
    hide enew
    setlocal bufhidden=hide buflisted buftype=nofile noswapfile
    file `=g:scratch_buffer_name`
    let s:bufnr = bufnr('%')

    " Initialize the scratch buffer.
    silent doautocmd User PluginScratchInitializeBefore
    call s:initialize_scratch_buffer()
    silent doautocmd User PluginScratchInitializeAfter

    " Switch back to the original buffer.
    if original_bufnr != s:bufnr
      execute 'buffer' original_bufnr
      let &l:bufhidden = original_bufhidden
    endif

    " Open the scratch buffer.
    if original_bufnr == s:bufnr && tabpagewinnr(tabpagenr(), '$') == 1
      " Do nothing -- in this case, the scratch buffer will be showed in two
      " windows if g:scratch_show_command contains a command to split window.
      " So don't use g:scratch_show_command to avoid such situation.
    else
      execute g:scratch_show_command s:bufnr
    endif
  else  " The scratch buffer exists.
    " FIXME: DRY: 'switchbuf' useopen.
    let winnr = bufwinnr(s:bufnr)
    if winnr == -1  " The scratch buffer is not visible.
      if bufname('')=='' && (!&l:modified) && tabpagewinnr(tabpagenr(),'$')==1
        " The current tab is "empty", so don't use g:scratch_show_command to
        " avoid show the scratch buffer in two windows.
        execute 'buffer' s:bufnr
      else
        execute g:scratch_show_command s:bufnr
      endif
    else
      execute winnr 'wincmd w'
    endif
  endif
endfunction




function! scratch#close()  "{{{2
  let scratch_winnr = bufwinnr(s:bufnr)
  if scratch_winnr == -1  " The scratch buffer is not visible.
    return
  endif

  let max_winnr = winnr('$')
  let original_winnr = winnr()
  execute scratch_winnr 'wincmd w'
  close
  if max_winnr <= 2
    " nop
  else
    execute (original_winnr - (scratch_winnr < original_winnr ? 1 : 0))
          \ 'wincmd w'
  endif
endfunction




function! scratch#evaluate_linewise(line1, line2, adjust_cursorp)  "{{{2
  let bufnr = bufnr('')
  call scratch#evaluate([bufnr, a:line1, 1, 0],
     \                  [bufnr, a:line2, len(getline(a:line2)), 0],
     \                  a:adjust_cursorp)
endfunction




function! scratch#evaluate(range_head, range_tail, adjust_cursorp)  "{{{2
  " Yank the script.
  let original_pos = getpos('.')
  let original_reg_a = @a
    call setpos('.', a:range_head)
    normal! v
    call setpos('.', a:range_tail)
    silent normal! "ay
    let script = @a
  let @a = original_reg_a

  " Evaluate it.
  execute substitute(script, '\n\s*\\', '', 'g')

  if a:adjust_cursorp
    " Move to the next line of the script (add new line if necessary).
    call setpos('.', a:range_tail)
    if line('.') == line('$')
      put =''
    else
      normal! +
    endif
  else
    call setpos('.', original_pos)
  endif
endfunction








" Misc.  "{{{1
function! s:initialize_scratch_buffer()  "{{{2
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

  silent! map <buffer> <unique> <CR>  <Plug>scratch-evaluate
  silent! map <buffer> <unique> <C-m>  <Plug>scratch-evaluate
  silent! map <buffer> <unique> <C-j>  <Plug>scratch-evaluate
endfunction








" __END__  "{{{1
" vim: foldmethod=marker
