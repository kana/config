" metarw scheme: git
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
function! metarw#git#complete(arglead, cmdline, cursorpos)  "{{{2
  " FIXME: *nix path separator assumption
  " a:arglead always contains "git:".

  let _ = split(a:arglead, ':', !0)
  if len(_) == 2
    let tree_ish = ''
    let incomplete_path = _[1]
  elseif 3 <= len(_)
    let tree_ish = _[1]
    let incomplete_path = join(_[2:], ':')
  else  " len(_) <= 1
    echoerr 'Unexpected a:arglead:' string(a:arglead)
    throw 'metarw:git#e1'
  endif

  let leading_path = join(split(incomplete_path, '/', !0)[:-2], '/')
  let candidates = []
  for line in split(system(printf("git ls-tree '%s' '%s'",
  \                        (tree_ish == '' ? 'HEAD' : tree_ish),
  \                        (leading_path == '' ? '.' : leading_path . '/'))),
  \                 "\n")
    let __ = matchlist(line, '^\([^ ]*\) \([^ ]*\) \([^\t]*\)\t\(.*\)$')
    " let mode = __[1]
    let type = __[2]
    " let object_id = __[3]
    let path = __[4]

    let word = printf('%s:%s:%s%s',
    \                 _[0],
    \                 tree_ish,
    \                 path,
    \                 (type ==# 'tree' ? '/' : ''))
    if stridx(word, a:arglead) == 0  " word starts with a:arglead?
      " FIXME: support wildcards to filter like -complete=file.
      call add(candidates, word)
    endif
  endfor

  return candidates
endfunction




function! metarw#git#read(fakefile)  "{{{2
  " FIXME: NIY - just for test
  return 'Reading from an object is not supported yet'
endfunction




function! metarw#git#write(fakefile, line1, line2, append_p)  "{{{2
  return 'Writing to an object is not supported'
endfunction








" Misc.  "{{{1








" __END__  "{{{1
" vim: foldmethod=marker
