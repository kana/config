" This file is to define user-defined surrounding objects, especially for the
" objects which contain multibyte characters.  Originally I put these
" definitions in ~/.vimrc, but multibyte strings will be broken whenever
" 'encoding' is changed.  So I moved the definitions into this file.
scriptencoding utf-8  " for &encoding != 'utf-8' environments
if !(exists('g:loaded_surround') && exists('*SurroundRegister'))
  " Skip if the loaded plugin is not a modified version of the following:
  " http://github.com/kana/config/tree/master/vim/dot.vim/plugin/surround.vim
  finish
endif


" for XML.
call SurroundRegister('g', '&', "&lt;\r&gt;")
call SurroundRegister('g', 'C', "<![CDATA[\r]]>")


" for various braces in Japanese language.
call SurroundRegister('g', 'jb', "（\r）")
call SurroundRegister('g', 'jB', "｛\r｝")
call SurroundRegister('g', 'jr', "［\r］")
call SurroundRegister('g', 'jk', "「\r」")
call SurroundRegister('g', 'jK', "『\r』")
call SurroundRegister('g', 'ja', "＜\r＞")
call SurroundRegister('g', 'jA', "≪\r≫")
call SurroundRegister('g', 'jy', "〈\r〉")
call SurroundRegister('g', 'jY', "《\r》")
call SurroundRegister('g', 'jt', "〔\r〕")
call SurroundRegister('g', 'js', "【\r】")


" __END__
