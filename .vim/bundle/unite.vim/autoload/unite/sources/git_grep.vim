"=============================================================================
" FILE: git_grep.vim
" AUTHOR:  Kirill Kosarev <kosarev.ka@yandex.ru>
" Last Modified: 19 apr 2014
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

" Variables  "{{{
"call unite#util#set_default('g:unite_source_find_command', 'find')
call unite#util#set_default('g:unite_source_git_grep_max_candidates', 500)
"call unite#util#set_default('g:unite_source_find_ignore_pattern',
      "\'\~$\|\.\%(bak\|sw[po]\)$\|'.
      "\'\%(^\|/\)\.\%(hg\|git\|bzr\|svn\)\%($\|/\)')
"}}}

function! unite#sources#git_grep#define() "{{{
  return s:source
endfunction "}}}

let s:source = {
      \ 'name': 'git_grep',
      \ 'max_candidates': g:unite_source_git_grep_max_candidates,
      \ 'hooks' : {},
      \ 'syntax' : 'uniteSource__Grep',
      \ 'matchers' : ['matcher_regexp'],
      \ }

function! s:source.hooks.on_init(args, context) "{{{
  if !unite#util#has_vimproc()
    call unite#print_source_error(
          \ 'vimproc is not installed.', s:source.name)
    return
  endif

 let a:context.source__target = get(a:args, 0, '')
 let a:context.source__extra_opts = get(a:args, 1, '')
 let a:context.source__input = get(a:args, 2, '')
 if a:context.source__input == ''
   redraw
   echo "Please input command-line(quote is needed) Ex: -name '*.vim'"
    let a:context.source__input = unite#util#input('git grep -n ')
  endif
endfunction"}}}

function! s:source.hooks.on_syntax(args, context) "{{{
  if !unite#util#has_vimproc()
    return
  endif

  syntax case ignore
  syntax region uniteSource__GrepLine
        \ start=' ' end='$'
        \ containedin=uniteSource__Grep
  syntax match uniteSource__GrepFile /^[^:]*/ contained
        \ containedin=uniteSource__GrepLine
        \ nextgroup=uniteSource__GrepSeparator
  syntax match uniteSource__GrepSeparator /:/ contained
        \ containedin=uniteSource__GrepLine
        \ nextgroup=uniteSource__GrepLineNr
  syntax match uniteSource__GrepLineNr /\d\+\ze:/ contained
        \ containedin=uniteSource__GrepLine
        \ nextgroup=uniteSource__GrepPattern
  execute 'syntax match uniteSource__GrepPattern /'
        \ . substitute(a:context.source__input, '\([/\\]\)', '\\\1', 'g')
        \ . '/ contained containedin=uniteSource__GrepLine'
  highlight default link uniteSource__GrepFile Directory
  highlight default link uniteSource__GrepLineNr LineNR
  execute 'highlight default link uniteSource__GrepPattern Search'
endfunction"}}}

function! s:source.hooks.on_post_filter(args, context) "{{{
  for candidate in a:context.candidates
    let candidate.kind = ['file', 'jump_list']
    let candidate.action__directory =
          \ unite#util#path2directory(candidate.action__path)
    let candidate.action__col_pattern = a:context.source__input
    let candidate.is_multiline = 1
  endfor
endfunction"}}}

function! s:source.hooks.on_close(args, context) "{{{
  if has_key(a:context, 'source__proc')
    call a:context.source__proc.kill()
  endif
endfunction "}}}

function! s:source.gather_candidates(args, context) "{{{
  if a:context.source__input == ''
    call unite#print_source_message('Completed.', s:source.name)
    let a:context.is_async = 0
    return []
  endif

  if a:context.is_redraw
    let a:context.is_async = 1
  endif

  let cmdline = printf('git grep --no-color -n %s %s', a:context.source__extra_opts,
    \ a:context.source__input)
  if (a:context.source__target != '')
    let cmdline .= ' -- '.a:context.source__target
  endif
  call unite#print_source_message('Command-line: ' . cmdline, s:source.name)

  let a:context.source__proc = vimproc#plineopen3(
        \ vimproc#util#iconv(cmdline, &encoding, 'char'), 1)

  return self.async_gather_candidates(a:args, a:context)
endfunction "}}}

function! s:source.async_gather_candidates(args, context) "{{{
  let variables = unite#get_source_variables(a:context)

  if !has_key(a:context, 'source__proc')
    let a:context.is_async = 0
    call unite#print_source_message('Completed.', s:source.name)
    return []
  endif

  let stderr = a:context.source__proc.stderr
  if !stderr.eof
    " Print error.
    let errors = filter(stderr.read_lines(-1, 100),
          \ "v:val !~ '^\\s*$'")
    if !empty(errors)
      call unite#print_source_error(errors, s:source.name)
    endif
  endif

  let stdout = a:context.source__proc.stdout
  if stdout.eof
    " Disable async.
    let a:context.is_async = 0
    call unite#print_source_message('Completed.', s:source.name)

    call a:context.source__proc.waitpid()
  endif

  let candidates = map(stdout.read_lines(-1, 100),
          \ "unite#util#iconv(v:val, 'char', &encoding)")
  let candidates = map(filter(candidates,
      \  'v:val =~ "^.\\+:.\\+$"'),
      \ '[v:val, split(v:val[2:], ":", 1)]')

  let _ = []
  for candidate in candidates
    let dict = {
            \   'action__path' : candidate[0][:1].candidate[1][0],
            \   'action__line' : candidate[1][1],
            \   'action__text' : join(candidate[1][2:], ':'),
            \ }
    let dict.action__path =
          \ unite#util#substitute_path_separator(
          \   fnamemodify(dict.action__path, ':p'))

    let dict.word = printf('%s:%s:%s',
          \  unite#util#substitute_path_separator(
          \     fnamemodify(dict.action__path, ':.')),
          \ dict.action__line, dict.action__text)

    call add(_, dict)
  endfor

  return _
endfunction "}}}

function! s:source.complete(args, context, arglead, cmdline, cursorpos) "{{{
  return unite#sources#file#complete_directory(
        \ a:args, a:context, a:arglead, a:cmdline, a:cursorpos)
endfunction"}}}

" vim: foldmethod=marker
