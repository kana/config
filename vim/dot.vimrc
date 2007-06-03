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


if $ENV_ACCESS ==# 'cygwin'  " accessed from Windows.
  set termencoding=cp932
else  " accessd from *nix.
  set termencoding=euc-jp
endif








" BASIC SETTINGS  "{{{1

if 1 < &t_Co && has('syntax')
  if &term ==# 'rxvt-cygwin-native'
    set t_Co=256
  endif
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
let maplocalleader='.'








" UTILITY FUNCTIONS & COMMANDS "{{{1
" Misc.  "{{{2

function! s:ToggleBell()
  if &visualbell
    set novisualbell t_vb&
    echo 'bell on'
  else
    set visualbell t_vb=
    echo 'bell off'
  endif
endfunction

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


function! s:Count(...)
  if v:count == v:count1  " count is specified.
    return v:count
  else  " count is not specified.  (the default '' is useful for special value)
    return a:0 == 0 ? '' : a:1
  endif
endfunction

command! -nargs=* -complete=expression -range -count=0 Execute
       \ call s:Execute(<f-args>)
function! s:Execute(...)
  let args = []
  for a in a:000
    if a ==# '[count]'
      let a = s:Count()
    endif
    call add(args, a)
  endfor
  execute join(args)
endfunction




" High-level key sequences  "{{{2

function! s:KeysToComplete()
  if strlen(&omnifunc)
    return "\<C-x>\<C-o>"
  elseif &filetype ==# 'vim'
    return "\<C-x>\<C-v>"
  else
    return "\<C-n>"
  endif
endfunction

function! s:KeysToStopInsertModeCompletion()
  if pumvisible()
    return "\<C-y>"
  else
    return "\<Space>\<BS>"
  endif
endfunction




" :edit with specified 'fileencoding'.  "{{{2
com! -nargs=? -complete=file -bang -bar Cp932  edit<bang> ++enc=cp932 <args>
com! -nargs=? -complete=file -bang -bar Eucjp  edit<bang> ++enc=euc-jp <args>
com! -nargs=? -complete=file -bang -bar Iso2022jp  Jis<bang> <args>
com! -nargs=? -complete=file -bang -bar Jis edit<bang> ++enc=iso-2022-jp <args>
com! -nargs=? -complete=file -bang -bar Sjis  Cp932<bang> <args>
com! -nargs=? -complete=file -bang -bar Utf8  edit<bang> ++enc=utf-8 <args>




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
      execute 'normal!' a:put_type
      let @@ = old_reg
    else
      call s:SelectLastMotion(a:motion_type)
      execute 'normal!' a:put_type
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








" KEY MAPPINGS  "{{{1
" RULES:
" - Don't use special keys such as <Tab>.
"   Use equivalent keys such as <C-i> instead.

" Misc.  "{{{2

nnoremap <C-h>  :h<Space>
nnoremap <Leader>cD  :top split \| SvnDiff<Return>


" Various hotkeys prefixed by <Space>.
  " To show <Space> in the bottom line.
map      <Space>  [Space]

noremap  [Space]  <Nop>
nnoremap [Space]/  :nohlsearch<Return>
nmap     [Space]b  <Plug>Buffuzzy
nnoremap [Space]e  :setlocal encoding? termencoding? fenc? fencs?<Return>
nnoremap [Space]i  :setlocal filetype? fileencoding? fileformat?<Return>
nnoremap [Space]ob  :call <SID>ToggleBell()<Return>
nnoremap [Space]ow  :call <SID>ToggleOption('wrap')<Return>
nnoremap [Space]s  <Nop>
nnoremap [Space]s.  :source $HOME/.vimrc<Return>
nnoremap [Space]ss  :source %<Return>
vnoremap [Space]s  :sort<Return>
nmap     [Space]w  [Space]ow


" Jump list
nnoremap <C-j>  <C-i>
nnoremap <C-k>  <C-o>


" Switch to the previously edited file (like Vz)
nnoremap <Esc>2  :e #<Return>
nmap <F2>  <Esc>2


" Visiting windows with one key.
nnoremap <C-i>  <C-w>w
nnoremap <Esc>i  <C-w>W


" Too lazy to press Shift key.
noremap ;  :
noremap :  ;


" Disable some dangerous key.
nnoremap ZZ  <Nop>
nnoremap ZQ  <Nop>


" Ex-mode will be never used and recordings are rarely used.
nnoremap Q  q


" Use a backslash (\) to repeat last change.
" Since a dot (.) is used as <LocalLeader>.
nnoremap \  .


" Search slashes easily (I'm too lazy to prefix backslashes to slashes.)
cnoremap <expr> /  getcmdtype() == '/' ? '\/' : '/'


" Complete or indent.
inoremap <expr> <C-i> (<SID>ShouldIndentRatherThanCompleteP()
                     \ ? '<C-i>'
                     \ : <SID>KeysToComplete())

function! s:ShouldIndentRatherThanCompleteP()
  let m = match(getline('.'), '\S')
  return m == -1 || col('.')-1 <= m
endfunction




" For plugin: scratch  "{{{2
" The default ``execution'' key, <C-m>, is used for tag jumping.
" But in the scratch buffer, I don't use tag jumping, so override them.
augroup Scratch
  au!
  au User Initialize  nmap <buffer> <C-m>  <Plug>Scratch_ExecuteLine
  au User Initialize  vmap <buffer> <C-m>  <Plug>Scratch_ExecuteSelection
augroup END




" Tag-related hotkeys  "{{{2
" Fallback  "{{{3

" ``T'' is also disabled for consistency.
noremap  t  <Nop>
noremap  T  <Nop>

" Alternatives for the original actions.
noremap  [Space]t  t
noremap  [Space]T  T


" Basics  "{{{3
nmap     t<Space>  tt
vmap     t<Space>  tt
nnoremap tt  <C-]>
vnoremap tt  <C-]>
nnoremap tj  :tag<Return>
nnoremap tk  :pop<Return>
nnoremap tl  :tags<Return>
nnoremap tn  :tnext<Return>
nnoremap tp  :tprevious<Return>
nnoremap tP  :tfirst<Return>
nnoremap tN  :tlast<Return>

" additionals, like Web browsers
nmap     <C-m>  tt
vmap     <C-m>  tt


" With preview window  "{{{3
nmap     t'<Space>  t't
vmap     t'<Space>  t't
nnoremap t't  <C-w>}
vnoremap t't  <C-w>}
nnoremap t'n  :ptnext<Return>
nnoremap t'p  :ptpevious<Return>
nnoremap t'P  :ptfirst<Return>
nnoremap t'N  :ptlast<Return>

" although :pclose is not related to tag.
nnoremap t'c  :pclose<Return>


" With :split  "{{{3
nnoremap tst  <C-w>]
vnoremap tst  <C-w>]
nmap     ts<Space>  tst
vmap     ts<Space>  tst
nnoremap tsn  :split \| tnext<Return>
nnoremap tsp  :split \| tpevious<Return>
nnoremap tsP  :split \| tfirst<Return>
nnoremap tsN  :split \| tlast<Return>


" With :vertical split  "{{{3
  " |:vsplit|-then-|<C-]>| is simple
  " but its modification to tag stacks is not same as |<C-w>]|.
nnoremap tvt  <C-]>:vsplit<Return><C-w>p<C-t><C-w>p
vnoremap tvt  <C-]>:vsplit<Return><C-w>p<C-t><C-w>p
nmap     tv<Space>  tvt
vmap     tv<Space>  tvt
nnoremap tvn  :vsplit \| tnext<Return>
nnoremap tvp  :vsplit \| tpevious<Return>
nnoremap tvP  :vsplit \| tfirst<Return>
nnoremap tvN  :vsplit \| tlast<Return>




" Quickfix hotkeys  "{{{2
" Fallback
nnoremap q  <Nop>

" For quickfix list
nnoremap qj        :Execute cnext [count]<Return>
nnoremap qk        :Execute cprevious [count]<Return>
nnoremap qr        :Execute crewind [count]<Return>
nnoremap qK        :Execute cfirst [count]<Return>
nnoremap qJ        :Execute clast [count]<Return>
nnoremap qfj       :Execute cnfile [count]<Return>
nnoremap qfk       :Execute cpfile [count]<Return>
nnoremap ql        :clist<Return>
nnoremap qq        :Execute cc [count]<Return>
nnoremap qo        :Execute copen [count]<Return>
nnoremap qc        :cclose<Return>
nnoremap qp        :Execute colder [count]<Return>
nnoremap qn        :Execute cnewer [count]<Return>
nnoremap qm        :make<Return>
nnoremap qM        :make<Space>
nnoremap q<Space>  :make<Space>
nnoremap qg        :grep<Space>

" For location list (mnemonic: Quickfix list for the current Window)
nnoremap qwj        :Execute lnext [count]<Return>
nnoremap qwk        :Execute lprevious [count]<Return>
nnoremap qwr        :Execute lrewind [count]<Return>
nnoremap qwK        :Execute lfirst [count]<Return>
nnoremap qwJ        :Execute llast [count]<Return>
nnoremap qwfj       :Execute lnfile [count]<Return>
nnoremap qwfk       :Execute lpfile [count]<Return>
nnoremap qwl        :llist<Return>
nnoremap qwq        :Execute ll [count]<Return>
nnoremap qwo        :Execute lopen [count]<Return>
nnoremap qwc        :lclose<Return>
nnoremap qwp        :Execute lolder [count]<Return>
nnoremap qwn        :Execute lnewer [count]<Return>
nnoremap qwm        :lmake<Return>
nnoremap qwM        :lmake<Space>
nnoremap qw<Space>  :lmake<Space>
nnoremap qwg        :lgrep<Space>




" Tab-pages hotkeys  "{{{2
" FIXME: sometimes, hit-enter prompt appears.  but no idea for the reason.
" Misc.  "{{{3
nnoremap <C-t>  <Nop>

nnoremap <C-t>n  :<C-u>tabnew<Return>
nnoremap <C-t>c  :<C-u>tabclose<Return>
nnoremap <C-t>o  :<C-u>tabonly<Return>
nnoremap <C-t>i  :<C-u>tabs<Return>

nmap <C-t><C-n>  <C-t>n
nmap <C-t><C-c>  <C-t>c
nmap <C-t><C-o>  <C-t>o
nmap <C-t><C-i>  <C-t>i


" Moving around tabs.  "{{{3
nnoremap <C-t>j  :<C-u>execute 'tabnext'
                 \ 1 + (tabpagenr() + v:count1 - 1) % tabpagenr('$')<Return>
nnoremap <C-t>k  :Execute tabprevious [count]<Return>
nnoremap <C-t>K  :<C-u>tabfirst<Return>
nnoremap <C-t>J  :<C-u>tablast<Return>
nmap <C-t>t  <C-t>j
nmap <C-t>T  <C-t>k

nmap <C-t><C-j>  <C-t>j
nmap <C-t><C-k>  <C-t>k
nmap <C-t><C-t>  <C-t>t


" Moving tabs themselves.  "{{{3
nnoremap <C-t>l  :<C-u>execute 'tabmove'
                 \ min([tabpagenr() + v:count1 - 1, tabpagenr('$')])<Return>
nnoremap <C-t>h  :<C-u>execute 'tabmove'
                 \ max([tabpagenr() - v:count1 - 1, 0])<Return>
nnoremap <C-t>L  :<C-u>tabmove<Return>
nnoremap <C-t>H  :<C-u>tabmove 0<Return>

nmap <C-t><C-l>  <C-t>l
nmap <C-t><C-h>  <C-t>h




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
" Misc.  "{{{2

augroup MyAutoCmd
  autocmd!

  autocmd FileType dosini
    \ call <SID>FileType_dosini()

  autocmd FileType python
    \ call <SID>SetShortIndent()
    \ | let python_highlight_numbers=1
    \ | let python_highlight_builtins=1
    \ | let python_highlight_space_errors=1

  autocmd FileType vim
    \ call <SID>FileType_vim()

  autocmd FileType html,xhtml,xml,xslt
    \ call <SID>FileType_xml()

  " Misc.
  autocmd FileType lua,sh,tex
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




" All  "{{{2

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




" Dosini (.ini)  "{{{2

function! s:FileType_dosini()
  nnoremap <buffer> <silent> ]]  :<C-u>call <SID>JumpSectionN('/^\[')<Return>
  nnoremap <buffer> <silent> ][  :<C-u>call <SID>JumpSectionN('/\n\[\@=')<CR>
  nnoremap <buffer> <silent> [[  :<C-u>call <SID>JumpSectionN('?^\[')<Return>
  nnoremap <buffer> <silent> []  :<C-u>call <SID>JumpSectionN('?\n\[\@=')<CR>
endfunction




" sh  "{{{2

let g:is_bash = 1




" Vim  "{{{2

function! s:FileType_vim()
  call <SID>SetShortIndent()
  let vim_indent_cont = &shiftwidth
endfunction




" XML/SGML and other applications  "{{{2

function! s:FileType_xml()
  call <SID>SetShortIndent()

  " To deal with namespace prefixes and tag-name-including-hyphens.
  setlocal iskeyword+=45  " hyphen (-)
  setlocal iskeyword+=58  " colon (:)

  " Support to input.
  inoremap <buffer> <LT>?  </
  imap     <buffer> ?<LT>  <LT>?
  inoremap <buffer> ?>  />
  imap     <buffer> >?  ?>

  " Complete end-tags or the tail of empty-element tags.
  " In the followings, {|} means the cursor position.

    " Image: Insert the end tag after the cursor.
    " Before: <code{|}
    " After:  <code>{|}</code>
  inoremap <buffer> >>  ><LT>/<C-x><C-o><C-r>=
                     \    <SID>KeysToStopInsertModeCompletion()
                     \  <Return><C-o>F<LT>

    " Image: Wrap the cursor with the tag.
    " Before: <code{|}
    " After:  <code>
    "           {|}
    "         </code>
  inoremap <buffer> ><LT>  ><Return>X<Return><LT>/<C-x><C-o><C-r>=
                        \    <SID>KeysToStopInsertModeCompletion()
                        \  <Return><C-o><Up><BS>
endfunction








" MISC.  "{{{1

" Plugin: vcscommand
let g:VCSCommandDeleteOnHide = 1




" Plugin: xml_autons
let g:AutoXMLns_Dict = {}
let g:AutoXMLns_Dict['http://www.w3.org/2000/svg'] = 'svg11'




set secure

" __END__
" vim: foldmethod=marker
