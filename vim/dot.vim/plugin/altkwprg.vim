" altkwprg - Alternative 'keywordprg' with :help-like window
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

if exists('g:loaded_altkwprg')
  finish
endif




command! -bang -bar -nargs=0 AltkwprgDefaultKeyMappings
\ call s:cmd_AltkwprgDefaultKeyMappings('<bang>' == '!')
function! s:cmd_AltkwprgDefaultKeyMappings(banged_p)
  let _ = a:banged_p ? '' : '<unique>'
  silent! execute 'nmap' _ 'K  <Plug>(altkwprg-look)'
  silent! execute 'vmap' _ 'K  <Plug>(altkwprg-look)'
endfunction

if !exists('g:altkwprg_no_default_key_mappings')
  AltkwprgDefaultKeyMappings
endif




nnoremap <silent> <Plug>(altkwprg-look)
\        :<C-u>call <SID>look(expand('<cword>'))<Return>
vnoremap <silent> <Plug>(altkwprg-look)
\        :<C-u>call <SID>look(<SID>selection())<Return>

function! s:look(keyword)
  " FIXME: NIY: count support
  let [keywordprg, local_keywordprg_p]
  \   = s:normalize_keywordprg(&l:keywordprg, &g:keywordprg, v:count)
  if keywordprg ==# ':help'
    execute 'help' a:keyword
    return
  endif

  let winnr = s:find_help_window()
  if winnr == -1
    " FIXME: more precise :help emulation - with vertically split windows
    execute &helpheight 'split'
  else
    execute winnr 'wincmd w'
  endif

  let bufname = s:bufname(keywordprg)
  let bufnr = bufnr(fnameescape(bufname))
  if bufnr == -1
    enew
    setlocal noswapfile
    silent file `=bufname`
  else
    execute bufnr 'buffer'
  endif

  setlocal modifiable
    silent % delete _
    silent execute 'read !' keywordprg fnameescape(a:keyword) '2>/dev/null'
    1 delete _
  setlocal nomodifiable
  setlocal nobuflisted
  setlocal buftype=help
  setlocal nomodified
  setlocal noswapfile
  if local_keywordprg_p
    let &l:keywordprg = keywordprg
  endif
endfunction

function! s:selection()
  let _ = [getreg('a'), getregtype('a')]
    normal! gv"ay
    let result = @a
  call setreg('a', _[0], _[1])
  return result
endfunction

function! s:bufname(keywordprg)
  return printf('%s %s',
  \             (has('unix') ? '*altkwprg*' : '[altkwprg]'),
  \             a:keywordprg)
endfunction

function! s:find_help_window()
  for i in range(1, winnr('$'))
    if getbufvar(winbufnr(i), '&buftype') ==# 'help'
      return i
    endif
  endfor
  return -1
endfunction

function! s:normalize_keywordprg(l_prog, g_prog, count)
  let local_p = a:l_prog != ''  " global-local
  let prog = local_p ? a:l_prog : a:g_prog
  if prog == ''
    let prog = ':help'
  endif
  if prog ==# 'man -s' && a:count == 0
    let prog = 'man'
  endif
  return [prog, local_p]
endfunction




let g:loaded_altkwprg = 1

" __END__
" vim: foldmethod=marker
