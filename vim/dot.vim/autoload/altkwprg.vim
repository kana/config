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
" Interface  "{{{1
function! altkwprg#look(keyword)  "{{{2
  let keyword = a:keyword is 0 ? s:selection() : a:keyword

  let [command_line, keywordprg, type] = s:make_command_line(
  \     keyword,
  \     v:count,
  \     exists('b:keywordprg') ? b:keywordprg : 0,
  \     exists('g:keywordprg') ? g:keywordprg : 0,
  \     &l:keywordprg,
  \     &g:keywordprg
  \   )
  if keywordprg ==# ':help'
    execute 'help' keyword
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
    silent execute 'read !' command_line '2>/dev/null'
    1 delete _
  setlocal nomodifiable
  setlocal nobuflisted
  setlocal buftype=help
  setlocal nomodified
  setlocal noswapfile
  if type ==# 'bv'
    let b:keywordprg = keywordprg
  elseif type ==# 'lo'
    let &l:keywordprg = keywordprg
  endif
endfunction








" Misc.  "{{{1
function! s:bufname(keywordprg)  "{{{2
  return printf('%s %s',
  \             (has('unix') ? '*altkwprg*' : '[altkwprg]'),
  \             substitute(a:keywordprg, '.\{-}\(\<[A-Za-z0-9_-]\+\>\).*',
  \                        '\1', ''))
endfunction




function! s:find_help_window()  "{{{2
  for i in range(1, winnr('$'))
    if getbufvar(winbufnr(i), '&buftype') ==# 'help'
      return i
    endif
  endfor
  return -1
endfunction




function! s:make_command_line(keyword, count, b_var, g_var, l_opt, g_opt) "{{{2
  if a:b_var isnot 0
    let prog = a:b_var
    let type = 'bv'
  elseif a:g_var isnot 0
    let prog = a:g_var
    let type = 0
  elseif a:l_opt != ''
    let prog = a:l_opt
    let type = 'lo'
  else
    let prog = a:g_opt
    let type = 0
  endif

  if prog ==# 'man -s' && a:count == 0
    let prog = 'man'
  endif
  if prog == ''
    let prog = ':help'
  endif

  if prog =~# '<keyword>'
    let _ = prog
    let _ = substitute(_, '<keyword>', fnameescape(a:keyword), 'g')
    let _ = substitute(_, '<count>', a:count ? a:count : '', 'g')
    let command_line = _
  elseif prog ==# 'man' || prog ==# 'man -s'
    let command_line = prog
    if a:count != 0
      let command_line .= ' ' . a:count
    endif
    let command_line .= ' ' . fnameescape(a:keyword)
  elseif prog ==# ':help'
    let command_line = 0  " dummy value, not used.
  else
    let command_line = prog . ' ' . fnameescape(a:keyword)
  endif

  return [command_line, prog, type]
endfunction




function! s:selection()  "{{{2
  let _ = [getreg('a'), getregtype('a')]
    normal! gv"ay
    let result = @a
  call setreg('a', _[0], _[1])
  return result
endfunction








" __END__  "{{{1
" vim: foldmethod=marker
