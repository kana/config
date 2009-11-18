" exjumplist - Extra commands for jumplist
" Version: 0.0.0
" Copyright (C) 2009 kana <http://whileimautomaton.net/>
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
function! exjumplist#go_first()  "{{{2
  let [older_count, newer_count] = s:jumplist_info()

  execute 'normal!' older_count."\<C-o>"
endfunction




function! exjumplist#go_last()  
  let [older_count, newer_count] = s:jumplist_info()

  execute 'normal'
  \       (s:portable_count(newer_count)
  \        . "\<Plug>(exjumplist-%-next-position)")
endfunction




function! exjumplist#next_buffer()  "{{{2
  let [older_count, newer_count] = s:jumplist_info()
  let current_bufnr = bufnr('')

  for _ in range(newer_count)
    execute 'normal' "\<Plug>(exjumplist-%-next-position)"

    if bufnr('') != current_bufnr
      break
    endif
  endfor

  " The current buffer is not changed - restore jumplist state.
  if bufnr('') == current_bufnr
    for _ in range(newer_count)
      execute 'normal!' "\<C-o>"
    endfor
    echo 'Cannot go beyond the last buffer'
  endif

  return
endfunction




function! exjumplist#previous_buffer()  "{{{2
  let [older_count, newer_count] = s:jumplist_info()
  let current_bufnr = bufnr('')

  for _ in range(older_count)
    execute 'normal!' "\<C-o>"

    if bufnr('') != current_bufnr
      break
    endif
  endfor

  " The current buffer is not changed - restore jumplist state.
  if bufnr('') == current_bufnr
    for _ in range(older_count)
      execute 'normal' "\<Plug>(exjumplist-%-next-position)"
    endfor
    echo 'Cannot go before the first buffer'
  endif

  return
endfunction








" Misc.  "{{{1
" Key mappings  "{{{2

" Ensure that <C-i> can be executed from Vim script.
" Because :execute 'normal!' "\<C-i>" raises E471.
nnoremap <silent> <Plug>(exjumplist-%-next-position)  <C-i>

" For portability on count.
nnoremap <SID>0  0
nnoremap <SID>1  1
nnoremap <SID>2  2
nnoremap <SID>3  3
nnoremap <SID>4  4
nnoremap <SID>5  5
nnoremap <SID>6  6
nnoremap <SID>7  7
nnoremap <SID>8  8
nnoremap <SID>9  9




function! exjumplist#_scope()  "{{{2
  return s:
endfunction




function! exjumplist#_sid()  "{{{2
  nnoremap <SID>  <SID>
  return maparg('<SID>', 'n')
endfunction




function! s:jumplist_info()  "{{{2
  redir => jumplist
  silent jumps
  redir END

  " ids = [..., 3, 2, 1, 1, 2, 3, ...]
  "    or [..., 3, 2, 1]
  "    or [1, 2, 3, ...]
  let ids = split(jumplist, '\n')
  call map(ids, 'matchstr(v:val, ''^\s*\zs\d\+\ze\s\+\d\+\s\+\d\+\s\+.*$'')')
  call filter(ids, 'v:val != ""')

  " ids = [..., 3, 2, 1, 1, 2, 3, ...]
  "          ... +1 +1  0 -1 -1 ...
  "        |           ||           |
  "        `-----------'`-----------'
  "         older_count  newer_count
  "    or [..., 3, 2, 1]
  "          ... +1 +1
  "        |          |
  "        `----------'
  "       older_count - 1
  "    or [1, 2, 3, ...]
  "         -1 -1 ...
  "        |          |
  "        `----------'
  "       newer_count - 1
  let older_count = 0
  let newer_count = 0
  for i in range(1, len(ids) - 1)
    let diff = ids[i - 1] - ids[i]
    if 0 <= diff
      let older_count += 1
    endif
    if diff <= 0
      let newer_count += 1
    endif
  endfor

  if older_count == 0
    let newer_count += 1
  endif
  if newer_count == 0
    let older_count += 1
  endif

  return [older_count, newer_count]
endfunction




function! s:portable_count(count)  "{{{2
  if 1 <= a:count
    let SID = substitute(exjumplist#_sid(), '<SNR>', "\<SNR>", '')
    return join(map(split(string(a:count), '\zs\ze'), 'SID . v:val'), '')
  else
    return ''
  endif
endfunction








" __END__  "{{{1
" vim: foldmethod=marker
