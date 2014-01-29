" Highlight nanoc metadata embedded in a markdown file.

unlet b:current_syntax

syntax include @yaml syntax/yaml.vim
syntax region markdownNanocMetadata
\      start=/^---$/ end=/^---$/
\      contains=@yaml keepend

let b:current_syntax = 'markdown'

" __END__
