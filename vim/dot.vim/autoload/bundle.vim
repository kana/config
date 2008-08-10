" bundle - Load a series of files easily
" Version: 0.0.1
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
" Variables  "{{{1

" See s:value_of().
let s:EVENT = {
\     'BundleAvailability': 'BundleAvailability',
\     'BundleUndefined': 'BundleUndefined',
\     'BundleUndefined!': 'BundleUndefined!',
\     'Invalid': 'Invalid',
\   }
let s:current_event = s:EVENT['Invalid']
let s:return_values = []








" Interface  "{{{1
function! bundle#args(banged_p, name)  "{{{2
  let bundle = s:find_proper_bundle(a:name)
  if bundle is 0
    return !!0
  endif

  execute 'args'.(a:banged_p ? '!' : '')
  \       join(map(copy(bundle), 'fnameescape(v:val)'))

  return !0
endfunction




function! bundle#complete(arglead, cmdline, cursorpos)  "{{{2
  return sort(filter(
  \        s:value_of('BundleAvailability') + keys(g:bundle_dictionary),
  \        'stridx(v:val, a:arglead) == 0'
  \      ))
endfunction




function! bundle#files(name)  "{{{2
  silent let bundle = s:find_proper_bundle(a:name)
  return bundle is 0 ? [] : bundle
endfunction




function! bundle#load(banged_p, name)  "{{{2
  let bundle = s:find_proper_bundle(a:name)
  if bundle is 0
    return !!0
  endif

  if a:banged_p
    let curbufnr = bufnr('')
    for file in bundle
      silent keepalt edit `=file`
    endfor
    execute 'silent keepalt' curbufnr 'buffer'
  else
    for file in bundle
      badd `=file`
    endfor
  endif

  return !0
endfunction




function! bundle#name()  "{{{2
  return matchstr(expand('<amatch>'), '\<BundleUndefined\+!\?:\zs.*$')
endfunction




function! bundle#return(...)  "{{{2
  if s:current_event is s:EVENT['BundleAvailability']
    call extend(s:return_values, a:1)
  elseif s:current_event is s:EVENT['BundleUndefined']
  \      || s:current_event is s:EVENT['BundleUndefined!']
    call add(s:return_values, a:1)
  else
    " Ignore.
  endif
  return
endfunction








" Misc.  "{{{1
function! s:find_proper_bundle(name)  "{{{2
  let bundles = s:value_of('BundleUndefined!', a:name)
  if 0 < len(bundles)
    return bundles[0]
  endif

  let _ = get(g:bundle_dictionary, a:name, 0)
  if _ isnot 0
    return _
  endif

  let bundles = s:value_of('BundleUndefined', a:name)
  if 0 < len(bundles)
    let g:bundle_dictionary[a:name] = bundles[0]
    return bundles[0]
  endif

  echo 'No such bundle:' string(a:name)
  return 0
endfunction




function! s:value_of(event_name, ...)  "{{{2
  let s:current_event = s:EVENT[a:event_name]
    let s:return_values = []
    silent execute 'doautocmd User' a:event_name.(1 <= a:0 ? ':'.a:1 : '')
  let s:current_event = s:EVENT['Invalid']

  return s:return_values
endfunction








" __END__  "{{{1
" vim: foldmethod=marker
