" ==============================================================================
" Name:         Vivid.vim
" Author:       Alex Vear
" HomePage:     https://github.com/axvr/Vivid.vim
" Version:      1.0.0
" ==============================================================================

" TODO allow extensions for Vivid (e.g. add async, etc.)
" FIXME make DOS compatible (:h dos  :h shellescape())
" TODO check that `packadd` can take multiple args and `au`s will be ran on each
" TODO use something similar to this in Vivid
"autocmd! SourceCmd ~/.vim/pack/vivid/opt/vim-qf/*/*.vim if vivid#enabled('vim-qf') == 0 | call vivid#enable('vim-qf') | echo "hello world" | endif

" Prevent Vivid being loaded multiple times (and users can check if enabled)
if exists('g:loaded_vivid') || !has('packages') | finish | endif
let g:loaded_vivid = 1

" New central plugin store (dictionary contains a sub-dictionary)
" TODO add more options
let s:plugins = { 'Vivid': { 
            \ 'remote': 'https://git::@github.com/axvr/Vivid.vim.git', 
            \ 'enabled': 1,
            \ }, }

" Print more information to user about updates, etc.
let g:vivid#verbose = 0

" Find Vivid install location (fast if nothing has yet been added to the &rtp)
" TODO allow for other/custom install locations
let s:where_am_i = split(&runtimepath, ',')
for s:path in s:where_am_i
    if s:path =~# '.Vivid\.vim$' 
        let s:install_location = substitute(s:path, '.Vivid\.vim', '', '')
        unlet s:path s:where_am_i
        break
    endif
endfor

" Generate helptags FIXME needs optimising, adapting & improving
function! s:gen_helptags(doc) abort
    if isdirectory(a:doc)
        execute 'helptags ' . a:doc
    endif
endfunction
call s:gen_helptags(expand(s:install_location . '/Vivid.vim/doc/'))
" FIXME ^ dos compatible and optimise


" Add a plugin for Vivid to manage
" Example:
" call vivid#add('tpope/vim-fugitive', {
"     \ 'path': 'fugitive.vim',
"     \ 'enabled': 1,
"     \ } )
" Arguments: 'remote', { 'path': 'string', 'enabled': boolean }
function! vivid#add(remote, ...) abort

    " Create empty dictionary to be added to s:plugins
    let l:new_plugin = {}

    " TODO add more sources
    if a:remote =~? '\m\C^https:\/\/.\+' || a:remote =~? '\m\C^http:\/\/.\+'
        let l:new_plugin['remote'] = a:remote
    elseif a:remote =~? '\m\C^.\+\/.\+'
        let l:new_plugin['remote'] = 'https://git::@github.com/' . a:remote . '.git'
    else
        echomsg 'Vivid: Remote address creation fail:' a:remote
        return
    endif

    " Generate the required local path if none were given
    if !has_key(a:000, 'path')
        let l:path = split(l:new_plugin['remote'], '/')
        let l:path = substitute(l:path[-1], '\m\C\.git$', '', '')
    else
        let l:path = a:000['path']
    endif

    " Merge the given dictionary to the calculated dictionary
    call extend(l:new_plugin, a:000)
    " Ensure 'enabled' is set to 0 so it can be enabled with low complexity
    let l:new_plugin['enabled': 0]

    " Add the new plugin to the plugin dictionary
    if !has_key(s:plugins, l:path)
        let s:plugins[l:path] = l:new_plugin
    endif

    " TODO enable plugin
    if has_key(a:000, 'enabled') && a:000['enabled'] == 0
        " Enable plugin
        echo "Work in progress"
    endif

    return
endfunction




" -----------------------------------------------------------------------

" Main list for Vivid to manage all plugins
" s:plugins = [[a, 1, 4], [b, 2, 5], [c, 3, 6],]
"              ^brackets = rows  ^numbers = columns
" | Name  | Remote Address                        | Install Path | Enabled |
" |-------|---------------------------------------|--------------|---------|
" | Vivid | https://github.com/axvr/Vivid.vim.git | Vivid.vim    | 1       |
let s:plugins = [['Vivid', 'https://git::@github.com/axvr/Vivid.vim', 'Vivid.vim', 1]]
" Dictionary containing locations of plugins in the list (for quickly finding
" a specific plugin, without requiring searching every item of the list)
let s:names   = { 'Vivid': 0, }
let s:next_location = 1
let s:install_dir = ''
" Allow user to check if Vivid is enabled
if exists("g:loaded_vivid") | finish | endif
let g:loaded_vivid = 1
" TODO print more information to user about updates etc.
"let g:vivid#verbose = 0

" --------------------------------

" Install plugins
" TODO async download
" TODO windows compatibility
function! vivid#install(...) abort
    if empty(a:000)
        " Install all plugins if no plugins were specified
        for l:plugin in s:plugins
            call s:install_plugins(l:plugin[0])
        endfor
    else
        " If arguments were passed to Vivid, install those plugins
        for l:plugin in a:000
            call s:install_plugins(l:plugin)
        endfor
    endif
    return
endfunction

function! s:install_plugins(plugin) abort
    let l:echo_message = 'Vivid: Plugin install -'
    let l:index = get(s:names, a:plugin, -1)
    if l:index != -1
        let l:install_path = s:install_dir . '/' . s:plugins[l:index][2]
        if !isdirectory(l:install_path)
            let l:cmd = 'git clone ' . s:plugins[l:index][1] . ' ' . l:install_path
            let l:output = system(l:cmd)
            " TODO check clone message
            " TODO verbose mode
            if l:output =~# '\m\C^fatal: repository '
                " 'Repository does not exist'
                echomsg l:echo_message 'Failed:   ' a:plugin
            elseif l:output =~# '\m\C^Cloning into '
                echomsg l:echo_message 'Installed:' s:plugins[l:index][0]
            else
                echomsg l:echo_message 'Failed:   ' a:plugin
            endif
        else
            " Plugin already installed. If broken, remove with vivid#clean
            echomsg l:echo_message 'Skipped:  ' s:plugins[l:index][0]
        endif
    else
        " Plugin is not being managed
        echomsg l:echo_message 'Failed:   ' a:plugin
    endif
    return
endfunction


" Update plugins (TODO async download)
" TODO frozen plugins
function! vivid#update(...) abort
    if empty(a:000)
        " Update all plugins because none were specified
        for l:plugin in s:plugins
            call s:update_plugins(l:plugin[0])
        endfor
    else
        " Update specified plugins only
        for l:plugin in a:000
            call s:update_plugins(l:plugin)
        endfor
    endif
    return
endfunction

function! s:update_plugins(plugin) abort
    let l:echo_message = 'Vivid: Plugin update  -'
    let l:index = get(s:names, a:plugin, -1)
    if l:index != -1
        let l:install_path = s:install_dir . '/' .
                    \ s:plugins[l:index][2]
        let l:cmd = 'git -C ' . l:install_path . ' pull'
        let l:output = system(l:cmd)
        if l:output =~# '\m\C^Already up-to-date\.'
            echomsg l:echo_message 'Latest:   ' s:plugins[l:index][0]
        else
            let l:output = split(l:output)
            " TODO give more information
            if l:output[0] =~# '\m\C^From$'
                echomsg l:echo_message 'Updated:  ' s:plugins[l:index][0]
            elseif l:output[0] =~# '\m\C^fatal:$'
                echomsg l:echo_message 'Failed:   ' s:plugins[l:index][0]
            else
                echomsg l:output[0]
            endif
        endif
    else
        echomsg l:echo_message 'Failed:   ' a:plugin
    endif
    return
endfunction


" Enable plugins
function! vivid#enable(...) abort
    if empty(a:000)
        " Enable all plugins because none were specified
        for l:plugin in s:plugins
            call s:enable_plugins(l:plugin[0])
        endfor
    else
        " Enable specified plugins only
        for l:plugin in a:000
            call s:enable_plugins(l:plugin)
        endfor
    endif
    return
endfunction

function! s:enable_plugins(plugin, ...) abort
    let l:index = get(s:names, a:plugin, -1)
    if l:index != -1
        if !isdirectory(s:install_dir . '/' . s:plugins[l:index][2])
            call vivid#install(s:plugins[l:index][0])
        endif
        if s:plugins[l:index][3] == 0 || exists('a:1')
            let s:plugins[l:index][3] = 1
            silent execute 'packadd! ' . s:plugins[l:index][2]
            let l:doc = expand(s:install_dir . '/' . s:plugins[l:index][2] . '/doc/')
            call s:gen_helptags(l:doc)
        endif
    else
        echomsg 'Vivid: Plugin enable  - Failed:   ' a:plugin
    endif
    return
endfunction


" TODO
"function! vivid#clean(...) abort
"endfunction


" Allows the user to check if a plugin is enabled or not
" return values:  1 == enabled, 0 == disabled or not a plugin
function! vivid#enabled(plugin) abort
    let l:index = get(s:names, a:plugin, -1)
    if l:index != -1
        return s:plugins[l:index][3]
    else | return 0
    endif
endfunction


" vim: set ts=4 sw=4 tw=80 et ft=vim fdm=marker fmr={{{,}}} :
