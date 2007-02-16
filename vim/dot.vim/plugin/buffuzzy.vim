" buffuzzy -- Alternate :buffer with fuzzy pattern.
" Author: kana <http://nicht.s8.xrea.com/>
" License: MIT license (see <http://www.opensource.org/licenses/mit-license>)
" Version: 0.0
" $Id$  "{{{1

if exists('g:loaded_buffuzzy')
  finish
endif








" USER INTERFACE -- KEY MAPPINGS & COMMANDS  "{{{1

nnoremap <Plug>Buffuzzy  :<C-u>Buffuzzy<Return>
command! -bang -bar Buffuzzy  call <SID>Open('<bang>')

if !hasmapto('<Plug>Buffuzzy')
  silent! nmap <unique> <Leader>b  <Plug>Buffuzzy
endif








" FUNCTIONS  "{{{1
" MISC.  "{{{2

function! s:Open(bang)
  top new
  setlocal buftype=nofile
  setlocal bufhidden=wipe
  setlocal noswapfile
  setlocal nobuflisted
  file `='*Fuzzy Buffer Search*'`
  1 wincmd _

  let s:bang = a:bang
  let s:old_completeopt = &completeopt
  set completeopt+=menuone

  nnor <buffer>          <Return>  :call <SID>Switch('')<Return>
  nnor <buffer>          o         :call <SID>Switch('split')<Return>
  nmap <buffer>          <C-o>     o
  nnor <buffer>          v         :call <SID>Switch('vsplit')<Return>
  nmap <buffer>          <C-v>     v
  nnor <buffer> <silent> <C-c>     :call <SID>Close()<Return>
  imap <buffer>          <Return>  <Esc><Return>
  imap <buffer>          <C-c>     <Esc><C-c>
  imap <buffer>          <C-o>     <Esc><C-o>
  imap <buffer>          <C-v>     <Esc><C-v>
    " Disable whole line completion activated by <C-h> in completion.
  inor <buffer> <expr>   <C-h>     pumvisible() ? "\<C-e>\<C-h>" : "\<C-h>"
  imap <buffer>          <BS>      <C-h>

  augroup Buffuzzy
    au!
    au CursorMovedI <buffer> call <SID>OnCursorMovedI()
    au WinLeave <buffer> call <SID>Close()
    au TabLeave <buffer> call <SID>Close()
  augroup END

  startinsert
endfunction


function! s:Close()
  let n = winnr('#') - 1

  close

  execute n 'wincmd w'
  let &completeopt = s:old_completeopt
endfunction


function! s:Switch(pre_switch_command)
  let pattern = getline('.')

  call s:Close()

  if 0 < strlen(a:pre_switch_command)
    execute a:pre_switch_command
  endif
  execute s:GetCandidates(pattern, 'one') 'buffer'.s:bang
endfunction


function! s:OnCursorMovedI()
  if getline('.') !~ '^\s*$'
    call complete(1, s:GetCandidates(getline('.'), 'all'))
  endif
endfunction




" COMPLETION  "{{{2

function! s:GetCandidates(pattern, mode)
  let words = []
  for word in split(substitute(a:pattern, '/', ' / ', 'g'), '\s\+')
    call add(words, toupper(word))
  endfor

  let candidates = []
  let i = 1
  let last_buffer_number = bufnr('$')
  while i <= last_buffer_number
    if buflisted(i) && s:FuzzyMatchedP(toupper(bufname(i)), words)
      if a:mode == 'one'
        return i
      endif
      call add(candidates, bufname(i))
    endif
    let i = i + 1
  endwhile

  return insert(candidates,
              \ {'word' : a:pattern,
              \  'menu': '-- '.len(candidates).' matching --'})
endfunction


function! s:FuzzyMatchedP(s, words)
  let i = 0
  let slashedp = 0
  for word in a:words
    let slashedp = slashedp || word == '/'
    let i_slash = stridx(a:s, '/', i)
    let i_word = stridx(a:s, word, i)
    if (i_word==-1) || (slashedp && word!='/' && i_slash!=-1 && i_slash<i_word)
      return 0
    endif
    let i = i_word + strlen(word)
  endfor
  return 1
endfunction








" ETC.  "{{{1

let g:loaded_buffuzzy = 1

" __END__
" vim: foldmethod=marker
