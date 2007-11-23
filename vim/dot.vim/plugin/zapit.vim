" zapit -- Support to select files, directories, buffers, and so forth.
" Version: 0.0
" Copyright: Copyright (C) 2007 kana <http://nicht.s8.xrea.com/>
" License: MIT license (see <http://www.opensource.org/licenses/mit-license>)
" $Id$  "{{{1

if exists('g:loaded_zapit')
  finish
endif








" Interfaces  "{{{1

command! -bang -bar -nargs=1 Zapit  call <SID>Start(<q-args>, '<bang>')
command! -bang -bar ZapitBuf  Zapit<bang> buf
command! -bang -bar ZapitDir  Zapit<bang> dir
command! -bang -bar ZapitFile  Zapit<bang> file
command! -bang -bar ZapitMix  Zapit<bang> mix








" Variables  "{{{1
" Global  "{{{2

let g:ZapitModes = {}




" Script-local  "{{{2

  " The most recent value of a:bang for s:Start().
let s:Bang = ''

  " The buffer number of zapit.
let s:INVALID_BUFNR = -3339
let s:BufNr = s:INVALID_BUFNR

  " The current mode of zapit.
let s:CurrentMode = ''

  " Key sequence to start (omni) completion
  " without auto-selecting the first match.
let s:KEYS_TO_START_COMPLETION = "\<C-x>\<C-o>\<C-p>"

  " The last column of the cursor.
let s:INVALID_COL = -3338
let s:LastCol = s:INVALID_COL

  " Contains the original value of &{option}
  " before the last s:Start() called.
let s:Orig_completeopt = ''
let s:Orig_ignorecase = ''

  " Prompt for user input (to automatically activate completion).
let s:PROMPT = '>>'

  " Contains winrestcmd() to restore the window sizes
  " before the last s:Start() called.
let s:WinRestCmd = ''








" Mode Definitions  "{{{1
" FIXME: definitions for other modes.
" buf  "{{{2

let g:ZapitModes.buf = {}

function! g:ZapitModes.buf.gather_candidates(findstart, base)
  if a:findstart
    return 0
  else
    let PATTERN = s:MakePattern(a:base[len(s:PROMPT):])
    let candidates = []
    for i in range(1, bufnr('$'))
      if buflisted(i) && bufname(i) =~ PATTERN
        call add(candidates,
           \     {'word': bufname(i),
           \      'abbr': printf('%3d  ', i) . bufname(i),
           \      '_bufnr': i})
      endif
    endfor
    return candidates
  endif
endfunction

function! g:ZapitModes.buf.zap(pre_zap_command, target)
  if has_key(a:target, '_bufnr')
    if a:pre_zap_command != ''
      execute a:pre_zap_command
    endif
    execute a:target._bufnr 'buffer'.s:Bang
  else
    echohl ErrorMsg
    echo 'No such buffer' string(a:target.word[len(s:PROMPT):])
  endif
endfunction








" Main Functions  "{{{1
function! s:Start(mode, bang)  "{{{2
  if s:ZapitModeStillActiveP()
    return  " ignore this calling silently.
  endif

  let s:Bang = a:bang
  let s:CurrentMode = a:mode
  let s:LastCol = s:INVALID_BUFNR
  let s:Orig_completeopt = &completeopt
  set completeopt+=menuone
  let s:Orig_ignorecase = &ignorecase
  set ignorecase
  let s:WinRestCmd = winrestcmd()

  topleft new
  1 wincmd _
  setlocal buftype=nofile
  setlocal bufhidden=wipe
  setlocal noswapfile
  setlocal nobuflisted
  let &l:omnifunc = s:SID_PREFIX() . 'Complete'
  file `='*zapit' . a:bang . ' - ' . a:mode . '*'`
  let s:BufNr = bufnr('%')

    " FIXME: customizability.
    " FIXME: i_<C-o>: can't override omnifunc mode?
    "        -- use i_<Esc>o.
  nnoremap <buffer> <silent> <Return>  :<C-u>call <SID>Zap('')<Return>
  imap     <buffer> <silent> <Return>  <Esc><Return>
  nnoremap <buffer> <silent> <C-o>     :<C-u>call <SID>Zap('split')<Return>
  nmap     <buffer> <silent> o         <C-o>
  imap     <buffer> <silent> <C-o>     <Esc><C-o>
  nnoremap <buffer> <silent> <C-v>     :<C-u>call <SID>Zap('vsplit')<Return>
  nmap     <buffer> <silent> v         <C-v>
  imap     <buffer> <silent> <C-v>     <Esc><C-v>
  nnoremap <buffer> <silent> <C-t>     :<C-u>call <SID>Zap('')<Return>
  imap     <buffer> <silent> <C-t>     <Esc><C-t>
  nnoremap <buffer> <silent> <C-b>      :<C-u>call <SID>Zap('')<Return>
  imap     <buffer> <silent> <C-b>     <Esc><C-b>
  nnoremap <buffer> <silent> <C-c>     :<C-u>call <SID>End()<Return>
  imap     <buffer> <silent> <C-c>     <Esc><C-c>
  inoremap <buffer> <expr>   <C-n>
         \ pumvisible() ? "\<C-n>" : s:KEYS_TO_START_COMPLETION . "\<C-n>"
  inoremap <buffer> <expr>   <C-p>
         \ pumvisible() ? "\<C-p>" : s:KEYS_TO_START_COMPLETION . "\<C-p>"

  autocmd CursorMovedI <buffer> call feedkeys(<SID>OnCursorMovedI(), 'n')
  autocmd WinLeave <buffer> call <SID>End()
  autocmd TabLeave <buffer> call <SID>End()

  call feedkeys('i', 'n')
  call feedkeys(s:PROMPT, 'n')
endfunction




function! s:End()  "{{{2
  let n = winnr('#') - 1

  close

  let s:BufNr = s:INVALID_BUFNR
  let &completeopt = s:Orig_completeopt
  let &ignorecase = s:Orig_ignorecase
  execute n 'wincmd w'
  execute s:WinRestCmd
endfunction




function! s:Zap(pre_zap_command)  "{{{2
  let candidates = s:Complete(0, getline('.'))

  call s:End()

  return g:ZapitModes[s:CurrentMode].zap(a:pre_zap_command, candidates[0])
endfunction




function! s:Complete(findstart, base)  "{{{2
  let cs = g:ZapitModes[s:CurrentMode].gather_candidates(a:findstart, a:base)
  if len(cs) == 0
    return [{'word': a:base, 'abbr': 'No match found'}]
  else
    call s:Sort(cs)
    return cs
  endif
endfunction




function! s:Sort(candidates)  "{{{2
  " FIXME: NIY
  return a:candidates
endfunction




function! s:OnCursorMovedI()  "{{{2
  let l = getline('.')
  if !(len(s:PROMPT) <= len(l) && l[:len(s:PROMPT) - 1] ==# s:PROMPT)
    " if the prompt doesn't exist.
    call setline('.', s:PROMPT . l[col('.') - 1:])
    return repeat("\<Right>", len(s:PROMPT)) . s:KEYS_TO_START_COMPLETION
  elseif col('.') <= len(s:PROMPT)
    " if the cursor is inside the prompt.
    return repeat("\<Right>", len(s:PROMPT) - col('.') + 1)
  elseif len(l) < col('.') && col('.') != s:LastCol
    " if the cursor is at the end of line AND the cursor is actually moved.
    let s:LastCol = col('.')
    return s:KEYS_TO_START_COMPLETION
  else
    " none of the above cases.
    return ''
  endif
endfunction








" Misc. Functions  "{{{1
function! s:MakePattern(s)  "{{{2
  " FIXME: more nice pattern.
  let p = substitute(a:s, '[^A-Za-z0-9._-]', '', 'g')
  let ps = map(split(p, '.\zs\ze.'), 'v:val == "." ? "\\." : v:val')
  return '.*' . join(ps, '.*') . '.*'
endfunction




function! s:SID_PREFIX()  "{{{2
 return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction




function! s:ZapitModeStillActiveP()  "{{{2
  return s:BufNr != s:INVALID_BUFNR
endfunction








" Fin.  "{{{1

" FIXME: for debug.
" let g:loaded_zapit = 1








" __END__
" vim: foldmethod=marker
