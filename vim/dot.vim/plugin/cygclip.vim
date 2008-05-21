" cygclip - pseude clipboard register for non-GUI version of Vim on Cygwin
" Version: 0.1
" Copyright: Copyright (C) 2007 kana <http://whileimautomaton.net/>
" License: MIT license (see <http://www.opensource.org/licenses/mit-license>)
"{{{1

if exists('g:loaded_cygclip') && has('clipboard') || !has('win32unix')
  finish
endif








" Key Mappings  "{{{1

" Old, not countable version:
"   nn <silent> <Plug>Cygclip_y  :<C-u>set operatorfunc=<SID>Yank<Return>g@
nnoremap <silent> <Plug>Cygclip_y
       \ :<C-u>set operatorfunc=<SID>Yank \| call <SID>Yank_n_y()<Return>
" Old, not countable version:
"   nn <silent> <Plug>Cygclip_Y  V:<C-u>call <SID>Yank('V')<Return>
nnoremap <silent> <Plug>Cygclip_Y  :<C-u>call <SID>Yank_n_Y()<Return>
vnoremap <silent> <Plug>Cygclip_y  :<C-u>call <SID>Yank(visualmode())<Return>
vnoremap <silent> <Plug>Cygclip_Y  :<C-u>call <SID>Yank('V')<Return>

nnoremap <silent> <Plug>Cygclip_p  :<C-u>call <SID>Put('', 'p')<Return>
nnoremap <silent> <Plug>Cygclip_P  :<C-u>call <SID>Put('', 'P')<Return>
nnoremap <silent> <Plug>Cygclip_gp  :<C-u>call <SID>Put('', 'gp')<Return>
nnoremap <silent> <Plug>Cygclip_gP  :<C-u>call <SID>Put('', 'gP')<Return>
vnoremap <silent> <Plug>Cygclip_p  :<C-u>call <SID>Put(visualmode(), 'p')<CR>
vnoremap <silent> <Plug>Cygclip_P  :<C-u>call <SID>Put(visualmode(), 'P')<CR>
vnoremap <silent> <Plug>Cygclip_gp  :<C-u>call <SID>Put(visualmode(), 'gp')<CR>
vnoremap <silent> <Plug>Cygclip_gP  :<C-u>call <SID>Put(visualmode(), 'gP')<CR>

inoremap <Plug>Cygclip_insert  <C-r>=<SID>GetClipboardContent()<Return>
cnoremap <Plug>Cygclip_insert  <C-r>=<SID>GetClipboardContent()<Return>


function! Cygclip_DefaultKeymappings()
  nmap "*  "+
  vmap "*  "+
  imap <C-r>* <C-r>+
  cmap <C-r>* <C-r>+

  nmap "+y  <Plug>Cygclip_y
  nmap "+Y  <Plug>Cygclip_Y
  vmap "+y  <Plug>Cygclip_y
  vmap "+Y  <Plug>Cygclip_Y

  nmap "+p  <Plug>Cygclip_p
  nmap "+P  <Plug>Cygclip_P
  nmap "+gp  <Plug>Cygclip_gp
  nmap "+gP  <Plug>Cygclip_gP
  vmap "+p  <Plug>Cygclip_p
  vmap "+P  <Plug>Cygclip_P
  vmap "+gp  <Plug>Cygclip_gp
  vmap "+gP  <Plug>Cygclip_gP

  imap <C-r>+  <Plug>Cygclip_insert
  cmap <C-r>+  <Plug>Cygclip_insert
endfunction


if !exists('g:cygclip_no_default_key_mappings')
  call Cygclip_DefaultKeymappings()
endif








" Functions  "{{{1

function! s:Yank(motion_type)
  let old_reg = @@

  call s:SelectLastMotion(a:motion_type)
  normal! y
  call writefile(split(@@, "\x0A", 1), '/dev/clipboard', 'b')

  let @@ = old_reg
endfunction

function! s:Yank_n_y()
  echo '<Plug>Cygclip_y{motion}'
  let c = nr2char(getchar())
  if c ==# 'y'
    call feedkeys(s:Count()."\<Plug>Cygclip_Y", 'm')
  else
    call feedkeys('g@' . s:Count() . c, 'm')
  endif
  return
endfunction

function! s:Yank_n_Y()
  let diff = s:Count() - 1
  normal! V
  if 0 < diff
    execute 'normal! '.diff.'j'
  endif
  execute "normal \<Plug>Cygclip_Y"
endfunction


function! s:Put(motion_type, put_type)
  let old_reg = @@
  let @@ = s:GetClipboardContent()

  if a:motion_type == ''
    execute 'normal!' s:Count().a:put_type
    let @@ = old_reg
  else
    call s:SelectLastMotion(a:motion_type)
    execute 'normal!' s:Count().a:put_type
  endif
endfunction




function! s:SelectLastMotion(motion_type)
  let old_selection = &selection
  let &selection = 'inclusive'

  if a:motion_type == 'char'
    silent normal! `[v`]
  elseif a:motion_type == 'line'
    silent normal! '[V']
  elseif a:motion_type == 'block'
    silent execute "normal! `[\<C-v>`]"
  else  " invoked from visual mode
    silent execute "normal! `<" . a:motion_type . "`>"
  endif

  let &selection = old_selection
endfunction


function! s:GetClipboardContent()
  let content = ''
  for line in readfile('/dev/clipboard', 'b')
    let content = content . "\x0A" . substitute(line, "\x0D", '', 'g')
  endfor
  return content[1:]
endfunction


function! s:Count()
  return (v:count == v:count1) ? v:count : ''
endfunction








" Etc  "{{{1

let g:loaded_cygclip = 1








" __END__  "{{{1
" vim: foldmethod=marker foldlevel=0
