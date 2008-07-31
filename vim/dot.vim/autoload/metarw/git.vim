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
  let _ = s:parse_incomplete_fakepath(a:arglead)

  let candidates = []
  if _.path_given_p  " git:{commit-ish}:{path} -- complete {path}.
    for object in s:git_ls_tree(_.commit_ish, _.leading_path)
      call add(candidates,
      \        printf('%s:%s:%s%s',
      \               _.scheme,
      \               _.given_commit_ish,
      \               object.path,
      \               (object.type ==# 'tree' ? '/' : '')))
    endfor
  else  " git:{commit-ish} -- complete {commit-ish}.
    " sort by remote branches or not.
    for branch_name in s:git_branches()
      call add(candidates, printf('%s:%s:', _.scheme, branch_name))
    endfor
  endif

    " FIXME: support wildcards to filter like -complete=file.
    " keep candidates which start with a:arglead.
  return filter(candidates, 'stridx(v:val, a:arglead) == 0')
endfunction




function! metarw#git#read(fakepath)  "{{{2
  let _ = s:parse_incomplete_fakepath(a:fakepath)
  if _.path_given_p
    " "git:{commit-ish}:..."?
    if _.incomplete_path == '' || _.incomplete_path[-1:] == '/'
      " "git:{commit-ish}:" OR "git:{commit-ish}:{tree}/"?
      let parent_path = join(split(_.leading_path, '/', !0)[:-2], '/')
      let result = {}
      let result.items = [{
      \     'label': '../',
      \     'fakepath': (_.incomplete_path == ''
      \                  ? printf('%s:', _.scheme)
      \                  : printf('%s:%s:%s',
      \                           _.scheme,
      \                           _.given_commit_ish,
      \                           parent_path . (parent_path=='' ? '' : '/'))),
      \   }]
      for object in s:git_ls_tree(_.commit_ish, _.incomplete_path)
        let path = object.path . (object.type ==# 'tree' ? '/' : '')
        let prefix_length = (_.leading_path == '' ? 0 : len(_.leading_path)+1)
        call add(result.items, {
        \      'label': path[(prefix_length):],
        \      'fakepath': printf('%s:%s:%s',
        \                         _.scheme,
        \                         _.given_commit_ish,
        \                         path),
        \    })
      endfor
    else
      " "git:{commit-ish}:{path}"?
      execute printf('read !git show ''%s:%s''',
      \              _.commit_ish,
      \              _.incomplete_path)
      let result = 0
    endif
  else
    " "git:{commit-ish}"?
    if _.given_commit_ish != ''
      execute 'read !git show' _.commit_ish
      let result = 0
    else
      let result = {}
      let result.items = [{
      \     'label': './',
      \     'fakepath': a:fakepath,
      \   }]
      for branch_name in s:git_branches()
        call add(result.items, {
        \      'label': branch_name,
        \      'fakepath': printf('%s:%s:', _.scheme, branch_name),
        \    })
      endfor
    endif
  endif

  if type(result) == type({})
    let result.buffer_name = printf('%s (%s)',
    \                               a:fakepath,
    \                               fnamemodify(getcwd(), ':~'))
  endif
  return v:shell_error == 0 ? result : 'git command failed'
endfunction




function! metarw#git#write(fakepath, line1, line2, append_p)  "{{{2
  return 'Writing to an object is not supported'
endfunction








" Misc.  "{{{1
function! s:git_branches()  "{{{2
  " Assumption: Branches given by "git branch -a" are already sorted.
  let output = system('git branch -a')
  if v:shell_error != 0
    echoerr 'git branch failed with the following reason:'
    echoerr output
    return []
  endif

  return map(split(output, "\n"), 'matchstr(v:val, ''^[ *]*\zs.*\ze$'')')
endfunction




function! s:git_ls_tree(commit_ish, leading_path)  "{{{2
  " Assumption: Objects given by "git ls-tree" are already sorted.
  let _ = []

  let output = system(printf("git ls-tree '%s' '%s%s'",
  \                          a:commit_ish,
  \                          a:leading_path,
  \                          (a:leading_path == '' ? '.' : '/')))
  if v:shell_error != 0
    echoerr 'git ls-tree failed with the following reason:'
    echoerr output
    return []
  endif

  for line in split(output, "\n")
    let columns = matchlist(line, '^\([^ ]*\) \([^ ]*\) \([^\t]*\)\t\(.*\)$')
    if columns[0] != ''  " valid line?
      call add(_, {
      \      'mode': columns[1],
      \      'type': columns[2],
      \      'id': columns[3],
      \      'path': columns[4],
      \    })
    endif
  endfor

  return _
endfunction




function! s:parse_incomplete_fakepath(incomplete_fakepath)  "{{{2
  let _ = {}
  " _.scheme - {scheme} part in a:incomplete_fakepath (should be always 'git')
  " _.given_commit_ish - {commit-ish} in a:incomplete_fakepath
  " _.commit_ish - normalized _.given_commit_ish
  " _.incomplete_path - {path} in a:incomplete_fakepath
  " _.leading_path - _.incomplete_path without the last component
  " _.path_given_p - a:incomplete_fakepath in 'git:{commit-ish}:...' form

  let fragments = split(a:incomplete_fakepath, ':', !0)

  let _.scheme = fragments[0]

  if len(fragments) == 2  " git:{commit-ish}
    let _.path_given_p = !!0
    let _.given_commit_ish = fragments[1]
    let _.incomplete_path = ''
  elseif 3 <= len(fragments)  " git:{commit-ish}:{path}
    let _.path_given_p = !0
    let _.given_commit_ish = fragments[1]
    let _.incomplete_path = join(fragments[2:], ':')
  else  " len(fragments) <= 1
    echoerr 'Unexpected a:incomplete_fakepath:' string(a:incomplete_fakepath)
    throw 'metarw:git#e1'
  endif

  let _.commit_ish = (_.given_commit_ish == '' ? 'HEAD' : _.given_commit_ish)
  let _.leading_path = join(split(_.incomplete_path, '/', !0)[:-2], '/')

  return _
endfunction








" __END__  "{{{1
" vim: foldmethod=marker
