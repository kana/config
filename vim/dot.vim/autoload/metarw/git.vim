" metarw scheme: git
" Version: 0.0.3
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
  " FIXME: Support {git-dir} completion like -complete=file
  " FIXME: *nix path separator assumption
  " a:arglead always contains "git:".
  let _ = s:parse_incomplete_fakepath(a:arglead)

  let candidates = []
  if _.path_given_p  " git:{commit-ish}:{path} -- complete {path}.
    for object in s:git_ls_tree(_.git_dir, _.commit_ish, _.leading_path)
      call add(candidates,
      \        printf('%s:%s%s:%s%s',
      \               _.scheme,
      \               _.git_dir_part,
      \               _.given_commit_ish,
      \               object.path,
      \               (object.type ==# 'tree' ? '/' : '')))
    endfor
    let head_part = printf('%s:%s%s:%s%s',
    \                      _.scheme,
    \                      _.git_dir_part,
    \                      _.given_commit_ish,
    \                      _.leading_path,
    \                      _.leading_path == '' ? '' : '/')
    let tail_part = _.last_component
  else  " git:{commit-ish} -- complete {commit-ish}.
    " sort by remote branches or not.
    for branch_name in s:git_branches(_.git_dir)
      call add(candidates,
      \        printf('%s:%s%s:', _.scheme, _.git_dir_part, branch_name))
    endfor
    let head_part = printf('%s:%s',
    \                      _.scheme,
    \                      _.git_dir_part)
    let tail_part = _.given_commit_ish
  endif

  return [candidates, head_part, tail_part]
endfunction




function! metarw#git#read(fakepath)  "{{{2
  let _ = s:parse_incomplete_fakepath(a:fakepath)
  if _.path_given_p  " 'git:{commit-ish}:...'?
    if _.incomplete_path == '' || _.incomplete_path[-1:] == '/'
      " 'git:{commit-ish}:' or 'git:{commit-ish}:{tree}/'?
      let result = s:read_tree(_)
    else  " 'git:{commit-ish}:path'?
      let result = s:read_blob(_)
    endif
  else  " 'git:...'?
    if _.given_commit_ish != ''  " 'git:{commit-ish}'?
      let result = s:read_commit(_)
    else  " 'git:'?
      let result = s:read_branches(_)
    endif
  endif

  return result
endfunction




function! metarw#git#write(fakepath, line1, line2, append_p)  "{{{2
  return ['error', 'Writing to an object is not supported']
endfunction








" Misc.  "{{{1
function! s:git_branches(git_dir)  "{{{2
  " Assumption: Branches given by "git branch" are already sorted.

  let output_local = system(printf('git --git-dir=%s branch',
  \                                shellescape(a:git_dir)))
  if v:shell_error != 0
    echoerr '"git branch" failed with the following reason:'
    echoerr output_local
    return []
  endif

  let output_remote = system(printf('git --git-dir=%s branch -r',
  \                                 shellescape(a:git_dir)))
  if v:shell_error != 0
    echoerr '"git branch -r" failed with the following reason:'
    echoerr output_remote
    return []
  endif

  return filter(map(split(output_local, "\n") + split(output_remote, "\n"),
  \                 'matchstr(v:val, ''^[ *]*\zs.*\ze$'')'),
  \             'v:val !=# "(no branch)" && v:val !~ " -> "')
endfunction




function! s:git_ls_tree(git_dir, commit_ish, leading_path)  "{{{2
  " Assumption: Objects given by "git ls-tree" are already sorted.
  let _ = []

  let output = system(printf("git --git-dir=%s ls-tree %s %s%s",
  \                          shellescape(a:git_dir),
  \                          shellescape(a:commit_ish),
  \                          shellescape(a:leading_path),
  \                          shellescape((a:leading_path == '' ? '.' : '/'))))
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
  " Return value '_' has the following items:
  "
  " Key			Value
  " ------------------  -----------------------------------------
  " given_fakepath      same as a:incomplete_fakepath
  "
  " scheme              {scheme} part in a:incomplete_fakepath (always 'git')
  "
  " git_dir_given_p     a:incomplete_fakepath in 'git:@{git-dir}:...' form
  " git_dir             normalized {git-dir}
  " git_dir_part        '@{git-dir}:' if _.git_dir_given_p.  otherwise ''.
  "
  " given_commit_ish    {commit-ish} in a:incomplete_fakepath
  " commit_ish          normalized _.given_commit_ish
  "
  " incomplete_path     {path} in a:incomplete_fakepath
  " leading_path        _.incomplete_path without the last component
  " last_component      the last component in _.incomplete_path
  " path_given_p        a:incomplete_fakepath in 'git:{commit-ish}:...' form
  let _ = {}

  let fragments = split(a:incomplete_fakepath, ':', !0)
  if  len(fragments) <= 1
    echoerr 'Unexpected a:incomplete_fakepath:' string(a:incomplete_fakepath)
    throw 'metarw:git#e1'
  endif

  let _.given_fakepath = a:incomplete_fakepath
  let _.scheme = fragments[0]

  " {git-dir}
  let i = 1
  if fragments[i][:0] == '@'
    let _.git_dir_given_p = !0
    let _.git_dir = fragments[i][1:]
    let _.git_dir_part = '@' . a:_.git_dir . ':'
    let i += 1
  else
    let _.git_dir_given_p = !!0
    let _.git_dir = './.git'
    let _.git_dir_part = ''
  endif

  " {commit-ish}
  if i < len(fragments)
    let _.given_commit_ish = fragments[i]
    let i += 1
  else
    let _.given_commit_ish = ''
  endif

  " {path}
  if i < len(fragments)
    let _.path_given_p = !0
    let _.incomplete_path = join(fragments[(i):], ':')
    let i += 1
  else
    let _.path_given_p = !!0
    let _.incomplete_path = ''
  endif

  let _.commit_ish = (_.given_commit_ish == '' ? 'HEAD' : _.given_commit_ish)
  let _.leading_path = join(split(_.incomplete_path, '/', !0)[:-2], '/')
  let _.last_component = join(split(_.incomplete_path, '/', !0)[-1:], '')

  return _
endfunction




function! s:read_blob(_)  "{{{2
  return ['read',
  \       printf('!git --git-dir=%s show %s:%s',
  \              shellescape(a:_.git_dir),
  \              shellescape(a:_.commit_ish),
  \              shellescape(a:_.incomplete_path))]
endfunction




function! s:read_branches(_)  "{{{2
  let result = [{
  \     'label': './',
  \     'fakepath': a:_.given_fakepath,
  \   }]
  for branch_name in s:git_branches(a:_.git_dir)
    call add(result, {
    \      'label': branch_name,
    \      'fakepath': printf('%s:%s%s:',
    \                         a:_.scheme,
    \                         a:_.git_dir_part,
    \                         branch_name),
    \    })
  endfor
  return ['browse', result]
endfunction




function! s:read_commit(_)  "{{{2
  return ['read',
  \       printf('!git --git-dir=%s show %s',
  \              shellescape(a:_.git_dir),
  \              shellescape(a:_.commit_ish))]
endfunction




function! s:read_tree(_)  "{{{2
  let parent_path = join(split(a:_.leading_path, '/', !0)[:-2], '/')
  let result = [{
  \     'label': '../',
  \     'fakepath': (a:_.incomplete_path == ''
  \                  ? printf('%s:%s', a:_.scheme, a:_.git_dir_part)
  \                  : printf('%s:%s%s:%s',
  \                           a:_.scheme,
  \                           a:_.git_dir_part,
  \                           a:_.given_commit_ish,
  \                           parent_path . (parent_path=='' ? '' : '/'))),
  \   }]
  for object in s:git_ls_tree(a:_.git_dir, a:_.commit_ish, a:_.incomplete_path)
    let path = object.path . (object.type ==# 'tree' ? '/' : '')
    let prefix_length = (a:_.leading_path == '' ? 0 : len(a:_.leading_path)+1)
    call add(result, {
    \      'label': path[(prefix_length):],
    \      'fakepath': printf('%s:%s%s:%s',
    \                         a:_.scheme,
    \                         a:_.git_dir_part,
    \                         a:_.given_commit_ish,
    \                         path),
    \    })
  endfor
  return ['browse', result]
endfunction








" __END__  "{{{1
" vim: foldmethod=marker
