" [regexp, emoji][]
let s:PATH_RULES = [
\   ['batch', ':hammer_and_wrench:'],
\   ['\.jsx$', ':react:'],
\   ['\.tpl$', ':html5:'],
\   ['\.tsx$', ':react:'],
\   ['\.vue\>', ':vue:'],
\   ['\<mail\|_mail', ':email:'],
\ ]

" {[key: filetype]: emoji}
let s:FILETYPE_RULE_MAP = {
\   'css': ':css3:',
\   'git': ':git:',
\   'gitcommit': ':git:',
\   'gitconfig': ':git:',
\   'gitrebase': ':git:',
\   'help': ':p-hatena:',
\   'html': ':html5:',
\   'javascript': ':javascript:',
\   'markdown': ':markdown:',
\   'php': ':php:',
\   'scss': ':css3:',
\   'sql': ':mysql:',
\   'typescript': ':typescript:',
\   'vim': ':vim-cleaner:',
\ }

" emoji[]
let s:FALLBACK_EMOJIS = [
\   ':blobcat:',
\   ':blobcatbirthday:',
\   ':blobcatblep:',
\   ':blobcatevil:',
\   ':blobcatfearful:',
\   ':blobcatglowsticks:',
\   ':blobcatjedi:',
\   ':blobcatjediblue:',
\   ':blobcatmorning:',
\   ':blobcatmorningcoffee:',
\   ':blobcatnotlike:',
\   ':blobcatnotlikethis:',
\   ':blobcatping:',
\   ':blobcatpolice:',
\   ':blobcatsith:',
\   ':blobcatthinking:',
\   ':blobcatthinkingeyes:',
\   ':blobcatuwu:',
\   ':blobcatwaitwhat:',
\   ':blobcatwindu:',
\   ':blobcoffee:',
\   ':blobdizzy:',
\   ':blobenjoy:',
\   ':blobgentlecat:',
\   ':blobgib:',
\   ':blobhero2:',
\   ':blobhyperthink:',
\   ':blobidea:',
\   ':bloblamp:',
\   ':bloblove:',
\   ':bloblul:',
\   ':blobmelt:',
\   ':blobnervous:',
\   ':blobnomcookie:',
\   ':blobpats:',
\   ':blobsmilehappyeyes:',
\   ':blobthinkingfast:',
\   ':blobtilt:',
\   ':blobugh:',
\   ':blobwizard:',
\   ':blobzippermouth:',
\   ':hand_spinner:',
\   ':iine:',
\   ':kyoumo:',
\   ':naruhodo:',
\   ':notepad:',
\   ':pencil:',
\   ':woa:',
\ ]

let s:VIMRUNTIME = fnamemodify($VIMRUNTIME, ':~')

" Format: [$branch] $path ($line,$col)
"
" Note that:
" - Head part of $path might be truncated if there is not enough room.
" - Tail part of $branch might be truncated too.
function! my#slacky_build_status_text()
  let branch = g#get_branch_name(getcwd())
  let bufname = bufname('')
  if bufname == ''
    let bufname = '[No Name]'
  endif
  let path = fnamemodify(bufname, ':~:.')
  if path[:len(s:VIMRUNTIME) - 1] ==# s:VIMRUNTIME
    let path = ':vim-cleaner:' . path[len(s:VIMRUNTIME):]
  endif
  let s_pos = ' (' . line('.') . ',' . col('.') . ')'

  let limit = 100
  let estimated_branch_room = min([16, strchars(branch, 1)]) + 3
  let path_room = limit - strchars(s_pos, 1) - estimated_branch_room
  if strchars(path, 1) <= path_room
    let s_path = path
  else
    let s_path = '…' . path[-(path_room - 1):]
  endif

  let actual_branch_room = limit - 3 - strchars(s_path, 1) - strchars(s_pos, 1)
  if strchars(branch, 1) <= actual_branch_room
    let s_branch = branch
  else
    let s_branch = branch[:actual_branch_room - 1 - 1] . '…'
  endif

  return '[' . s_branch . '] ' . s_path . s_pos
endfunction

function! my#slacky_build_status_emoji()
  let path = bufname('')

  for [pattern, emoji] in s:PATH_RULES
    if path =~? pattern
      return emoji
    endif
  endfor

  let emoji = get(s:FILETYPE_RULE_MAP, &l:filetype, 0)
  if emoji isnot 0
    return emoji
  endif

  let hash = s:hash_path(path)
  return s:FALLBACK_EMOJIS[hash % len(s:FALLBACK_EMOJIS)]
endfunction

function! s:hash_path(path)
  let n = len(a:path)
  let m = 4
  let hash = 0
  for i in range(m)
    let hash = xor(hash * 2, char2nr(a:path[n * i / m]))
  endfor
  return hash
endfunction
