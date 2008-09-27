" altftsys - alternative filetype plugin loader - :filetype plugin on
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

if exists('g:did_load_ftplugin')
  finish
endif

let s:cpoptions = &cpoptions
set cpoptions&vim




augroup filetypeplugin
  autocmd!
  autocmd FileType *  call s:load_filetype_plugins()
augroup END

function! s:load_filetype_plugins()
  if exists('b:undo_ftplugin')
    execute b:undo_ftplugin
  endif
  unlet! b:did_ftplugin b:undo_ftplugin

  if &cpoptions =~# 'S' && exists('b:did_ftplugin')
    " In compatible mode options are reset to the global values, need to set
    " the local values also when a plugin was already used.
    unlet! b:did_ftplugin
  endif

  let undo_ftplugin = ''

    " BUGS: Assumes paths never contain any comma.
  let _ = split(&runtimepath, ',')
  let runtimepath_after = join(filter(copy(_), 'v:val=~#''[/\\]after'''), ',')
  let runtimepath_nonafter = join(filter(copy(_),'v:val!~#''[/\\]after'''),',')
  let filetypes = split(&l:filetype, '\.')

  let original_runtimepath = &runtimepath
  let &runtimepath = runtimepath_nonafter
    for ft in filetypes
      unlet! b:did_ftplugin b:undo_ftplugin
      execute 'runtime ftplugin/'.ft.'.vim'
      if exists('b:undo_ftplugin')
        let undo_ftplugin .= '|' . b:undo_ftplugin
      endif
    endfor
    let b:undo_ftplugin = undo_ftplugin
  let &runtimepath = original_runtimepath

  for ft in filetypes
    let ftplugins = globpath(runtimepath_after, 'ftplugin/'.ft.'{,_*,/*}.vim')
    for ftplugin in split(ftplugins, '\n')
      execute 'source' ftplugin
    endfor
  endfor
endfunction




" The name of the checker variable MUST be g:did_load_ftplugin to avoid not to
" source all content of the original filetype plugin loader.
let g:did_load_ftplugin = 1

let &cpoptions = s:cpoptions
unlet s:cpoptions

" __END__
" vim: foldmethod=marker
