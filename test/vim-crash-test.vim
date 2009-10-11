let &runtimepath = join(['./vim/dot.vim',
\                       '../vim-debug/runtime',
\                       '../vim-debug/runtime/after',
\                       './vim/dot.vim/after'],
\                      ',')
runtime! plugin/**/*.vim
source test/libtest.vim
1 verbose source test/vim-ku/core-internal-candidate.input
qall!
