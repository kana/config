" vim600: set foldmethod=marker:
"
" CVS extension for VCSCommand.
"
" Last Change:
" Version:       VCS development
" Maintainer:    Bob Hiestand <bob.hiestand@gmail.com>
" License:       This file is placed in the public domain.
"
" Section: Documentation {{{1
"
" Command documentation {{{2
"
" The following commands only apply to files under CVS source control.
"
" CVSEdit          Performs "cvs edit" on the current file.
"   
" CVSEditors       Performs "cvs editors" on the current file.
"   
" CVSUnedit        Performs "cvs unedit" on the current file.
"   
" CVSWatch         Takes an argument which must be one of [on|off|add|remove].
"                  Performs "cvs watch" with the given argument on the current
"                  file.
"   
" CVSWatchers      Performs "cvs watchers" on the current file.
"   
" CVSWatchAdd      Alias for "CVSWatch add"
"   
" CVSWatchOn       Alias for "CVSWatch on"
"   
" CVSWatchOff      Alias for "CVSWatch off"
"   
" CVSWatchRemove   Alias for "CVSWatch remove"
"
" Mapping documentation: {{{2
"
" By default, a mapping is defined for each command.  User-provided mappings
" can be used instead by mapping to <Plug>CommandName, for instance:
"
" nnoremap ,ce <Plug>CVSEdit
"
" The default mappings are as follow:
"
"   <Leader>ce CVSEdit
"   <Leader>ci CVSEditors
"   <Leader>ct CVSUnedit
"   <Leader>cwv CVSWatchers
"   <Leader>cwa CVSWatchAdd
"   <Leader>cwn CVSWatchOn
"   <Leader>cwf CVSWatchOff
"   <Leader>cwr CVSWatchRemove
"
" Options documentation: {{{2
"
" VCSCommandCVSExec
"   This variable specifies the CVS executable.  If not set, it defaults to
"   'cvs' executed from the user's executable path.
"
" VCSCommandCVSDiffOpt
"   This variable, if set, determines the options passed to the cvs diff
"   command.  If not set, it defaults to 'u'.

if v:version < 700
  finish
endif

" Section: Variable initialization {{{1

let s:cvsFunctions = {}

" Section: Utility functions {{{1

" Function: s:DoCommand(cmd, cmdName, statusText) {{{2
" Wrapper to VCSCommandDoCommand to add the name of the CVS executable to the
" command argument.
function! s:DoCommand(cmd, cmdName, statusText)
  try
    if VCSCommandGetVCSType(expand('%')) == 'CVS'
      let fullCmd = VCSCommandGetOption('VCSCommandCVSExec', 'cvs') . ' ' . a:cmd
      return VCSCommandDoCommand(fullCmd, a:cmdName, a:statusText)
    else
      throw 'No suitable plugin'
    endif
  catch /No suitable plugin/
    echohl WarningMsg|echomsg 'Cannot apply CVS commands to this file.'|echohl None
  endtry
endfunction

" Section: VCS function implementations {{{1

" Function: s:cvsFunctions.Identify(buffer) {{{2
function! s:cvsFunctions.Identify(buffer)
  let fileName = resolve(bufname(a:buffer))
  if isdirectory(fileName)
    let directory = fileName
  else
    let directory = fnamemodify(fileName, ':h')
  endif
  if strlen(directory) > 0
    let CVSRoot = directory . '/CVS/Root'
  else
    let CVSRoot = 'CVS/Root'
  endif
  if filereadable(CVSRoot)
    return 1
  else
    return 0
  endif
endfunction

" Function: s:cvsFunctions.Add() {{{2
function! s:cvsFunctions.Add(argList)
  return s:DoCommand('add', 'add', '')
endfunction

" Function: s:cvsFunctions.Annotate(argList) {{{2
function! s:cvsFunctions.Annotate(argList)
  if len(a:argList) == 0
    if &filetype == 'CVSAnnotate'
      " This is a CVSAnnotate buffer.  Perform annotation of the version
      " indicated by the current line.
      let revision = matchstr(getline('.'),'\v%(^[0-9.]+)')
    else
      let revision=VCSCommandGetRevision()
      if revision == ''
        throw 'Unable to obtain version information.'
      elseif revision == 'Unknown'
        throw 'File not under source control'
      elseif revision == 'New'
        throw 'No annotatation available for new file.'
      endif
    endif
  else
    let revision=a:argList[0]
  endif

  if revision == 'New'
    throw 'No annotatation available for new file.'
  endif

  let resultBuffer=s:DoCommand('-q annotate -r ' . revision, 'annotate', revision) 
  if resultBuffer > 0
    set filetype=CVSAnnotate
    " Remove header lines from standard error
    silent v/^\d\+\%(\.\d\+\)\+/d
  endif
  return resultBuffer
endfunction

" Function: s:cvsFunctions.Commit(argList) {{{2
function! s:cvsFunctions.Commit(argList)
  let resultBuffer = s:DoCommand('commit -F "' . a:argList[0] . '"', 'commit', '')
  if resultBuffer == 0
    echomsg 'No commit needed.'
  endif
  return resultBuffer
endfunction

" Function: s:cvsFunctions.Diff(argList) {{{2
function! s:cvsFunctions.Diff(argList)
  if len(a:argList) == 1
    let revOptions = '-r ' . a:argList[0]
    let caption = '(' . a:argList[0] . ' : current)'
  elseif len(a:argList) == 2
    let revOptions = '-r ' . a:argList[0] . ' -r ' . a:argList[1]
    let caption = '(' . a:argList[0] . ' : ' . a:argList[1] . ')'
  else
    let revOptions = ''
    let caption = ''
  endif

  let cvsdiffopt = VCSCommandGetOption('VCSCommandCVSDiffOpt', 'u')

  if cvsdiffopt == ''
    let diffoptionstring = ''
  else
    let diffoptionstring = ' -' . cvsdiffopt . ' '
  endif

  let resultBuffer = s:DoCommand('diff ' . diffoptionstring . revOptions , 'diff', caption)
  if resultBuffer > 0
    set filetype=diff
  else
    echomsg 'No differences found'
  endif
  return resultBuffer
endfunction

" Function: s:cvsFunctions.GetBufferInfo() {{{2
" Provides version control details for the current file.  Current version
" number and current repository version number are required to be returned by
" the vcscommand plugin.  This CVS extension adds branch name to the return
" list as well.
" Returns: List of results:  [revision, repository, branch]

function! s:cvsFunctions.GetBufferInfo()
  let originalBuffer = VCSCommandGetOriginalBuffer(bufnr('%'))
  let fileName = bufname(originalBuffer)
  let realFileName = fnamemodify(resolve(fileName), ':t')
  if !filereadable(fileName)
    return ['Unknown']
  endif
  let oldCwd=VCSCommandChangeToCurrentFileDir(fileName)
  try
    let statusText=system(VCSCommandGetOption('VCSCommandCVSExec', 'cvs') . ' status "' . realFileName . '"')
    if(v:shell_error)
      return []
    endif
    let revision=substitute(statusText, '^\_.*Working revision:\s*\(\d\+\%(\.\d\+\)\+\|New file!\)\_.*$', '\1', '')

    " We can still be in a CVS-controlled directory without this being a CVS
    " file
    if match(revision, '^New file!$') >= 0 
      let revision='New'
    elseif match(revision, '^\d\+\.\d\+\%(\.\d\+\.\d\+\)*$') <0
      return ['Unknown']
    endif

    let branch=substitute(statusText, '^\_.*Sticky Tag:\s\+\(\d\+\%(\.\d\+\)\+\|\a[A-Za-z0-9-_]*\|(none)\).*$', '\1', '')
    let repository=substitute(statusText, '^\_.*Repository revision:\s*\(\d\+\%(\.\d\+\)\+\|New file!\|No revision control file\)\_.*$', '\1', '')
    let repository=substitute(repository, '^New file!\|No revision control file$', 'New', '')
    return [revision, repository, branch]
  finally
    execute 'cd' escape(oldCwd, ' ')
  endtry
endfunction

" Function: s:cvsFunctions.Log() {{{2
function! s:cvsFunctions.Log(argList)
  if len(a:argList) == 0
    let versionOption = ''
    let caption = ''
  else
    let versionOption=' -r' . a:argList[0]
    let caption = a:argList[0]
  endif

  let resultBuffer=s:DoCommand('log' . versionOption, 'log', caption)
  if resultBuffer > 0
    set filetype=rcslog
  endif
  return resultBuffer
endfunction

" Function: s:cvsFunctions.Revert(argList) {{{2
function! s:cvsFunctions.Revert(argList)
  return s:DoCommand('update -C', 'revert', '')
endfunction

" Function: s:cvsFunctions.Review(argList) {{{2
function! s:cvsFunctions.Review(argList)
  if len(a:argList) == 0
    let versiontag = '(current)'
    let versionOption = ''
  else
    let versiontag = a:argList[0]
    let versionOption = ' -r ' . versiontag . ' '
  endif

  let resultBuffer = s:DoCommand('-q update -p' . versionOption, 'review', versiontag)
  if resultBuffer > 0
    let &filetype=getbufvar(b:VCSCommandOriginalBuffer, '&filetype')
  endif
  return resultBuffer
endfunction

" Function: s:cvsFunctions.Status(argList) {{{2
function! s:cvsFunctions.Status(argList)
  return s:DoCommand('status', 'status', '')
endfunction

" Function: s:cvsFunctions.Update(argList) {{{2
function! s:cvsFunctions.Update(argList)
  return s:DoCommand('update', 'update', '')
endfunction

" Section: CVS-specific functions {{{1

" Function: s:CVSEdit() {{{2
function! s:CVSEdit()
  return s:DoCommand('edit', 'cvsedit', '')
endfunction

" Function: s:CVSEditors() {{{2
function! s:CVSEditors()
  return s:DoCommand('editors', 'cvseditors', '')
endfunction

" Function: s:CVSUnedit() {{{2
function! s:CVSUnedit()
  return s:DoCommand('unedit', 'cvsunedit', '')
endfunction

" Function: s:CVSWatch(onoff) {{{2
function! s:CVSWatch(onoff)
  if a:onoff !~ '^\c\%(on\|off\|add\|remove\)$'
    echoerr 'Argument to CVSWatch must be one of [on|off|add|remove]'
    return -1
  end
  return s:DoCommand('watch ' . tolower(a:onoff), 'cvswatch', '')
endfunction

" Function: s:CVSWatchers() {{{2
function! s:CVSWatchers()
  return s:DoCommand('watchers', 'cvswatchers', '')
endfunction

" Section: Command definitions {{{1
" Section: Primary commands {{{2
com! CVSEdit call s:CVSEdit()
com! CVSEditors call s:CVSEditors()
com! CVSUnedit call s:CVSUnedit()
com! -nargs=1 CVSWatch call s:CVSWatch(<f-args>)
com! CVSWatchAdd call s:CVSWatch('add')
com! CVSWatchOn call s:CVSWatch('on')
com! CVSWatchOff call s:CVSWatch('off')
com! CVSWatchRemove call s:CVSWatch('remove')
com! CVSWatchers call s:CVSWatchers()

" Section: Plugin command mappings {{{1

let s:cvsExtensionMappings = {}
let mappingInfo = [
      \['CVSEdit', 'CVSEdit', 'ce'],
      \['CVSEditors', 'CVSEditors', 'ci'],
      \['CVSUnedit', 'CVSUnedit', 'ct'],
      \['CVSWatchers', 'CVSWatchers', 'cwv'],
      \['CVSWatchAdd', 'CVSWatch add', 'cwa'],
      \['CVSWatchOff', 'CVSWatch off', 'cwf'],
      \['CVSWatchOn', 'CVSWatch on', 'cwn'],
      \['CVSWatchRemove', 'CVSWatch remove', 'cwr']
      \]

for [pluginName, commandText, shortCut] in mappingInfo
  execute 'nnoremap <silent> <Plug>' . pluginName . ' :' . commandText . '<CR>'
  if !hasmapto('<Plug>' . pluginName)
    let s:cvsExtensionMappings[shortCut] = commandText
  endif
endfor

" Section: Menu items {{{1
silent! aunmenu Plugin.VCS.CVS
amenu <silent> &Plugin.VCS.CVS.&Edit       <Plug>CVSEdit
amenu <silent> &Plugin.VCS.CVS.Ed&itors    <Plug>CVSEditors
amenu <silent> &Plugin.VCS.CVS.Unedi&t     <Plug>CVSUnedit
amenu <silent> &Plugin.VCS.CVS.&Watchers   <Plug>CVSWatchers
amenu <silent> &Plugin.VCS.CVS.WatchAdd    <Plug>CVSWatchAdd
amenu <silent> &Plugin.VCS.CVS.WatchOn     <Plug>CVSWatchOn
amenu <silent> &Plugin.VCS.CVS.WatchOff    <Plug>CVSWatchOff
amenu <silent> &Plugin.VCS.CVS.WatchRemove <Plug>CVSWatchRemove

" Section: Plugin Registration {{{1
" If the vcscommand.vim plugin hasn't loaded, delay registration until it
" loads.
if exists('g:loaded_VCSCommand')
  call VCSCommandRegisterModule('CVS', expand('<sfile>'), s:cvsFunctions, s:cvsExtensionMappings)
else
  augroup VCSCommand
    au User VCSLoadExtensions call VCSCommandRegisterModule('CVS', expand('<sfile>'), s:cvsFunctions, s:cvsExtensionMappings)
  augroup END
endif
