" textobj-jabraces - Text objects for Japanese braces
" Version: 0.1.1
" Copyright (C) 2008 kana <http://whileimautomaton.net/>
" License: MIT license (see <http://www.opensource.org/licenses/mit-license>)
scriptencoding utf-8

if exists('g:loaded_textobj_jabraces')
  finish
endif




call textobj#user#plugin('jabraces', {
\      'parens': {
\         '*pattern*': ["\uFF08", "\uFF09"],
\         'select-a': ['ajb', 'aj(', 'aj)'],
\         'select-i': ['ijb', 'ij(', 'ij)']
\      },
\      'brackets': {
\         '*pattern*': ["\uFF3B", "\uFF3D"],
\         'select-a': ['ajr', 'aj[', 'aj]'],
\         'select-i': ['ijr', 'ij[', 'ij]']
\      },
\      'braces': {
\         '*pattern*': ["\uFF5B", "\uFF5D"],
\         'select-a': ['ajB', 'aj{', 'aj}'],
\         'select-i': ['ijB', 'ij{', 'ij}']
\      },
\      'angles': {
\         '*pattern*': ["\uFF1C", "\uFF1E"],
\         'select-a': ['aja', 'aj<', 'aj>'],
\         'select-i': ['ija', 'ij<', 'ij>']
\      },
\      'double-angles': {
\         '*pattern*': ["\u226A", "\u226B"],
\         'select-a': 'ajA',
\         'select-i': 'ijA'
\      },
\      'kakko': {
\         '*pattern*': ["\u300C", "\u300D"],
\         'select-a': 'ajk',
\         'select-i': 'ijk'
\      },
\      'double-kakko': {
\         '*pattern*': ["\u300E", "\u300F"],
\         'select-a': 'ajK',
\         'select-i': 'ijK'
\      },
\      'yama-kakko': {
\         '*pattern*': ["\u3008", "\u3009"],
\         'select-a': 'ajy',
\         'select-i': 'ijy'
\      },
\      'double-yama-kakko': {
\         '*pattern*': ["\u300A", "\u300B"],
\         'select-a': 'ajY',
\         'select-i': 'ijY'
\      },
\      'kikkou-kakko': {
\         '*pattern*': ["\u3014", "\u3015"],
\         'select-a': 'ajt',
\         'select-i': 'ijt'
\      },
\      'sumi-kakko': {
\         '*pattern*': ["\u3010", "\u3011"],
\         'select-a': 'ajs',
\         'select-i': 'ijs'
\      },
\    })




let g:loaded_textobj_jabraces = 1

" __END__
