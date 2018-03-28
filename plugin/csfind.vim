if exists('g:csfind_Pluginloaded')
    finish
endif

let g:csfind_PluginLoaded = 1

if !exists('g:csfind_rgBinary')
    let g:csfind_rgBinary = 'rg'
endif

if !exists('g:csfind_rgArgs')
    let g:csfind_rgArgs = '--vimgrep'
endif

if !exists('g:csfind_format')
  let g:csfind_format = "%f:%l:%c:%m"
endif

fun! s:hasUppercaseChar(string)
    let l:lower = tolower(a:string)
    if a:string ==# l:lower
        return 0
    endif

    return 1
endfun

fun! s:getQuery()
    call inputsave()
    let l:query = input('find: ')
    call inputrestore()
    if strlen(l:query) > 0
        return l:query
    endif
endfun

fun! s:run(query)
    if empty(a:query)
        return 0
    endif

    let l:cmd = g:csfind_rgBinary . ' ' . g:csfind_rgArgs
    call s:runGrepContext(function('s:doSearch'), l:cmd, a:query)
endfun

fun! s:runPrompt()
    let l:query = shellescape(s:getQuery())

    if empty(l:query)
        return 0
    endif

    let l:cmd = g:csfind_rgBinary . ' ' . g:csfind_rgArgs
    if !s:hasUppercaseChar(l:query)
        let l:cmd = l:cmd . ' -i'
    endif

    call s:runGrepContext(function('s:doSearch'), l:cmd, l:query)
endfun

fun! s:runCursor()
    let l:query = expand("<cword>")

    if empty(l:query)
        return 0
    endif

    let l:cmd = g:csfind_rgBinary . ' ' . g:csfind_rgArgs
    call s:runGrepContext(function('s:doSearch'), l:cmd, l:query)
endfun

fun! s:doSearch(query)
    silent! exe 'grep! ' . a:query
    if len(getqflist())
        copen
        let w:quickfix_title = "csfind search: " . a:query
        redraw!
    else
        cclose
        redraw!
        echo "No results for " . a:query
    endif
endfun

fun! s:runGrepContext(cb, cmd, query)
    " Get mappings to restore them later
    let l:grepCmd = &grepprg
    let l:grepFmt = &grepformat
    let l:termTe = &t_te
    let l:termTi = &t_ti

    let &grepprg = a:cmd
    let &grepformat = g:csfind_format

    set t_te =
    set t_ti =
    
    call a:cb(a:query)
    
    " Restore mappings
    let &t_te = l:termTe
    let &t_ti = l:termTi
    let &grepprg = l:grepCmd
    let &grepformat = l:grepFmt
endfun

command! -nargs=? Csf :call s:run(<q-args>)
command! CsfPrompt :call s:runPrompt()
command! CsfCursor :call s:runCursor()

