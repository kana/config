" skeleton - Skeleton for newly created files
" Version: 0.0.2
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

if exists('g:loaded_skeleton')
  finish
endif

let s:SKELETON_DIR = 'xtr/skeleton/'




command! -bang -bar -complete=customlist,s:cmd_SkeletonLoad_complete -nargs=1
\ SkeletonLoad
\ call s:cmd_SkeletonLoad(<q-args>, expand('<abuf>') == '', <bang>0)

function! s:cmd_SkeletonLoad(name, interactive_use_p, banged_p)
  if &l:buftype != ''
    if a:interactive_use_p
      echo 'This buffer is not a normal one.  Skeleton leaves it as is.'
    endif
    return
  endif
  if (!a:banged_p) && (line('$') != 1 || len(getline(1)) != 0)
    if a:interactive_use_p
      echo 'This buffer is not empty.  Skeleton leaves it as is.'
    endif
    return
  endif

  let candidates = split(globpath(&runtimepath, s:SKELETON_DIR.a:name), "\n")
  if len(candidates) < 1
    if a:interactive_use_p
      echo 'Skeleton file is not found:' string(a:name)
    endif
    return
  endif

  " Load skeleton file.
  if a:banged_p
    % delete _
  endif
  silent keepalt 1 read `=candidates[0]`
  0 delete _

  return
endfunction

function! s:cmd_SkeletonLoad_complete(arglead, cmdline, cursorpos)
  return map(split(globpath(&runtimepath, s:SKELETON_DIR.a:arglead.'*'), "\n"),
  \          'fnamemodify(v:val, ":t")')
endfunction




augroup plugin-skeleton
  autocmd!
  autocmd BufNewFile *  call s:on_BufNewFile()
augroup END

function! s:on_BufNewFile()
  silent doautocmd User plugin-skeleton-detect

  if &l:filetype != ''
    execute 'SkeletonLoad' &l:filetype
  endif
endfunction




let g:loaded_skeleton = 1

" __END__
" vim: foldmethod=marker
