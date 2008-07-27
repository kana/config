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
  let _ = s:parse_incomplete_fakefile(a:arglead)

  let candidates = []
  if _.path_given_p  " git:{commit-ish}:{path} -- complete {path}.
    for line in split(system(printf("git ls-tree '%s' '%s'",
    \                               _.commit_ish,
    \                               _.leading_path . '/')),
    \                 "\n")
      let __ = matchlist(line, '^\([^ ]*\) \([^ ]*\) \([^\t]*\)\t\(.*\)$')
      " let mode = __[1]
      let type = __[2]
      " let object_id = __[3]
      let path = __[4]
  
      let word = printf('%s:%s:%s%s',
      \                 _.scheme,
      \                 _.given_commit_ish,
      \                 path,
      \                 (type ==# 'tree' ? '/' : ''))
      call add(candidates, word)
    endfor
  else  " git:{commit-ish} -- complete {commit-ish}.
    " sort by remote branches or not.
    for line in split(system('git branch -a'), "\n")
      let word = matchstr(line, '^[ *]*\zs.*\ze$')
      call add(candidates, printf('%s:%s:', _.scheme, word))
    endfor
  endif

    " FIXME: support wildcards to filter like -complete=file.
    " keep candidates which start with a:arglead.
  return filter(candidates, 'stridx(v:val, a:arglead) == 0')
endfunction




function! metarw#git#read(fakefile)  "{{{2
  " FIXME: NIY - just for test
  return 'Reading from an object is not supported yet'
endfunction




function! metarw#git#write(fakefile, line1, line2, append_p)  "{{{2
  return 'Writing to an object is not supported'
endfunction








" Misc.  "{{{1
function! s:parse_incomplete_fakefile(incomplete_fakefile)
  let _ = {}
  " _.scheme - {scheme} part in a:incomplete_fakefile (should be always 'git')
  " _.given_commit_ish - {commit-ish} in a:incomplete_fakefile
  " _.commit_ish - normalized _.given_commit_ish
  " _.incomplete_path - {path} in a:incomplete_fakefile
  " _.leading_path - _.incomplete_path without the last component
  " _.path_given_p - a:incomplete_fakefile in 'git:{commit-ish}:...' form

  let fragments = split(a:incomplete_fakefile, ':', !0)

  let _.scheme = fragments[0]

  if len(fragments) == 2  " git:{commit-ish} or git:{path}
    let _.path_given_p = !!0
    let _.given_commit_ish = ''
    let _.incomplete_path = fragments[1]
  elseif 3 <= len(fragments)  " git:{commit-ish}:{path}
    let _.path_given_p = !0
    let _.given_commit_ish = fragments[1]
    let _.incomplete_path = join(fragments[2:], ':')
  else  " len(fragments) <= 1
    echoerr 'Unexpected a:incomplete_fakefile:' string(a:incomplete_fakefile)
    throw 'metarw:git#e1'
  endif

  let _.commit_ish = (_.given_commit_ish == '' ? 'HEAD' : _.given_commit_ish)
  let _.leading_path = join(split(_.incomplete_path, '/', !0)[:-2], '/')

  return _
endfunction








" __END__  "{{{1
" vim: foldmethod=marker
