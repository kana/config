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








" Basic  "{{{1
" Absolute  "{{{2

set nocompatible  " to use many extensions of Vim.


function! s:SID_PREFIX()
 return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction




" Encoding  "{{{2

" To deal with Japanese language.
if $ENV_WORKING ==# 'colinux' || $ENV_WORKING ==# 'mac'
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
nohlsearch  " To avoid (re)highlighting the last search pattern
            " whenever $MYVIMRC is (re)loaded.
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
  "" temporary disabled.
  "let &statusline .= '(%{' . s:SID_PREFIX() . 'vcs_branch_name(getcwd())}) '
let &statusline .= '[%{&fileencoding == "" ? &encoding : &fileencoding}]'
let &statusline .= '  %-14.(%l,%c%V%) %P'

function! s:my_tab_line()  "{{{
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
let &tabline = '%!' . s:SID_PREFIX() . 'my_tab_line()'

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


call idwintab#load()








" Syntax  "{{{1
" User-defined commands to extend Vim script syntax.
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




" Fcommand - wrapper of :command to easily call a function  "{{{2
"
" :Fcommand[!] {option}... {command-name} {function-name} {arg}...
"
" [!]
"   Same as :command.
"
" {option}
"   Same as :command.
"
" {command-name}
"   The name of the wewly defined command.
"
" {function-name}
"   The name of the function which is called whenever {command-name} is
"   executed.
"
" {arg}
"   Arguments to {function-name}.  All escape sequences of :command are also
"   available.  Note that {arg}s are splited by spaces and each spaces are
"   replaced by ", ".  See :help <f-args> to how to escape spaces.

command! -bang -nargs=* Fcommand  call s:cmd_Fcommand('<bang>', [<f-args>])
function! s:cmd_Fcommand(bang, args)
  let [options, rest] = s:separate_list(a:args, '^-')
  if len(rest) < 2
    throw 'Insufficient number of arguments: ' . string(rest)
  endif
  let command_name = rest[0]
  let function_name = rest[1]
  let function_args = rest[2:]

  execute 'command'.a:bang join(options) command_name
  \ 'call' function_name '(' join(function_args, ', ') ')'
endfunction




" Fmap - wrapper of :map to easily call a function  "{{{2
"
" :Fmap {lhs} {expression}
"   Other variants:
"   Fmap!, Fcmap, Fimap, Flmap, Fnmap, Fomap, Fsmap, Fvmap, Fxmap.
"
" {lhs}
"   Same as :map.
"
" {expression}
"   An expression to call a function (without :call).  This expression is
"   executed whenever key sequence {lhs} are typed.

Fcommand! -bang -nargs=* Fmap  s:cmd_Fmap '' '<bang>' [<f-args>]
Fcommand! -nargs=* Fcmap  s:cmd_Fmap 'c' '' [<f-args>]
Fcommand! -nargs=* Fimap  s:cmd_Fmap 'i' '' [<f-args>]
Fcommand! -nargs=* Flmap  s:cmd_Fmap 'l' '' [<f-args>]
Fcommand! -nargs=* Fnmap  s:cmd_Fmap 'n' '' [<f-args>]
Fcommand! -nargs=* Fomap  s:cmd_Fmap 'o' '' [<f-args>]
Fcommand! -nargs=* Fsmap  s:cmd_Fmap 's' '' [<f-args>]
Fcommand! -nargs=* Fvmap  s:cmd_Fmap 'v' '' [<f-args>]
Fcommand! -nargs=* Fxmap  s:cmd_Fmap 'x' '' [<f-args>]
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




" Allmap - :map in all modes  "{{{2

command! -nargs=+ Allmap
\   execute 'map' <q-args>
\ | execute 'map!' <q-args>

command! -nargs=+ Allnoremap
\   execute 'noremap' <q-args>
\ | execute 'noremap!' <q-args>

command! -nargs=+ Allunmap
\   execute 'silent! unmap' <q-args>
\ | execute 'silent! unmap!' <q-args>




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

Fcommand! -nargs=+ KeyboardLayout  s:cmd_KeyboardLayout <f-args>
function! s:cmd_KeyboardLayout(physical_key, logical_key)
  let indirect_key = '<Plug>(physical-key-' . a:physical_key . ')'
  execute 'Allmap' a:logical_key indirect_key
  execute 'Allnoremap' indirect_key a:logical_key
endfunction




" Cmap - wrapper of :map to easily execute commands  "{{{2
"
" :Cmap {lhs} {script}
"   Other variants:
"   Cmap!, Ccmap, Cimap, Clmap, Cnmap, Comap, Csmap, Cvmap, Cxmap.
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

Fcommand! -bang -nargs=* Cmap  s:cmd_Cmap '' '<bang>' [<f-args>]
Fcommand! -nargs=* Ccmap  s:cmd_Cmap 'c' '' [<f-args>]
Fcommand! -nargs=* Cimap  s:cmd_Cmap 'i' '' [<f-args>]
Fcommand! -nargs=* Clmap  s:cmd_Cmap 'l' '' [<f-args>]
Fcommand! -nargs=* Cnmap  s:cmd_Cmap 'n' '' [<f-args>]
Fcommand! -nargs=* Comap  s:cmd_Cmap 'o' '' [<f-args>]
Fcommand! -nargs=* Csmap  s:cmd_Cmap 's' '' [<f-args>]
Fcommand! -nargs=* Cvmap  s:cmd_Cmap 'v' '' [<f-args>]
Fcommand! -nargs=* Cxmap  s:cmd_Cmap 'x' '' [<f-args>]
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




" AlternateCommand - support to input alternative command  "{{{2
"
" :AlternateCommand {original-name} {alternate-name}
"
"   This is wrapper of :cnoreabbrev to support to input the name of a command
"   which is alternative one to another command.  For example, with
"   ":AlternateCommand cd CD", whenever you type "cd" as a command name in the
"   Command-line, it will be replaced with "CD".
"
"   {original-name}
"     The name of a command to type.  To denote the tail part of the name
"     which may be omitted, enclose it with square brackets.  For example:
"     "cd", "h[elp]", "quita[ll]".
"
"     Note that <buffer> is available, but <expr> is not available.
"
"   {alternate-name}
"     The name of an alternative command to {original-name} command.
"
" FIXME: Abbreviations defined by :AlternateCommand aren't expanded if range
"        is specified.  It should be expanded if {original-name} is appeared
"        as the name of a command.
"
" FIXME: Write :AlternateCommandClear to easily delete unnecessary
"        abbreviations defined by :AlternateCommand.

Fcommand! -nargs=* AlternateCommand  s:cmd_AlternateCommand [<f-args>]
function! s:cmd_AlternateCommand(args)
  let buffer_p = (a:args[0] ==? '<buffer>')
  let original_name = a:args[buffer_p ? 1 : 0]
  let alternate_name = a:args[buffer_p ? 2 : 1]

  if original_name =~ '\['
    let [original_name_head, original_name_tail] = split(original_name, '[')
    let original_name_tail = substitute(original_name_tail, '\]', '', '')
  else
    let original_name_head = original_name
    let original_name_tail = ''
  endif
  let original_name_tail = ' ' . original_name_tail

  for i in range(len(original_name_tail))
    let lhs = original_name_head . original_name_tail[1:i]
    execute 'cnoreabbrev <expr>' lhs
    \ '(getcmdtype() == ":" && getcmdline() ==# "' . lhs  . '")'
    \ '?' ('"' . alternate_name . '"')
    \ ':' ('"' . lhs . '"')
  endfor
endfunction




" Hecho, Hechon, Hechomsg - various :echo with highlight specification  "{{{2

Fcommand! -bar -nargs=+ Hecho  s:cmd_Hecho 'echo' [<f-args>]
Fcommand! -bar -nargs=+ Hechon  s:cmd_Hecho 'echon' [<f-args>]
Fcommand! -bar -nargs=+ Hechomsg  s:cmd_Hecho 'echomsg' [<f-args>]
function! s:cmd_Hecho(echo_command, args)
  let highlight_name = a:args[0]
  let messages = a:args[1:]

  execute 'echohl' highlight_name
  execute a:echo_command join(messages)
  echohl None
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

command! -nargs=+ OnFileType  call <SID>cmd_OnFileType(<f-args>)
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




" TabTitle - name the current tab page  "{{{2

command! -bar -nargs=* TabTitle
\   if <q-args> == ''
\ |   let t:title = input("Set tabpage's title to: ",'')
\ | else
\ |   let t:title = <q-args>
\ | endif




" TabCD - wrapper of :cd to keep cwd for each tab page  "{{{2
" FIXME: escape spaces in <q-args> and t:cwd on :cd.

command! -nargs=? TabCD
\   execute 'cd' <q-args>
\ | let t:cwd = getcwd()

autocmd MyAutoCmd TabEnter *
\   if !exists('t:cwd')
\ |   let t:cwd = getcwd()
\ | endif
\ | execute 'cd' t:cwd




" CD - alternative :cd with more user-friendly completion  "{{{2

command! -complete=customlist,<SID>complete_cdpath -nargs=1 CD  TabCD <args>
function! s:complete_cdpath(arglead, cmdline, cursorpos)
  return split(globpath(&cdpath, a:arglead . '*/'), "\n")
endfunction

AlternateCommand cd  CD




" Utf8 and others - :edit with specified 'fileencoding'  "{{{2

command! -nargs=? -complete=file -bang -bar Cp932
\ edit<bang> ++enc=cp932 <args>
command! -nargs=? -complete=file -bang -bar Eucjp
\ edit<bang> ++enc=euc-jp <args>
command! -nargs=? -complete=file -bang -bar Iso2022jp
\ edit<bang> ++enc=iso-2022-jp <args>
command! -nargs=? -complete=file -bang -bar Utf8
\ edit<bang> ++enc=utf-8 <args>

command! -nargs=? -complete=file -bang -bar Jis  Iso2022jp<bang> <args>
command! -nargs=? -complete=file -bang -bar Sjis  Cp932<bang> <args>




" UsualDays - set up the layout of my usual days  "{{{2

command! -bar -nargs=0 UsualDays  call s:cmd_UsualDays()
function! s:cmd_UsualDays()
  normal! 'T
  execute 'CD' fnamemodify(expand('%'), ':p:h')
  TabTitle meta

  tabnew
  normal! 'V
  execute 'CD' fnamemodify(expand('%'), ':p:h:h')
  TabTitle config
endfunction




"{{{2








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


function! s:move_window_into_tab_page(target_tabpagenr)
  " Move the current window into a:target_tabpagenr.
  " If a:target_tabpagenr is 0, move into new tab page.
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


function! s:scroll_other_window(scroll_command)
  if winnr('$') == 1 || winnr('#') == 0
    " Do nothing when there is only one window or no previous window.
    Hecho ErrorMsg 'There is no window to scroll.'
  else
    execute 'normal!' "\<C-w>p"
    execute 'normal!' (s:count() . a:scroll_command)
    execute 'normal!' "\<C-w>p"
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




" Misc.  "{{{2

function! s:toggle_bell()
  if &visualbell
    set novisualbell t_vb&
    echo 'bell on'
  else
    set visualbell t_vb=
    echo 'bell off'
  endif
endfunction

function! s:toggle_option(option_name)
  execute 'setlocal' a:option_name.'!'
  execute 'setlocal' a:option_name.'?'
endfunction


function! s:extend_highlight(target_group, original_group, new_settings)
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


function! s:count(...)
  if v:count == v:count1  " count is specified.
    return v:count
  else  " count is not specified.  (the default '' is useful for special value)
    return a:0 == 0 ? '' : a:1
  endif
endfunction

command! -nargs=* -complete=expression -range -count=0 Execute
\ call s:cmd_Execute(<f-args>)
function! s:cmd_Execute(...)
  let args = []
  for a in a:000
    if a ==# '[count]'
      let a = s:count()
    endif
    call add(args, a)
  endfor
  execute join(args)
endfunction


" like join (J), but move the next line into the cursor position.
function! s:join_here(...)
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


function! s:set_short_indent()
  setlocal expandtab softtabstop=2 shiftwidth=2
endfunction


function! s:gettabvar(tabnr, varname)
  " Wrapper for non standard (my own) built-in function gettabvar().
  return exists('*gettabvar') ? gettabvar(a:tabnr, a:varname) : ''
endfunction


" :source with echo.
command! -bar -nargs=1 Source  echo 'Sourcing ...' <args> | source <args>


function! s:first_line(file)
  let lines = readfile(a:file, '', 1)
  return 1 <= len(lines) ? lines[0] : ''
endfunction








" Mappings  "{{{1
" FIXME: some mappings are not countable.
" Physical/Logical keyboard layout declaration  "{{{2

if $ENV_WORKING ==# 'mac' || $HOST !=# 'summer'
  " Semicolon and Return are swapped by KeyRemap4MacBook or Mayu on some
  " environments.
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


" Lazy man's hacks on the Semicolon key.
" - Don't want to press Shift to enter the Command-line mode.
" - Don't want to press far Return key to input <Return>.
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

Cnmap <silent> qj  Execute cnext [count]
Cnmap <silent> qk  Execute cprevious [count]
Cnmap <silent> qr  Execute crewind [count]
Cnmap <silent> qK  Execute cfirst [count]
Cnmap <silent> qJ  Execute clast [count]
Cnmap <silent> qfj  Execute cnfile [count]
Cnmap <silent> qfk  Execute cpfile [count]
Cnmap <silent> ql  clist
Cnmap <silent> qq  Execute cc [count]
Cnmap <silent> qo  Execute copen [count]
Cnmap <silent> qc  cclose
Cnmap <silent> qp  Execute colder [count]
Cnmap <silent> qn  Execute cnewer [count]
Cnmap <silent> qm  make
Cnmap <noexec> qM  make<Space>
Cnmap <noexec> q<Space>  make<Space>
Cnmap <noexec> qg  grep<Space>


" For location list (mnemonic: Quickfix list for the current Window)  "{{{3

Cnmap <silent> qwj  Execute lnext [count]
Cnmap <silent> qwk  Execute lprevious [count]
Cnmap <silent> qwr  Execute lrewind [count]
Cnmap <silent> qwK  Execute lfirst [count]
Cnmap <silent> qwJ  Execute llast [count]
Cnmap <silent> qwfj  Execute lnfile [count]
Cnmap <silent> qwfk  Execute lpfile [count]
Cnmap <silent> qwl  llist
Cnmap <silent> qwq  Execute ll [count]
Cnmap <silent> qwo  Execute lopen [count]
Cnmap <silent> qwc  lclose
Cnmap <silent> qwp  Execute lolder [count]
Cnmap <silent> qwn  Execute lnewer [count]
Cnmap <silent> qwm  lmake
Cnmap <noexec> qwM  lmake<Space>
Cnmap <noexec> qw<Space>  lmake<Space>
Cnmap <noexec> qwg  lgrep<Space>




" Tab pages  "{{{2
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
Cnmap <silent> <C-t>o  tabonly
Cnmap <silent> <C-t>i  tabs

nmap <C-t><C-n>  <C-t>n
nmap <C-t><C-c>  <C-t>c
nmap <C-t><C-o>  <C-t>o
nmap <C-t><C-i>  <C-t>i

Cnmap <silent> <C-t>T  TabTitle


" Moving around tabs.  "{{{3

Cnmap <silent> <C-t>j
\ execute 'tabnext' 1 + (tabpagenr() + v:count1 - 1) % tabpagenr('$')
Cnmap <silent> <C-t>k  Execute tabprevious [count]
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


" Moving tabs themselves.  "{{{3

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

Cnmap <silent> [Space]e  setlocal enc? tenc? fenc? fencs?
Cnmap <silent> [Space]f  setlocal ft? fenc? ff?

" insert one character
nnoremap [Space]I  I<C-r>=<SID>keys_to_insert_one_character()<Return>
nnoremap [Space]i  i<C-r>=<SID>keys_to_insert_one_character()<Return>

Fnmap <silent> [Space]J  <SID>join_here(1)
Fnmap <silent> [Space]gJ  <SID>join_here(0)

" unjoin  " BUGS: side effect - destroy the last inserted text (".).
nnoremap [Space]j  i<Return><Esc>

Cnmap <silent> [Space]m  marks

nnoremap [Space]o  <Nop>
Fnmap <silent> [Space]ob  <SID>toggle_bell()
Fnmap <silent> [Space]ow  <SID>toggle_option('wrap')

Cnmap <silent> [Space]q  help quickref

Cnmap <silent> [Space]r  registers

nnoremap [Space]s  <Nop>
Cnmap <silent> [Space]s.  Source $MYVIMRC
Cnmap <silent> [Space]ss  Source %

Cvmap <count> <silent> [Space]s  sort

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
  execute 'Fnmap <silent> <Esc>'.i
  \ '<SID>move_window_then_equalize_if_necessary("'.i.'")'
endfor
unlet i


" This {lhs} overrides the default action (Move cursor to top-left window).
" But I rarely use its {lhs}s, so this mapping is not problematic.
Fnmap <silent> <C-w><C-t>
\ <SID>move_window_into_tab_page(<SID>ask_tab_page_number())
function! s:ask_tab_page_number()
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
  execute 'Fnmap <silent> <Esc><C-'.i.'>'
  \       '<SID>scroll_other_window("<Bslash><LT>C-'.i.'>")'
endfor
unlet i


" Adjust the height of the current window as same as the selected range.
vnoremap <silent> _
\ <Esc>:execute (line("'>") - line("'<") + 1) 'wincmd' '_'<Return>`<zt
nnoremap <silent> _
\ :set operatorfunc=<SID>adjust_window_height_to_the_selection<Return>g@
function! s:adjust_window_height_to_the_selection(visual_mode)
  normal! `[v`]
  normal _
endfunction


" Like "<C-w>q", but does ":quit!".
Cnmap <C-w>Q  quit!




" Misc.  "{{{2

Cnmap <noexec> <C-h>  help<Space>
Cnmap <noexec> <C-o>  edit<Space>
Cnmap <C-w>.  edit .


" Jump list
nnoremap <C-j>  <C-i>
nnoremap <C-k>  <C-o>


" Switch to the previously edited file (like Vz)
Cnmap <Esc>2  edit #
nmap <F2>  <Esc>2


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


" Start Insert mode with [count] blank lines.
" The default [count] is 0, so no blank line is inserted.
" (I prefer this behavior to the default behavior of [count]o/O
"  -- repeat the next insertion [count] times.)
Fnmap <silent> o  <SID>start_insert_mode_with_blank_lines('o')
Fnmap <silent> O  <SID>start_insert_mode_with_blank_lines('O')
function! s:start_insert_mode_with_blank_lines(command)
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
  Hecho ModeMsg '-- INSERT (open) --'
  echohl None
  let c = nr2char(getchar())
  call feedkeys((c != "\<Esc>" ? a:command : 'A'), 'n')
  call feedkeys(c, 'n')

  " to undo the next inserted text and the preceding blank lines in 1 step.
  undojoin
endfunction


" Search for the selected text.
Fvmap *  <SID>search_the_selected_text_literaly()

  " FIXME: escape to search the selected text literaly.
function! s:search_the_selected_text_literaly()
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
Fmap <silent> <C-z>  <SID>pseudo_suspend_with_automatic_cd()

if !exists('s:gnu_screen_availablep')
  " Check the existence of $WINDOW to avoid using GNU screen in Vim on
  " a remote machine (for example, "screen -t remote ssh example.com").
  let s:gnu_screen_availablep = len($WINDOW) != 0
endif
function! s:pseudo_suspend_with_automatic_cd()
  if s:gnu_screen_availablep
    " \015 = <C-m>
    " To avoid adding the cd script into the command-line history,
    " there are extra leading whitespaces in the cd script.
    silent execute '!screen -X eval'
    \              '''select another'''
    \              '''stuff "  cd \"'.getcwd().'\"  \#\#,vim-auto-cd\015"'''
    redraw!
    let s:gnu_screen_availablep = (v:shell_error == 0)
  endif

  if !s:gnu_screen_availablep
    suspend
  endif
endfunction


" Show the lines which match to the last search pattern.
Cnmap <count> g/  global//print
Cvmap <count> g/  global//print








" Filetypes  "{{{1
" All filetypes   "{{{2
" Here also contains misc. autocommands.

autocmd MyAutoCmd FileType *
\ call <SID>on_FileType_any()
function! s:on_FileType_any()
  " To use my global mappings for section jumping,
  " remove buffer local mappings defined by ftplugin.
  silent! vunmap <buffer> ]]
  silent! vunmap <buffer> ][
  silent! vunmap <buffer> []
  silent! vunmap <buffer> [[
  silent! ounmap <buffer> ]]
  silent! ounmap <buffer> ][
  silent! ounmap <buffer> []
  silent! ounmap <buffer> [[

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
\   call <SID>extend_highlight('Pmenu', 'Normal', 'cterm=underline')
\ | call <SID>extend_highlight('PmenuSel', 'Search', 'cterm=underline')
\ | call <SID>extend_highlight('PmenuSbar', 'Normal', 'cterm=reverse')
\ | call <SID>extend_highlight('PmenuThumb', 'Search', '')
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
\ call <SID>shift_to_insert_mode(expand('<amatch>'))
function! s:shift_to_insert_mode(not_a_command_character)
  if char2nr(a:not_a_command_character) <= 0xFF  " not a multibyte character?
    return  " should beep as same as the default behavior, but how?
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
\ call <SID>set_short_indent()




" dosini (.ini)  "{{{2

autocmd MyAutoCmd FileType dosini
\ call <SID>on_FileType_dosini()

function! s:on_FileType_dosini()
  Fnmap <buffer> <silent> ]]  <SID>jump_section_n('/^\[')
  Fnmap <buffer> <silent> ][  <SID>jump_section_n('/\n\[\@=')
  Fnmap <buffer> <silent> [[  <SID>jump_section_n('?^\[')
  Fnmap <buffer> <silent> []  <SID>jump_section_n('?\n\[\@=')
endfunction




" help  "{{{2

autocmd MyAutoCmd FileType help
\ call textobj#user#define('|[^| \t]*|', '', '', {
\                            'move-to-next': '<buffer> gj',
\                            'move-to-prev': '<buffer> gk',
\                          })




" lua  "{{{2

autocmd MyAutoCmd FileType lua
\ call <SID>set_short_indent()




" netrw  "{{{2
"
" Consider these buffers have "another" filetype=netrw.

autocmd MyAutoCmd BufReadPost {dav,file,ftp,http,rcp,rsync,scp,sftp}://*
\ setlocal bufhidden=hide




" python  "{{{2

autocmd MyAutoCmd FileType python
\   call <SID>set_short_indent()
\ | let python_highlight_numbers=1
\ | let python_highlight_builtins=1
\ | let python_highlight_space_errors=1




" ruby  "{{{2

autocmd MyAutoCmd FileType ruby
\   call <SID>set_short_indent()




" sh  "{{{2

autocmd MyAutoCmd FileType sh
\ call <SID>set_short_indent()

" FIXME: use $SHELL.
let g:is_bash = 1




" tex  "{{{2

autocmd MyAutoCmd FileType tex
\ call <SID>set_short_indent()




" vcsicommit  "{{{2
" 'filetype' for commit log buffers created by vcsi.

autocmd MyAutoCmd FileType {vcsicommit,*.vcsicommit}
\ setlocal comments=sr:*,mb:\ ,ex:NOT_DEFINED




" vim  "{{{2

autocmd MyAutoCmd FileType vim
\ call <SID>on_FileType_vim()

function! s:on_FileType_vim()
  call <SID>set_short_indent()
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
\ call <SID>on_FileType_xml()

function! s:on_FileType_xml()
  call <SID>set_short_indent()

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








" Plugins  "{{{1
" ku  "{{{2

autocmd MyAutoCmd User KuLoaded  call <SID>on_User_KuLoaded()
function! s:on_User_KuLoaded()
  function! s:ku_type_any_action_my_cd(item)
    " FIXME: escape special characters.
    if isdirectory(a:item.word)
      execute 'CD' a:item.word
    elseif filereadable(a:item.word)
      execute 'CD' fnamemodify(a:item.word, ':h')
    else
      echo printf('Item %s (type: %s) is not a file or directory.',
      \           a:item.word, a:item._ku_type.name)
    endif
  endfunction

  call ku#custom_action('*fallback*', 'cd',
  \                     function(s:SID_PREFIX() . 'ku_type_any_action_my_cd'))
endfunction


autocmd MyAutoCmd User KuBufferInitialize
\ call <SID>on_User_KuBufferInitialize()
function! s:on_User_KuBufferInitialize()
  call ku#default_key_mappings()
endfunction


Cnmap [Space]ka  Ku
Cnmap [Space]kb  Ku buffer
Cnmap [Space]kf  Ku file




" narrow  "{{{2

Cmap <count> [Space]xn  Narrow
Cmap [Space]xw  Widen




" scratch  "{{{2

nmap <Leader>s  <Plug>(scratch-open)


" I already use <C-m>/<Return> for tag jumping.
" But I don't use it in the scratch buffer, so it should be overridden.
autocmd MyAutoCmd User PluginScratchInitializeAfter
\ map <buffer> <Plug>(physical-key-<Return>)  <Plug>(scratch-evaluate)




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
