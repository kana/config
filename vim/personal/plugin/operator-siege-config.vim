" The following configuration must be written in other than vimrc, because
" strings with multibyte characters are broken whenever 'encoding' is changed.

scriptencoding utf-8  " for &encoding != 'utf-8' environments

" Assumption: vim-textobj-jabraces is installed.
let g:operator_siege_decos = [
\   {'chars': ['（', '）'], 'objs': ['ajb', 'ijb'], 'keys': ['jb']},
\   {'chars': ['｛', '｝'], 'objs': ['ajB', 'ijB'], 'keys': ['jB']},
\   {'chars': ['［', '］'], 'objs': ['ajr', 'ijr'], 'keys': ['jr']},
\   {'chars': ['「', '」'], 'objs': ['ajk', 'ijk'], 'keys': ['jk']},
\   {'chars': ['『', '』'], 'objs': ['ajK', 'ijK'], 'keys': ['jK']},
\   {'chars': ['＜', '＞'], 'objs': ['aja', 'ija'], 'keys': ['ja']},
\   {'chars': ['≪', '≫'], 'objs': ['ajA', 'ijA'], 'keys': ['jA']},
\   {'chars': ['〈', '〉'], 'objs': ['ajy', 'ijy'], 'keys': ['jy']},
\   {'chars': ['《', '》'], 'objs': ['ajY', 'ijY'], 'keys': ['jY']},
\   {'chars': ['〔', '〕'], 'objs': ['ajt', 'ijt'], 'keys': ['jt']},
\   {'chars': ['【', '】'], 'objs': ['ajs', 'ijs'], 'keys': ['js']},
\ ]

" __END__
