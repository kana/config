" tag#php - for smart tag jump
" Interface  "{{{1
function! tag#php#guess_tag_priority()  "{{{2
  let class_name = s:GuessClassName()
  if class_name == ''
    return 0
  endif

  let tags = taglist(expand('<cword>'), expand('%'))
  for tag in tags
    if has_key(tag, 'class') && tag['class'] ==# class_name
      return index(tags, tag) + 1
    endif
  endfor

  return 0
endfunction








" Misc.  "{{{1
function! s:GuessClassName()  "{{{2
  let cursor_pos = getpos('.')
  let class_name = s:_GuessClassName()
  call setpos('.', cursor_pos)
  return class_name
endfunction




function! s:_GuessClassName()  "{{{2
  let line = getline('.')
  let prefix_end_index = s:_GetCwordStartPos()[1] - 2
  let prefix = prefix_end_index >= 0 ? line[:prefix_end_index] : ''

  if prefix =~# '\<self::$' || prefix =~# '$this->$'
    return s:_GetCurrentClassName()
  elseif prefix =~# '\<\k\+::$'
    return matchstr(prefix, '\<\zs\k\+\ze::$')
  else
    return ''
  endif
endfunction




function! s:_GetCwordStartPos()  "{{{2
  let cword = expand('<cword>')
  let cword_pattern = '\V' . escape(cword, '\')
  let cword_end_pos = searchpos(cword_pattern, 'ceW', line('.'))
  let cword_start_pos = searchpos(cword_pattern, 'bcW', line('.'))
  return cword_start_pos
endfunction




function! s:_GetCurrentClassName()  "{{{2
  normal! 999[{
  if search('\<class\>', 'bW') == 0
    return ''
  endif
  normal! W
  return expand('<cword>')
endfunction








" __END__  "{{{1
" vim: foldmethod=marker
