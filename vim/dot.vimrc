" My .vimrc
" $Id$
" Notes  "{{{1
"
" * This file consists of "sections".
"
"   - The name of each section should be one word.
"
" * Each section consists of zero or more "subsections".
"
"   - There is no rule for the name of each subsection.
"
" * The last subsection in a section should be named as "Misc.".
"
" * Whenever new subsection is inserted,
"   it should be inserted just before Misc. subsection.
"
" * If a setting can be categorized into two or more sections,
"   it should be put into the most bottom section in this file.
"
"   For example, key mappings for a specific plugin should be put into the
"   Plugins section.
"
"
" Coding Rule
"
" * Separate sections with 8 blank lines.
"
" * Separate subsections with 4 blank lines.
"
" * Character Encoding and Indentation:
"   see the modelines in the bottom of this files.
"
" * Limit all lines to a maximum of 79 characters.
"
" * Separate {lhs} and {rhs} of key mappings with 2 spaces.
"
" * Separate {cmd} and {rep} of :command definitions with 2 spaces.
"
" * Write the full name for each command,
"   e.g., write nnoremap not nn.
"
"     - But abbreviated names may be used to follow the maximum line length.
"
" * Key Notation:
"
"   - Control-keys: Write as <C-x>, neither <C-X> nor <c-x>.
"
"   - Carriage return: Write as <Return>, neither <Enter> nor <CR>.
"
"     - But <CR> may be used to follow the maximum line length.
"
"   - Other characters: Write as same as :help key-notation








" Basic  "{{{1
" Absolute  "{{{2

set nocompatible  " to use many extensions of Vim.




" Encoding  "{{{2

" To deal with Japanese language.
if $ENV_WORKING ==# 'colinux'
  set encoding=utf-8
else
  set encoding=japan
endif
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
  let &fileencodings = 'ucs-bom'
  if &encoding !=# 'utf-8'
    let &fileencodings = &fileencodings . ',' . 'ucs-2le'
    let &fileencodings = &fileencodings . ',' . 'ucs-2'
  endif
  let &fileencodings = &fileencodings . ',' . s:enc_jis

  if &encoding ==# 'utf-8'
    let &fileencodings = &fileencodings . ',' . s:enc_euc
    let &fileencodings = &fileencodings . ',' . 'cp932'
  elseif &encoding =~# '^euc-\%(jp\|jisx0213\)$'
    let &encoding = s:enc_euc
    let &fileencodings = &fileencodings . ',' . 'utf-8'
    let &fileencodings = &fileencodings . ',' . 'cp932'
  else  " cp932
    let &fileencodings = &fileencodings . ',' . 'utf-8'
    let &fileencodings = &fileencodings . ',' . s:enc_euc
  endif
  let &fileencodings = &fileencodings . ',' . &encoding

  unlet s:enc_euc
  unlet s:enc_jis

  let did_encoding_settings = 1
endif


if $ENV_ACCESS ==# 'cygwin'
  set termencoding=cp932
elseif $ENV_ACCESS ==# 'linux'
  set termencoding=euc-jp
else  " 'colinux'
  set termencoding=utf-8
endif




" Options  "{{{2

if 1 < &t_Co && has('syntax')
  if &term ==# 'rxvt-cygwin-native'
    set t_Co=256
  endif
  syntax enable
  colorscheme default
  set background=dark
endif

filetype plugin indent on


set ambiwidth=double
set autoindent
set backspace=indent,eol,start
set backup
set backupcopy&
set backupdir=.,~/tmp
set backupskip&
set backupskip+=svn-commit.tmp,svn-commit.[0-9]*.tmp
set cinoptions=:0,t0,(0,W1s
set directory=.,~/tmp
set noequalalways
set formatoptions=tcroqnlM1
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
set titlestring=Vim:\ %f\ %h%r%m
set wildmenu

set viminfo=<50,'10,h,r/a,n~/.viminfo

" To automatically detect the width and the height of the terminal,
" the followings must not be set.
"
" set columns=80
" set lines=25


let mapleader=','
let maplocalleader='.'








" Utilities  "{{{1
" CMapABC: support input for Alternate Built-in Commands "{{{2

let s:CMapABC_Entries = []
function! s:CMapABC_Add(original_pattern, alternate_name)
  call add(s:CMapABC_Entries, [a:original_pattern, a:alternate_name])
endfunction


cnoremap <expr> <Space>  <SID>CMapABC()
function! s:CMapABC()
  let cmdline = getcmdline()
  for [original_pattern, alternate_name] in s:CMapABC_Entries
    if cmdline =~# original_pattern
      return "\<C-u>" . alternate_name . ' '
    endif
  endfor
  return ' '
endfunction




" Alternate :cd which uses 'cdpath' for completion  "{{{2

command! -complete=customlist,<SID>CommandComplete_cdpath -nargs=1
       \ CD  cd <args>

function! s:CommandComplete_cdpath(arglead, cmdline, cursorpos)
  return split(globpath(&cdpath, a:arglead . '*/'), "\n")
endfunction

call s:CMapABC_Add('^cd', 'CD')




" Help-related stuffs  "{{{2

function! s:HelpBufWinNR()
  let wn = 1
  while wn <= winnr('$')
    let bn = winbufnr(wn)
    if getbufvar(bn, '&buftype') == 'help'
      return [bn, wn]
    endif
    let wn = wn + 1
  endwhile
  return [-1, 0]
endfunction

function! s:HelpWindowClose()
  let [help_bufnr, help_winnr] = s:HelpBufWinNR()
  if help_bufnr == -1
    return
  endif

  let current_winnr = winnr()
  execute help_winnr 'wincmd w'
  execute 'wincmd c'
  if current_winnr < help_winnr
    execute current_winnr 'wincmd w'
  elseif help_winnr < current_winnr
    execute (current_winnr-1) 'wincmd w'
  else
    " NOP
  endif
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


function! s:KeysToEscapeCommandlineModeIfEmpty(key)
  if getcmdline() == ''
    return "\<Esc>"
  else
    return a:key
  end
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


function! s:RenameBuffer(name)
  let name = a:name
  let i = 0
  while 1
    if !bufexists(name)
      break
    endif
    let i = i + 1
    let name = a:name . ' (' . i . ')'
  endwhile
  file `=name`
endfunction


function! s:CreateTemporaryBuffer(name, how_to_open)
  execute a:how_to_open
  setlocal bufhidden=wipe buflisted buftype=nofile noswapfile
  call s:RenameBuffer(a:name)
endfunction

function! s:CreateCommandOutputBuffer(command, ...)  " spliting_modifier?
  let spliting_modifier = (1 <= a:0 ? a:1 : '')
  let previous_window_nr = winnr()
  let previous_windows_placement = winrestcmd()

  call s:CreateTemporaryBuffer('CMD: '.a:command, spliting_modifier.' new')
  silent execute 'read !' a:command

  if line('$') == 1 && getline(1) == ''
    close
    execute previous_windows_placement
    execute previous_window_nr 'wincmd w'

    redraw  " to ensure show the following message.
    echomsg 'No output from the command:' a:command
    return 0
  else
    1
    delete
    filetype detect
    return 1
  endif
endfunction


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


" like join (J), but move the next line into the cursor position.
function! s:JoinHere(...)
  let adjust_spacesp = a:0 ? a:1 : 1
  let pos = getpos('.')
  let r = @"

  if adjust_spacesp  " adjust spaces between texts being joined as same as J.
    normal! D
    let l = @"

    normal! J

    call append(line('.'), '')
    call setreg('"', l, 'c')
    normal! jpkJ
  else  " don't adjust spaces like gJ.
    call setreg('"', getline(line('.') + 1), 'c')
    normal! ""Pjdd
  endif

  let @" = r
  call setpos('.', pos)
endfunction


function! s:SCCSDiffAll()
  if isdirectory('.svn')
    let cmd = 'svn'
  elseif isdirectory('CVS')
    let cmd = 'cvs'
  else
    let cmd = 'svk'
  endif

  let was_tab_boredp = s:BoringTabP()
  let openp = s:CreateCommandOutputBuffer(cmd.' diff', 'botright')
  if was_tab_boredp && openp
    only  " close all boring windows.
  endif
endfunction


function! s:BoringTabP(...)  " are all windows in the tab boring?
  " boring window is a window which shows a boring buffer.
  let tid = a:0 ? a:1 : tabpagenr()
  for wid in range(1, tabpagewinnr(tid, '$'))
    let bid = winbufnr(wid)
    if !s:BoringBufferP(bid)
      return 0
    endif
  endfor
  return 1
endfunction

function! s:BoringBufferP(bid)  " is the buffer unnamed and not editted?
  return bufname(a:bid) == '' && getbufvar(a:bid, '&modified') == 0
endfunction








" Key Mappings  "{{{1
" Tag jumping  "{{{2
" Fallback  "{{{3

" ``T'' is also disabled for consistency.
noremap  t  <Nop>
noremap  T  <Nop>

" Alternatives for the original actions.
noremap  [Space]t  t
noremap  [Space]T  T


" Basic  "{{{3

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


" With the preview window  "{{{3

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




" Quickfix  "{{{2
" Fallback  "{{{3

" the prefix key.
nnoremap q  <Nop>

" alternative key for the original action.
" -- Ex-mode will be never used and recordings are rarely used.
nnoremap Q  q


" For quickfix list  "{{{3

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


" For location list (mnemonic: Quickfix list for the current Window)  "{{{3

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




" Tab pages  "{{{2
" The mappings defined here are similar to the ones for windows.
" FIXME: sometimes, hit-enter prompt appears.  but no idea for the reason.
" Fallback  "{{{3

" the prefix key.
" -- see Tag jumping subsection for alternative keys for the original action
"    of <C-t>.
nnoremap <C-t>  <Nop>


" Basic  "{{{3

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




" Command-line editting  "{{{2

" pseudo vi-like keys
cnoremap <Esc>h  <Left>
cnoremap <Esc>j  <Down>
cnoremap <Esc>k  <Up>
cnoremap <Esc>l  <Right>
cnoremap <Esc>H  <Home>
cnoremap <Esc>L  <End>
cnoremap <Esc>w  <S-Right>
cnoremap <Esc>b  <S-Left>
cnoremap <Esc>x  <Del>

" escape Command-line mode if the command line is empty (like <C-h>)
cnoremap <expr> <C-u>  <SID>KeysToEscapeCommandlineModeIfEmpty("\<C-u>")
cnoremap <expr> <C-w>  <SID>KeysToEscapeCommandlineModeIfEmpty("\<C-w>")




" Input: datetime  "{{{2
"
" Input the current date/time (Full, Date, Time).
"
" FIXME: use timezone of the system, instead of static one.
"
" FIXME: revise the {lhs}s, compare with the default keys of todatetime.

inoremap <Leader>dF  <C-r>=strftime('%Y-%m-%dT%H:%M:%S+09:00')<Return>
inoremap <Leader>df  <C-r>=strftime('%Y-%m-%dT%H:%M:%S')<Return>
inoremap <Leader>dd  <C-r>=strftime('%Y-%m-%d')<Return>
inoremap <Leader>dT  <C-r>=strftime('%H:%M:%S')<Return>
inoremap <Leader>dt  <C-r>=strftime('%H:%M')<Return>




" Section jumping  "{{{2
"
" Enable *consistent* ]] and other motions in Visual and Operator-pending
" mode.  Because some ftplugins provide these motions only for Normal mode
" and other ftplugins provides provide these motions with some faults, e.g.,
" not countable.

vnoremap <silent> ]]  :<C-u>call <SID>JumpSectionV(']]')<Return>
vnoremap <silent> ][  :<C-u>call <SID>JumpSectionV('][')<Return>
vnoremap <silent> [[  :<C-u>call <SID>JumpSectionV('[[')<Return>
vnoremap <silent> []  :<C-u>call <SID>JumpSectionV('[]')<Return>
onoremap <silent> ]]  :<C-u>call <SID>JumpSectionO(']]')<Return>
onoremap <silent> ][  :<C-u>call <SID>JumpSectionO('][')<Return>
onoremap <silent> [[  :<C-u>call <SID>JumpSectionO('[[')<Return>
onoremap <silent> []  :<C-u>call <SID>JumpSectionO('[]')<Return>




" The <Space>  "{{{2
"
" Various hotkeys prefixed by <Space>.

" to show <Space> in the bottom line.
map      <Space>  [Space]

" fallback
noremap  [Space]  <Nop>


nnoremap [Space]/  :nohlsearch<Return>

nnoremap [Space]?  :call <SID>HelpWindowClose()<Return>

  " append one character
nnoremap [Space]A  A<Space><Esc>r
nnoremap [Space]a  a<Space><Esc>r

nmap     [Space]b  <Plug>Buffuzzy

nnoremap [Space]e  :setlocal encoding? termencoding? fenc? fencs?<Return>
nnoremap [Space]f  :setlocal filetype? fileencoding? fileformat?<Return>

  " insert one character
nnoremap [Space]I  I<Space><Esc>r
nnoremap [Space]i  i<Space><Esc>r

nnoremap [Space]J  :<C-u>call <SID>JoinHere(1)<Return>
nnoremap [Space]gJ  :<C-u>call <SID>JoinHere(0)<Return>
  " unjoin
nnoremap [Space]j  i<Return><Esc>

nnoremap [Space]ob  :call <SID>ToggleBell()<Return>
nnoremap [Space]ow  :call <SID>ToggleOption('wrap')<Return>

nnoremap [Space]q  :help quickref<Return>

nnoremap [Space]r  :registers<Return>

nnoremap [Space]s  <Nop>
nnoremap [Space]s.  :source $HOME/.vimrc<Return>
nnoremap [Space]ss  :source %<Return>

vnoremap [Space]s  :sort<Return>

  " for backward compatibility
nmap     [Space]w  [Space]ow




" Misc.  "{{{2

nnoremap <C-h>  :h<Space>
nnoremap <C-o>  :e<Space>
nnoremap <C-w>.  :e .<Return>
nnoremap <silent> <Leader>cD  :<C-u>call <SID>SCCSDiffAll()<CR>


" Jump list
nnoremap <C-j>  <C-i>
nnoremap <C-k>  <C-o>


" Switch to the previously edited file (like Vz)
nnoremap <Esc>2  :e #<Return>
nmap <F2>  <Esc>2


" Visiting windows with one key.
nnoremap <C-i>  <C-w>w
nnoremap <Esc>i  <C-w>W

nmap <S-Tab>  <Esc>i


" Too lazy to press Shift key.
noremap ;  :
noremap :  ;


" Disable some dangerous key.
nnoremap ZZ  <Nop>
nnoremap ZQ  <Nop>


" Use a backslash (\) to repeat last change.
" Since a dot (.) is used as <LocalLeader>.
nnoremap \  .


" Search slashes easily (too lazy to prefix backslashes to slashes)
cnoremap <expr> /  getcmdtype() == '/' ? '\/' : '/'


" Complete or indent.
inoremap <expr> <C-i>  (<SID>ShouldIndentRatherThanCompleteP()
                      \ ? '<C-i>'
                      \ : <SID>KeysToComplete())

function! s:ShouldIndentRatherThanCompleteP()
  let m = match(getline('.'), '\S')
  return m == -1 || col('.')-1 <= m
endfunction


" Swap ` and ' -- I prefer ` to ' and ` is not easy to type.
noremap ' `
noremap ` '


" To be able to undo these types of deletion in Insert mode.
inoremap <C-w>  <C-g>u<C-w>
inoremap <C-u>  <C-g>u<C-u>


" Search the word nearest to the cursor in new window.
nnoremap <C-w>*  <C-w>s*
nnoremap <C-w>#  <C-g>s#








" FILETYPE  "{{{1
" Misc.  "{{{2

augroup MyAutoCmd
  autocmd!

  autocmd FileType dosini
    \ call <SID>FileType_dosini()

  autocmd FileType python
    \   call <SID>SetShortIndent()
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

    " I consider that these buffers have another filetype=netrw.
  autocmd BufReadPost {dav,file,ftp,http,rcp,rsync,scp,sftp}://*
    \ setlocal bufhidden=hide
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

  " Support to input some parts of tags.
  inoremap <buffer> <LT>?  </
  imap     <buffer> ?<LT>  <LT>?
  inoremap <buffer> ?>  />
  imap     <buffer> >?  ?>

  " Support to input some blocks.
  inoremap <buffer> <LT>!C  <LT>![CDATA[]]><Left><Left><Left>
  inoremap <buffer> <LT>#  <LT>!----><Left><Left><Left><C-r>=
                         \   <SID>FileType_xml_comment_dispatch()
                         \ <Return>

  " Complete proper end-tags.
  " In the following description, {|} means the cursor position.

    " Insert the end tag after the cursor.
    " Before: <code{|}
    " After:  <code>{|}</code>
  inoremap <buffer> <LT><LT>  ><LT>/<C-x><C-o><C-r>=
                           \    <SID>KeysToStopInsertModeCompletion()
                           \  <Return><C-o>F<LT>

    " Wrap the cursor with the tag.
    " Before: <code{|}
    " After:  <code>
    "           {|}
    "         </code>
  inoremap <buffer> >>  ><Return>X<Return><LT>/<C-x><C-o><C-r>=
                     \    <SID>KeysToStopInsertModeCompletion()
                     \  <Return><C-o><Up><BS>
endfunction


function! s:FileType_xml_comment_dispatch()
  let c = nr2char(getchar())
  return get(s:FileType_xml_comment_data, c, c)
endfunction
let s:FileType_xml_comment_data = {
  \   "\<Space>": "\<Space>\<Space>\<Left>",
  \   "\<Return>": "\<Return>X\<Return>\<Up>\<End>\<BS>",
  \   '_': '',
  \   '-': '',
  \   '{': '{{'. "{\<Esc>",
  \   '}': '}}'. "}\<Esc>",
  \   '1': '{{'."{1\<Esc>",
  \   '2': '{{'."{2\<Esc>",
  \   '3': '{{'."{3\<Esc>",
  \   '4': '{{'."{4\<Esc>",
  \   '5': '{{'."{5\<Esc>",
  \   '6': '{{'."{6\<Esc>",
  \   '7': '{{'."{7\<Esc>",
  \   '8': '{{'."{8\<Esc>",
  \   '9': '{{'."{9\<Esc>",
  \   '!': '{{'."{1\<Esc>",
  \   '@': '{{'."{2\<Esc>",
  \   '#': '{{'."{3\<Esc>",
  \   '$': '{{'."{4\<Esc>",
  \   '%': '{{'."{5\<Esc>",
  \   '^': '{{'."{6\<Esc>",
  \   '&': '{{'."{7\<Esc>",
  \   '*': '{{'."{8\<Esc>",
  \   '(': '{{'."{9\<Esc>",
  \ }








" Plugins  "{{{1
" cygclip  "{{{2

" Because plugins will be loaded after ~/.vimrc.
autocmd MyAutoCmd User DelayedSettings
      \   if exists('g:loaded_cygclip')
      \ |   call Cygclip_DefaultKeymappings()
      \ | endif




" scratch  "{{{2

" I already use <C-m> for tag jumping.
" But I don't use it in the scratch buffer, so it should be overridden.
augroup Scratch
  au!
  au User Initialize  nmap <buffer> <C-m>  <Plug>Scratch_ExecuteLine
  au User Initialize  vmap <buffer> <C-m>  <Plug>Scratch_ExecuteSelection
augroup END




" surround  "{{{2

" The default mapping ys for <Plug>Ysurround is not consistent with
" the default mappings of vi -- y is for yank.
nmap s  <Plug>Ysurround
nmap ss  <Plug>Yssurround

autocmd MyAutoCmd User DelayedSettings
      \   if exists('g:loaded_surround') || exists('*SurroundRegister')
      \ |   call SurroundRegister('g', 'js', "「\r」")
      \ |   call SurroundRegister('g', 'jd', "『\r』")
      \ | endif




" todatetime  "{{{2

autocmd MyAutoCmd User DelayedSettings
      \   if exists('g:loaded_todatetime')
      \ |   call TODateTime_DefaultKeymappings(1)
      \ | endif




" vcscommand  "{{{2

let g:VCSCommandDeleteOnHide = 1

nmap <Leader>cR  <Plug>VCSDelete




" xml_autons  "{{{2

let g:AutoXMLns_Dict = {}
let g:AutoXMLns_Dict['http://www.w3.org/2000/svg'] = 'svg11'








" Fin.  "{{{1

if !exists('s:loaded_my_vimrc')
  let s:loaded_my_vimrc = 1
  autocmd MyAutoCmd VimEnter *
    \ doautocmd MyAutoCmd User DelayedSettings
else
  doautocmd MyAutoCmd User DelayedSettings
endif




set secure  " must be written at the last.  see :help 'secure'.








" __END__  "{{{1
" vim: fileencoding=utf-8 bomb
" vim: expandtab softtabstop=2 shiftwidth=2
" vim: foldmethod=marker
