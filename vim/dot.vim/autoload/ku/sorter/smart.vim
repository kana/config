" ku-sorter-smart - Smart sorter
" Version: 0.0.0
" Copyright (C) 2009 kana <http://whileimautomaton.net/>
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
function! ku#sorter#smart#sort(lcandidates, args)  "{{{2
  let _ = copy(a:lcandidates)

  call map(_, '[s:score(v:val.word, a:args.pattern), v:val]')
  call filter(_, '0 < v:val[0]')
  call sort(_, 's:compare')
  call map(_, 'v:val[1]')

  return _
endfunction








" Misc.  "{{{1
function! ku#sorter#smart#_scope()  "{{{2
  return s:
endfunction




function! ku#sorter#smart#_sid()  "{{{2
  nnoremap <SID>  <SID>
  return maparg('<SID>', 'n')
endfunction




function! s:compare(...)  "{{{2
  return a:2[0] - a:1[0]
endfunction




function! s:score(word, pattern)  "{{{2
  " Return value is an N-digit integer corresponding to an (3+M)-digit real
  " number, where 3+M-1 is the number of decimal places of the real number.
  " For example, if M = 2, 9876 means 0.9876 = 098.76%.
  "
  " Notation: l{x} = Length of {x}
  " FIXME: Scoring on case-sensitivity
  " FIXME: Scoring on tokens
  let PCT = 1  " To denote 97% as '97*PCT'
  let w = toupper(a:word)  " w = Word
  let p = toupper(a:pattern)  " p = Pattern
  let lw = len(w)
  let lp = len(p)

  if lw < lp  " p never matches to w
    return 0*PCT * s:BASE
  endif
  if lp == 0  " Base cases
    return 90*PCT * s:BASE
  endif

  " Calculate score.
  for lhp in range(lp, 1, -1)
    let hp = p[:lhp-1]  " hp = Head of Pattern
    let lit = stridx(w, hp)  " it = Ignored Text
    if 0 <= lit
      let rest_word = w[(lhp+lit):]
      let rest_pattern = p[(lhp):]
      let rest_score = s:score(rest_word, rest_pattern)
      if 0 < rest_score
        return (((lit * 0*PCT * s:BASE)
        \        + (lhp * 100*PCT * s:BASE)
        \        + (len(rest_word) * rest_score))
        \       / lw)
      endif
    endif
  endfor

  " p doesn't match to w
  return 0*PCT * s:BASE
endfunction

let s:M = 2
let s:BASE = ('1' . repeat('0', s:M)) + 0








" __END__  "{{{1
" vim: foldmethod=marker
