"=============================================================================
"
"     FileName: lua.vim
"         Desc: best lua indent plugin: https://github.com/dantezhu/lua_indent
"         modify from https://gist.github.com/bonsaiviking/8845871 and fix some bugs
"
"       Author: dantezhu
"        Email: zny2008@gmail.com
"     HomePage: http://www.vimer.cn
"
"      Created: 2014-10-06 17:55:33
"      Version: 1.0.1
"      History:
"               1.0.1 | dantezhu | 2014-10-06 17:55:33 | init
"
"=============================================================================

" Vim indent file
" Language:     Lua
" Maintainer:       Daniel Miller <daniel@bonsaiviking.com>
" Original Author:  Daniel Miller <daniel@bonsaiviking.com>
" Last Change:      2014 Feb 6
 
" Only load this indent file when no other was loaded.
if exists("b:did_indent")
  finish
endif
let b:did_indent = 1
 
" Some preliminary settings
setlocal nolisp     " Make sure lisp indenting doesn't supersede us
setlocal autoindent " indentexpr isn't much help otherwise
 
setlocal indentexpr=GetLuaIndent()
setlocal indentkeys+==end,=until,=elseif,=else
 
" Only define the function once.
if exists("*GetLuaIndent")
  finish
endif
 
" Come here when loading the script the first time.
 
function IsValidMatch()
  "echom synIDattr(synID(line('.'), col('.'), 1), 'name') . " match "
  "      \ . getline(".")[col(".")-1] . " in col " . col(".")
  return synIDattr(synID(line('.'), col('.'), 1), 'name') =~ '\%(Comment\|String2\?\)$'
endfunction
 
function GetLuaIndent()
  let openmatch = '\%(\<\%(function\|if\|repeat\|do\)\>\|(\|{\|\[\)'
  let middlematch = '\<\%(else\|elseif\)\>'
  let closematch = '\%(\<\%(end\|until\)\>\|)\|}\|\]\)'
 
  let save_cursor = getpos(".")
 
  " If the start of the line is in a [[string]] don't change the indent.
  if has('syntax_items')
        \ && synIDattr(synID(v:lnum, 1, 1), "name") =~ 'String2$'
    "echom "String, no indent"
    return -1
  endif
 
  " Search backwards for the previous non-empty line.
  let plnum = prevnonblank(v:lnum - 1)
  " [[multiline strings]] shouldn't affect indentation
  while synIDattr(synID(plnum, 1, 1), 'name') =~ 'String2$'
    let plnum = prevnonblank(plnum - 1)
  endwhile
 
  if plnum == 0
    " This is the first non-empty line, use zero indent.
    return 0
  endif
 
  let i = 0
 
  "check open keywords on line above
  call cursor(v:lnum, 1)
  let parnum = searchpair(openmatch,
        \ middlematch, closematch, 'mWrb',
        \ "IsValidMatch()", plnum)
  if parnum > 0
    "echom parnum . "open matches above"
    let i += parnum
  endif
 
  "check closed keywords on current line
  call cursor(plnum, col([plnum,'$']))
  let parnum = searchpair(openmatch,
        \ middlematch, closematch, 'mWr',
        \ "IsValidMatch()", v:lnum)
  if parnum > 0
    "echom parnum . "closed matches here"
    let i -= parnum
  endif
 
" create(
"     get(
"         1,
"         2
"         ),
"     val(),
"     )
"
" to
"
" create(
"     get(
"         1,
"         2
"     ),
"     val(),
" )

" DEL-BEGIN by dantezhu in 2014-10-06 17:50:18
  "Special case for parentheses (indent the closing paren)
  "If the previous line closed a paren, dedent
  call cursor(plnum - 1, col([plnum - 1, '$']))
  let parnum = searchpair('(', '', ')', 'mWr',
        \ "IsValidMatch()", plnum)
  if parnum > 0
    "echom parnum . "closed parens above"
    let i -= 1
  endif

  "If this line closed a paren, indent
  call cursor(plnum, col([plnum, '$']))
  let parnum = searchpair('(', '', ')', 'mWr',
        \ "IsValidMatch()", v:lnum)
  if parnum > 0
    "echom parnum . "closed parens here"
    let i += 1
  endif
" DEL-END
 
  "restore cursor
  call setpos(".", save_cursor)
 
  "return the calculated indent
  return indent(plnum) + (&sw * i)
 
endfunction
 
" vim:sw=2
