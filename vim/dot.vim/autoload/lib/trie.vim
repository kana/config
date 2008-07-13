" lib#trie - Trie library
" Version: 0.0
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
"{{{1
"
" trie ::= {'root': node,
"           'default_value': <any value>}
" default-value ::= <any value>
" node ::= {'value': <any value>,
"           'children': {<a part of key (1 char)>: node,
"                        ...}}

let s:trie = {}




function! lib#trie#new(default_value)  "{{{1
    let new_instance = copy(s:trie)
    let new_instance.root = s:trie.node.new(a:default_value)
    let new_instance.default_value = a:default_value
    return new_instance
endfunction




function! s:trie.dump()  "{{{1
    echomsg 'Trie:' '(default_value:' string(self.default_value) ')'
    call self.root.dump('root', 1)
endfunction




function! s:trie.put(sequence, value)  "{{{1
    let node = self.root
    let i = 0
    while i < len(a:sequence)
        let item = a:sequence[i]
        if !has_key(node.children, item)
            let node.children[item] = s:trie.node.new(self.default_value)
        endif
        let node = node.children[item]
        let i = i + 1
    endwhile
    let old_value = node.value
    let node.value = a:value
    return old_value
endfunction




function! s:trie.get(sequence, accept_halfway_matchp, ...)  "{{{1
    let default_value = a:0 ? a:1 : self.default_value
    let node = self.root
    let i = 0
    while i < len(a:sequence)
        let item = a:sequence[i]
        if !has_key(node.children, item)
            return default_value
        endif
        let node = node.children[item]
        let i = i + 1
    endwhile

    if node.leafp() || a:accept_halfway_matchp
        return node.value
    else
        return default_value
    endif
endfunction




function! s:trie.take(sequence)  "{{{1
    if len(a:sequence) == 0
        throw 'empty sequence is not allowed'
    endif
    let parent = self.root
    let node = self.root
    let i = 0
    while i < len(a:sequence)
        let item = a:sequence[i]
        if !has_key(node.children, item)
            throw 'value corresponding to the given sequence is not found'
        endif
        let parent = node
        let node = node.children[item]
        let i = i + 1
    endwhile
    return remove(parent.children, item).value
endfunction




function! s:trie.get_incremental(accept_halfway_matchp, ...)  "{{{1
    let state = {}
    let state.accept_halfway_matchp = a:accept_halfway_matchp
    let state.default_value = a:0 ? a:1 : self.default_value
    let state.node = self.root
    let state.i = 0

    function state.feed(item)
        if !has_key(self.node.children, a:item)
            return [s:trie.FAILED, self.default_value]
        endif
        let self.node = self.node.children[a:item]
        let self.i = self.i + 1

        if self.node.leafp() || self.accept_halfway_matchp
            return [s:trie.MATCHED, self.node.value]
        else
            return [s:trie.CONTINUED, self.default_value]
        endif
    endfunction

    return state
endfunction

let s:trie.CONTINUED = ['CONTINUED']
let s:trie.FAILED = ['FAILED']
let s:trie.MATCHED = ['MATCHED']




" node  "{{{1

let s:trie.node = {}


function! s:trie.node.new(value)  "{{{2
    let new_instance = copy(s:trie.node)
    let new_instance.value = a:value
    let new_instance.children = {}
    return new_instance
endfunction


function! s:trie.node.leafp()  "{{{2
    return len(self.children) == 0
endfunction


function! s:trie.node.dump(label, lv)  "{{{2
    echomsg repeat('  ', a:lv)[1:] string(a:label) ':' string(self.value)
    for key in sort(keys(self.children))
        call self.children[key].dump(key, a:lv+1)
    endfor
endfunction




" __END__  "{{{1
" vim: foldmethod=marker
