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
"
" * Line continuation:
"
"   - Key mappings and abbreviations: Write \ at the previous column of the
"     start of the {rhs}.
"
"   - Others: Write \ at the same column of the end of the previous command.
"     Note that don't include "!".
"
"   - Examples:
"
"     silent! execute foo()
"          \        . bar()
"          \        . baz()
"
"     map <silent> xyzzy  :<C-u>execute foo()
"                        \ bar()
"                        \ baz()
"                        \<Return>








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
  if iconv("\x87\x64\x87\x6a", 'cp932', 'euc-jisx0213') ==# "\xad\xc5\xad\xcb"
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
elseif $ENV_ACCESS ==# 'colinux'
  set termencoding=utf-8
else  " fallback
  set termencoding=  " same as 'encoding'
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
set formatlistpat&
let &formatlistpat .= '\|^\s*[*+-]\s*'
set history=100
set hlsearch
set grepprg=internal
set incsearch
set laststatus=2  " always show status lines.
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

" default 'statusline' with 'fileencoding'.
let &statusline = ''
let &statusline .= '%<%f %h%m%r%w'
let &statusline .= '%='
let &statusline .= '[%{&fileencoding == "" ? &encoding : &fileencoding}]'
let &statusline .= '  %-14.(%l,%c%V%) %P'

function! s:MyTabLine()  "{{{
  let s = ''

  for i in range(1, tabpagenr('$'))
    let curbufnr = tabpagebuflist(i)[tabpagewinnr(i) - 1]

    let prefix = ''
    if 1 < tabpagewinnr(i, '$')
      let prefix .= tabpagewinnr(i, '$')
    endif
    if getbufvar(curbufnr, '&modified')
      let prefix .= '+'
    endif

    let curbufname = bufname(curbufnr)
    if  curbufname == ''
      let curbufname = '[No Name]'
    endif
    if getbufvar(curbufnr, '&buftype') !=# 'help'
      let curbufname = fnamemodify(curbufname, ':t')
    else
      let curbufname = '[help] ' . fnamemodify(curbufname, ':t:r')
    endif

    let s .= '%'.i.'T'
    let s .= (prefix != '' ? '%#Title#'.prefix.' ' : '')
    let s .= '%#' . (i == tabpagenr() ? 'TabLineSel' : 'TabLine') . '#'
    let s .= curbufname
    let s .= '%#TabLineFill#'
    let s .= '  '
  endfor

  let s .= '%#TabLineFill#%T'
  let s .= '%=%#TabLine#%999Xx%X'
  return s
endfunction "}}}
function! s:SID_PREFIX()
 return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction
let &tabline = '%!' . s:SID_PREFIX() . 'MyTabLine()'

" To automatically detect the width and the height of the terminal,
" the followings must not be set.
"
" set columns=80
" set lines=25


let mapleader=','
let maplocalleader='.'


" Use this group for any autocmd defined in this file.
augroup MyAutoCmd
  autocmd!
augroup END








" Utilities  "{{{1
" MAP: wrapper for :map variants.  "{{{2
"
" :MAP {option}* {modes} {lhs} {rhs}
"
"   {option}
"     One of the following string:
"       <echo>    The mapping will be echoed on the command line.
"                 Default: not echoed.
"       <re>      The mapping will be remapped.
"                 Default: not remapped.
"
"   {modes}
"     String which consists of the following characters:
"       c i l n o s v x
"
"   {lhs}, {rhs}
"     Same as :map.

command! -bar -complete=mapping -nargs=+ MAP  call s:MAP(<f-args>)

function! s:MAP(...)
  if !(3 <= a:0)
    throw 'Insufficient arguments: '.string(a:000)
  endif

  let silentp = 1
  let noremap = 1
  let i = 0
  while i < a:0
    if a:000[i] ==# '<echo>'
      let silentp = 0
    elseif a:000[i] ==# '<re>'
      let noremap = 0
    else
      break
    endif
    let i += 1
  endwhile

  let mapcommand = (noremap ? 'noremap' : 'map')
  let silentoption = (silentp ? '<silent>' : '')
  let j = 0
  let modes = a:000[i]
  while j < len(modes)
    execute (modes[j] . mapcommand) silentoption join(a:000[i+1:])
    let j += 1
  endwhile
endfunction


autocmd MyAutoCmd FileType vim
      \   syntax keyword my_vim_MAP MAP
      \     skipwhite
      \     nextgroup=my_vim_MAP_option,my_vim_MAP_modes,vimMapMod,vimMapLhs
      \ | syntax match my_vim_MAP_option '<\(echo\|re\)>'
      \     skipwhite
      \     nextgroup=my_vim_MAP_option,my_vim_MAP_modes,vimMapMod,vimMapLhs
      \ | syntax match my_vim_MAP_modes '\<[cilnosvx]\+\>'
      \     skipwhite
      \     nextgroup=vimMapMod,vimMapLhs
      \ | highlight default link my_vim_MAP vimMap
      \ | highlight default link my_vim_MAP_option vimUserAttrbCmplt
      \ | highlight default link my_vim_MAP_modes vimUserAttrbKey




" CMapABC: support input for Alternate Built-in Commands  "{{{2

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

command! -complete=customlist,<SID>CommandComplete_cdpath -nargs=1 CD
      \ TabCD <args>

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
  if &l:filetype ==# 'vim'
    return "\<C-x>\<C-v>"
  elseif strlen(&l:omnifunc)
    return "\<C-x>\<C-o>"
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


function! s:KeysToInsertOneCharacter()
  Echo ModeMsg '-- INSERT (one char) --'
  return nr2char(getchar()) . "\<Esc>"
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




" Per-tab current directory  "{{{2

command! -nargs=1 TabCD
      \   execute 'cd' <q-args>
      \ | let t:cwd = getcwd()

autocmd MyAutoCmd TabEnter *
      \   if !exists('t:cwd')
      \ |   let t:cwd = getcwd()
      \ | endif
      \ | execute 'cd' t:cwd




" Window-related stuffs  "{{{2

" Are the windows :split'ed and :vsplit'ed?
function! s:WindowsJumbledP()
  " Calculate the terminal height by some values other than 'lines'.
  " Don't consider about :vsplit.
  let calculated_height = &cmdheight
  let winid = winnr('$')
  while 0 < winid
    let calculated_height += 1  " statusline
    let calculated_height += winheight(winid)
    let winid = winid - 1
  endwhile
  if &laststatus == 0
    let calculated_height -= 1
  elseif &laststatus == 1 && winnr('$') == 1
    let calculated_height -= 1
  else  " &laststatus == 2
    " nothing to do
  endif

  " Calculate the terminal width by some values other than 'columns'.
  " Don't consider about :split.
  let calculated_width = 0
  let winid = winnr('$')
  while 0 < winid
    let calculated_width += 1  " VertSplit
    let calculated_width += winwidth(winid)
    let winid = winid - 1
  endwhile
  let calculated_width -= 1

  " If the windows are only :split'ed, &lines == calculated_height.
  " If the windows are only :vsplit'ed, &columns == calculated_width.
  " If there is only one window, both pairs are same.
  " If the windows are :split'ed and :vsplit'ed, both pairs are different.
  return (&lines != calculated_height) && (&columns != calculated_width)
endfunction


function! s:MoveWindowThenEqualizeIfNecessary(direction)
  let jumbled_beforep = s:WindowsJumbledP()
  execute 'wincmd' a:direction
  let jumbled_afterp = s:WindowsJumbledP()

  if jumbled_beforep || jumbled_afterp
    wincmd =
  endif
endfunction


function! s:MoveWindowIntoTabPage(target_tabpagenr)
  " Move the current window into a:target_tabpagenr.
  " If a:target_tabpagenr is 0, move into new tab page.
  let original_tabnr = tabpagenr()
  let target_bufnr = bufnr('')
  let window_view = winsaveview()

  if a:target_tabpagenr == 0
    tablast
    tabnew
    execute target_bufnr 'buffer'
    let target_tabpagenr = tabpagenr()
  else
    execute a:target_tabpagenr 'tabnext'
    let target_tabpagenr = a:target_tabpagenr
    topleft new  " FIXME: be customizable?
    execute target_bufnr 'buffer'
  endif
  call winrestview(window_view)

  execute original_tabnr 'tabnext'
  if 1 < winnr('$')
    close
  else
    enew
  endif

  execute target_tabpagenr 'tabnext'
endfunction


function! s:ScrollOtherWindow(scroll_command)
  if winnr('$') == 1 || winnr('#') == 0
    " Do nothing when there is only one window or no previous window.
    Echo ErrorMsg 'There is no window to scroll.'
  else
    execute 'normal!' "\<C-w>p"
    execute 'normal!' (s:Count() . a:scroll_command)
    execute 'normal!' "\<C-w>p"
  endif
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
       \     '|' 'highlight' a:target_group original_settings
       \     '|' 'highlight' a:target_group a:new_settings
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

  if line('.') == line('$')
    Echo ErrorMsg 'Unable to join at the bottom line.'
    return
  endif

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


function! s:SetShortIndent()
  setlocal expandtab softtabstop=2 shiftwidth=2
endfunction


command! -bar -nargs=+ -range Echo  call <SID>Echo(<f-args>)
function! s:Echo(hl_name, ...)
  execute 'echohl' a:hl_name
  execute 'echo' join(a:000)
  echohl None
endfunction








" Key Mappings  "{{{1
" FIXME: many {rhs}s use : without <C-u> (clearing count effect).
" FIXME: some mappings are not countable.
" Tag jumping  "{{{2
" FIXME: the target window of :split/:vsplit version.
" Fallback  "{{{3

" ``T'' is also disabled for consistency.
noremap           t          <Nop>
noremap           T          <Nop>

" Alternatives for the original actions.
noremap           [Space]t   t
noremap           [Space]T   T


" Basic  "{{{3

nnoremap          tt         <C-]>
vnoremap          tt         <C-]>
nnoremap <silent> tj         :<C-u>tag<Return>
nnoremap <silent> tk         :<C-u>pop<Return>
nnoremap <silent> tl         :<C-u>tags<Return>
nnoremap <silent> tn         :<C-u>tnext<Return>
nnoremap <silent> tp         :<C-u>tprevious<Return>
nnoremap <silent> tP         :<C-u>tfirst<Return>
nnoremap <silent> tN         :<C-u>tlast<Return>

" additions, like Web browsers
nmap              <C-m>      tt
vmap              <C-m>      tt

" addition, interactive use.
nnoremap          t<Space>   :<C-u>tag<Space>


" With the preview window  "{{{3

nnoremap          t't        <C-w>}
vnoremap          t't        <C-w>}
nnoremap <silent> t'n        :<C-u>ptnext<Return>
nnoremap <silent> t'p        :<C-u>ptpevious<Return>
nnoremap <silent> t'P        :<C-u>ptfirst<Return>
nnoremap <silent> t'N        :<C-u>ptlast<Return>

" although :pclose is not related to tag.
" BUGS: t'' is not related to the default meaning of ''.
nnoremap <silent> t'c        :<C-u>pclose<Return>
nmap              t'z        t'z
nmap              t''        t'c


" With :split  "{{{3

nnoremap          tst        <C-w>]
vnoremap          tst        <C-w>]
nnoremap <silent> tsn        :<C-u>split \| tnext<Return>
nnoremap <silent> tsp        :<C-u>split \| tpevious<Return>
nnoremap <silent> tsP        :<C-u>split \| tfirst<Return>
nnoremap <silent> tsN        :<C-u>split \| tlast<Return>


" With :vertical split  "{{{3

  " |:vsplit|-then-|<C-]>| is simple
  " but its modification to tag stacks is not same as |<C-w>]|.
nnoremap <silent> tvt        <C-]>:<C-u>vsplit<Return><C-w>p<C-t><C-w>p
vnoremap <silent> tvt        <C-]>:<C-u>vsplit<Return><C-w>p<C-t><C-w>p
nnoremap <silent> tvn        :<C-u>vsplit \| tnext<Return>
nnoremap <silent> tvp        :<C-u>vsplit \| tpevious<Return>
nnoremap <silent> tvP        :<C-u>vsplit \| tfirst<Return>
nnoremap <silent> tvN        :<C-u>vsplit \| tlast<Return>




" Quickfix  "{{{2
" Fallback  "{{{3

" the prefix key.
nnoremap          q          <Nop>

" alternative key for the original action.
" -- Ex-mode will be never used and recordings are rarely used.
nnoremap          Q          q


" For quickfix list  "{{{3

nnoremap <silent> qj         :Execute cnext [count]<Return>
nnoremap <silent> qk         :Execute cprevious [count]<Return>
nnoremap <silent> qr         :Execute crewind [count]<Return>
nnoremap <silent> qK         :Execute cfirst [count]<Return>
nnoremap <silent> qJ         :Execute clast [count]<Return>
nnoremap <silent> qfj        :Execute cnfile [count]<Return>
nnoremap <silent> qfk        :Execute cpfile [count]<Return>
nnoremap <silent> ql         :<C-u>clist<Return>
nnoremap <silent> qq         :Execute cc [count]<Return>
nnoremap <silent> qo         :Execute copen [count]<Return>
nnoremap <silent> qc         :<C-u>cclose<Return>
nnoremap <silent> qp         :Execute colder [count]<Return>
nnoremap <silent> qn         :Execute cnewer [count]<Return>
nnoremap <silent> qm         :<C-u>make<Return>
nnoremap <silent> qM         :<C-u>make<Space>
nnoremap <silent> q<Space>   :<C-u>make<Space>
nnoremap <silent> qg         :<C-u>grep<Space>


" For location list (mnemonic: Quickfix list for the current Window)  "{{{3

nnoremap <silent> qwj        :Execute lnext [count]<Return>
nnoremap <silent> qwk        :Execute lprevious [count]<Return>
nnoremap <silent> qwr        :Execute lrewind [count]<Return>
nnoremap <silent> qwK        :Execute lfirst [count]<Return>
nnoremap <silent> qwJ        :Execute llast [count]<Return>
nnoremap <silent> qwfj       :Execute lnfile [count]<Return>
nnoremap <silent> qwfk       :Execute lpfile [count]<Return>
nnoremap <silent> qwl        :<C-u>llist<Return>
nnoremap <silent> qwq        :Execute ll [count]<Return>
nnoremap <silent> qwo        :Execute lopen [count]<Return>
nnoremap <silent> qwc        :<C-u>lclose<Return>
nnoremap <silent> qwp        :Execute lolder [count]<Return>
nnoremap <silent> qwn        :Execute lnewer [count]<Return>
nnoremap <silent> qwm        :<C-u>lmake<Return>
nnoremap <silent> qwM        :<C-u>lmake<Space>
nnoremap <silent> qw<Space>  :<C-u>lmake<Space>
nnoremap <silent> qwg        :<C-u>lgrep<Space>




" Tab pages  "{{{2
" The mappings defined here are similar to the ones for windows.
" FIXME: sometimes, hit-enter prompt appears.  but no idea for the reason.
" Fallback  "{{{3

" the prefix key.
" -- see Tag jumping subsection for alternative keys for the original action
"    of <C-t>.
nnoremap <C-t>  <Nop>


" Basic  "{{{3

  " :tabnew creates new tab page at the next of the current one,
  " but I prefer to create at the next of the last one.
nnoremap <silent> <C-t>n  :<C-u>tablast \| tabnew<Return>
nnoremap <silent> <C-t>c  :<C-u>tabclose<Return>
nnoremap <silent> <C-t>o  :<C-u>tabonly<Return>
nnoremap <silent> <C-t>i  :<C-u>tabs<Return>

nmap <C-t><C-n>  <C-t>n
nmap <C-t><C-c>  <C-t>c
nmap <C-t><C-o>  <C-t>o
nmap <C-t><C-i>  <C-t>i


" Moving around tabs.  "{{{3

nnoremap <silent> <C-t>j  :<C-u>execute 'tabnext'
                         \ 1 + (tabpagenr() + v:count1 - 1) % tabpagenr('$')
                         \<Return>
nnoremap <silent> <C-t>k  :Execute tabprevious [count]<Return>
nnoremap <silent> <C-t>K  :<C-u>tabfirst<Return>
nnoremap <silent> <C-t>J  :<C-u>tablast<Return>
nmap <C-t>t  <C-t>j
nmap <C-t>T  <C-t>k

nmap <C-t><C-j>  <C-t>j
nmap <C-t><C-k>  <C-t>k
nmap <C-t><C-t>  <C-t>t


" Moving tabs themselves.  "{{{3

nnoremap <silent> <C-t>l  :<C-u>execute 'tabmove'
                         \ min([tabpagenr() + v:count1 - 1, tabpagenr('$')])
                         \<Return>
nnoremap <silent> <C-t>h  :<C-u>execute 'tabmove'
                         \ max([tabpagenr() - v:count1 - 1, 0])
                         \<Return>
nnoremap <silent> <C-t>L  :<C-u>tabmove<Return>
nnoremap <silent> <C-t>H  :<C-u>tabmove 0<Return>

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

" Search slashes easily (too lazy to prefix backslashes to slashes)
cnoremap <expr> /  getcmdtype() == '/' ? '\/' : '/'




" Input: datetime  "{{{2
"
" Input the current date/time (Full, Date, Time).
"
" FIXME: use timezone of the system, instead of static one.
" FIXME: revise the {lhs}s, compare with the default keys of textobj-datetime.

inoremap <Leader>dF  <C-r>=strftime('%Y-%m-%dT%H:%M:%S+09:00')<Return>
inoremap <Leader>df  <C-r>=strftime('%Y-%m-%dT%H:%M:%S')<Return>
inoremap <Leader>dd  <C-r>=strftime('%Y-%m-%d')<Return>
inoremap <Leader>dT  <C-r>=strftime('%H:%M:%S')<Return>
inoremap <Leader>dt  <C-r>=strftime('%H:%M')<Return>




" Section jumping  "{{{2
"
" Enable *consistent* ]] and other motions in Visual and Operator-pending
" mode.  Because some ftplugins provide these motions only for Normal mode and
" other ftplugins provide these motions with some faults, e.g., not countable.

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
map               <Space>    [Space]

" fallback
noremap           [Space]    <Nop>


nnoremap <silent> [Space]/   :<C-u>nohlsearch<Return>

nnoremap <silent> [Space]?   :<C-u>call <SID>HelpWindowClose()<Return>

" append one character
nnoremap          [Space]A   A<C-r>=<SID>KeysToInsertOneCharacter()<Return>
nnoremap          [Space]a   a<C-r>=<SID>KeysToInsertOneCharacter()<Return>

nnoremap <silent> [Space]e   :<C-u>setlocal enc? tenc? fenc? fencs?<Return>
nnoremap <silent> [Space]f   :<C-u>setlocal ft? fenc? ff?<Return>

" insert one character
nnoremap          [Space]I   I<C-r>=<SID>KeysToInsertOneCharacter()<Return>
nnoremap          [Space]i   i<C-r>=<SID>KeysToInsertOneCharacter()<Return>

nnoremap <silent> [Space]J   :<C-u>call <SID>JoinHere(1)<Return>
nnoremap <silent> [Space]gJ  :<C-u>call <SID>JoinHere(0)<Return>

" unjoin  " BUGS: side effect - destroy the last inserted text (".).
nnoremap          [Space]j   i<Return><Esc>

nnoremap <silent> [Space]m   :<C-u>marks<Return>

nnoremap          [Space]o   <Nop>
nnoremap <silent> [Space]ob  :<C-u>call <SID>ToggleBell()<Return>
nnoremap <silent> [Space]ow  :<C-u>call <SID>ToggleOption('wrap')<Return>

nnoremap <silent> [Space]q   :<C-u>help quickref<Return>

nnoremap <silent> [Space]r   :<C-u>registers<Return>

nnoremap          [Space]s   <Nop>
nnoremap <silent> [Space]s.  :<C-u>source $MYVIMRC<Return>
nnoremap <silent> [Space]ss  :<C-u>source %<Return>

vnoremap <silent> [Space]s   :sort<Return>

" for backward compatibility
nmap              [Space]w   [Space]ow

" for other use.
noremap           [Space]x   <Nop>




" Windows  "{{{2

" Synonyms for the default mappings, with single key strokes.
nmap     <Tab>    <C-i>
nmap     <S-Tab>  <Esc>i
nnoremap <C-i>    <C-w>w
nnoremap <Esc>i   <C-w>W
  " For other mappings (<Esc>{x} to <C-w>{x}).
nmap     <Esc>    <C-w>


for i in ['H', 'J', 'K', 'L']
  execute 'nnoremap <silent> <Esc>'.i
        \ ':<C-u>call <SID>MoveWindowThenEqualizeIfNecessary("'.i.'")<Return>'
endfor
unlet i


" This {lhs} overrides the default action (Move cursor to top-left window).
" But I rarely use its {lhs}s, so this mapping is not problematic.
nnoremap <silent> <C-w><C-t>
       \ :<C-u>call <SID>MoveWindowIntoTabPage(v:count)<Return>


" like GNU Emacs' (scroll-other-window),
" but the target to scroll is the previous window.
for i in ['f', 'b', 'd', 'u', 'e', 'y']
  execute 'nnoremap <silent> <Esc><C-'.i.'>'
        \ ':<C-u>call <SID>ScrollOtherWindow("<Bslash><LT>C-'.i.'>")<Return>'
endfor
unlet i




" Misc.  "{{{2

nnoremap <C-h>  :h<Space>
nnoremap <C-o>  :e<Space>
nnoremap <C-w>.  :e .<Return>


" Jump list
nnoremap <C-j>  <C-i>
nnoremap <C-k>  <C-o>


" Switch to the previously edited file (like Vz)
nnoremap <Esc>2  :e #<Return>
nmap <F2>  <Esc>2


" Too lazy to press Shift key.
noremap ;  :
noremap :  ;


" Disable some dangerous key.
nnoremap ZZ  <Nop>
nnoremap ZQ  <Nop>


" Use a backslash (\) to repeat last change.
" Since a dot (.) is used as <LocalLeader>.
nnoremap \  .


" Complete or indent.
inoremap <expr> <C-i>  (<SID>ShouldIndentRatherThanCompleteP()
                      \ ? '<C-i>'
                      \ : <SID>KeysToComplete())

function! s:ShouldIndentRatherThanCompleteP()
  let m = match(getline('.'), '\S')
  return m == -1 || col('.')-1 <= m
endfunction


" Swap ` and ' -- I prefer ` to ' and ` is not easy to type.
" <SID>jump-default and <SID>jump-another are the name for these actions
" to use other places in this file.
map '  <SID>jump-default
map `  <SID>jump-another
noremap <SID>jump-default  `
noremap <SID>jump-another  '


" To be able to undo these types of deletion in Insert mode.
inoremap <C-w>  <C-g>u<C-w>
inoremap <C-u>  <C-g>u<C-u>


" Search the word nearest to the cursor in new window.
nnoremap <C-w>*  <C-w>s*
nnoremap <C-w>#  <C-g>s#


" Synonyms for <> and [], same as plugin surround.
onoremap aa  a>
onoremap ia  i>
vnoremap aa  a>
vnoremap ia  i>

onoremap ar  a]
onoremap ir  i]
vnoremap ar  a]
vnoremap ir  i]


" Delete the content of the current line (not the line itself).
" BUGS: not repeatable.
" BUGS: the default behavior is overridden, but it's still available via "x".
nnoremap dl  0d$


" Like gv, but select the last changed text.
nnoremap gc  `[v`]


" Make I/A available in characterwise-visual and linewise-visual.
vnoremap I  :<C-u>call <SID>ForceBlockwiseVisual('I')<Return>
vnoremap A  :<C-u>call <SID>ForceBlockwiseVisual('A')<Return>

function! s:ForceBlockwiseVisual(next_key)
  if visualmode() ==# 'V'
    execute "normal! `<0\<C-v>`>$"
  else
    execute "normal! `<\<C-v>`>"
  endif
  call feedkeys(a:next_key, 'n')
endfunction


" Start Insert mode with [count] blank lines.
" The default [count] is 0, so no blank line is inserted.
" (I prefer this behavior to the default behavior of [count]o/O
"  -- repeat the next insertion [count] times.)
nnoremap o  :<C-u>call <SID>StartInsertModeWithBlankLines('o')<Return>
nnoremap O  :<C-u>call <SID>StartInsertModeWithBlankLines('O')<Return>

function! s:StartInsertModeWithBlankLines(command)
  " Do "[count]o<Esc>o" and so forth.
  " BUGS: In map-<expr>, v:count and v:count1 don't hold correct values.
  " FIXME: improper indenting in comments.
  " FIXME: imperfect repeating (blank lines will not be repeated).

  if v:count != v:count1  " [count] is not specified?
    call feedkeys(a:command, 'n')
    return
  endif

  let script = v:count . a:command . "\<Esc>"
  if a:command ==# 'O'
    let script .= "\<Down>" . v:count . "\<Up>"  " Adjust the cursor position.
  endif

  execute 'normal!' script
  redraw
  Echo ModeMsg '-- INSERT (open) --'
  echohl None
  let c = nr2char(getchar())
  call feedkeys((c != "\<Esc>" ? a:command : 'A'), 'n')
  call feedkeys(c, 'n')

  " to undo the next inserted text and the preceding blank lines in 1 step.
  undojoin
endfunction


" Search for the selected text.
vnoremap *  :<C-u>call <SID>SearchForTheSelectedText()<Return>

  " FIXME: escape to search the selected text literaly.
function! s:SearchForTheSelectedText()
  let reg_u = @"
  let reg_0 = @0

  normal! gvy
  let @/ = @0
  call histadd('/', @0)
  normal! n

  let @0 = reg_0
  let @" = reg_u
endfunction


" Pseudo :suspend with automtic cd.
" Assumption: Use GNU screen.
" Assumption: There is a window with the title "another".
noremap <silent> <C-z>  :<C-u>call <SID>PseudoSuspendWithAutomaticCD()<Return>

if !exists('s:gnu_screen_availablep')
  let s:gnu_screen_availablep = 1
endif
function! s:PseudoSuspendWithAutomaticCD()
  if s:gnu_screen_availablep
    " \015 = <C-m>
    silent execute '!screen -X eval'
         \         '''select another'''
         \         '''stuff "cd \"'.getcwd().'\"  \#\#,vim-auto-cd\015"'''
    redraw!
    let s:gnu_screen_availablep = (v:shell_error == 0)
  endif

  if !s:gnu_screen_availablep
    suspend
  endif
endfunction








" Filetypes  "{{{1
" Any filetype   "{{{2

autocmd MyAutoCmd FileType *
      \ call <SID>FileType_any()
function! s:FileType_any()
  " To use my global mappings for section jumping,
  " remove buffer local mappings defined by ftplugin.
  silent! vunmap <buffer>  ]]
  silent! vunmap <buffer>  ][
  silent! vunmap <buffer>  []
  silent! vunmap <buffer>  [[
  silent! ounmap <buffer>  ]]
  silent! ounmap <buffer>  ][
  silent! ounmap <buffer>  []
  silent! ounmap <buffer>  [[

  " Make omni completion available for all filetypes.
  if &l:omnifunc == ''
    setlocal omnifunc=syntaxcomplete#Complete
  endif
endfunction


" Fix 'fileencoding' to use 'encoding'
" if the buffer only contains 7-bit characters.
" Note that if the buffer is not 'modifiable',
" its 'fileencoding' cannot be changed, so that such buffers are skipped.
autocmd MyAutoCmd BufReadPost *
      \   if &modifiable && !search('[^\x00-\x7F]', 'cnw')
      \ |   setlocal fileencoding=
      \ | endif


" although this is not a filetype settings.
autocmd MyAutoCmd ColorScheme *
      \   call <SID>ExtendHighlight('Pmenu', 'Normal', 'cterm=underline')
      \ | call <SID>ExtendHighlight('PmenuSel', 'Search', 'cterm=underline')
      \ | call <SID>ExtendHighlight('PmenuSbar', 'Normal', 'cterm=reverse')
      \ | call <SID>ExtendHighlight('PmenuThumb', 'Search', '')
      \
      \ | highlight TabLineSel
      \             term=bold,reverse
      \             cterm=bold,underline ctermfg=lightgray ctermbg=237
      \ | highlight TabLine
      \             term=reverse
      \             cterm=NONE           ctermfg=lightgray ctermbg=237
      \ | highlight TabLineFill
      \             term=reverse
      \             cterm=NONE           ctermfg=lightgray ctermbg=237
doautocmd MyAutoCmd ColorScheme because-colorscheme-has-been-set-above.




" css  "{{{2

autocmd MyAutoCmd FileType css
      \ call <SID>SetShortIndent()




" dosini (.ini)  "{{{2

autocmd MyAutoCmd FileType dosini
      \ call <SID>FileType_dosini()

function! s:FileType_dosini()
  nnoremap <buffer> <silent> ]]  :<C-u>call <SID>JumpSectionN('/^\[')<Return>
  nnoremap <buffer> <silent> ][  :<C-u>call <SID>JumpSectionN('/\n\[\@=')<CR>
  nnoremap <buffer> <silent> [[  :<C-u>call <SID>JumpSectionN('?^\[')<Return>
  nnoremap <buffer> <silent> []  :<C-u>call <SID>JumpSectionN('?\n\[\@=')<CR>
endfunction




" help  "{{{2

autocmd MyAutoCmd FileType help
      \ call textobj#user#define('|[^| \t]*|', '', '', {
      \                            'move-to-next': '<buffer> gj',
      \                            'move-to-prev': '<buffer> gk',
      \                          })




" lua  "{{{2

autocmd MyAutoCmd FileType lua
      \ call <SID>SetShortIndent()




" netrw  "{{{2
"
" Consider these buffers have "another" filetype=netrw.

autocmd MyAutoCmd BufReadPost {dav,file,ftp,http,rcp,rsync,scp,sftp}://*
      \ setlocal bufhidden=hide




" python  "{{{2

autocmd MyAutoCmd FileType python
      \   call <SID>SetShortIndent()
      \ | let python_highlight_numbers=1
      \ | let python_highlight_builtins=1
      \ | let python_highlight_space_errors=1




" ruby  "{{{2

autocmd MyAutoCmd FileType ruby
      \   call <SID>SetShortIndent()




" sh  "{{{2

autocmd MyAutoCmd FileType sh
      \ call <SID>SetShortIndent()

" FIXME: use $SHELL.
let g:is_bash = 1




" tex  "{{{2

autocmd MyAutoCmd FileType tex
      \ call <SID>SetShortIndent()




" vcsicommit  "{{{2
" 'filetype' for commit log buffers created by vcsi.

autocmd MyAutoCmd FileType {vcsicommit,*.vcsicommit}
      \ setlocal comments=sr:*,mb:\ ,ex:NOT_DEFINED




" vim  "{{{2

autocmd MyAutoCmd FileType vim
      \ call <SID>FileType_vim()

function! s:FileType_vim()
  call <SID>SetShortIndent()
  let vim_indent_cont = &shiftwidth

  iabbr <buffer> jf  function!()<Return>
                    \endfunction<Return>
                    \<Up><Up><End><Left><Left>
  iabbr <buffer> ji  if<Return>
                    \endif<Return>
                    \<Up><Up><End>
  iabbr <buffer> je  if<Return>
                    \else<Return>
                    \endif<Return>
                    \<Up><Up><Up><End>
  iabbr <buffer> jw  while<Return>
                    \endwhile<Return>
                    \<Up><Up><End>

  " Fix the default syntax to properly highlight
  " autoload#function() and dictionary.function().
  syntax clear vimFunc
  syntax match vimFunc
    \ "\%([sS]:\|<[sS][iI][dD]>\|\<\%(\I\i*[#.]\)\+\)\=\I\i*\ze\s*("
    \ contains=vimFuncName,vimUserFunc,vimCommand,vimNotFunc,vimExecute
  syntax clear vimUserFunc
  syntax match vimUserFunc contained
    \ "\%([sS]:\|<[sS][iI][dD]>\|\<\%(\I\i*[#.]\)\+\)\i\+\|\<\u\i*\>\|\<if\>"
    \ contains=vimNotation,vimCommand
endfunction




" XML/SGML and other applications  "{{{2

autocmd MyAutoCmd FileType html,xhtml,xml,xslt
      \ call <SID>FileType_xml()

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
                          \<SID>FileType_xml_comment_dispatch()
                          \<Return>

  " Complete proper end-tags.
  " In the following description, {|} means the cursor position.

    " Insert the end tag after the cursor.
    " Before: <code{|}
    " After:  <code>{|}</code>
  inoremap <buffer> <LT><LT>  ><LT>/<C-x><C-o><C-r>=
                             \<SID>KeysToStopInsertModeCompletion()
                             \<Return><C-o>F<LT>

    " Wrap the cursor with the tag.
    " Before: <code{|}
    " After:  <code>
    "           {|}
    "         </code>
  inoremap <buffer> >>  ><Return>X<Return><LT>/<C-x><C-o><C-r>=
                       \<SID>KeysToStopInsertModeCompletion()
                       \<Return><C-o><Up><BS>
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
" narrow  "{{{2

noremap [Space]xn  :Narrow<Return>
noremap [Space]xw  :<C-u>Widen<Return>




" scratch  "{{{2

nmap <Leader>s  <Plug>(scratch-open)


" I already use <C-m> for tag jumping.
" But I don't use it in the scratch buffer, so it should be overridden.
autocmd MyAutoCmd User PluginScratchInitializeAfter
      \ map <buffer> <C-m>  <Plug>(scratch-evaluate)




" surround  "{{{2

" The default mapping ys for <Plug>Ysurround is not consistent with
" the default mappings of vi -- y is for yank.
nmap s  <Plug>Ysurround
nmap ss  <Plug>Yssurround

" See also ~/.vim/plugin/surround_config.vim .




" vcsi  "{{{2

let g:vcsi_diff_in_commit_logp = 1




" xml_autons  "{{{2

let g:AutoXMLns_Dict = {}
let g:AutoXMLns_Dict['http://www.w3.org/2000/svg'] = 'svg11'




" zapit  "{{{2

nnoremap <Leader>b  :<C-u>ZapitBuf<Return>

" retained for the backward compatibility,
" but this should be prefixed by <Leader>.
nmap [Space]b  <Leader>b








" Fin.  "{{{1

if !exists('s:loaded_my_vimrc')
  let s:loaded_my_vimrc = 1
  " autocmd MyAutoCmd VimEnter *
  "   \ doautocmd MyAutoCmd User DelayedSettings
else
  " doautocmd MyAutoCmd User DelayedSettings
endif




set secure  " must be written at the last.  see :help 'secure'.








" __END__  "{{{1
" vim: bomb
" vim: expandtab softtabstop=2 shiftwidth=2
" vim: foldmethod=marker
