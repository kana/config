" Additional Vim filetype plugin for XML to support moving around various objs
" Language: xml
" Version: 0.0.1
" Copyright: Copyright (C) 2007 kana <http://nicht.s8.xrea.com/>
" License: MIT license (see <http://www.opensource.org/licenses/mit-license>)
" $Id$  "{{{1

if exists('b:did_ftplugin')
  finish
endif








" BUFFER-LOCAL PART  "{{{1

silent! map <buffer> <unique> <LocalLeader>j  <Plug>XmlMove_SObjNextHeadSR
silent! map <buffer> <unique> <LocalLeader>k  <Plug>XmlMove_SObjPrevHeadSR

silent! map <buffer> <unique> <LocalLeader>f  <Plug>XmlMove_SObjNextHeadSR
silent! map <buffer> <unique> <LocalLeader>F  <Plug>XmlMove_SObjNextTailSR
silent! map <buffer> <unique> <LocalLeader>r  <Plug>XmlMove_SObjPrevHeadSR
silent! map <buffer> <unique> <LocalLeader>R  <Plug>XmlMove_SObjPrevTailSR
silent! map <buffer> <unique> <LocalLeader>d  <Plug>XmlMove_EObjNextHeadSR
silent! map <buffer> <unique> <LocalLeader>D  <Plug>XmlMove_EObjNextTailSR
silent! map <buffer> <unique> <LocalLeader>e  <Plug>XmlMove_EObjPrevHeadSR
silent! map <buffer> <unique> <LocalLeader>E  <Plug>XmlMove_EObjPrevTailSR
silent! map <buffer> <unique> <LocalLeader>s  <Plug>XmlMove_TextNextHeadSR
silent! map <buffer> <unique> <LocalLeader>S  <Plug>XmlMove_TextNextTailSR
silent! map <buffer> <unique> <LocalLeader>w  <Plug>XmlMove_TextPrevHeadSR
silent! map <buffer> <unique> <LocalLeader>W  <Plug>XmlMove_TextPrevTailSR
silent! map <buffer> <unique> <LocalLeader>a  <Plug>XmlMove_AttrNextHeadSR
silent! map <buffer> <unique> <LocalLeader>A  <Plug>XmlMove_AttrNextTailSR
silent! map <buffer> <unique> <LocalLeader>q  <Plug>XmlMove_AttrPrevHeadSR
silent! map <buffer> <unique> <LocalLeader>Q  <Plug>XmlMove_AttrPrevTailSR








" COMMON PART  "{{{1

if exists('s:loaded_xml_move')
" KEY MAPPINGS  "{{{2

function! s:M(name)
  for mode in ['n', 'v', 'o']
    execute mode.'noremap' '<silent>' '<Plug>XmlMove_'.a:name
      \ ':<C-u>call <SID>W(function("<SID>MoveTo'.a:name.'"), "'.mode.'")<CR>'
  endfor
endfunction

call s:M('SObjNextHeadSR')
call s:M('SObjNextTailSR')
call s:M('SObjPrevHeadSR')
call s:M('SObjPrevTailSR')
call s:M('EObjNextHeadSR')
call s:M('EObjNextTailSR')
call s:M('EObjPrevHeadSR')
call s:M('EObjPrevTailSR')
call s:M('TextNextHeadSR')
call s:M('TextNextTailSR')
call s:M('TextPrevHeadSR')
call s:M('TextPrevTailSR')
call s:M('AttrNextHeadSR')
call s:M('AttrNextTailSR')
call s:M('AttrPrevHeadSR')
call s:M('AttrPrevTailSR')

delfunction s:M




" REGULAR EXPRESSIONS FOR VARIOUS OBJECTS  "{{{2

" Spaces and other characters
let s:S = '[ \t\n\r]'
let s:Ss = '\%('.s:S.'*\)'  " s means star (*)
let s:Sp = '\%('.s:S.'\+\)'  " p means plus (+)

" Name of tags and attributes
let s:Name = '[[:alpha:]_:][[:alnum:]_:.-]*'  " BUGS: Omit some chars.

" Attribute
let s:AttrValue = '\%('
               \        . '"\_[^"]*"'
               \ . '\|' . "'\\_[^']*'"
               \ . '\)'
let s:Attr = s:Name.s:Ss.'='.s:Ss.s:AttrValue


" Start/End/eMpty-elemnt Tag
let s:STag = '<'.s:Name.'\%('.s:Sp.s:Attr.'\)*'.s:Ss.'>'
let s:ETag = '<\/'.s:Name.s:Ss.'>'
let s:MTag = '<'.s:Name.'\%('.s:Sp.s:Attr.'\)*'.s:Ss.'\/>'

" STag or MTag with one or more attributes
let s:ATag = '<[!?]\?'.s:Name.'\%('.s:Sp.s:Attr.'\)\+'.s:Ss.'[!?/]\?>'

" Start/End of a CDATA section
let s:SCDSect = '<!\[CDATA\['
let s:ECDSect = '\]\]>'

" Start/End of a comment
let s:SComment = '<!--'
let s:EComment = '-->'

let s:ProcessingInstruction = '<?\_[^<>]*?>'
let s:Declaration = '<!\_[^<>]*>'


" Start/End of a pair of objects (MTag and other objects count as SObj)
let s:SObj = '\%('
          \        . s:STag
          \ . '\|' . s:SCDSect
          \ . '\|' . s:SComment
          \ . '\|' . s:MTag
          \ . '\|' . s:ProcessingInstruction
          \ . '\|' . s:Declaration
          \ . '\)'
let s:EObj = '\%('
          \        . s:ETag
          \ . '\|' . s:ECDSect
          \ . '\|' . s:EComment
          \ . '\)'

" Any object
let s:AObj = '\%('.s:SObj.'\|'.s:EObj.'\)'




" FUNCTIONS (MAIN)  "{{{2

function! s:MoveToSObjNextHeadSR()
  return s:Search(s:SObj, '/^')
endfunction
function! s:MoveToSObjNextTailSR()
  return s:Search(s:SObj, '/$')
endfunction
function! s:MoveToSObjPrevHeadSR()
  return s:Search(s:SObj, '?^')
endfunction
function! s:MoveToSObjPrevTailSR()
  return s:Search(s:SObj, '?$')
endfunction

function! s:MoveToEObjNextHeadSR()
  return s:Search(s:EObj, '/^')
endfunction
function! s:MoveToEObjNextTailSR()
  return s:Search(s:EObj, '/$')
endfunction
function! s:MoveToEObjPrevHeadSR()
  return s:Search(s:EObj, '?^')
endfunction
function! s:MoveToEObjPrevTailSR()
  return s:Search(s:EObj, '?$')
endfunction

function! s:MoveToTextNextHeadSR()
  return s:SearchText(s:AObj, '/$', s:AObj, '/^', '[^ \t]', '/^')
endfunction
function! s:MoveToTextNextTailSR()
  let pos = searchpos(s:Ss.'.', 'enW')
  if pos[0] && (pos == searchpos(s:AObj, 'nW'))
    call setpos('.', [0, pos[0], pos[1], 0])
  endif
  if !s:SearchText(s:AObj, '/^', s:AObj, '?$', '[^ \t]', '?^')
    return 0
  endif
  return 1
endfunction
function! s:MoveToTextPrevHeadSR()
  let pos = searchpos('.'.s:Ss, 'bnW')
  if pos[0] && (pos == searchpos(s:AObj, 'benW'))
    call setpos('.', [0, pos[0], pos[1], 0])
  endif
  if !s:SearchText(s:AObj, '?$', s:AObj, '/^', '[^ \t]', '/^')
    return 0
  endif
  return 1
endfunction
function! s:MoveToTextPrevTailSR()
  return s:SearchText(s:AObj, '?^', s:AObj, '?$', '[^ \t]', '?^')
endfunction

function! s:MoveToAttrNextHeadSR()
  return s:MoveToAttrSR('/^')
endfunction
function! s:MoveToAttrNextTailSR()
  return s:MoveToAttrSR('/$')
endfunction
function! s:MoveToAttrPrevHeadSR()
  return s:MoveToAttrSR('?^')
endfunction
function! s:MoveToAttrPrevTailSR()
  return s:MoveToAttrSR('?$')
endfunction




" FUNCTIONS (UTILITIES)  "{{{2

" Wrapper for moving functions.
" * Support count.
" * Mark the original position for '' and ``.
function! s:W(f, mode)
  mark `
  if a:mode == 'v'
    execute 'normal!' "gv\<Esc>"
  endif
  let i = 1
  while i <= v:count1
    let pos_once = getpos('.')
    if !a:f()
      call setpos('.', pos_once)
      if a:mode == 'v'
        normal! gv
      endif
      return 0
    endif
    let i = i + 1
  endwhile
  if a:mode == 'v'
    let pos = getpos('.')
    normal! gv
    call setpos('.', pos)
  endif
  return 1
endfunction


function! s:Search(pattern, flags)
  let flags = 'W'
  if strpart(a:flags, 0, 1) == '?'
    let flags = flags.'b'
  endif
  if strpart(a:flags, 1, 1) == '$'
    let flags = flags.'e'
  endif
  let flags = flags.strpart(a:flags, 2)

  return search(a:pattern, flags)
endfunction


function! s:SearchText(p1, f1, p2, f2, p3, f3)
  while 1
    if !s:Search(a:p1, a:f1) | return 0 | endif
    let pos1 = getpos('.')

    if !s:Search(a:p2, a:f2) | return 0 | endif
    let pos2 = getpos('.')
    call setpos('.', pos1)

    if !s:Search(a:p3, a:f3) | return 0 | endif
    if pos2 != getpos('.')
      break
    endif
    call setpos('.', pos1)
  endwhile
  return 1
endfunction


function! s:MoveToAttrSR(flags)
  let regions = s:CalculateATagRegions()
  while 1
    if !s:Search(s:Attr, a:flags) | return 0 | endif
    let pos_attr = getpos('.')
    for [region_head, region_tail] in regions
      if s:PosLE(region_head, pos_attr) && s:PosLE(pos_attr, region_tail)
        return 1
      endif
    endfor
  endwhile
endfunction

" Calculate the following regions:
" r0: ATag including or backward the cursor.
" r1: ATag backward the cursor.
" r2: ATag forward the cursor.
function! s:CalculateATagRegions()
  let regions = []
  let pos_orig = getpos('.')

  if s:Search(s:ATag, '?^c')
    let pos_r0_head = getpos('.')
    if s:Search(s:ATag, '/$c')
      let pos_r0_tail = getpos('.')
      call add(regions, [pos_r0_head, pos_r0_tail])
    endif
  endif
  call setpos('.', pos_orig)

  if s:Search(s:ATag, '?^c') && s:Search(s:ATag, '?^')
    let pos_r1_head = getpos('.')
    if s:Search(s:ATag, '/$c')
      let pos_r1_tail = getpos('.')
      call add(regions, [pos_r1_head, pos_r1_tail])
    endif
  endif
  call setpos('.', pos_orig)

  if s:Search(s:ATag, '/^c')
    let pos_r2_head = getpos('.')
    if s:Search(s:ATag, '/$c')
      let pos_r2_tail = getpos('.')
      call add(regions, [pos_r2_head, pos_r2_tail])
    endif
  endif
  call setpos('.', pos_orig)

  return regions
endfunction

function! s:PosLE(a, b)  " compare two positions (returned by getpos())
  return (a:a[1] < a:b[1]) || ((a:a[1] == a:b[1]) && (a:a[2] <= a:b[2]))
endfunction




"}}}2
endif








" ETC  "{{{1

let s:loaded_xml_move = 1


" BUGS: Don't set b:did_ftplugin to load other filetype plugins.  Because this
" filetype plugin is an addition to the default ones and user filetype plugins
" are loaded before them.
"
" let b:did_ftplugin = 1

" __END__
" vim: foldmethod=marker
