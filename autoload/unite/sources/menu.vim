"=============================================================================
" FILE: menu.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu at gmail.com>
" Last Modified: 02 Jan 2012.
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
"=============================================================================

let s:save_cpo = &cpo
set cpo&vim

call unite#util#set_default('g:unite_source_menu_menus', {})

function! unite#sources#menu#define()
  return s:source
endfunction

let s:source = {
      \ 'name' : 'menu',
      \ 'description' : 'candidates from user defined menus',
      \}

function! s:source.gather_candidates(args, context)"{{{
  let menu_name = get(a:args, 0, '')
  if menu_name == ''
    " All menus.
    return values(map(copy(g:unite_source_menu_menus), "{
          \ 'word' : v:key,
          \ 'abbr' : (v:key . (has_key(v:val, 'description') ?
          \                   ' - ' . v:val.description : '')),
          \ 'kind' : 'source',
          \ 'action__source_name' : 'menu',
          \ 'action__source_args' : [v:key],
          \ }"))
  endif

  " Check menu name.
  if !has_key(g:unite_source_menu_menus, menu_name)
    call unite#print_error('[menu] Invalid menu name : ' . menu_name)
    return []
  endif

  let menu = g:unite_source_menu_menus[menu_name]
  if has_key(menu, 'map')
    let candidates = []
    if type(menu.candidates) == type([])
      let key = 1
      for value in menu.candidates
        call add(candidates, menu.map(key, value))
        let key += 1
      endfor
    else
      for [key, value] in items(menu.candidates)
        call add(candidates, menu.map(key, value))
      endfor
    endif
  else
    let candidates = copy(menu.candidates)
  endif

  if type(candidates) == type({})
    let save_candidates = candidates
    unlet candidates
    let candidates = values(save_candidates)
  endif

  return sort(candidates)
endfunction"}}}

function! s:source.complete(args, context, arglead, cmdline, cursorpos)"{{{
  return keys(g:unite_source_menu_menus)
endfunction"}}}


let &cpo = s:save_cpo
unlet s:save_cpo
