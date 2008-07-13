" Vim additional ftplugin: xml_autons - auto :XMLns by the current content
" Version: 0.0.1
" Copyright (C) 2007 kana <http://whileimautomaton.net/>
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}




if !exists(':AutoXMLns')
  " INTERFACE  "{{{1

  command! -bar AutoXMLns  silent call s:AutoXMLns()

  " Namespace URI -> a part of filename for :XMLns
  if !exists('g:AutoXMLns_Dict')
    let g:AutoXMLns_Dict = {}
  endif
  if !exists('g:AutoXMLns_Dict["http://www.w3.org/1999/xhtml"]')
    let g:AutoXMLns_Dict['http://www.w3.org/1999/xhtml'] = 'xhtml11'
  endif
  if !exists('g:AutoXMLns_Dict["http://www.w3.org/1999/XSL/Transform"]')
    let g:AutoXMLns_Dict['http://www.w3.org/1999/XSL/Transform'] = 'xsl'
  endif




  " MISC. UTILITIES  "{{{1

  function! s:AutoXMLns()
    let original_position = getpos('.')

    let root_range = s:GetRangeOfRootStartTag()
    if !empty(root_range)
      let [root_begin, root_end] = root_range
      for [name, value] in s:ListAttrsInRange(root_begin, root_end)
        if name =~# '^xmlns\%(:\|$\)'
          let canonical_name = get(g:AutoXMLns_Dict, value, '')
          if canonical_name != ''
            let prefix = matchstr(name, '^xmlns:\?\zs.*')
            execute 'XMLns' canonical_name prefix
          endif
        endif
      endfor
    endif

    call setpos('.', original_position)
  endfunction


  function! s:GetRangeOfRootStartTag()
    keepjumps normal! gg0
    if !search(s:SMTag, 'c') | return 0 | endif
    let range_begin = getpos('.')

    keepjumps normal! gg0
    if !search(s:SMTag, 'ce') | return 0 | endif
    let range_end = getpos('.')

    return [range_begin, range_end]
  endfunction


  function! s:ListAttrsInRange(range_begin, range_end)
    let reg_orig = @"
    call setpos('.', a:range_begin)
    normal! v
    call setpos('.', a:range_end)
    normal! y
    let text = @"
    let @" = reg_orig

    let attrs = []
    call substitute(text, s:Attr,
         \ '\=add(attrs, [submatch(1), matchstr(submatch(2),".\\zs.*\\ze.")])',
         \ 'g')
    return attrs
  endfunction




  " CONSTANTS  "{{{1
  " FIXME: Most of them are copied from xml_move -- violate DRY.

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
  let s:Attr = '\('.s:Name.'\)'.s:Ss.'='.s:Ss.'\('.s:AttrValue.'\)'

  " Start or eMpty-elemnt Tag
  let s:SMTag = '<'.s:Name.'\%('.s:Sp.s:Attr.'\)*'.s:Ss.'\/\?>'

  "}}}1
endif




AutoXMLns

" __END__
" vim: foldmethod=marker
