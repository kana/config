" Vim filetype plugin file
" Language: BUGS
" Maintainer: kana <http://nicht.s8.xrea.com/>
" Last Change: $Date: 2006/09/23 02:02:58 $
" Remark: Just for me.
" Id: $Id$

if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1




let b:undo_ftplugin = "setlocal foldmethod< foldexpr< foldtext<"

setlocal foldmethod=expr
setlocal foldexpr=BugsFoldLevel(v:lnum)
setlocal foldtext=BugsFoldText()




if exists("*BugsFoldLevel")
  finish
endif


function BugsFoldLevel(lnum)
  let l:line = getline(a:lnum)
  if l:line =~ '^\s*$'  " blank-line?
    return '='  " same as the previous line
  endif

  let l:indent = strlen(matchstr(l:line, '^\t\+'))
  if l:line =~ '[^\t]\t\d\d\d\d-\d\d-\d\d[^\t]*$'  " header?
    return '>' . (l:indent + 1)  " starting fold
  elseif l:indent > 0  " text?
    " (mostly) equivalent to (and faster than?) '=' for this case
    "return l:indent
    return "="
  else  " non-item?
    return 0  " not in a fold
  endif
endfunction

function BugsFoldText()
  let l:line = getline(v:foldstart)
  let l:line = substitute(l:line,
                        \ '^\t*\([^\t]\+\)\t\([^\tT]\+\)\(T[^\t]\+\)\?$',
                        \ '\1  (\2)',
                        \ '')

  return '+' . strpart(s:strrep('-', &tabstop * (v:foldlevel - 1)), 1 + 1)
        \ . ' ' . l:line . ' '
endfunction


function s:strrep(s, n)
  let l:result = ''
  let l:i = 0
  while l:i < a:n
    let l:result = l:result . a:s
    let l:i = l:i + 1
  endwhile
  return l:result
endfunction


" vim: et sts=2 sw=2
