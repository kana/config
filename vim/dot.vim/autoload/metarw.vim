" metarw - a framework to read/write a fake:file
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
function! metarw#complete(arglead, cmdline, cursorpos)  "{{{2
  let scheme = matchstr(a:arglead, '^[a-z]\+\ze:')
  if scheme != ''
    if s:available_scheme_p(scheme)
      let _ = metarw#{scheme}#complete(a:arglead, a:cmdline, a:cursorpos)
    else
      echoerr 'No such scheme:' string(scheme)
      let _ = []
    endif
  elseif a:arglead == ':'  " experimental
    let _ = map(s:available_schemes(), 'v:val . ":"')
  else
    let _ = split(glob(a:arglead . (a:arglead[-1:] == '*' ? '' : '*')), "\n")
    call map(_, 'v:val . (isdirectory(v:val) ? "/" : "")')
    if a:arglead == ''
      call extend(_, map(s:available_schemes(), 'v:val . ":"'))
    endif
  endif
  return _
endfunction








" Misc.  "{{{1
function! s:available_scheme_p(scheme)  "{{{2
  return 0 <= index(s:available_schemes(), a:scheme)
endfunction




function! s:available_schemes()  "{{{2
  return sort(map(
  \        split(globpath(&runtimepath, 'autoload/metarw/*.vim'), "\n"),
  \        'substitute(v:val, ''^.*/\([^/]*\)\.vim$'', ''\1'', '''')'
  \      ))
endfunction








" __END__  "{{{1
" vim: foldmethod=marker
