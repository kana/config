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
  " Don't reset twice on reloading - 'compatible' has SO many side effects.
  set nocompatible  " to use many extensions of Vim.
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
    colorscheme desert
    set background=dark
  endif
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
nohlsearch  " To avoid (re)highlighting the last search pattern
            " whenever $MYVIMRC is (re)loaded.
" set grepprg=... " See s:toggle_grepprg().
set incsearch
set laststatus=2  " always show status lines.
set mouse=
set ruler
set showcmd
set showmode
set updatetime=60000
set title
set titlestring=Vim:\ %f\ %h%r%m
set ttimeoutlen=50  " Reduce annoying delay for key codes, especially <Esc>...
set wildmenu
set viminfo=<50,'10,h,r/a,n~/.viminfo

" default 'statusline' with 'fileencoding'.
let &statusline = ''
let &statusline .= '%<%f %h%m%r%w'
let &statusline .= '%='
  "" temporary disabled.
  "let &statusline .= '(%{' . s:SID_PREFIX() . 'vcs_branch_name(getcwd())}) '
let &statusline .= '[%{&l:fileencoding == "" ? &encoding : &l:fileencoding}]'
let &statusline .= '  %-14.(%l,%c%V%) %P'

function! s:my_tabline()  "{{{
  let s = ''

  for i in range(1, tabpagenr('$'))
    let bufnrs = tabpagebuflist(i)
    let curbufnr = bufnrs[tabpagewinnr(i) - 1]  " first window, first appears

    let no = (i <= 10 ? i-1 : '#')  " display 0-origin tabpagenr.
    let mod = len(filter(bufnrs, 'getbufvar(v:val, "&modified")')) ? '+' : ' '
    let title = s:gettabvar(i, 'title')
    let title = len(title) ? title : fnamemodify(s:gettabvar(i, 'cwd'), ':t')
    let title = len(title) ? title : fnamemodify(bufname(curbufnr),':t')
    let title = len(title) ? title : '[No Name]'

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

" To automatically detect the width and the height of the terminal,
" the followings must not be set.
"
" set columns=80
" set lines=25


let mapleader = ','
let maplocalleader = '.'




" Misc.  "{{{2

" Use this group for any autocmd defined in this file.
augroup MyAutoCmd
  autocmd!
augroup END


call altercmd#load()
call arpeggio#load()
call idwintab#load()








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

command! -complete=customlist,s:complete_cdpath -nargs=+ CD  TabpageCD <args>
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




" OnFileType - wrapper of :autocmd FileType for compound 'filetype'  "{{{2
"
" To write a bit of customization per 'filetype', an easy way is to write some
" ":autocmd"s like "autocmd FileType c".  But it doesn't match to compound
" 'filetype' such as "c.doxygen".  So the pattern should be
" "{c,*.c,c.*,*.c.*}", but it's hard to read and to write.  :OnFileType is
" a wrapper for ":autocmd FileType" to support to write such customization.
"
" Note: If a:filetype contains one of the following characters:
"               * ? { } [ ]
"       a:filetype will be treated as-is to write customization for compound
"       'filetype' with :OnFileType.
"
" Note: If a:filetype contains one or more ",", :OnFileType will be called for
"       each ","-separated filetype in a:filetype.
"
" FIXME: syntax highlighting and completion.
"
" BUGS: This doesn't work for most cases because of the limit of the maximum
"       number of arguments to a function.

command! -nargs=+ OnFileType  call s:cmd_OnFileType(<f-args>)
function! s:cmd_OnFileType(group, filetype, ...)
  let group = (a:group == '-' ? '' : a:group)
  let commands = join(a:000)

  let SPECIAL_CHARS = '[*?{}[\]]'
  if a:filetype !~ SPECIAL_CHARS && a:filetype =~ ','
    for ft in split(a:filetype, ',')
      call s:cmd_OnFileType(group, ft, commands)
    endfor
    return
  endif
  let filetype = (a:filetype =~ SPECIAL_CHARS
  \               ? a:filetype
  \               : substitute('{x,x.*,*.x,*.x.*}', 'x', a:filetype, 'g'))

  execute 'autocmd' group 'FileType' filetype commands
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




" SuspendWithAutomticCD  "{{{2
" Assumption: Use GNU screen.
" Assumption: There is a window with the title "another".

if !exists('s:GNU_SCREEN_AVAILABLE_P')
  " Check the existence of $WINDOW to avoid using GNU screen in Vim on
  " a remote machine (for example, "screen -t remote ssh example.com").
  let s:GNU_SCREEN_AVAILABLE_P = len($WINDOW) != 0
endif

command! -bar -nargs=0 SuspendWithAutomticCD
\ call s:cmd_SuspendWithAutomticCD()
function! s:cmd_SuspendWithAutomticCD()
  if s:GNU_SCREEN_AVAILABLE_P
    " \015 = <C-m>
    " To avoid adding the cd script into the command-line history,
    " there are extra leading whitespaces in the cd script.
    silent execute '!screen -X eval'
    \              '''select another'''
    \              '''stuff "  cd \"'.getcwd().'\"  \#\#,vim-auto-cd\015"'''
    redraw!
    let s:GNU_SCREEN_AVAILABLE_P = (v:shell_error == 0)
  endif

  if !s:GNU_SCREEN_AVAILABLE_P
    suspend
  endif
endfunction




" TabpageCD - wrapper of :cd to keep cwd for each tabpage  "{{{2

command! -nargs=? TabpageCD
\   execute 'cd' fnameescape(<q-args>)
\ | let t:cwd = getcwd()

autocmd MyAutoCmd TabEnter *
\   if !exists('t:cwd')
\ |   let t:cwd = getcwd()
\ | endif
\ | execute 'cd' fnameescape(t:cwd)




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
  execute 'CD' fnamemodify(expand('%'), ':p:h:h')
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

function! s:keys_to_stop_insert_mode_completion()
  if pumvisible()
    return "\<C-y>"
  else
    return "\<Space>\<BS>"
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
let s:_vcs_branch_name_cache = {}  " dir_path = [branch_name, key_file_mtime]


function! s:vcs_branch_name(dir)
  let cache_entry = get(s:_vcs_branch_name_cache, a:dir, 0)
  if cache_entry is 0
  \  || cache_entry[1] < getftime(s:_vcs_branch_name_key_file(a:dir))
    unlet cache_entry
    let cache_entry = s:_vcs_branch_name(a:dir)
    let s:_vcs_branch_name_cache[a:dir] = cache_entry
  endif

  return cache_entry[0]
endfunction


function! s:_vcs_branch_name_key_file(dir)
  return a:dir . '/.git/HEAD'
endfunction


function! s:_vcs_branch_name(dir)
  let head_file = s:_vcs_branch_name_key_file(a:dir)
  let branch_name = ''

  if filereadable(head_file)
    let ref_info = s:first_line(head_file)
    if ref_info =~ '^\x\{40}$'
      let remote_refs_dir = a:dir . '/.git/refs/remotes/'
      let remote_branches = split(glob(remote_refs_dir . '**'), "\n")
      call filter(remote_branches, 's:first_line(v:val) ==# ref_info')
      if 1 <= len(remote_branches)
        let branch_name = 'remote: '. remote_branches[0][len(remote_refs_dir):]
      endif
    else
      let branch_name = matchlist(ref_info, '^ref: refs/heads/\(\S\+\)$')[1]
      if branch_name == ''
        let branch_name = ref_info
      endif
    endif
  endif

  return [branch_name, getftime(head_file)]
endfunction




function! s:count_sum_of_fields()  "{{{2
  '<,'>!awk 'BEGIN{c=0} {c+=$1} END{print c}'
  let _ = getline('.')
  undo
  '>put =_
endfunction




function! s:extend_highlight(target_group, original_group, new_settings)  "{{{2
  redir => resp
  silent execute 'highlight' a:original_group
  redir END
  if resp =~# 'xxx cleared'
    let original_settings = ''
  elseif resp =~# 'xxx links to'
    return s:extend_highlight(
    \        a:target_group,
    \        substitute(resp, '\_.*xxx links to\s\+\(\S\+\)', '\1', ''),
    \        a:new_settings
    \      )
  else  " xxx {key}={arg} ...
    let t = substitute(resp,'\_.*xxx\(\(\_s\+[^= \t]\+=[^= \t]\+\)*\)','\1','')
    let original_settings = substitute(t, '\_s\+', ' ', 'g')
  endif

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
" FIXME: the target window of :split/:vsplit version.
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
Cnmap <silent> t'p  ptpevious
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


" With :vertical split  "{{{3

  " |:vsplit|-then-|<C-]>| is simple
  " but its modification to tag stacks is not same as |<C-w>]|.
nnoremap <silent> tvt  <C-]>:<C-u>vsplit<Return><C-w>p<C-t><C-w>p
vnoremap <silent> tvt  <C-]>:<C-u>vsplit<Return><C-w>p<C-t><C-w>p
Cnmap <silent> tvn  vsplit \| tnext
Cnmap <silent> tvp  vsplit \| tpevious
Cnmap <silent> tvP  vsplit \| tfirst
Cnmap <silent> tvN  vsplit \| tlast




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
Cnmap <noexec> q<Space>  make<Space>
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
Cnmap <noexec> qw<Space>  lmake<Space>
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

nmap <C-t><C-j>  <C-t>j
nmap <C-t><C-k>  <C-t>k
nmap <C-t><C-t>  <C-t>j

" GNU screen like mappings.
" Note that the numbers in {lhs}s are 0-origin.  See also 'tabline'.
for i in range(10)
  execute 'nnoremap <silent>' ('<C-t>'.(i))  ((i+1).'gt')
endfor
unlet i


" Moving tabpages themselves.  "{{{3

Cnmap <silent> <C-t>l
\ execute 'tabmove' min([tabpagenr() + v:count1 - 1, tabpagenr('$')])
Cnmap <silent> <C-t>h
\ execute 'tabmove' max([tabpagenr() - v:count1 - 1, 0])
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

Fvmap <silent> [Space]c  <SID>count_sum_of_fields()

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
nnoremap gc  `[v`]
  " as a text object
Objnoremap gc  :<C-u>normal gc<CR>
  " synonyms for gc - "m" stands for "M"odified.
  " built-in motion "gm" is overridden, but I'll never use it.
map gm  gc




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
" User key mappings will be defined later - see [Space].




" Misc.  "{{{2

Cnmap <noexec> <C-h>  help<Space>
Cnmap <noexec> <C-o>  edit<Space>
Cnmap <C-w>.  edit .


" Jump list
nnoremap <C-j>  <C-i>
nnoremap <C-k>  <C-o>


" Switch to the previously edited file (like Vz)
nnoremap <Esc>2  <C-^>
nmap <F2>  <Esc>2


" Disable some dangerous key.
nnoremap ZZ  <Nop>
nnoremap ZQ  <Nop>


" Use a backslash (\) to repeat last change.
" Since a dot (.) is used as <LocalLeader>.
nmap \  <Plug>(repeat-.)


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


" Delete the content of the current line (not the line itself).
" BUGS: not repeatable.
" BUGS: the default behavior is overridden, but it's still available via "x".
nnoremap dl  0d$


" Make I/A available in characterwise-visual and linewise-visual.
Fvmap <silent> I  <SID>force_blockwise_visual('I')
Fvmap <silent> A  <SID>force_blockwise_visual('A')

function! s:force_blockwise_visual(next_key)
  if visualmode() ==# 'V'
    execute "normal! `<0\<C-v>`>$"
  else
    execute "normal! `<\<C-v>`>"
  endif
  call feedkeys(a:next_key, 'n')
endfunction


" Like o/O, but insert additional [count] blank lines.
" The default [count] is 0, so that they do the same as the default o/O.
" I prefer this behavior to the default behavior of [count]o/O which repeats
" the next insertion [count] times, because I've never felt that it is useful.
nnoremap <expr> <Plug>(arpeggio-default:o)
\        <SID>start_insert_mode_with_blank_lines('o')
nnoremap <expr> O
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
  let @/ = @0
  call histadd('/', '\V' . escape(@0, '\'))
  execute 'normal!' a:search_command
  let v:searchforward = a:search_command ==# 'n'

  call setreg('0', reg_0[0], reg_0[1])
  call setreg('"', reg_u[0], reg_u[1])
endfunction


Cnmap <C-z>  SuspendWithAutomticCD
vnoremap <C-z>  <Nop>
onoremap <C-z>  <Nop>


" Show the lines which match to the last search pattern.
Cnmap <count> g/  global//print
Cvmap <count> g/  global//print


" Experimental: alternative <Esc>
Allnoremap <C-@>  <Esc>

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
noremap <expr> n  v:searchforward ? 'nzv' : 'Nzv'
noremap <expr> N  v:searchforward ? 'Nzv' : 'nzv'








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
doautocmd MyAutoCmd ColorScheme because-colorscheme-has-been-set-above.


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
autocmd MyAutoCmd InsertLeave *  set nopaste




" css  "{{{2

autocmd MyAutoCmd FileType css
\ call s:set_short_indent()




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




" help  "{{{2

" Removed - not so useful.
" let s:filetype_help_pattern_special = '<[^ <>]\+>'

let s:filetype_help_pattern_link = '|[^ |]\+|'
let s:filetype_help_pattern_option = '''[A-Za-z0-9_-]\{2,}'''
let s:filetype_help_pattern_any = join([s:filetype_help_pattern_link,
\                                       s:filetype_help_pattern_option],
\                                      '\|')

" J/K are experimental keys.
autocmd MyAutoCmd FileType help
\ call s:on_FileType_help()

function! s:on_FileType_help()
  call textobj#user#plugin('help', {
  \      'any': {
  \        '*pattern*': s:filetype_help_pattern_any,
  \        'move-n': '<buffer> <LocalLeader>j',
  \        'move-p': '<buffer> <LocalLeader>k',
  \        'move-N': '<buffer> <LocalLeader>J',
  \        'move-P': '<buffer> <LocalLeader>K',
  \      },
  \      'link': {
  \        '*pattern*': s:filetype_help_pattern_link,
  \        'move-n': '<buffer> <LocalLeader>f',
  \        'move-p': '<buffer> <LocalLeader>r',
  \        'move-N': '<buffer> <LocalLeader>F',
  \        'move-P': '<buffer> <LocalLeader>R',
  \      },
  \      'option': {
  \        '*pattern*': s:filetype_help_pattern_option,
  \        'move-n': '<buffer> <LocalLeader>d',
  \        'move-p': '<buffer> <LocalLeader>e',
  \        'move-N': '<buffer> <LocalLeader>D',
  \        'move-P': '<buffer> <LocalLeader>E',
  \      },
  \    })
  if &l:readonly
    map <buffer> J  <Plug>(textobj-help-any-n)
    map <buffer> K  <Plug>(textobj-help-any-p)
  endif
endfunction




" issue  "{{{2

autocmd MyAutoCmd FileType issue
\   nmap <buffer> <Plug>(physical-key-<Return>)  <Plug>(issue-jump-to-issue)
\ | let b:undo_ftplugin .= ' | silent! nunmap <buffer> <Plug>(physical-key-<Return>)'




" lua  "{{{2

autocmd MyAutoCmd FileType lua
\ call s:set_short_indent()




" netrw  "{{{2
"
" Consider these buffers have "another" filetype=netrw.

autocmd MyAutoCmd BufReadPost {dav,file,ftp,http,rcp,rsync,scp,sftp}://*
\ setlocal bufhidden=hide




" python  "{{{2

autocmd MyAutoCmd FileType python
\   call s:set_short_indent()
\ | let python_highlight_numbers = 1
\ | let python_highlight_builtins = 1
\ | let python_highlight_space_errors = 1




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




" tex  "{{{2

autocmd MyAutoCmd FileType tex
\ call s:set_short_indent()




" vim  "{{{2

autocmd MyAutoCmd FileType vim
\ call s:on_FileType_vim()

function! s:on_FileType_vim()
  call s:set_short_indent()
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
" bundle  "{{{2

autocmd MyAutoCmd User BundleAvailability
\ call bundle#return(s:available_packages())

autocmd MyAutoCmd User BundleUndefined!:*
\ call bundle#return(s:package_files(bundle#name()))


let s:CONFIG_DIR = '~/working/config'
let s:CONFIG_MAKEFILE = s:CONFIG_DIR . '/Makefile'

function! s:available_packages()
  return split(s:system('make -f '
  \                     . shellescape(s:CONFIG_MAKEFILE)
  \                     . ' list-available-packages'))
endfunction

function! s:package_files(name)
  return map(split(s:system('make -f ' . shellescape(s:CONFIG_MAKEFILE)
  \                         . ' PACKAGE_NAME=' . a:name
  \                         . ' list-files-in-a-package')),
  \          'fnamemodify(s:CONFIG_DIR . "/" . v:val, ":~:.")')
endfunction

function! s:system(command)
  let _ = system(a:command)
  if v:shell_error != 0
    echoerr 'Command failed:' string(a:command)
    let _ = ''
  endif
  return _
endfunction




" grex  "{{{2

Arpeggio map od  <Plug>(operator-grex-delete)
Arpeggio map oy  <Plug>(operator-grex-yank)

  " Compatibility for oldie
nmap gy  <Plug>(operator-grex-yank)<Plug>(textobj-entire-a)
vmap gy  <Plug>(operator-grex-yank)
omap gy  <Plug>(operator-grex-yank)




" ku  "{{{2

autocmd MyAutoCmd FileType ku  call ku#default_key_mappings(s:TRUE)


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




" surround  "{{{2

" The default mapping ys for <Plug>Ysurround is not consistent with
" the default mappings of vi -- y is for yank.
nmap s  <Plug>Ysurround
nmap ss  <Plug>Yssurround

" See also ~/.vim/plugin/surround_config.vim .




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
  " autocmd MyAutoCmd VimEnter *
  " \ doautocmd MyAutoCmd User DelayedSettings
else
  " doautocmd MyAutoCmd User DelayedSettings
endif




set secure  " must be written at the last.  see :help 'secure'.








" __END__  "{{{1
" vim: expandtab softtabstop=2 shiftwidth=2
" vim: foldmethod=marker
