" My .vimrc
" Notes  "{{{1
"
" * This file consists of "sections".
"
"   - The name of each section should be single word.
"
" * Each section consists of zero or more "subsections".
"
"   - There is no rule for the name of each subsection.
"
" * The last subsection in a section should be named as "Misc.".
"
" * Whenever new subsection is inserted,
"   it should be inserted just before "Misc." subsection.
"
" * If a setting can be categorized into two or more sections,
"   it should be put into the most bottom section in this file.
"
"   For example, key mappings for a specific plugin should be put into the
"   "Plugins" section.
"
"
" Coding Rule
"
" * Separate sections with 8 blank lines.
"
" * Separate subsections with 4 blank lines.
"
" * Indentation: See the modelines at the bottom of this file.
"
" * Character Encoding: Use UTF-8 for this file and other files such as
"   plugins, but this file must contain only unibyte (i.e. 7-bit ASCII)
"   characters.
"
"   Because changing 'encoding' does not affect the character encoding of
"   existing buffers, so that each multibyte character will be treated as
"   multiple single byte characters at the first time of loading this file.
"   For example, if this file contains a character U+3042 (Japanese Hiragana
"   "A"), it will be converted into 3 independent bytes -- E3, 81 and 82.
"
" * Limit all lines to a maximum of 79 characters.
"
" * Separate {lhs} and {rhs} of key mappings with 2 spaces.
"
" * Separate {cmd} and {rep} of :command definitions with 2 spaces.
"
" * Sort arguments for :command such as -nargs=* and others by alphabetically
"   order.
"
" * Write the full name for each command -- don't abbreviate it.
"   For example, write "nnoremap", not "nn".
"
" * Key Notation:
"
"   - Control-keys: Write as <C-x>, neither <C-X> nor <c-x>.
"
"   - Carriage return: Write as <Return>, neither <Enter> nor <CR>.
"
"   - Other characters: Write as same as :help key-notation
"
" * Line continuation:
"
"   - At the middle of key mappings, abbreviations and other proler places:
"     Write "\" at the previous column of the start of the {rhs}.
"
"   - Others: Write "\" at the same column of the beggining of the command.
"
"   - Examples:
"
"     execute "echo"
"     \       "foo"
"     \       "baz"
"
"     map <silent> xyzzy  :<C-u>if has('cryptv')
"                        \|  X
"                        \|endif<Return>
"
" * Don't align columns.  So don't write like the following code:
"
"     map     <expr>   foo  bar
"     noremap <silent> bar  baz
"
"   instead, write like the following code:
"
"     map <expr> foo  bar
"     noremap <silent> bar  baz
"
" * Naming:
"
"   - Functions: Don't use upper case characters if possible.
"
"   - Functions: Use "cmd_{command}" for a {command} such as:
"     command! -nargs=* {command}  call s:cmd_{command}(<f-args>)
"
"   - Functions: Use "complete_{type}" for :command-completion-custom or
"     :command-completion-customlist functions.
"
"   - Functions: Use "on_{event}_{mod}" for a handler of :autocmd {event}.
"
"   - Use "tabpage" instead of "tab_page" or "tab page" or "tab".
"
" * Register usage:
"
"   - "g for :global.
"
"   - Don't overwrite other named registers.








" Basic  "{{{1
" Absolute  "{{{2

if !exists('s:loaded_my_vimrc')
  runtime flavors/bootstrap.vim
endif


function! s:SID_PREFIX()
 return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction




" Encoding  "{{{2

" To deal with Japanese language.
if $ENV_WORKING ==# 'summer'
  set encoding=japan
else
  set encoding=utf-8
endif

if has('iconv')
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
endif


if $ENV_ACCESS ==# 'summer'
  set termencoding=cp932
elseif has('gui_macvim')
  " E617 - It's not possible to change 'termencoding' in MacVim.
else  " fallback
  set termencoding=  " same as 'encoding'
endif




" Options  "{{{2

if (1 < &t_Co || has('gui')) && has('syntax')
  if &term ==# 'rxvt-cygwin-native'
    set t_Co=256
  endif
  syntax enable
  if !exists('g:colors_name')  " Don't override colorscheme on reloading.
    colorscheme nevfn
    set background=dark
  endif
endif

filetype plugin indent on


set ambiwidth=single
set autoindent
set backspace=indent,eol,start
set backup
set backupcopy&
set backupdir=~/tmp/vim
set backupskip&
set backupskip+=svn-commit.tmp,svn-commit.[0-9]*.tmp
set cinkeys& cinkeys-=0#
set cinoptions=:0,t0,(0,W1s
set directory=~/tmp/vim
set noequalalways
set expandtab
set formatoptions=tcroqnlM1
set formatlistpat&
let &formatlistpat .= '\|^\s*[*+-]\s*'
if exists('+fuoptions')
  set fuoptions=maxhorz,maxvert
endif
if exists('+guicursor')
  set guicursor&
  set guicursor=a:blinkwait4000-blinkon1500-blinkoff500
endif
if exists('+guifont')
  set guifont=Menlo\ Regular:h12 antialias
endif
if exists('+guioptions')
  set guioptions=cgM
endif
set history=100
set hlsearch
nohlsearch  " To avoid (re)highlighting the last search pattern
            " whenever $MYVIMRC is (re)loaded.
" set grepprg=... " See s:toggle_grepprg().
set incsearch
set laststatus=2  " always show status lines.
if exists('+macmeta')
  set macmeta
endif
set modeline  " Some distros disable this by default.
set mouse=a
set ruler
set showcmd
set showmode
set updatetime=4000
set title
set titlestring=Vim:\ %f\ %h%r%m
if exists('+transparency')
  set transparency=10
endif
set ttimeoutlen=50  " Reduce annoying delay for key codes, especially <Esc>...
set wildmenu
set viminfo=<50,'10,h,r/a,n~/.viminfo

" default 'statusline' with 'fileencoding'.
let &statusline = ''
let &statusline .= '%<%f %h%m%r%w'
let &statusline .= '%='
let &statusline .= '['
let &statusline .=   '%{&l:fileencoding == "" ? &encoding : &l:fileencoding}'
let &statusline .=   '%{&l:bomb ? "/BOM" : ""}'
let &statusline .= ']'
let &statusline .= '[%{&l:fileformat}]'
let &statusline .= '  %-14.(%l,%c%V%) %P'

function! s:my_tabline()  "{{{
  let s = ''

  for i in range(1, tabpagenr('$'))
    let bufnrs = tabpagebuflist(i)
    let curbufnr = bufnrs[tabpagewinnr(i) - 1]  " first window, first appears

    let no = (i <= 10 ? i-1 : '#')  " display 0-origin tabpagenr.
    let mod = len(filter(bufnrs, 'getbufvar(v:val, "&modified")')) ? '+' : ' '
    let title = s:gettabvar(i, 'title')
    let title = title != '' ? title : fnamemodify(s:gettabvar(i, 'cwd'), ':t')
    let title = title != '' ? title : fnamemodify(getcwd(), ':t')

    let s .= '%'.i.'T'
    let s .= '%#' . (i == tabpagenr() ? 'TabLineSel' : 'TabLine') . '#'
    let s .= no
    let s .= mod
    let s .= title
    let s .= '%#TabLineFill#'
    let s .= '  '
  endfor

  let s .= '%#TabLineFill#%T'
  let s .= '%=%#TabLine#'
  let s .= '| '
  let s .= '%999X'
  let branch_name = s:vcs_branch_name(getcwd())
  let s .= (branch_name != '' ? branch_name : '?')
  let s .= '%X'
  return s
endfunction "}}}
let &tabline = '%!' . s:SID_PREFIX() . 'my_tabline()'

if has('gui_running')
  set columns=161  " 80 + 1 + 80
  set lines=999    " Maximize GUI window vertically
endif


let g:mapleader = ','
let g:maplocalleader = '.'




" Misc.  "{{{2

" Use this group for any autocmd defined in this file.
augroup MyAutoCmd
  autocmd!
augroup END


call altercmd#load()
call arpeggio#load()


if !isdirectory($HOME . '/tmp/vim')
  call mkdir($HOME . '/tmp/vim', 'p', 0700)
endif








" Syntax  "{{{1
" User-defined commands to extend Vim script syntax.
" - Place commands which are for interactive use at the bottom.
" FIXME: syntax highlighting
" FIXME: completion
" Stuffs  "{{{2

let s:FALSE = 0
let s:TRUE = !s:FALSE


function! s:separate_list(list, regexp)
  let i = 0
  while i < len(a:list) && a:list[i] =~# a:regexp
    let i += 1
  endwhile
  return [(0 < i ? a:list[:i-1] : []), a:list[(i):]]
endfunction


function! s:contains_p(list, regexp)
  for item in a:list
    if item =~# a:regexp
      return s:TRUE
    endif
  endfor
  return s:FALSE
endfunction




" :map wrappers "{{{2
" Allmap - :map in all modes  "{{{3

command! -nargs=+ Allmap
\   execute 'map' <q-args>
\ | execute 'map!' <q-args>

command! -nargs=+ Allnoremap
\   execute 'noremap' <q-args>
\ | execute 'noremap!' <q-args>

command! -nargs=+ Allunmap
\   execute 'unmap' <q-args>
\ | execute 'unmap!' <q-args>


" Cmap - wrapper of :map to easily execute commands  "{{{3
"
" :Cmap {lhs} {script}
"   Other variants:
"   Cmap!, Ccmap, Cimap, Clmap, Cnmap, Comap, Csmap, Cvmap, Cxmap,
"   Callmap, Cobjmap.
"
" {lhs}
"   Same as :map.  As additional :map-arguments, <count> and <noexec> are
"   available.
"
"   <count>
"     Whenever {script} are executed, count effect (e.g. typing "3:" will be
"     treated as ":.,+2") is ignored unless <count> is specified.
"
"   <noexec>
"     If <noexec> is specified, {script} is just inserted in the
"     Command-line, but it's not executed.
"
" {script}
"   A script which is executed whenever key sequence {lhs} are typed.

command! -bang -nargs=* Cmap  call s:cmd_Cmap('', '<bang>', [<f-args>])
command! -nargs=* Ccmap  call s:cmd_Cmap('c', '', [<f-args>])
command! -nargs=* Cimap  call s:cmd_Cmap('i', '', [<f-args>])
command! -nargs=* Clmap  call s:cmd_Cmap('l', '', [<f-args>])
command! -nargs=* Cnmap  call s:cmd_Cmap('n', '', [<f-args>])
command! -nargs=* Comap  call s:cmd_Cmap('o', '', [<f-args>])
command! -nargs=* Csmap  call s:cmd_Cmap('s', '', [<f-args>])
command! -nargs=* Cvmap  call s:cmd_Cmap('v', '', [<f-args>])
command! -nargs=* Cxmap  call s:cmd_Cmap('x', '', [<f-args>])
command! -nargs=* Callmap  call s:cmd_Cmap('All', '', [<f-args>])
command! -nargs=* Cobjmap  call s:cmd_Cmap('Obj', '', [<f-args>])
function! s:cmd_Cmap(prefix, suffix, args)
  " FIXME: This parsing may not be compatible with the original one.
  let [options, rest] = s:separate_list(a:args,
  \ '^\c<\(buffer\|expr\|script\|silent\|special\|unique\|count\|noexec\)>$')
  if len(rest) < 2
    throw 'Insufficient number of arguments: ' . string(rest)
  endif
  let lhs = rest[0]
  let script = rest[1:]
  let count_p = s:contains_p(options, '^\c<count>$')
  let noexec_p = s:contains_p(options, '^\c<noexec>$')
  call filter(options, 'v:val !~# ''^\c<\(count\|noexec\)>$''')

  execute a:prefix.'noremap'.a:suffix join(options) lhs
  \ ':'.(count_p ? '' : '<C-u>') . join(script) . (noexec_p ? '' : '<Return>')
endfunction


" Fmap - wrapper of :map to easily call a function  "{{{3
"
" :Fmap {lhs} {expression}
"   Other variants:
"   Fmap!, Fcmap, Fimap, Flmap, Fnmap, Fomap, Fsmap, Fvmap, Fxmap,
"   Fallmap, Fobjmap.
"
" {lhs}
"   Same as :map.
"
" {expression}
"   An expression to call a function (without :call).  This expression is
"   executed whenever key sequence {lhs} are typed.

command! -bang -nargs=* Fmap  call s:cmd_Fmap('', '<bang>', [<f-args>])
command! -nargs=* Fcmap  call s:cmd_Fmap('c', '', [<f-args>])
command! -nargs=* Fimap  call s:cmd_Fmap('i', '', [<f-args>])
command! -nargs=* Flmap  call s:cmd_Fmap('l', '', [<f-args>])
command! -nargs=* Fnmap  call s:cmd_Fmap('n', '', [<f-args>])
command! -nargs=* Fomap  call s:cmd_Fmap('o', '', [<f-args>])
command! -nargs=* Fsmap  call s:cmd_Fmap('s', '', [<f-args>])
command! -nargs=* Fvmap  call s:cmd_Fmap('v', '', [<f-args>])
command! -nargs=* Fxmap  call s:cmd_Fmap('x', '', [<f-args>])
command! -nargs=* Fallmap  call s:cmd_Fmap('All', '', [<f-args>])
command! -nargs=* Fobjmap  call s:cmd_Fmap('Obj', '', [<f-args>])
function! s:cmd_Fmap(prefix, suffix, args)
  " FIXME: This parsing may not be compatible with the original one.
  let [options, rest] = s:separate_list(a:args,
  \ '^\c<\(buffer\|expr\|script\|silent\|special\|unique\)>$')
  if len(rest) < 2
    throw 'Insufficient number of arguments: ' . string(rest)
  endif
  let lhs = rest[0]
  let rhs = rest[1:]

  execute a:prefix.'noremap'.a:suffix join(options) lhs
  \ ':<C-u>call' join(rhs) '<Return>'
endfunction


" Objmap - :map for text objects  "{{{3
"
" Keys for text objects should be mapped in Visual mode and Operator-pending
" mode.  The following commands are just wrappers to avoid DRY violation.

command! -nargs=+ Objmap
\   execute 'omap' <q-args>
\ | execute 'vmap' <q-args>

command! -nargs=+ Objnoremap
\   execute 'onoremap' <q-args>
\ | execute 'vnoremap' <q-args>

command! -nargs=+ Objunmap
\   execute 'ounmap' <q-args>
\ | execute 'vunmap' <q-args>


" Operatormap - :map for oeprators  "{{{3
"
" Keys for operators should be mapped in Normal mode and Visual mode.  The
" following commands are just wrappers to avoid DRY violation.
"
" FIXME: How about mapping to g@ in Operator-pending mode
"        to use {operator}{operator} pattern?

command! -nargs=+ Operatormap
\   execute 'nmap' <q-args>
\ | execute 'vmap' <q-args>

command! -nargs=+ Operatornoremap
\   execute 'nnoremap' <q-args>
\ | execute 'vnoremap' <q-args>

command! -nargs=+ Operatorunmap
\   execute 'nunmap' <q-args>
\ | execute 'vunmap' <q-args>




" CD - alternative :cd with more user-friendly completion  "{{{2

command! -complete=customlist,s:complete_cdpath -nargs=+ CD  cd <args>
function! s:complete_cdpath(arglead, cmdline, cursorpos)
  return split(globpath(&cdpath,
  \                     join(split(a:cmdline, '\s', s:TRUE)[1:], ' ') . '*/'),
  \            "\n")
endfunction

AlterCommand cd  CD




" Hecho, Hechon, Hechomsg - various :echo with highlight specification  "{{{2

command! -bar -nargs=+ Hecho  call s:cmd_Hecho('echo', [<f-args>])
command! -bar -nargs=+ Hechon  call s:cmd_Hecho('echon', [<f-args>])
command! -bar -nargs=+ Hechomsg  call s:cmd_Hecho('echomsg', [<f-args>])
function! s:cmd_Hecho(echo_command, args)
  let highlight_name = a:args[0]
  let messages = a:args[1:]

  execute 'echohl' highlight_name
  execute a:echo_command join(messages)
  echohl None
endfunction




" KeyboardLayout - declare differences of logical and physical layouts  "{{{2
"
" :KeyboardLayout {physical-key}  {logical-key}
"
"   Declare that whenever Vim gets a character {logical-key}, the
"   corresponding physical key is {physical-key}.  This declaration is useful
"   to define a mapping based on physical keyboard layout.
"
"   Example: Map the physical key {X} to {rhs}:
"   noremap <Plug>(physical-key-{X}) {rhs}

command! -nargs=+ KeyboardLayout  call s:cmd_KeyboardLayout(<f-args>)
function! s:cmd_KeyboardLayout(physical_key, logical_key)
  let indirect_key = '<Plug>(physical-key-' . a:physical_key . ')'
  execute 'Allmap' a:logical_key indirect_key
  execute 'Allnoremap' indirect_key a:logical_key
endfunction




" Qexecute - variant of :execute with some extensions  "{{{2
"
" Like :execute but all arguments are treated as single string like <q-args>.
" As an extension, "[count]" will be expanded to the currently given count.

command! -complete=command -nargs=* Qexecute  call s:cmd_Qexecute(<q-args>)
function! s:cmd_Qexecute(script)
  execute substitute(a:script, '\[count\]', s:count(), 'g')
endfunction

function! s:count(...)
  if v:count == v:count1  " is count given?
    return v:count
  else  " count isn't given.  (the default '' is useful for special value)
    return a:0 == 0 ? '' : a:1
  endif
endfunction




" Source - wrapper of :source with echo.  "{{{2
" FIXME: better name.

command! -bar -nargs=1 Source
\   echo 'Sourcing ...' expand(<q-args>)
\ | source <args>




" Split - :split variants  "{{{2

command! -bar -nargs=1 Split  call s:cmd_Split(<q-args>)
function! s:cmd_Split(direction)
  let DIRECTION_MODIFIER_TABLE = {
  \   'Top': 'topleft',
  \   'Bottom': 'botright',
  \   'Left': 'vertical topleft',
  \   'Right': 'vertical botright',
  \   'above': 'leftabove',
  \   'below': 'rightbelow',
  \   'left': 'vertical leftabove',
  \   'right': 'vertical rightbelow',
  \ }

  let modifier = get(DIRECTION_MODIFIER_TABLE, a:direction, 0)
  if modifier is 0
    echoerr 'Invalid direction:' string(a:direction)
    return
  endif

  execute modifier 'split'
endfunction




" SuspendWithAutomticCD  "{{{2
" Assumption: Use GNU screen.
" Assumption: There is a window with the title "another".
" FIXME: Open a (GNU screen) window for each directory.

if !exists('s:GNU_SCREEN_AVAILABLE_P')
  if has('gui_running')
    " In GUI, $WINDOW is not reliable, because GUI process is independent from
    " GNU screen process.  Check availability of executable instead.
    let s:GNU_SCREEN_AVAILABLE_P = executable('screen')
  else
    " In CUI, availability of executable is not reliable, because Vim may be
    " invoked with "screen ssh example.com vim" and GNU screen may be
    " available at example.com.  Check $WINDOW instead.
    let s:GNU_SCREEN_AVAILABLE_P = len($WINDOW) != 0
  endif
endif

command! -bar -nargs=0 SuspendWithAutomticCD
\ call s:cmd_SuspendWithAutomticCD()
function! s:cmd_SuspendWithAutomticCD()
  if s:GNU_SCREEN_AVAILABLE_P
    call s:activate_terminal()

    " \015 = <C-m>
    " To avoid adding the cd script into the command-line history,
    " there are extra leading whitespaces in the cd script.
    silent execute '!screen -X eval'
    \              '''select another'''
    \              '''stuff "  cd \"'.getcwd().'\"  \#\#,vim-auto-cd\015"'''
    redraw!
    " TODO: Show what happened on failure.
  else
    suspend
  endif
endfunction




" TabpageTitle - name the current tabpage  "{{{2

command! -bar -nargs=* TabpageTitle
\   if <q-args> == ''
\ |   let t:title = input("Set tabpage's title to: ",'')
\ | else
\ |   let t:title = <q-args>
\ | endif




" UsualDays - set up the layout of my usual days  "{{{2

command! -bar -nargs=0 UsualDays  call s:cmd_UsualDays()
function! s:cmd_UsualDays()
  normal! 'T
  execute 'CD' fnamemodify(expand('%'), ':p:h')
  TabpageTitle meta

  tabnew
  normal! 'V
  execute 'CD' fnamemodify(expand('%'), ':p:h:h:h')
  TabpageTitle config
endfunction




" Utf8 and others - :edit with specified 'fileencoding'  "{{{2

command! -bang -bar -complete=file -nargs=? Cp932
\ edit<bang> ++enc=cp932 <args>
command! -bang -bar -complete=file -nargs=? Eucjp
\ edit<bang> ++enc=euc-jp <args>
command! -bang -bar -complete=file -nargs=? Iso2022jp
\ edit<bang> ++enc=iso-2022-jp <args>
command! -bang -bar -complete=file -nargs=? Utf8
\ edit<bang> ++enc=utf-8 <args>

command! -bang -bar -complete=file -nargs=? Jis  Iso2022jp<bang> <args>
command! -bang -bar -complete=file -nargs=? Sjis  Cp932<bang> <args>








" Utilities  "{{{1
" Font selector  "{{{2

command! -complete=customlist,s:cmd_Font_complete -nargs=* Font
\ set guifont=<args>

function! s:cmd_Font_complete(arglead, cmdline, cursorpos)
  " FIXME: Proper completion
  return [
  \   'Ayuthaya:h14 antialias',
  \   'cinecaption:h16 antialias',
  \   'DejaVu\ Sans\ Mono:h14 antialias',
  \   'Droid\ Sans\ Mono:h14 antialias',
  \   'Monaco:h14 antialias',
  \   'Osaka-Mono:h15 antialias',
  \   'Osaka-Mono:h16 antialias',
  \   'PC98:h16 noantialias',
  \   'Source\ Code\ Pro:h14 antialias',
  \ ]
endfunction




" Help-related stuffs  "{{{2

function! s:helpbufwinnr()
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

function! s:close_help_window()
  let [help_bufnr, help_winnr] = s:helpbufwinnr()
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

function! s:keys_to_complete()
  if &l:filetype ==# 'vim'
    return "\<C-x>\<C-v>"
  elseif strlen(&l:omnifunc)
    return "\<C-x>\<C-o>"
  else
    return "\<C-n>"
  endif
endfunction


function! s:keys_to_escape_command_line_mode_if_empty(key)
  if getcmdline() == ''
    return "\<Esc>"
  else
    return a:key
  end
endfunction


function! s:keys_to_insert_one_character()
  Hecho ModeMsg '-- INSERT (one char) --'
  return nr2char(getchar()) . "\<Esc>"
endfunction


function! s:keys_to_select_the_last_changed_text()
  " It is not possible to determine whether the last operation to change text
  " is linewise or not, so guess the wise of the last operation from the range
  " of '[ and '], like wise of a register content set by setreg() without
  " {option}.

  let col_begin = col("'[")
  let col_end = col("']")
  let length_end = len(getline("']"))

  let maybe_linewise_p = (col_begin == 1
  \                       && (col_end == length_end
  \                           || (length_end == 0 && col_end == 1)))
  return '`[' . (maybe_linewise_p ? 'V' : 'v') . '`]'
endfunction


function! s:keys_to_stop_insert_mode_completion()
  if pumvisible()
    return "\<C-y>"
  else
    return "\<Space>\<BS>"
  endif
endfunction




" Jump sections  "{{{2

" for normal mode.  a:pattern is '/regexp' or '?regexp'.
function! s:jump_section_n(pattern)
  let pattern = a:pattern[1:]
  let forward_p = a:pattern[0] == '/'
  let flags = forward_p ? 'W' : 'Wb'

  mark '
  let i = 0
  while i < v:count1
    if search(pattern, flags) == 0
      if forward_p
        normal! G
      else
        normal! gg
      endif
      break
    endif
    let i = i + 1
  endwhile
endfunction


" for visual mode.  a:motion is '[[', '[]', ']]' or ']['.
function! s:jump_section_v(motion)
  execute 'normal!' "gv\<Esc>"
  execute 'normal' v:count1 . a:motion
  let line = line('.')
  let col = col('.')

  normal! gv
  call cursor(line, col)
endfunction


" for operator-pending mode.  a:motion is '[[', '[]', ']]' or ']['.
function! s:jump_section_o(motion)
  execute 'normal' v:count1 . a:motion
endfunction




" Sum numbers "{{{2

command! -bang -bar -nargs=* -range Sum
\ <line1>,<line2>call s:cmd_Sum(<bang>0, <f-args>)
function! s:cmd_Sum(banged_p, ...) range
  let field_number = (1 <= a:0 ? a:1 : 1)
  let field_separator = (2 <= a:0 ? a:2 : 0)
  execute a:firstline ',' a:lastline '!awk'
  \ (field_separator is 0 ? '' : '-F'.field_separator)
  \ "'"
  \ 'BEGIN {x = 0}'
  \ '{x = x + $'.field_number '}'
  \ '{if (\!' a:banged_p ') print $0}'
  \ 'END {print x}'
  \ "'"
endfunction




" Tabpage visit history  "{{{2

autocmd MyAutoCmd TabEnter *  let t:entered_at = reltime()
if !exists('s:loaded_my_vimrc')
  " TabEnter will never be triggered for the initial tabpage.
  doautocmd MyAutoCmd TabEnter
endif

function! s:back_to_the_last_tabpage()
  if tabpagenr('$') == 1
    Hecho ErrorMsg 'There is only one tab page.  Nowhere to back.'
    return
  endif

  let tn = tabpagenr()
  let xs = []
  noautocmd tabdo call add(xs, [reltimestr(t:entered_at), tabpagenr()])
  noautocmd execute 'normal!' tn . 'gt'
  call remove(xs, tn - 1)
  call sort(xs)

  execute 'normal!' xs[-1][1] . 'gt'
endfunction




" Toggle options  "{{{2

function! s:toggle_bell()
  if &visualbell
    set novisualbell t_vb&
    echo 'bell on'
  else
    set visualbell t_vb=
    echo 'bell off'
  endif
endfunction

function! s:toggle_grepprg()
  " Toggle, more precisely, rotate the value of 'grepprg'.
  " If 'grepprg' has a value not listed in VALUES,
  " treat VALUES[0] as the default/fallback value,
  " and set 'grepprg' to the value.
  let VALUES = ['git grep -n', 'internal']
  let i = (index(VALUES, &grepprg) + 1) % len(VALUES)

  let grepprg = &grepprg
  let &grepprg = VALUES[i]
  echo "'grepprg' =" &grepprg '(was' grepprg.')'
endfunction
if !exists('s:loaded_my_vimrc')
  " Set 'grepprg' to my default value.  In this scope, 'grepprg' has Vim's
  " default value and it differs from what I want to use.  So that calling
  " s:toggle_grepprg() at here does set 'grepprg' to my default value.
  silent call s:toggle_grepprg()

  if !has('unix')
    " For non-*nix environments, git is not usually available.  To avoid error
    " and manual toggling, set 'grepprg' to my alternative value.
    silent call s:toggle_grepprg()
  endif
endif

function! s:toggle_option(option_name)
  execute 'setlocal' a:option_name.'!'
  execute 'setlocal' a:option_name.'?'
endfunction




" Window-related stuffs  "{{{2

" Are the windows :split'ed and :vsplit'ed?
function! s:windows_jumbled_p()
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


function! s:move_window_then_equalize_if_necessary(direction)
  let jumbled_beforep = s:windows_jumbled_p()
  execute 'wincmd' a:direction
  let jumbled_afterp = s:windows_jumbled_p()

  if jumbled_beforep || jumbled_afterp
    wincmd =
  endif
endfunction


function! s:move_window_into_tabpage(target_tabpagenr)
  " Move the current window into a:target_tabpagenr.
  " If a:target_tabpagenr is 0, move into new tabpage.
  if a:target_tabpagenr < 0  " ignore invalid number.
    return
  endif
  let original_tabnr = tabpagenr()
  let target_bufnr = bufnr('')
  let window_view = winsaveview()

  if a:target_tabpagenr == 0
    tabnew
    tabmove  " Move new tabpage at the last.
    execute target_bufnr 'buffer'
    let target_tabpagenr = tabpagenr()
  else
    execute a:target_tabpagenr 'tabnext'
    let target_tabpagenr = a:target_tabpagenr
      " FIXME: be customizable?
    execute 'topleft' target_bufnr 'sbuffer'
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


function! s:scroll_other_window(scroll_command)
  if winnr('#') == 0 || winnr('#') == winnr()
    " Do nothing if there is not proper previous window.
    " Note that winnr('#') sometime returns the number for the current window
    " instead of 0.  So the latter condition is necessary.
    "
    " Example session to reproduce the winnr('#') problem:
    "   tabnew
    "   wincmd v
    "   wincmd h
    "   wincmd l
    "   wincmd h
    "   echo winnr('#')  " ==> 2
    "   wincmd l
    "   wincmd c
    "   echo winnr('#')  " ==> 1 -- although it should be 0.
    Hecho WarningMsg 'No window to scroll'
  else
    wincmd p
    execute 'normal!' (s:count() . a:scroll_command)
    wincmd p
  endif
endfunction


command! -bar -nargs=0 SplitNicely  call s:split_nicely()
function! s:split_nicely()
  if 80*2 * 15/16 <= winwidth(0)  " FIXME: threshold customization
    vsplit
  else
    split
  endif
endfunction




" VCS branch name  "{{{2
" Returns the name of the current branch of the given directory.
" BUGS: git is only supported.
let s:_vcs_branch_name_cache = {}  " dir_path = [branch_name, cache_key]


function! s:vcs_branch_name(dir)
  let cache_entry = get(s:_vcs_branch_name_cache, a:dir, 0)
  if cache_entry is 0
  \  || cache_entry[1] !=# s:_vcs_branch_name_cache_key(a:dir)
    unlet cache_entry
    let cache_entry = s:_vcs_branch_name(a:dir)
    let s:_vcs_branch_name_cache[a:dir] = cache_entry
  endif

  return cache_entry[0]
endfunction


function! s:_vcs_branch_name_cache_key(dir)
  return getftime(a:dir . '/.git/HEAD') . getftime(a:dir . '/.git/MERGE_HEAD')
endfunction


function! s:_vcs_branch_name(dir)
  let git_dir = a:dir . '/.git'

  if isdirectory(git_dir)
    if isdirectory(git_dir . '/rebase-apply')
      if filereadable(git_dir . '/rebase-apply/rebasing')
        let additional_info = 'REBASE'
      elseif filereadable(git_dir . '/rebase-apply/applying')
        let additional_info = 'AM'
      else
        let additional_info = 'AM/REBASE'
      endif
      let head_info = s:first_line(git_dir . '/HEAD')
    elseif filereadable(git_dir . '/rebase-merge/interactive')
      let additional_info = 'REBASE-i'
      let head_info = s:first_line(git_dir . '/rebase-merge/head-name')
    elseif isdirectory(git_dir . '/rebase-merge')
      let additional_info = 'REBASE-m'
      let head_info = s:first_line(git_dir . '/rebase-merge/head-name')
    elseif filereadable(git_dir . '/MERGE_HEAD')
      let additional_info = 'MERGING'
      let head_info = s:first_line(git_dir . '/HEAD')
    else  " Normal case
      let additional_info = ''
      let head_info = s:first_line(git_dir . '/HEAD')
    endif

    let branch_name = matchstr(head_info, '^\(ref: \)\?refs/heads/\zs\S\+\ze$')
    if branch_name == ''
      let lines = readfile(git_dir . '/logs/HEAD')
      let co_lines = filter(lines, 'v:val =~# "checkout: moving from"')
      let log = empty(co_lines) ? '' : co_lines[-1]
      let branch_name = substitute(log, '^.* to \([^ ]*\)$', '\1', '')
      if branch_name == ''
        let branch_name = '(unknown)'
      endif
    endif
    if additional_info != ''
      let branch_name .= ' ' . '(' . additional_info . ')'
    endif
  else  " Not in a git repository.
    let branch_name = '-'
  endif

  return [branch_name, s:_vcs_branch_name_cache_key(a:dir)]
endfunction




function! s:activate_terminal()  "{{{2
  if !has('gui_running')
    return
  endif

  if has('macunix')
    " There is alternative way to activate, but it's slow:
    " !osascript -e 'tell application "Terminal" to activate the front window'
    silent !open -a Terminal
  else
    " This platform is not supported.
  endif
endfunction




function! s:all_combinations(xs)  "{{{2
  let cs = []

  for r in range(1, len(a:xs))
    call extend(cs, s:combinations(a:xs, r))
  endfor

  return cs
endfunction




function! s:combinations(pool, r)  "{{{2
  let n = len(a:pool)
  if n < a:r || a:r <= 0
    return []
  endif

  let result = []

  let indices = range(a:r)
  call add(result, join(map(copy(indices), 'a:pool[v:val]'), ''))

  while s:TRUE
    let broken_p = s:FALSE
    for i in reverse(range(a:r))
      if indices[i] != i + n - a:r
        let broken_p = s:TRUE
        break
      endif
    endfor
    if !broken_p
      break
    endif

    let indices[i] += 1
    for j in range(i + 1, a:r - 1)
      let indices[j] = indices[j-1] + 1
    endfor
    call add(result, join(map(copy(indices), 'a:pool[v:val]'), ''))
  endwhile

  return result
endfunction




function! s:extend_highlight(target_group, original_group, new_settings)  "{{{2
  let mode = has('gui_running') ? 'gui' : (1 < &t_Co ? 'cterm' : 'term')
  let m = mode[0]
  let items = [
  \   'bg',
  \   'bold',
  \   'fg',
  \   'font',
  \   'italic',
  \   'reverse',
  \   'sp',
  \   'standout',
  \   'undercurl',
  \   'underline',
  \ ]
  let d = {}
  for i in items
    let d[i] = synIDattr(synIDtrans(hlID(a:original_group)), i)
  endfor

  let attributes = filter(
  \   map(
  \     ['bold', 'italic', 'reverse', 'standout', 'undercurl', 'underline'],
  \     'd[v:val] ? v:val : 0'
  \   ),
  \   'v:val isnot 0'
  \ )
  let original_settings = join([
  \   mode.'='.join(empty(attributes) ? ['NONE'] : attributes, ','),
  \   (m !=# 't' && d['bg'] != '' && 0 <= d['bg'] ? mode.'bg='.d['bg'] : ''),
  \   (m !=# 't' && d['fg'] != '' && 0 <= d['fg'] ? mode.'fg='.d['fg'] : ''),
  \   (m ==# 'g' && d['sp'] != '' ? mode.'sp='.d['sp'] : ''),
  \   (m ==# 'g' && d['font'] != '' ? 'font='.d['font'] : ''),
  \ ])

  silent execute 'highlight' a:target_group 'NONE'
  \          '|' 'highlight' a:target_group original_settings
  \          '|' 'highlight' a:target_group a:new_settings
endfunction




function! s:first_line(file)  "{{{2
  let lines = readfile(a:file, '', 1)
  return 1 <= len(lines) ? lines[0] : ''
endfunction




function! s:gettabvar(tabpagenr, varname)  "{{{2
  " Wrapper for non standard (my own) built-in function gettabvar().
  return exists('*gettabvar') ? gettabvar(a:tabpagenr, a:varname) : ''
endfunction




function! s:git_controlled_directory_p()  "{{{2
  call system('git rev-parse --is-inside-work-tree')
  return v:shell_error == 0
endfunction




function! s:join_here(...)  "{{{2
  " like join (J), but move the next line into the cursor position.

  let adjust_spacesp = a:0 ? a:1 : 1
  let pos = getpos('.')
  let r = @"

  if line('.') == line('$')
    Hecho ErrorMsg 'Unable to join at the bottom line.'
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




function! s:operator_adjust_window_height(motion_wiseness)  "{{{2
  execute (line("']") - line("'[") + 1) 'wincmd' '_'
  normal! `[zt
endfunction




function! s:operator_calculate_sum_of_fields(motion_wiseness)  "{{{2
  let sum = 0
  for line in getline(line("'["), line("']"))
    let sum += str2nr(matchstr(line, '^\s*\zs-\?\d\+\ze\>'))
  endfor
  ']put =sum
endfunction




function! s:set_short_indent()  "{{{2
  setlocal expandtab softtabstop=2 shiftwidth=2
endfunction








" Mappings  "{{{1
" FIXME: some mappings are not countable.
" Physical/Logical keyboard layout declaration  "{{{2

if $ENV_WORKING != 'summer' && $ENV_WORKING !=# 'winter'
  " Semicolon and Return are swapped by KeyRemap4MacBook, Mayu or Kinesis on
  " some environments.
  KeyboardLayout ;  <Return>
  KeyboardLayout :  <S-Return>
  KeyboardLayout <Return>  ;
  KeyboardLayout <S-Return>  :
else
  KeyboardLayout ;  ;
  KeyboardLayout :  :
  KeyboardLayout <Return>  <Return>
  KeyboardLayout <S-Return>  <S-Return>
endif

" For ease of typing, treat <kEnter> as if it is a <Return> key.
Allmap <kEnter>  <Return>
Allmap <S-kEnter>  <S-Return>




" Terminal-GUI interoperability  "{{{2
"
" A key which user actually types (A) may be translated into other key
" sequence (T) in terminal.  For example, <C-Space> is translated into <C-@>
" = <Nul>.
"
" Most of key mappings in this vimrc are written in (T), because:
" - It's possible to reuse existing settings without big change.
" - It's not possible to use some key mappings which are not available in
"   terminal as {lhs} of :map commands.
"
" To deal with this problem, define the following key mappings to emulate the
" translation of terminal for GUI environment.

" <M-{x}> => <Esc>x
function! s:emulate_meta_esc_behavior_in_terminal()
  " [key, acceptable-modifiers-except-meta]  "{{{
  let keys = [
  \   ['!', ''],
  \   ['"', ''],
  \   ['#', ''],
  \   ['$', ''],
  \   ['%', ''],
  \   ['&', ''],
  \   ['''', ''],
  \   ['(', ''],
  \   [')', ''],
  \   ['*', ''],
  \   ['+', ''],
  \   [',', ''],
  \   ['-', ''],
  \   ['.', ''],
  \   ['0', ''],
  \   ['1', ''],
  \   ['2', ''],
  \   ['3', ''],
  \   ['4', ''],
  \   ['5', ''],
  \   ['6', ''],
  \   ['7', ''],
  \   ['8', ''],
  \   ['9', ''],
  \   [':', ''],
  \   [';', ''],
  \   ['<BS>', 'CS'],
  \   ['<Bar>', ''],
  \   ['<Bslash>', 'C'],
  \   ['<Del>', 'CS'],
  \   ['<Down>', 'CS'],
  \   ['<End>', 'CS'],
  \   ['<Esc>', 'CS'],
  \   ['<F10>', 'CS'],
  \   ['<F11>', 'CS'],
  \   ['<F12>', 'CS'],
  \   ['<F1>', 'CS'],
  \   ['<F2>', 'CS'],
  \   ['<F3>', 'CS'],
  \   ['<F4>', 'CS'],
  \   ['<F5>', 'CS'],
  \   ['<F6>', 'CS'],
  \   ['<F7>', 'CS'],
  \   ['<F9>', 'CS'],
  \   ['<F9>', 'CS'],
  \   ['<Home>', 'CS'],
  \   ['<LT>', ''],
  \   ['<Left>', 'CS'],
  \   ['<PageDown>', 'CS'],
  \   ['<PageUp>', 'CS'],
  \   ['<Return>', 'CS'],
  \   ['<Right>', 'CS'],
  \   ['<Space>', 'CS'],
  \   ['<Tab>', 'CS'],
  \   ['<Up>', 'CS'],
  \   ['=', ''],
  \   ['>', ''],
  \   ['@', 'C'],
  \   ['A', ''],
  \   ['B', ''],
  \   ['C', ''],
  \   ['D', ''],
  \   ['E', ''],
  \   ['F', ''],
  \   ['G', ''],
  \   ['H', ''],
  \   ['I', ''],
  \   ['J', ''],
  \   ['K', ''],
  \   ['L', ''],
  \   ['M', ''],
  \   ['N', ''],
  \   ['O', ''],
  \   ['P', ''],
  \   ['Q', ''],
  \   ['R', ''],
  \   ['S', ''],
  \   ['T', ''],
  \   ['U', ''],
  \   ['V', ''],
  \   ['W', ''],
  \   ['X', ''],
  \   ['Y', ''],
  \   ['Z', ''],
  \   ['[', 'C'],
  \   [']', 'C'],
  \   ['^', 'C'],
  \   ['_', 'C'],
  \   ['`', ''],
  \   ['a', 'C'],
  \   ['b', 'C'],
  \   ['c', 'C'],
  \   ['d', 'C'],
  \   ['e', 'C'],
  \   ['f', 'C'],
  \   ['g', 'C'],
  \   ['h', 'C'],
  \   ['i', 'C'],
  \   ['j', 'C'],
  \   ['k', 'C'],
  \   ['l', 'C'],
  \   ['m', 'C'],
  \   ['n', 'C'],
  \   ['o', 'C'],
  \   ['p', 'C'],
  \   ['q', 'C'],
  \   ['r', 'C'],
  \   ['s', 'C'],
  \   ['t', 'C'],
  \   ['u', 'C'],
  \   ['v', 'C'],
  \   ['w', 'C'],
  \   ['x', 'C'],
  \   ['y', 'C'],
  \   ['z', 'C'],
  \   ['{', ''],
  \   ['}', ''],
  \   ['~', ''],
  \ ]
  "}}}

  for [key, modifiers] in keys
    let k = substitute(key, '\v^\<(.*)\>$', '\1', '')

    execute 'Allmap' '<M-'.k.'>'  '<Esc>'.key
    for m in s:modifier_combinations(modifiers)
      execute 'Allmap' '<M-'.m.k.'>'  '<Esc><'.m.k.'>'
    endfor
  endfor
endfunction

function! s:modifier_combinations(modifiers)
  let prefixes = map(range(len(a:modifiers)), 'a:modifiers[v:val] . "-"')
  return s:all_combinations(prefixes)
endfunction


if has('gui_running')
  " NUL
  Allmap <C-Space>  <C-@>

  call s:emulate_meta_esc_behavior_in_terminal()
endif




" Lazy man's hacks on the Semicolon key  "{{{2
"
" - Don't want to press Shift to enter the Command-line mode.
" - Don't want to press far Return key to input <Return>.
"
" Note: To override these definitions by other mappings, these must be written
" before them.

noremap <Plug>(physical-key-;)  :
noremap <Plug>(physical-key-:)  ;
noremap <Plug>(physical-key-<Return>)  <Return>
noremap <Plug>(physical-key-<S-Return>)  <S-Return>
noremap! <Plug>(physical-key-;)  <Return>
noremap! <Plug>(physical-key-:)  <S-Return>
noremap! <Plug>(physical-key-<Return>)  ;
noremap! <Plug>(physical-key-<S-Return>)  :

" Synonyms for the far Return key.
map [Space]<Return>  <Plug>(physical-key-<Return>)
map [Space];  <Plug>(physical-key-<Return>)

" Experimental: to input semicolon/colon without the far Semicolon key.
noremap! <Esc>,  ;
noremap! <Esc>.  :
noremap! <Esc>/  ;
noremap! <Esc>?  :




" Tag jumping  "{{{2
" Fallback  "{{{3

" ``T'' is also disabled for consistency.
noremap t  <Nop>
noremap T  <Nop>

" Alternatives for the original actions.
noremap [Space]t  t
noremap [Space]T  T


" Basic  "{{{3

nnoremap tt  <C-]>
vnoremap tt  <C-]>
Cnmap <silent> tj  tag
Cnmap <silent> tk  pop
Cnmap <silent> tl  tags
Cnmap <silent> tn  tnext
Cnmap <silent> tp  tprevious
Cnmap <silent> tP  tfirst
Cnmap <silent> tN  tlast

" additions, like Web browsers
nmap <Plug>(physical-key-<Return>)  tt
vmap <Plug>(physical-key-<Return>)  tt

" addition, interactive use.
Cnmap <noexec> t<Space>  tag<Space>


" With the preview window  "{{{3

nnoremap t't  <C-w>}
vnoremap t't  <C-w>}
Cnmap <silent> t'n  ptnext
Cnmap <silent> t'p  ptprevious
Cnmap <silent> t'P  ptfirst
Cnmap <silent> t'N  ptlast

" although :pclose is not related to tag.
" BUGS: t'' is not related to the default meaning of ''.
Cnmap <silent> t'c  pclose
nmap t'z  t'c
nmap t''  t'c


" With :split  "{{{3

nnoremap tst  <C-w>]
vnoremap tst  <C-w>]
Cnmap <silent> tsn  split \| tnext
Cnmap <silent> tsp  split \| tpevious
Cnmap <silent> tsP  split \| tfirst
Cnmap <silent> tsN  split \| tlast

  " FIXME: Define also in Visual mode -- but is it really useful?
  " NB: <C-]> is not inserted also in Command-line mode since Vim 7.3.1235.
Cnmap <silent> tsH  Split Left \| normal! <C-v><C-]>
Cnmap <silent> tsJ  Split Bottom \| normal! <C-v><C-]>
Cnmap <silent> tsK  Split Top \| normal! <C-v><C-]>
Cnmap <silent> tsL  Split Right \| normal! <C-v><C-]>
Cnmap <silent> tsh  Split left \| normal! <C-v><C-]>
Cnmap <silent> tsj  Split below \| normal! <C-v><C-]>
Cnmap <silent> tsk  Split above \| normal! <C-v><C-]>
Cnmap <silent> tsl  Split right \| normal! <C-v><C-]>




" Quickfix  "{{{2
" Fallback  "{{{3

" the prefix key.
nnoremap q  <Nop>

" alternative key for the original action.
" -- Ex-mode will be never used and recordings are rarely used.
nnoremap Q  q


" For quickfix list  "{{{3

Cnmap <silent> qj  Qexecute cnext [count]
Cnmap <silent> qk  Qexecute cprevious [count]
Cnmap <silent> qr  Qexecute crewind [count]
Cnmap <silent> qK  Qexecute cfirst [count]
Cnmap <silent> qJ  Qexecute clast [count]
Cnmap <silent> qfj  Qexecute cnfile [count]
Cnmap <silent> qfk  Qexecute cpfile [count]
Cnmap <silent> ql  clist
Cnmap <silent> qq  Qexecute cc [count]
Cnmap <silent> qo  Qexecute copen [count]
Cnmap <silent> qc  cclose
Cnmap <silent> qp  Qexecute colder [count]
Cnmap <silent> qn  Qexecute cnewer [count]
Cnmap <silent> qm  make
Cnmap <noexec> qM  make<Space>
Cnmap <noexec> q<Space>  grep<Space>
Cnmap <noexec> qg  grep<Space>


" For location list (mnemonic: Quickfix list for the current Window)  "{{{3

Cnmap <silent> qwj  Qexecute lnext [count]
Cnmap <silent> qwk  Qexecute lprevious [count]
Cnmap <silent> qwr  Qexecute lrewind [count]
Cnmap <silent> qwK  Qexecute lfirst [count]
Cnmap <silent> qwJ  Qexecute llast [count]
Cnmap <silent> qwfj  Qexecute lnfile [count]
Cnmap <silent> qwfk  Qexecute lpfile [count]
Cnmap <silent> qwl  llist
Cnmap <silent> qwq  Qexecute ll [count]
Cnmap <silent> qwo  Qexecute lopen [count]
Cnmap <silent> qwc  lclose
Cnmap <silent> qwp  Qexecute lolder [count]
Cnmap <silent> qwn  Qexecute lnewer [count]
Cnmap <silent> qwm  lmake
Cnmap <noexec> qwM  lmake<Space>
Cnmap <noexec> qw<Space>  lgrep<Space>
Cnmap <noexec> qwg  lgrep<Space>




" Tabpages  "{{{2
" The mappings defined here are similar to the ones for windows.
" FIXME: sometimes, hit-enter prompt appears.  but no idea for the reason.
" Fallback  "{{{3

" the prefix key.
" -- see Tag jumping subsection for alternative keys for the original action
"    of <C-t>.
nnoremap <C-t>  <Nop>


" Basic  "{{{3

  " Move new tabpage at the last.
Cnmap <silent> <C-t>n  tabnew \| tabmove
Cnmap <silent> <C-t>c  tabclose
Cnmap <silent> <C-t>C  tabclose!
Cnmap <silent> <C-t>o  tabonly
Cnmap <silent> <C-t>i  tabs

nmap <C-t><C-n>  <C-t>n
nmap <C-t><C-c>  <C-t>c
nmap <C-t><C-o>  <C-t>o
nmap <C-t><C-i>  <C-t>i

Cnmap <silent> <C-t>T  TabpageTitle


" Moving around tabpages.  "{{{3

Cnmap <silent> <C-t>j
\ execute 'tabnext' 1 + (tabpagenr() + v:count1 - 1) % tabpagenr('$')
Cnmap <silent> <C-t>k  Qexecute tabprevious [count]
Cnmap <silent> <C-t>K  tabfirst
Cnmap <silent> <C-t>J  tablast
Cnmap <silent> <C-t><C-t>  call <SID>back_to_the_last_tabpage()

nmap <C-t><C-j>  <C-t>j
nmap <C-t><C-k>  <C-t>k

" GNU screen like mappings.
" Note that the numbers in {lhs}s are 0-origin.  See also 'tabline'.
for i in range(10)
  execute 'nnoremap <silent>' ('<C-t>'.(i))  ((i+1).'gt')
endfor
unlet i


" Moving tabpages themselves.  "{{{3

Cnmap <silent> <C-t>l  tabmove +
Cnmap <silent> <C-t>h  tabmove -
Cnmap <silent> <C-t>L  tabmove
Cnmap <silent> <C-t>H  tabmove 0

nmap <C-t><C-l>  <C-t>l
nmap <C-t><C-h>  <C-t>h




" Argument list  "{{{2

" the prefix key.
" -- the default action of <C-g> is almost never used.
nnoremap <C-g>  <Nop>


Cnmap <noexec> <C-g><Space>  args<Space>
Cnmap <silent> <C-g>l  args
Cnmap <silent> <C-g>j  next
Cnmap <silent> <C-g>k  previous
Cnmap <silent> <C-g>J  last
Cnmap <silent> <C-g>K  first
Cnmap <silent> <C-g>wj  wnext
Cnmap <silent> <C-g>wk  wprevious

nmap <C-g><C-l>  <C-g>l
nmap <C-g><C-j>  <C-g>j
nmap <C-g><C-k>  <C-g>k
nmap <C-g><C-w><C-j>  <C-g>wj
nmap <C-g><C-w><C-k>  <C-g>wk




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
cnoremap <expr> <C-u>  <SID>keys_to_escape_command_line_mode_if_empty("\<C-u>")
cnoremap <expr> <C-w>  <SID>keys_to_escape_command_line_mode_if_empty("\<C-w>")

" Search slashes easily (too lazy to prefix backslashes to slashes)
cnoremap <expr> /  getcmdtype() == '/' ? '\/' : '/'




" Experimental: Little movement in Insert mode  "{{{2

inoremap <Esc>h  <Left>
inoremap <Esc>j  <Down>
inoremap <Esc>k  <Up>
inoremap <Esc>l  <Right>

inoremap <Esc>w  <C-Right>
inoremap <Esc>b  <C-Left>
inoremap <Esc>e  <C-o>e
inoremap <Esc>W  <C-o>W
inoremap <Esc>B  <C-o>B
inoremap <Esc>E  <C-o>E




" Input: datetime  "{{{2
"
" Input the current date/time (Full, Date, Time).
"
" FIXME: use timezone of the system, instead of static one.
" FIXME: revise the {lhs}s, compare with the default keys of textobj-datetime.

inoremap <Leader>dF  <C-r>=strftime('%Y-%m-%dT%H:%M:%S+09:00')<Return>
inoremap <Leader>df  <C-r>=strftime('%Y-%m-%dT%H:%M:%S')<Return>
inoremap <Leader>dd  <C-r>=strftime('%Y-%m-%d')<Return>
inoremap <Leader>dm  <C-r>=strftime('%Y-%m')<Return>
inoremap <Leader>dy  <C-r>=strftime('%Y')<Return>
inoremap <Leader>dT  <C-r>=strftime('%H:%M:%S')<Return>
inoremap <Leader>dt  <C-r>=strftime('%H:%M')<Return>




" Section jumping  "{{{2
"
" Enable *consistent* ]] and other motions in Visual and Operator-pending
" mode.  Because some ftplugins provide these motions only for Normal mode and
" other ftplugins provide these motions with some faults, e.g., not countable.

Fvmap <silent> ]]  <SID>jump_section_v(']]')
Fvmap <silent> ][  <SID>jump_section_v('][')
Fvmap <silent> [[  <SID>jump_section_v('[[')
Fvmap <silent> []  <SID>jump_section_v('[]')
Fomap <silent> ]]  <SID>jump_section_o(']]')
Fomap <silent> ][  <SID>jump_section_o('][')
Fomap <silent> [[  <SID>jump_section_o('[[')
Fomap <silent> []  <SID>jump_section_o('[]')




" The <Space>  "{{{2
"
" Various hotkeys prefixed by <Space>.

" to show <Space> in the bottom line.
map <Space>  [Space]

" fallback
noremap [Space]  <Nop>


Cnmap <silent> [Space]/  nohlsearch

Fnmap <silent> [Space]?  <SID>close_help_window()

" append one character
nnoremap [Space]A  A<C-r>=<SID>keys_to_insert_one_character()<Return>
nnoremap [Space]a  a<C-r>=<SID>keys_to_insert_one_character()<Return>

Operatormap [Space]c  <Plug>(operator-my-calculate-sum-of-fields)

Cnmap <silent> [Space]e
\              setlocal encoding? termencoding? fileencoding? fileencodings?
Cnmap <silent> [Space]f  setlocal filetype? fileencoding? fileformat?

" Close a fold.
nnoremap [Space]h  zc

" insert one character
nnoremap [Space]I  I<C-r>=<SID>keys_to_insert_one_character()<Return>
nnoremap [Space]i  i<C-r>=<SID>keys_to_insert_one_character()<Return>

" Open a fold.
nnoremap [Space]l  zo

Fnmap <silent> [Space]J  <SID>join_here(1)
Fnmap <silent> [Space]gJ  <SID>join_here(0)

" unjoin  " BUGS: side effect - destroy the last inserted text (".).
nnoremap [Space]j  i<Return><Esc>

Cnmap <silent> [Space]m  marks

nnoremap [Space]o  <Nop>
Fnmap <silent> [Space]ob  <SID>toggle_bell()
Fnmap <silent> [Space]of  <SID>toggle_option('fullscreen')
Fnmap <silent> [Space]og  <SID>toggle_grepprg()
Fnmap <silent> [Space]ow  <SID>toggle_option('wrap')

Cnmap <silent> [Space]q  help quickref

Cnmap <silent> [Space]r  registers

  " FIXME: ambiguous mappings - fix or not.
Operatormap [Space]s  <Plug>(operator-my-sort)
omap [Space]s  g@
Cnmap <silent> [Space]s.  Source $MYVIMRC
Cnmap <silent> [Space]ss  Source %

" Close all folds but including the cursor.
nnoremap [Space]v  zMzv

" for backward compatibility
nmap [Space]w  [Space]ow

" for other use.
noremap [Space]x  <Nop>

Cmap [Space]xI  UsualDays




" Windows  "{{{2

" Synonyms for the default mappings, with single key strokes.
nmap <Tab>  <C-i>
nmap <S-Tab>  <Esc>i
nnoremap <C-i>  <C-w>w
nnoremap <Esc>i  <C-w>W
  " For other mappings (<Esc>{x} to <C-w>{x}).
nmap <Esc>  <C-w>


for i in ['H', 'J', 'K', 'L']
  execute 'Fnmap <silent> <C-w>'.i
  \ '<SID>move_window_then_equalize_if_necessary("'.i.'")'
endfor
unlet i


" This {lhs} overrides the default action (Move cursor to top-left window).
" But I rarely use its {lhs}s, so this mapping is not problematic.
Fnmap <silent> <C-w><C-t>
\ <SID>move_window_into_tabpage(<SID>ask_tabpage_number())
function! s:ask_tabpage_number()
  echon 'Which tabpage to move this window into?  '

  let c = nr2char(getchar())
  if c =~# '[0-9]'
    " Convert 0-origin number (typed by user) into 1-origin number (used by
    " Vim's internal functions).  See also 'tabline'.
    return 1 + char2nr(c) - char2nr('0')
  elseif c =~# "[\<C-c>\<Esc>]"
    return -1
  else
    return 0
  endif
endfunction


" like GNU Emacs' (scroll-other-window),
" but the target to scroll is the previous window.
for i in ['f', 'b', 'd', 'u', 'e', 'y']
  execute 'Fnmap <silent> <C-w><C-'.i.'>'
  \       '<SID>scroll_other_window("<Bslash><LT>C-'.i.'>")'
endfor
unlet i


" Like "<C-w>q", but does ":quit!".
Cnmap <C-w>Q  quit!


Cnmap <C-w>y  SplitNicely


" Search the word nearest to the cursor in new window.
nnoremap <C-w>*  <C-w>s*
nnoremap <C-w>#  <C-w>s#




" Text objects  "{{{2

" Synonyms for <> and [], same as plugin surround.
Objnoremap aa  a>
Objnoremap ia  i>
Objnoremap ar  a]
Objnoremap ir  i]


" Select the last chaged text - "c" stands for "C"hanged.
  " like gv
nnoremap <expr> gc  <SID>keys_to_select_the_last_changed_text()
  " as a text object
Objnoremap gc  :<C-u>normal gc<CR>
  " synonyms for gc - "m" stands for "M"odified.
  " built-in motion "gm" is overridden, but I'll never use it.
map gm  gc


" Select the last selected text.
onoremap gv  :<C-u>normal! gv<Return>




" Operators  "{{{2

" Adjust the height of the current window as same as the selected range.
call operator#user#define('my-adjust-window-height',
\                         s:SID_PREFIX() . 'operator_adjust_window_height')
map _  <Plug>(operator-my-adjust-window-height)


call operator#user#define_ex_command('my-left', 'left')
call operator#user#define_ex_command('my-right', 'right')
call operator#user#define_ex_command('my-center', 'center')
Arpeggio map oh  <Plug>(operator-my-left)
Arpeggio map ol  <Plug>(operator-my-right)
Arpeggio map om  <Plug>(operator-my-center)


call operator#user#define_ex_command('my-join', 'join')
Arpeggio map oj  <Plug>(operator-my-join)


call operator#user#define_ex_command('my-sort', 'sort')
call operator#user#define('my-calculate-sum-of-fields',
\                         s:SID_PREFIX() . 'operator_calculate_sum_of_fields')
" User key mappings will be defined later - see [Space].


call operator#user#define_ex_command('my-reverse', "global/^/move '[-1'")
Arpeggio map OR  <Plug>(operator-my-reverse)




" Misc.  "{{{2

Cnmap <noexec> <C-h>  help<Space>
Cnmap <noexec> <C-o>  edit<Space>
Cnmap <C-w>.  edit .


" Jump list
nnoremap <C-j>  <C-i>
nnoremap <C-k>  <C-o>


" Disable some dangerous key.
nnoremap ZZ  <Nop>
nnoremap ZQ  <Nop>


" Use a backslash (\) to repeat last change.
" Since a dot (.) is used as <LocalLeader>.
nnoremap \  .


" Complete or indent.
inoremap <expr> <C-i>  (<SID>should_indent_rather_than_complete_p()
                      \ ? '<C-i>'
                      \ : <SID>keys_to_complete())

function! s:should_indent_rather_than_complete_p()
  let m = match(getline('.'), '\S')
  return m == -1 || col('.')-1 <= m
endfunction


" Swap ` and ' -- I prefer ` to ' and ` is not easy to type.
noremap '  `
noremap `  '


" To be able to undo these types of deletion in Insert mode.
inoremap <C-w>  <C-g>u<C-w>
inoremap <C-u>  <C-g>u<C-u>


" Like o/O, but insert additional [count] blank lines.
" The default [count] is 0, so that they do the same as the default o/O.
" I prefer this behavior to the default behavior of [count]o/O which repeats
" the next insertion [count] times, because I've never felt that it is useful.
nnoremap <expr> <Plug>(arpeggio-default:o)
\        <SID>start_insert_mode_with_blank_lines('o')
nnoremap <expr> <Plug>(arpeggio-default:O)
\        <SID>start_insert_mode_with_blank_lines('O')
function! s:start_insert_mode_with_blank_lines(command)
  if v:count != v:count1
    return a:command  " Behave the same as the default commands.
  endif

  if a:command ==# 'o'
    return "\<Esc>o" . repeat("\<Return>", v:count)
  else  " a:command ==# 'O'
    " BUGS: Not repeatable - nothing hapens.  It's possible to fix but it's
    "       too troublesome to implement and it's not so useful.
    return "\<Esc>OX\<Esc>m'o" . repeat("\<Return>", v:count-1) . "\<Esc>''S"
  endif
endfunction


" Search for the selected text.
Fvmap *  <SID>search_the_selected_text_literaly('n')
Fvmap #  <SID>search_the_selected_text_literaly('N')

function! s:search_the_selected_text_literaly(search_command)
  let reg_0 = [@0, getregtype('0')]
  let reg_u = [@", getregtype('"')]

  normal! gvy
  let @/ = '\V' . escape(@0, '\')
  call histadd('/', @/)
  execute 'normal!' a:search_command
  let v:searchforward = a:search_command ==# 'n'

  call setreg('0', reg_0[0], reg_0[1])
  call setreg('"', reg_u[0], reg_u[1])
endfunction


Allnoremap <C-z>  <Nop>
Cnmap <C-z>  SuspendWithAutomticCD


" Show the lines which match to the last search pattern.
Cnmap <count> g/  global//print
Cvmap <count> g/  global//print


" Experimental: alternative <Esc>
Allnoremap <C-@>  <Esc>
inoremap <C-l>  <Esc>

  " c_<Esc> mapped from something doesn't work the same as
  " c_<Esc> directly typed by user.
cnoremap <C-@>  <C-c>


" Experimental: Additional keys to increment/decrement
nnoremap +  <C-a>
nnoremap -  <C-x>


" Disable solely typed <Leader>/<LocalLeader> to avoid unexpected behavior.
noremap <Leader>  <Nop>
noremap <LocalLeader>  <Nop>


" Make searching directions consistent
  " 'zv' is harmful for Operator-pending mode and it should not be included.
  " For example, 'cn' is expanded into 'cnzv' so 'zv' will be inserted.
nnoremap <expr> n  <SID>search_forward_p() ? 'nzv' : 'Nzv'
nnoremap <expr> N  <SID>search_forward_p() ? 'Nzv' : 'nzv'
vnoremap <expr> n  <SID>search_forward_p() ? 'nzv' : 'Nzv'
vnoremap <expr> N  <SID>search_forward_p() ? 'Nzv' : 'nzv'
onoremap <expr> n  <SID>search_forward_p() ? 'n' : 'N'
onoremap <expr> N  <SID>search_forward_p() ? 'N' : 'n'

function! s:search_forward_p()
  return exists('v:searchforward') ? v:searchforward : s:TRUE
endfunction


" Easy to type aliases.
noremap <Esc>(  [(
noremap <Esc>)  ])
noremap <Esc>{  [{
noremap <Esc>}  ]}








" Filetypes  "{{{1
" All filetypes   "{{{2
" Here also contains misc. autocommands.

autocmd MyAutoCmd FileType *
\ call s:on_FileType_any()
function! s:on_FileType_any()
  " To use my global mappings for section jumping,
  " remove buffer local mappings defined by ftplugin.
  silent! Objunmap <buffer> ]]
  silent! Objunmap <buffer> ][
  silent! Objunmap <buffer> []
  silent! Objunmap <buffer> [[

  " Make omni completion available for all filetypes.
  if &l:omnifunc == ''
    setlocal omnifunc=syntaxcomplete#Complete
  endif

  " Universal indent undo: Undo indent settings whenever 'filetype' is set.
  " Most indent scripts don't undo their settings in the event, and it causes
  " some problems.  For example:
  "
  " (1) A file is opened and its 'filetype' is set to FOO by default.
  " (2) The file contain modelines to override 'filetype' to BAR.
  " (3) But indent scripts for FOO don't set b:undo_indent.
  "     So that some settings are configured for FOO but other settings are
  "     configured for BAR.  Inconsistent settings make users mad.
  if exists('b:undo_indent')
    let b:undo_indent .= ' | '
  else
    let b:undo_indent = ''
  endif
  let b:undo_indent .= 'setlocal
  \ autoindent<
  \ cindent<
  \ cinkeys<
  \ cinoptions<
  \ cinwords<
  \ copyindent<
  \ indentexpr<
  \ indentkeys<
  \ lisp<
  \ lispwords<
  \ preserveindent<
  \ shiftround<
  \ shiftwidth<
  \ smartindent<
  \ softtabstop<
  \ tabstop<
  \ '
endfunction


" Fix 'fileencoding' to use 'encoding'
" if the buffer only contains 7-bit characters.
" Note that if the buffer is not 'modifiable',
" its 'fileencoding' cannot be changed, so that such buffers are skipped.
autocmd MyAutoCmd BufReadPost *
\   if &modifiable && !search('[^\x00-\x7F]', 'cnw')
\ |   setlocal fileencoding=
\ | endif


" Adjust highlight settings according to the current colorscheme.
if !has('gui_running')
  autocmd MyAutoCmd ColorScheme *
  \   call s:extend_highlight('Pmenu', 'Normal', 'cterm=underline')
  \ | call s:extend_highlight('PmenuSel', 'Search', 'cterm=underline')
  \ | call s:extend_highlight('PmenuSbar', 'Normal', 'cterm=reverse')
  \ | call s:extend_highlight('PmenuThumb', 'Search', '')
  \
  \ | highlight TabLineSel
  \             term=bold,reverse
  \             cterm=bold,underline ctermfg=lightgray ctermbg=darkgray
  \ | highlight TabLine
  \             term=reverse
  \             cterm=NONE ctermfg=lightgray ctermbg=darkgray
  \ | highlight TabLineFill
  \             term=reverse
  \             cterm=NONE ctermfg=lightgray ctermbg=darkgray
  if !exists('s:loaded_my_vimrc')
    doautocmd MyAutoCmd ColorScheme because-colorscheme-has-been-set-above.
  endif
endif


" Automatically shift to the Insert mode
" when a multibyte character is typed in Normal mode.
" Note: To use nonstandard event NCmdUndefined, use the following version:
"       http://repo.or.cz/w/vim-kana.git?a=shortlog;h=hack/ncmdundefined
silent! autocmd MyAutoCmd NCmdUndefined *
\ call s:shift_to_insert_mode(expand('<amatch>'))
function! s:shift_to_insert_mode(not_a_command_character)
  if char2nr(a:not_a_command_character) <= 0xFF  " not a multibyte character?
    " should beep as same as the default behavior, but how?
    return
  endif

  " Take all keys in the typeahead buffer.
  let keys = a:not_a_command_character
  while !0
    let c = getchar(0)
    if c == 0
      break
    endif
    let keys .= nr2char(c)
  endwhile

  " Shfit to Insert mode, then emulate typing the keys.
  " Note: If :startinsert is used to shifting to Insert mode,
  "       instead of keys[0], unexpected string '<t_<fd>_>' will be inserted.
  call feedkeys('i', 'n')
  call feedkeys(keys, 't')
endfunction


" Unset 'paste' automatically.  It's often hard to do so because of most
" mappings are disabled in Paste mode.
if !has('gui_running')  " 'paste'/autopaste is not used in GUI version.
  autocmd MyAutoCmd InsertLeave *  set nopaste
  autocmd MyAutoCmd CursorHoldI *  set nopaste | echo 'redraw the bottom line'
endif




" coffee  "{{{2

autocmd MyAutoCmd FileType coffee
\ call s:set_short_indent()




" css  "{{{2

autocmd MyAutoCmd FileType css
\ call s:set_short_indent()




" cucumber  "{{{2

autocmd MyAutoCmd FileType cucumber
\   call s:set_short_indent()




" dosini (.ini)  "{{{2

autocmd MyAutoCmd FileType dosini
\ call s:on_FileType_dosini()

function! s:on_FileType_dosini()
  " Jumping around sections.
  Fnmap <buffer> <silent> ]]  <SID>jump_section_n('/^\[')
  Fnmap <buffer> <silent> ][  <SID>jump_section_n('/\n\[\@=')
  Fnmap <buffer> <silent> [[  <SID>jump_section_n('?^\[')
  Fnmap <buffer> <silent> []  <SID>jump_section_n('?\n\[\@=')

  " Folding sections.
  setlocal foldmethod=expr
  let &l:foldexpr = '(getline(v:lnum)[0] == "[") ? ">1" :'
  \               . '(getline(v:lnum) =~# ''^;.*\(__END__\|\*\*\*\)'' ? 0 : "=")'
endfunction




" gtd  "{{{2

autocmd MyAutoCmd FileType gtd
\   nmap <buffer> <Plug>(physical-key-<Return>)  <Plug>(gtd-jump-to-issue)
\ | let b:undo_ftplugin .= ' | silent! nunmap <buffer> <Plug>(physical-key-<Return>)'




" html  "{{{2

" Restore the indentation sytle in Vim 7.3 or earlier.
let g:html_indent_inctags = 'html,head,body'




" issue  "{{{2

autocmd MyAutoCmd FileType issue
\   nmap <buffer> <Plug>(physical-key-<Return>)  <Plug>(issue-jump-to-issue)
\ | let b:undo_ftplugin .= ' | silent! nunmap <buffer> <Plug>(physical-key-<Return>)'




" javascript  "{{{2

autocmd MyAutoCmd FileType javascript
\ call s:set_short_indent()




" lua  "{{{2

autocmd MyAutoCmd FileType lua
\ call s:set_short_indent()




" markdown  "{{{2

autocmd MyAutoCmd FileType markdown
\ setlocal expandtab shiftwidth=4 softtabstop=4




" netrw  "{{{2
"
" Consider these buffers have "another" filetype=netrw.

autocmd MyAutoCmd BufReadPost {dav,file,ftp,http,rcp,rsync,scp,sftp}://*
\ setlocal bufhidden=hide




" python  "{{{2

autocmd MyAutoCmd FileType python
\   call s:set_short_indent()

let g:python_highlight_all = 1




" ruby  "{{{2

autocmd MyAutoCmd FileType ruby
\   call s:set_short_indent()




" scheme  "{{{2

let g:is_gauche = 1




" sh, zsh  "{{{2

autocmd MyAutoCmd FileType sh,zsh
\ call s:set_short_indent()

" FIXME: use $SHELL.
let g:is_bash = 1




" rust  "{{{2

autocmd MyAutoCmd FileType rust
\ setlocal expandtab shiftwidth=4 softtabstop=4




" tex  "{{{2

autocmd MyAutoCmd FileType tex
\ call s:set_short_indent()




" vim  "{{{2

autocmd MyAutoCmd FileType vim
\ call s:on_FileType_vim()

function! s:on_FileType_vim()
  call s:set_short_indent()
  let vim_indent_cont = &shiftwidth

  inoreabbrev <buffer> je  if<Return>
                          \else<Return>
                          \endif
                          \<Up><Up><End>
  inoreabbrev <buffer> jf  function!()<Return>
                          \endfunction
                          \<Up><End><Left><Left>
  inoreabbrev <buffer> ji  if<Return>
                          \endif
                          \<Up><End>
  inoreabbrev <buffer> jr  for<Return>
                          \endfor
                          \<Up><End>
  inoreabbrev <buffer> jt  try<Return>
                          \catch /.../<Return>
                          \finally<Return>
                          \endtry
                          \<Up><Up><Up><End>
  inoreabbrev <buffer> jw  while<Return>
                          \endwhile
                          \<Up><End>

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
\ call s:on_FileType_xml()

function! s:on_FileType_xml()
  call s:set_short_indent()

  " To deal with namespace prefixes and tag-name-including-hyphens.
  setlocal iskeyword+=45  " hyphen (-)
  setlocal iskeyword+=58  " colon (:)

  " Support to input some parts of tags.
  inoremap <buffer> <LT>?  </
  imap <buffer> ?<LT>  <LT>?
  inoremap <buffer> ?>  />
  imap <buffer> >?  ?>

  " Support to input some blocks.
  inoremap <buffer> <LT>!C  <LT>![CDATA[]]><Left><Left><Left>
  inoremap <buffer> <LT>#  <LT>!----><Left><Left><Left><C-r>=
                          \<SID>on_FileType_xml_comment_dispatch()
                          \<Return>

  " Complete proper end-tags.
  " In the following description, {|} means the cursor position.

    " Insert the end tag after the cursor.
    " Before: <code{|}
    " After:  <code>{|}</code>
  inoremap <buffer> <LT><LT>  ><LT>/<C-x><C-o><C-r>=
                             \<SID>keys_to_stop_insert_mode_completion()
                             \<Return><C-o>F<LT>

    " Wrap the cursor with the tag.
    " Before: <code{|}
    " After:  <code>
    "           {|}
    "         </code>
  inoremap <buffer> >>  ><Return>X<Return><LT>/<C-x><C-o><C-r>=
                       \<SID>keys_to_stop_insert_mode_completion()
                       \<Return><C-o><Up><BS>

  if search('\V\<xmlns:n="http://nicht.s8.xrea.com/"', 'cnw') != 0
    call s:on_FileType_nicht()
  endif
endfunction


function! s:on_FileType_xml_comment_dispatch()
  let c = nr2char(getchar())
  return get(s:on_FileType_xml_comment_dispatch_data, c, c)
endfunction
let s:on_FileType_xml_comment_dispatch_data = {
\     "\<Space>": "\<Space>\<Space>\<Left>",
\     "\<Return>": "\<Return>X\<Return>\<Up>\<End>\<BS>",
\     '_': '',
\     '-': '',
\     '{': '{{'. "{\<Esc>",
\     '}': '}}'. "}\<Esc>",
\     '1': '{{'."{1\<Esc>",
\     '2': '{{'."{2\<Esc>",
\     '3': '{{'."{3\<Esc>",
\     '4': '{{'."{4\<Esc>",
\     '5': '{{'."{5\<Esc>",
\     '6': '{{'."{6\<Esc>",
\     '7': '{{'."{7\<Esc>",
\     '8': '{{'."{8\<Esc>",
\     '9': '{{'."{9\<Esc>",
\     '!': '{{'."{1\<Esc>",
\     '@': '{{'."{2\<Esc>",
\     '#': '{{'."{3\<Esc>",
\     '$': '{{'."{4\<Esc>",
\     '%': '{{'."{5\<Esc>",
\     '^': '{{'."{6\<Esc>",
\     '&': '{{'."{7\<Esc>",
\     '*': '{{'."{8\<Esc>",
\     '(': '{{'."{9\<Esc>",
\   }


function! s:on_FileType_nicht()
  Fnmap <buffer> <silent> <LocalLeader>n  <SID>nicht_add_new_topic()
endfunction

function! s:nicht_add_new_topic()
  let reg_pattern = @/

  execute 'normal!' "gg/<n:body>\<Return>"
  put =''
  put =''
  put =''
  put =''
  put ='<n:topic datetime=\"'.strftime('%Y-%m-%dT%H:%M:%S').'\" tags=\"\">'
  put ='  <n:title></n:title>'
  put =''
  put ='  <p></p>'
  put ='</n:topic>'
  execute 'normal!' "?datetime\<Return>Wf\""

  let @/ = reg_pattern
endfunction









" Plugins  "{{{1
" altr  "{{{2

" If I remember correctly, <F2> is a keyboard shortcut to switch to the
" previously edited file in Vz editor.  I often used the keyboard shortcut, so
" that I bound <F2> to <C-^> before.
"
" But I noticed that there is a relationship between the current buffer and
" the previously edited file in many cases, like *.c and *.h.  And what
" I really wanted is a function to switch to some file which is related to the
" current buffer.  <C-^> doesn't behave so.
"
" So that now I use altr instead of <C-^>.
nmap <F1>  <Plug>(altr-back)
nmap <F2>  <Plug>(altr-forward)

" Aliases.  Because function keys are usually far to type.
nmap <Esc>1  <F1>
nmap <Esc>2  <F2>




" bundle  "{{{2

autocmd MyAutoCmd User BundleAvailability
\ call bundle#return(s:available_bundles())

autocmd MyAutoCmd User BundleUndefined!:*
\ call bundle#return(s:files_in_a_bundle(bundle#name()))


let s:BUNDLE_NAME_CURRENT_REPOSITORY = 'current-repository'
function! s:available_bundles()
  if s:git_controlled_directory_p()
    return [s:BUNDLE_NAME_CURRENT_REPOSITORY]
  else
    return []
  endif
endfunction

function! s:files_in_a_bundle(name)
  if a:name ==# s:BUNDLE_NAME_CURRENT_REPOSITORY
    return split(s:system('git ls-files'), "\n")
  else
    return []
  endif
endfunction

function! s:system(command)
  let _ = system(a:command)
  if v:shell_error != 0
    echoerr 'Command failed:' string(a:command)
    let _ = ''
  endif
  return _
endfunction




" exjumplist  "{{{2

" <C-j>/<C-k> for consistency with my UI key mappings on jumplist.
" BUGS: Inconsistency - <Esc>{x} is usually used for window-related operation.
nmap <Esc><C-j>  <Plug>(exjumplist-next-buffer)
nmap <Esc><C-k>  <Plug>(exjumplist-previous-buffer)




" fakeclip  "{{{2

" Use GNU screen rather than tmux if
" * Both GNU screen and tmux are installed, and
" * The current Vim (especially gVim) is not in sessions of both applications.
let g:fakeclip_terminal_multiplexer_type = 'gnuscreen'




" grex  "{{{2

Arpeggio map od  <Plug>(operator-grex-delete)
Arpeggio map oy  <Plug>(operator-grex-yank)

  " Compatibility for oldie
nmap gy  <Plug>(operator-grex-yank)<Plug>(textobj-entire-a)
vmap gy  <Plug>(operator-grex-yank)
omap gy  <Plug>(operator-grex-yank)




" ku  "{{{2

autocmd MyAutoCmd FileType ku  call ku#default_key_mappings(s:TRUE)
let g:ku_common_junk_pattern = '\v((^|\/)\,|\~$)'


call ku#custom_action('common', 'Yank', s:SID_PREFIX().'ku_common_action_Yank')
call ku#custom_action('common', 'cd', s:SID_PREFIX().'ku_common_action_my_cd')
call ku#custom_action('common', 'yank', s:SID_PREFIX().'ku_common_action_yank')
call ku#custom_action('myproject', 'default', 'common', 'tab-Right')
call ku#custom_action('metarw/git', 'checkout',
\                     s:SID_PREFIX().'ku_metarw_git_action_checkout')

function! s:ku_common_action_my_cd(item)
  if isdirectory(a:item.word)
    execute 'CD' a:item.word
  else  " treat a:item as a file name
    execute 'CD' fnamemodify(a:item.word, ':h')
  endif
endfunction

function! s:ku_common_action_yank(item)
  call setreg('"', a:item.word, 'c')
endfunction
function! s:ku_common_action_Yank(item)
  call setreg('"', a:item.word, 'l')
endfunction

function! s:ku_metarw_git_action_checkout(item)
  if a:item.ku__completed_p
    let branch_name = matchstr(a:item.word, '^git:\zs[^:]\+\ze:')
    let message = system('git checkout ' . shellescape(branch_name))
    if v:shell_error == 0
      echomsg 'git checkout' branch_name
      return 0
    else
      return message
    endif
  else
    return 'No such branch: ' . string(a:item.word)
  endif
endfunction



call ku#custom_key('common', 'y', 'yank')
call ku#custom_key('common', 'Y', 'Yank')
call ku#custom_key('metarw/git', '/', 'checkout')
call ku#custom_key('metarw/git', '?', 'checkout')


call ku#custom_prefix('common', '.vim', $HOME.'/.vim')
call ku#custom_prefix('common', 'DL', $HOME.'/Downloads')
call ku#custom_prefix('common', 'HOME', $HOME)
call ku#custom_prefix('common', 'LA', $HOME.'/Downloads')
call ku#custom_prefix('common', 'VIM', $VIMRUNTIME)
call ku#custom_prefix('common', '~', $HOME)


Cnmap <silent> [Space]ka  Ku args
Cnmap <silent> [Space]kb  Ku buffer
Cnmap <silent> [Space]kf  Ku file
Cnmap <silent> [Space]kg  Ku metarw/git
Cnmap <silent> [Space]kh  Ku history
Cnmap <silent> [Space]kk  call ku#restart()
Cnmap <silent> [Space]km  Ku mru
  " p is for packages.
Cnmap <silent> [Space]kp  Ku bundle
Cnmap <silent> [Space]kq  Ku quickfix
Cnmap <silent> [Space]ks  Ku source
  " w is for ~/working.
Cnmap <silent> [Space]kw  Ku myproject




" narrow  "{{{2

Cmap <count> [Space]xn  Narrow
Cmap [Space]xw  Widen




" operator-replace  "{{{2

Arpeggio map or  <Plug>(operator-replace)




" operator-siege  "{{{2

map s  <Plug>(operator-siege-add)
nmap ss  <Plug>(operator-siege-add)<Plug>(textobj-line-i)
vmap S  <Plug>(operator-siege-add-with-indent)
nmap cs  <Plug>(operator-siege-change)
nmap ds  <Plug>(operator-siege-delete)

" See also: plugin/operator-siege-config.vim




" scratch  "{{{2

nmap <Leader>s  <Plug>(scratch-open)


" I already use <C-m>/<Return> for tag jumping.
" But I don't use it in the scratch buffer, so it should be overridden.
autocmd MyAutoCmd User PluginScratchInitializeAfter
\ map <buffer> <Plug>(physical-key-<Return>)  <Plug>(scratch-evaluate)




" skeleton  "{{{2

autocmd MyAutoCmd User plugin-skeleton-detect
\ call s:on_User_plugin_skeleton_detect()
function! s:on_User_plugin_skeleton_detect()
  " TODO: skeletons for simple plugins using textobj-user.

  let _ = matchlist(expand('%'),
  \                 '\v^%(.*<vim>.{-}\/(after\/)?)?'
  \                   . '(autoload|doc|ftplugin|indent|plugin|syntax)'
  \                   . '\/.*\.(txt|vim)$')
  if len(_) == 0
    return
  endif
  let after_p = _[1] != ''
  let type = _[2]
  let extension = _[3]

  if type ==# 'doc' && extension ==# 'txt'
    SkeletonLoad help-doc
  endif

  if type !=# 'doc' && extension ==# 'vim'
    if after_p != ''
      execute 'SkeletonLoad' 'vim-additional-'._[2]
    endif
    execute 'SkeletonLoad' 'vim-'._[2]
  endif

  return
endfunction




" smarttill  "{{{2

Objmap q  <Plug>(smarttill-t)
Objmap Q  <Plug>(smarttill-T)




" vcsi  "{{{2

let g:vcsi_diff_in_commit_buffer_p = 1
let g:vcsi_open_command = 'SplitNicely | enew'
let g:vcsi_use_native_message_p = 1




" wwwsearch  "{{{2

Arpeggio map ow  <Plug>(operator-wwwsearch)

Cnmap [Space]*  Wwwsearch -default <C-r><C-w>




" xml_autons  "{{{2

let g:AutoXMLns_Dict = {}
let g:AutoXMLns_Dict['http://www.w3.org/2000/svg'] = 'svg11'








" Fin.  "{{{1

if !exists('s:loaded_my_vimrc')
  let s:loaded_my_vimrc = 1
endif




set secure  " must be written at the last.  see :help 'secure'.








" __END__  "{{{1
" vim: expandtab softtabstop=2 shiftwidth=2
" vim: foldmethod=marker
