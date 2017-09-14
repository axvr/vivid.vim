" ==============================================================================
" Name:         Vivid.vim
" Author:       Alex Vear
" HomePage:     https://github.com/axvr/Vivid.vim
" Version:      1.0.0
" ==============================================================================


" Main list for Vivid to manage all plugins
" s:plugins = [[a, 1, 4], [b, 2, 5], [c, 3, 6],]
"              ^brackets = rows  ^numbers = columns
" | Name  | Remote Address                        | Install Path | Enabled |
" |-------+---------------------------------------+--------------+---------|
" | Vivid | https://github.com/axvr/Vivid.vim.git | Vivid        | 1       |
let s:plugins = [['Vivid', 'https://git::@github.com/axvr/Vivid.vim', 'Vivid.vim', 1]]
" Dictionary containing locations of plugins in the list (for quickly finding
" a specific plugin, without requiring searching every item of the list)
let s:names   = { 'Vivid': 0, }
let s:next_location = 1
let s:install_dir = ''
" TODO print more information to user about upgrades etc.
"let g:vivid#verbose = 0


" Set install directory automatically
let s:nvim_path = $HOME . '/.config/nvim/pack/vivid/opt'
let s:vim_path  = $HOME . '/.vim/pack/vivid/opt'
" TODO add more options for different types of vim (e.g. macvim)
if has('nvim')
    if !isdirectory(s:nvim_path)
        call mkdir(s:nvim_path, 'p')
    endif
    let s:install_dir = s:nvim_path
else
    if !isdirectory(s:vim_path)
        call mkdir(s:vim_path, 'p')
    endif
    let s:install_dir = s:vim_path
endif

" Generate helptags
function! s:gen_helptags(doc) abort
    if isdirectory(a:doc)
        execute 'helptags ' . a:doc
    endif
endfunction
call s:gen_helptags(expand(s:install_dir . '/' . s:plugins[0][2] . '/doc/'))

" TODO Allow manual setting of plugin directory by the user, use symbolic links
"function! vivid#set_install_dir(path) abort
"    let s:install_dir = expand(a:path)
"    call s:gen_helptags(expand(s:install_dir . '/' . s:plugins[0][2] . '/doc/'))
"endfunction


" Add a plugin for Vivid to manage
" Example:
" call vivid#add('rhysd/clever-f.vim', {
"     \ 'name': 'Clever-f',
"     \ 'path': 'clever-f.vim',
"     \ 'enabled': 1,
"     \ } )
" Arguments: 'remote', { 'name': 'string', 'path': 'string', 'enabled': boolean }
function! vivid#add(remote, ...) abort

    " Create remote path for plugin
    " TODO add functionality for other sources and methods
    " TODO windows shellescape()
    if a:remote =~? '\m\C^https:\/\/.\+' || a:remote =~? '\m\C^http:\/\/.\+'
        let l:remote = a:remote
    elseif a:remote =~? '\m\C^.\+\/.\+'
        let l:remote = 'https://git::@github.com/' . a:remote . '.git'
    else
        echomsg 'Vivid: Remote address creation fail:' a:remote
        return
    endif

    " If extra info is given create a new dictionary for it
    if a:0 == 1
        let l:info = a:1
    endif

    " Create the path from the remote address (unless one was given)
    if a:0 == 1 && has_key(l:info, 'path')
        let l:path = l:info['path']
    else
        let l:path = l:remote
        let l:path = split(l:path, '/')
        let l:path = l:path[-1]
        let l:path = substitute(l:path, '\m\C\.git$', '', '')
    endif

    " Create the name from the remote address (unless one was given)
    if a:0 == 1 && has_key(l:info, 'name')
        let l:name = l:info['name']
    else
        let l:name = l:remote
        let l:name = split(l:name, '/')
        let l:name = l:name[-1]
        " for some reason, split() does not work on '.'
        let l:name = substitute(l:name, '\m\C\.', ';', '')
        let l:name = split(l:name, ';')
        let l:name = l:name[0]
    endif

    " Default the auto-enabled to false (unless explicitly stated otherwise)
    if a:0 == 1 && has_key(l:info, 'enabled')
        if l:info['enabled'] == 0 || l:info['enabled'] == 1
            let l:enabled = l:info['enabled']
        endif
    else
        let l:enabled = 0
    endif

    " Check that the same plugin has not already been added to Vivid
    if !has_key(s:names, l:name)
        " Add plugin to the (2D) list
        let l:plugin = [l:name, l:remote, l:path, l:enabled]
        call add(s:plugins, l:plugin)
        " Add plugin to the s:names dictionary to find the info quickly
        let s:names[l:name] = s:next_location
        let s:next_location += 1
    endif

    if l:enabled == 1
        call s:enable(l:name, 1)
    endif

    return
endfunction


" Install plugins
" TODO async download
" TODO windows compatibility
function! vivid#install(...) abort
    if empty(a:000)
        " Install all plugins if no plugins were specified
        for l:plugin in s:plugins
            call s:install(l:plugin[0])
        endfor
    else
        " If arguments were passed to Vivid, install those plugins
        for l:plugin in a:000
            call s:install(l:plugin)
        endfor
    endif
    return
endfunction

function! s:install(plugin) abort
    let l:echo_message = 'Vivid: Plugin install -'
    let l:index = get(s:names, l:plugin, -1)
    if l:index != -1
        let l:install_path = s:install_dir . '/' . s:plugins[l:index][2]
        if !isdirectory(l:install_path)
            let l:cmd = 'git clone ' . s:plugins[l:index][1] . ' ' . l:install_path
            let l:clone = system(l:cmd)
            " TODO check clone message
            echomsg l:echo_message 'Installed:' s:plugins[l:index][0]
        else
            " Plugin nalready installed. If broken, remove with vivid#clean
            echomsg l:echo_message 'Skipped:  ' s:plugins[l:index][0]
        endif
    else
        echomsg l:echo_message 'Failed:   ' l:plugin
    endif
    return
endfunction


" Upgrade plugins (TODO async download)
" TODO frozen plugins
function! vivid#upgrade(...) abort
    if empty(a:000)
        " Upgrade all plugins because none were specified
        for l:plugin in s:plugins
            call s:upgrade(l:plugin[0])
        endfor
    else
        " Upgrade specified plugins only
        for l:plugin in a:000
            call s:upgrade(l:plugin)
        endfor
    endif
    return
endfunction

function! s:upgrade(plugin) abort
    let l:echo_message = 'Vivid: Plugin upgrade -'
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
                echomsg l:echo_message 'Upgraded: ' s:plugins[l:index][0]
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
            call s:enable(l:plugin[0])
        endfor
    else
        " Enable specified plugins only
        for l:plugin in a:000
            call s:enable(l:plugin)
        endfor
    endif
    return
endfunction

function! s:enable(plugin, ...) abort
    let l:index = get(s:names, a:plugin, -1)
    if l:index != -1
        if !isdirectory(s:install_dir . '/' . s:plugins[l:index][2])
            call vivid#install(s:plugins[l:index][0])
        endif
        if s:plugins[l:index][3] == 0 || exists('a:1')
            let s:plugins[l:index][3] = 1
            silent execute 'packadd ' . s:plugins[l:index][2]
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
