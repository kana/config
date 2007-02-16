" My .vimrc
" $Id$
" SETTINGS WHICH ARE ABSOLUTELY NECESSARY  "{{{1

" To use many extensions of Vim.
set nocompatible


" To deal with Japanese language.
set encoding=japan
if !exists('did_encoding_settings') && has('iconv')
  let s:enc_euc = 'euc-jp'
  let s:enc_jis = 'iso-2022-jp'

  " Does iconv support JIS X 0213 ?
  if iconv("\x87\x64\x87\x6a", 'cp932', 'euc-jisx0213')
     \ ==# "\xad\xc5\xad\xcb"
    let s:enc_euc = 'euc-jisx0213,euc-jp'
    let s:enc_jis = 'iso-2022-jp-3'
  endif

  " Make fileencodings
  let &fileencodings = &fileencodings . ',' . s:enc_jis
  set fileencodings+=utf-8,ucs-2le,ucs-2

  if &encoding =~# '^euc-\%(jp\|jisx0213\)$'
    set fileencodings+=cp932
    let &encoding = s:enc_euc
  else
    let &fileencodings = &fileencodings .','. s:enc_euc
  endif

  unlet s:enc_euc
  unlet s:enc_jis

  let did_encoding_settings = 1
endif








" BASIC SETTINGS  "{{{1

if 1 < &t_Co && has('syntax')
  syntax enable
  colorscheme default
  set background=dark
endif

filetype plugin indent on


set autoindent
set backspace=indent,eol,start
set backup
set backupcopy&
set backupdir=.,~/tmp
set cinoptions=:0,t0,(0,W1s
set directory=.,~/tmp
set noequalalways
set history=100
set hlsearch
set grepprg=internal
set incsearch
set mouse=
set ruler
set showcmd
set showmode
set smartindent
set updatetime=60000
set title
set titlestring=vi:\ %f\ %h%r%m

set viminfo=<50,'10,h,r/a,n~/.viminfo

" To detect the width and the height of the terminal automatically,
" the followings must not be set.
"
" set columns=80
" set lines=25


let mapleader=','








" UTILITY FUNCTIONS & COMMANDS "{{{1
" Misc.  "{{{2

function! s:ToggleOption(option_name)
  execute 'setlocal' a:option_name.'!'
  execute 'setlocal' a:option_name.'?'
endfunction


function! s:ExtendHighlight(target_group, original_group, new_settings)
  redir => resp
  silent execute 'highlight' a:original_group
  redir END
  if resp =~# 'xxx cleared'
    let original_settings = ''
  elseif resp =~# 'xxx links to'
    return s:ExtendHighlight(
         \   a:target_group,
         \   substitute(resp, '\_.*xxx links to\s\+\(\S\+\)', '\1', ''),
         \   a:new_settings
         \ )
  else  " xxx {key}={arg} ...
    let t = substitute(resp,'\_.*xxx\(\(\_s\+[^= \t]\+=[^= \t]\+\)*\)','\1','')
    let original_settings = substitute(t, '\_s\+', ' ', 'g')
  endif

  silent execute 'highlight' a:target_group 'NONE'
           \ '|' 'highlight' a:target_group original_settings
           \ '|' 'highlight' a:target_group a:new_settings
endfunction


function! s:CreateTemporaryBuffer(name)
    hide enew
    setlocal bufhidden=wipe buflisted buftype=nofile noswapfile
    file `=a:name`
endfunction

function! s:CreateCommandOutputBuffer(command)
  call s:CreateTemporaryBuffer(a:command)
  silent execute 'read !' a:command
  1
  delete
endfunction

command! -nargs=? -complete=file -bar SvnDiff
  \ call s:CreateCommandOutputBuffer('svn diff')
  \ | setfiletype diff




" :edit with specified 'fileencoding'.  "{{{2
com! -nargs=? -complete=file -bang -bar Cp932 edit<bang> ++enc=cp932 <args>
com! -nargs=? -complete=file -bang -bar Eucjp edit<bang> ++enc=euc-jp <args>
com! -nargs=? -complete=file -bang -bar Iso2022jp Jis<bang> <args>
com! -nargs=? -complete=file -bang -bar Jis edit<bang> ++enc=iso-2022-jp <args>
com! -nargs=? -complete=file -bang -bar Sjis Cp932<bang> <args>
com! -nargs=? -complete=file -bang -bar Utf8 edit<bang> ++enc=utf-8 <args>




" :Buffer -- alternate :buffer with unescaped buffer name completion.  "{{{2

command! -complete=customlist,<SID>Complete_UnescapedBufferName -nargs=1
  \ Buffer buffer <args>
cnoremap <expr> b<Space>  getcmdtype()==':'&&getcmdpos()==1 ? 'Buffer ' : 'b '


function! s:Complete_UnescapedBufferName(ArgLead, CmdLine, CursorPos)
  let candidates = []
  for name in s:GetAllListedBufferNames()
    if stridx(toupper(name), toupper(a:ArgLead)) != -1  " case-insensitive
      call add(candidates, name)
    end
  endfor
  return candidates
endfunction

function! s:GetAllListedBufferNames()
  let names = []
  let i = 1
  while i <= bufnr('$')
    if buflisted(i)
      call add(names, bufname(i))
    endif
    let i = i + 1
  endwhile
  return names
endfunction




" Jump sections  "{{{2

" for normal mode.  a:pattern is '/regexp' or '?regexp'.
function! s:JumpSectionN(pattern)
  let pattern = strpart(a:pattern, '1')
  if strpart(a:pattern, 0, 1) == '/'
    let flags = 'W'
  else
    let flags = 'Wb'
  endif

  mark '
  let i = 0
  while i < v:count1
    if search(pattern, flags) == 0
      if stridx(flags, 'b') != -1
        normal! gg
      else
        normal! G
      endif
      break
    endif
    let i = i + 1
  endwhile
endfunction


" for visual mode.  a:motion is '[[', '[]', ']]' or ']['.
function! s:JumpSectionV(motion)
  execute 'normal!' "gv\<Esc>"
  execute 'normal' v:count1 . a:motion
  let line = line('.')
  let col = col('.')

  normal! gv
  call cursor(line, col)
endfunction


" for operator-pending mode.  a:motion is '[[', '[]', ']]' or ']['.
function! s:JumpSectionO(motion)
  execute 'normal' v:count1 . a:motion
endfunction




" Yank/Put with the Windows' clipboard in Cygwin.  "{{{2
" BUGS: Putting is always characterwise.
" BUGS: The last <EOL> in text to be put is always stripped.

if has('win32unix') && !has('clipboard')
  " Key mapping
  nmap "*  "+
  vmap "*  "+

  nnoremap <silent> "+y  :set operatorfunc=<SID>YankToClipboard<Return>g@
  nmap "+yy  V"+y
  nmap "+Y  "+yy
  vnoremap <silent> "+y  :<C-u>call <SID>YankToClipboard(visualmode())<Return>
  vnoremap <silent> "+Y  :<C-u>call <SID>YankToClipboard('V')<Return>

  nnoremap <silent> "+p  :call <SID>PutFromClipboard('', 'p')<Return>
  nnoremap <silent> "+P  :call <SID>PutFromClipboard('', 'P')<Return>
  vnoremap <silent> "+p  :<C-u>call <SID>PutFromClipboard(visualmode(),'p')<CR>
  vnoremap <silent> "+P  :<C-u>call <SID>PutFromClipboard(visualmode(),'P')<CR>


  " Main functions
  function! s:YankToClipboard(motion_type)
    let old_reg = @@
    call s:SelectLastMotion(a:motion_type)
    normal! y
    new
    setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted
    setlocal binary noendofline
    silent normal! P
    silent write! /dev/clipboard
    bwipe
    let @@ = old_reg
  endfunction

  function! s:PutFromClipboard(motion_type, put_type)
    let old_reg = @@
    call s:GetClipboardContent()

    if a:motion_type == ''
      execute 'normal' a:put_type
      let @@ = old_reg
    else
      call s:SelectLastMotion(a:motion_type)
      execute 'normal' a:put_type
    endif
  endfunction


  " Misc. functions
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
    new
    setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted
    read !getclip
    silent normal! ggj0vG$hy
    bwipe
  endfunction
endif




" Text objects -- C functions  "{{{2
"
" Assumes that C functions are written in the following style:
"
"   return-type
"   function-name(arg1, arg2, ..., argN)
"   {
"     ...
"   }
"
" * return-type must be written in one line.
"
" * function-name must be followed by ``(''.
"
" * argument list may be written in one or more lines,
"   but the last line must end with ``)''.
"
" BUGS: Visual mode will be linewise after these text objects.
"
" BUGS: In visual mode, the previous selection will be forgotten
"       and will be replaced by new selection with this text object.
"
" BUGS: If the cursor is out of any C functions,
"       these text objects will select the next C function after the cursor.

function! s:TextObject_CFunction_Inner()
  let current_position = getpos('.')

  if getline('.') != '}'
    normal ][
  endif
  let e = line('.')
  normal [[
  let b = line('.')

  if 1 < e - b  " is there some code?
    execute 'normal!' (b+1).'G'
    normal! V
    execute 'normal!' (e-1).'G'
  else  " is there no code?
    if mode() == 'n'  " operator-pending mode?
      call setpos('.', current_position)
    else  " visual mode?
      normal! gv
    endif
  endif
endfunction


function! s:TextObject_CFunction_All()
  if getline('.') != '}'
    normal ][
  endif
  let e = line('.')
  normal [[k$%0k
  let b = line('.')

  execute 'normal' b.'G'
  normal V
  execute 'normal' e.'G'
endfunction








" KEY MAPPINGS  "{{{1
" Misc.  "{{{2

nnoremap \  :call <SID>ToggleOption('wrap')<Return>
nnoremap <C-h>  :h<Space>
nnoremap <Space>  <Nop>
nnoremap <Space>i  :setlocal filetype? fileencoding? fileformat?<Return>
nnoremap <Space>e  :setlocal encoding? termencoding? fenc? fencs?<Return>
nnoremap <Space>ss  :source %<Return>
nnoremap <Space>s.  :source $HOME/.vimrc<Return>
vnoremap <Space>s  :sort<Return>
nnoremap <Leader>cD  :top split \| SvnDiff<Return>

" Jump list
nnoremap <C-j>  <C-i>
nnoremap <C-k>  <C-o>

" Switch to the previously edited file (like Vz)
nnoremap <F2>  :e #<Return>
nnoremap <Esc>2  :e #<Return>

" Visiting windows with one key.
nnoremap <Tab>  <C-w>w
nnoremap <C-i>  <C-w>w
nnoremap <S-Tab>  <C-w>W
nnoremap <Esc>i  <C-w>W

" Too lazy to press Shift key.
nnoremap ;  :
vnoremap ;  :

" Disable some dangerous key.
nnoremap ZZ  <Nop>
nnoremap ZQ  <Nop>

" Ex-mode will be never used and recordings are rarely used.
nnoremap Q  q




" Quickfix hotkeys  "{{{2
nnoremap qj  :cnext<Return>
nnoremap qk  :cprevious<Return>
nnoremap qr  :crewind<Return>
nnoremap qK  :cfirst<Return>
nnoremap qJ  :clast<Return>
nnoremap qf  :cnfile<Return>
nnoremap qF  :cpfile<Return>
nnoremap ql  :clist<Return>
nnoremap qq  :cc<Return>
nnoremap qo  :copen<Return>
nnoremap qc  :cclose<Return>
nnoremap qw  :cwindow<Return>
nnoremap qp  :colder<Return>
nnoremap qn  :cnewer<Return>
nnoremap qm  :make<Return>
nnoremap qM  :make<Space>
nnoremap qg  :grep<Space>
nnoremap q   <Nop>




" For command-line editting  "{{{2
cnoremap <C-u>  <C-e><C-u>

cnoremap <Esc>h  <Left>
cnoremap <Esc>j  <Down>
cnoremap <Esc>k  <Up>
cnoremap <Esc>l  <Right>
cnoremap <Esc>H  <Home>
cnoremap <Esc>L  <End>
cnoremap <Esc>w  <S-Right>
cnoremap <Esc>b  <S-Left>
cnoremap <Esc>x  <Del>




" Input the current date/time (Full, Date, Time).  "{{{2
inoremap <Leader>dF  <C-r>=strftime('%Y-%m-%dT%H:%M:%S+09:00')<Return>
inoremap <Leader>df  <C-r>=strftime('%Y-%m-%dT%H:%M:%S')<Return>
inoremap <Leader>dd  <C-r>=strftime('%Y-%m-%d')<Return>
inoremap <Leader>dT  <C-r>=strftime('%H:%M:%S')<Return>
inoremap <Leader>dt  <C-r>=strftime('%H:%M')<Return>




" Enable ]] and other motions in visual and operator-pending mode.  "{{{2
vnoremap <silent> ]]  :<C-u>call <SID>JumpSectionV(']]')<Return>
vnoremap <silent> ][  :<C-u>call <SID>JumpSectionV('][')<Return>
vnoremap <silent> [[  :<C-u>call <SID>JumpSectionV('[[')<Return>
vnoremap <silent> []  :<C-u>call <SID>JumpSectionV('[]')<Return>
onoremap <silent> ]]  :<C-u>call <SID>JumpSectionO(']]')<Return>
onoremap <silent> ][  :<C-u>call <SID>JumpSectionO('][')<Return>
onoremap <silent> [[  :<C-u>call <SID>JumpSectionO('[[')<Return>
onoremap <silent> []  :<C-u>call <SID>JumpSectionO('[]')<Return>








" FILETYPE  "{{{1

augroup MyAutoCmd
  autocmd!

  autocmd FileType c
    \ call <SID>FileType_c()

  autocmd FileType dosini
    \ call <SID>FileType_dosini()

  autocmd FileType python
    \ call <SID>SetShortIndent()
    \ | let python_highlight_numbers=1
    \ | let python_highlight_builtins=1
    \ | let python_highlight_space_errors=1

  autocmd FileType vim
    \ call <SID>SetShortIndent()
    \ | let vim_indent_cont = &shiftwidth

  " Misc.
  autocmd FileType html,xhtml,xml,xslt,sh,tex
    \ call <SID>SetShortIndent()

  autocmd FileType *
    \ call <SID>FileType_any()

  autocmd ColorScheme *
    \   call <SID>ExtendHighlight('Pmenu', 'Normal', 'cterm=underline')
    \ | call <SID>ExtendHighlight('PmenuSel', 'Search', 'cterm=underline')
    \ | call <SID>ExtendHighlight('PmenuSbar', 'Normal', 'cterm=reverse')
    \ | call <SID>ExtendHighlight('PmenuThumb', 'Search', '')
  doautocmd ColorScheme because-colorscheme-has-been-set-above.
augroup END


function! s:SetShortIndent()
  setlocal expandtab softtabstop=2 shiftwidth=2
endfunction




function! s:FileType_any()
  " To use my global mappings for section jumping,
  " remove buffer local mappings for them.
  silent! vunmap <buffer>  ]]
  silent! vunmap <buffer>  ][
  silent! vunmap <buffer>  []
  silent! vunmap <buffer>  [[
  silent! ounmap <buffer>  ]]
  silent! ounmap <buffer>  ][
  silent! ounmap <buffer>  []
  silent! ounmap <buffer>  [[
endfunction




function! s:FileType_c()
  vnorem <buffer> <silent> if  :<C-u>call <SID>TextObject_CFunction_Inner()<CR>
  vnorem <buffer> <silent> af  :<C-u>call <SID>TextObject_CFunction_All()<CR>
  onorem <buffer> <silent> if  :<C-u>call <SID>TextObject_CFunction_Inner()<CR>
  onorem <buffer> <silent> af  :<C-u>call <SID>TextObject_CFunction_All()<CR>
endfunction




function! s:FileType_dosini()
  nnoremap <buffer> <silent> ]]  :<C-u>call <SID>JumpSectionN('/^\[')<Return>
  nnoremap <buffer> <silent> ][  :<C-u>call <SID>JumpSectionN('/\n\[\@=')<CR>
  nnoremap <buffer> <silent> [[  :<C-u>call <SID>JumpSectionN('?^\[')<Return>
  nnoremap <buffer> <silent> []  :<C-u>call <SID>JumpSectionN('?\n\[\@=')<CR>
endfunction




let g:is_bash = 1








" MISC.  "{{{1

" Plugin: vcscommand
let g:VCSCommandDeleteOnHide = 1




set secure

" __END__
" vim: foldmethod=marker
