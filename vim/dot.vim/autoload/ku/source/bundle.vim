" ku source: bundle
" Version: 0.2.0
" Copyright (C) 2008-2009 kana <http://whileimautomaton.net/>
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
" Variables  "{{{1

let s:KINDS_FOR_A_FILE_IN_A_BUNDLE = ['file', 'buffer', 'common']
let s:REGEXP_BUNDLE_PATH_SEPARATOR = '[/\\]'








" Interface  "{{{1
function! ku#source#bundle#action_args(candidate)  "{{{2
  return s:call('bundle#args', !!0, a:candidate.word)
endfunction




function! ku#source#bundle#action_args_x(candidate)  "{{{2
  return s:call('bundle#args', !0, a:candidate.word)
endfunction




function! ku#source#bundle#action_load(candidate)  "{{{2
  return s:call('bundle#load', !!0, a:candidate.word)
endfunction




function! ku#source#bundle#action_load_x(candidate)  "{{{2
  return s:call('bundle#load', !0, a:candidate.word)
endfunction




function! ku#source#bundle#gather_candidates(args)  "{{{2
  " FIXME: More caching

  let i = match(a:args.pattern, s:REGEXP_BUNDLE_PATH_SEPARATOR)
  if 0 <= i  " args.pattern is '{bundle}/{path}' - list files in the {bundle}
    let bundle_name = a:args.pattern[:i-1]
    let j = index(bundle#available_bundles(), bundle_name)
    return map((0 <= j ? copy(bundle#files(bundle_name)) : []),
    \          '{"word": bundle_name . a:args.pattern[i] . v:val,
    \            "ku__kinds": s:KINDS_FOR_A_FILE_IN_A_BUNDLE,
    \            "ku_file_path": v:val}')
  else  " args.pattern is '{bundle}' - list bundles
    return map(copy(bundle#available_bundles()), '{"word": v:val}')
  endif
endfunction








" Misc.  "{{{1
function! s:call(function_name, banged_p, bundle_name)  "{{{2
  let v:errmsg = ''

  silent! let succeeded_p = {a:function_name}(a:banged_p, a:bundle_name) != 0
  if !succeeded_p
    let v:errmsg = 'No such bundle: ' . a:bundle_name
  endif

  return v:errmsg == '' ? 0 : v:errmsg
endfunction








" __END__  "{{{1
" vim: foldmethod=marker
