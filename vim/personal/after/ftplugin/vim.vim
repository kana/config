" Vim additional ftplugin: vim

inoreabbrev <buffer> jd  def()<Return>
                        \enddef
                        \<Up><End><Left><Left>
inoreabbrev <buffer> je  if<Return>
                        \else<Return>
                        \endif
                        \<Up><Up><End>
inoreabbrev <buffer> jf  function!()<Return>
                        \endfunction
                        \<Up><End><Left><Left>
inoreabbrev <buffer> ji  if<Return>
                        \endif
                        \<Up><End>
inoreabbrev <buffer> jr  for<Return>
                        \endfor
                        \<Up><End>
inoreabbrev <buffer> jt  try<Return>
                        \catch /.../<Return>
                        \finally<Return>
                        \endtry
                        \<Up><Up><Up><End>
inoreabbrev <buffer> jw  while<Return>
                        \endwhile
                        \<Up><End>

function! b:.undo_after_ftplugin_vim()
  iunabbrev <buffer> jd
  iunabbrev <buffer> je
  iunabbrev <buffer> jf
  iunabbrev <buffer> ji
  iunabbrev <buffer> jr
  iunabbrev <buffer> jt
  iunabbrev <buffer> jw
endfunction

let b:undo_ftplugin .= ' | silent! call b:.undo_after_ftplugin_vim()'

" __END__
" vim: foldmethod=marker
