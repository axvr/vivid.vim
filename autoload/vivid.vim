" ==============================================================================
" Name:         Vivid.vim
" Author:       Alex Vear
" HomePage:     https://github.com/axvr/vivid.vim
" Licence:      MIT Licence
" ==============================================================================

" Prevent Vivid being loaded multiple times (and users can check if enabled)
if exists('g:loaded_vivid') || !has('packages') || &cp | finish | endif
let g:loaded_vivid = 1 | lockvar g:loaded_vivid

let s:plugins = {}
let s:plugin_defaults = { 'enabled': 0, 'name': '' }
lockvar s:plugin_defaults

let g:vivid_path = expand('<sfile>:p:h:h:h')
lockvar g:vivid_path

" Completion for Vivid commands
function! vivid#complete(...)
    return sort(filter(keys(s:plugins), 'stridx(v:val, a:1) == 0'))
endfunction

" Add a plugin for Vivid to manage
function! vivid#add(remote, ...) abort

    " Create dictionary to be added to s:plugins
    let l:new_plugin = copy(s:plugin_defaults)
    if !empty(a:000) && type(a:1) == v:t_dict
        call extend(l:new_plugin, a:1, 'force')
    endif

    " Create the remote address, if the shortened variant was provided
    if a:remote =~# '\m\C^[-A-Za-z0-9]\+\/[-._A-Za-z0-9]\+$'
        let l:new_plugin['remote'] = 'https://git::@github.com/' . a:remote
    elseif empty(a:remote)
        throw 'No remote address given'
    else
        let l:new_plugin['remote'] = a:remote
    endif

    " Generate a name if none was given
    let l:name = l:new_plugin['name']
    if l:name ==# ''
        let l:name = split(l:new_plugin['remote'], '/')
        let l:name = substitute(l:name[-1], '\m\C\.git$', '', '')
    endif

    if has_key(l:new_plugin, 'command')
        for l:cmd in l:new_plugin['command']
            execute 'command '.l:cmd.' :call vivid#enable("'.l:name.'") | silent! '.l:cmd
        endfor
    endif

    " Add the new plugin to the plugins dictionary
    if !has_key(s:plugins, l:name)
        let s:plugins[l:name] = l:new_plugin
    endif

    " Enable plugin (if auto-enable was selected)
    if l:new_plugin['enabled'] == 1
        let s:plugins[l:name]['enabled'] = 0
        call vivid#enable(l:name)
    endif

    return l:name

endfunction

" Allows the user to check if a plugin is enabled or not
" Returns: 1 == enabled, 0 == disabled or not managed by Vivid
function! vivid#enabled(plugin_name) abort
    return get(s:plugins, a:plugin_name, 0)['enabled']
endfunction

" Create a list of plugins to operate on
" --------------------------------------
" - If a list is given (and is not empty), a dictionary will be created
"   consisting of valid plugins based on the input list.
" - If no arguments are passed (or argument is an empty list), the function will
"   return the main plugin dictionary.
function! s:create_plugin_dict(...) abort
    if empty(a:000) || a:000 == [[]]
        return s:plugins
    elseif !empty(a:000) && type(a:1) == v:t_list
        return filter(copy(s:plugins), 'index(a:1, v:key) != -1')
    endif
endfunction

" Install plugins
function! vivid#install(...) abort
    for [l:plugin, l:data] in items(<SID>create_plugin_dict(a:000))
        let l:install_path = expand(g:vivid_path . '/' . l:plugin)

        if isdirectory(l:install_path)
            continue
        endif

        call system('git clone --recurse-submodules "'.l:data['remote'].'" "'.l:install_path.'"')

        if v:shell_error
            echohl ErrorMsg
            echomsg 'Install - Failed:   ' l:plugin
            echohl None
        else
            echomsg 'Install - Installed:' l:plugin
        endif
    endfor
endfunction

" Update plugins
function! vivid#update(...) abort
    for l:plugin in keys(<SID>create_plugin_dict(a:000))
        let l:plugin_location = expand(g:vivid_path . '/' . l:plugin)

        if !isdirectory(l:plugin_location)
            continue
        endif

        let l:output = system('git -C "'.l:plugin_location.'" pull --recurse-submodules')

        if v:shell_error
            echohl ErrorMsg
            echomsg 'Update  - Failed:   ' l:plugin
            echohl None
        elseif l:output =~# '\m\CAlready up[- ]to[- ]date\.'
            echomsg 'Update  - Latest:   ' l:plugin
        else
            echomsg 'Update  - Updated:  ' l:plugin
        endif
    endfor
endfunction

" Enable plugins
function! vivid#enable(...) abort
    for l:plugin in keys(<SID>create_plugin_dict(a:000))
        if s:plugins[l:plugin]['enabled'] == 0
            if !isdirectory(g:vivid_path . '/' . l:plugin)
                call vivid#install(l:plugin)
            endif

            let s:plugins[l:plugin]['enabled'] = 1
            silent execute 'packadd ' . l:plugin

            " Generate help tags
            let l:doc = expand(g:vivid_path . '/' . l:plugin . '/doc/')
            if isdirectory(l:doc)
                execute 'helptags ' . expand(l:doc)
            endif
        endif
    endfor
endfunction

" Create a list of all files in plugin directory to delete
function! s:create_file_list() abort
    let l:dirs = globpath(g:vivid_path, '*', 0, 1)
    return filter(l:dirs, {i, v -> !has_key(s:plugins, split(v, '/')[-1])})
endfunction

" Clean up unmanaged plugins from the plugin directory
function! vivid#clean(...) abort
    if empty(a:000) || a:000 == [[]]
        for l:file in <SID>create_file_list()
            call delete(expand(l:file), 'rf')
            echomsg 'Removed: ' l:file
        endfor
    else
        for l:plugin in keys(<SID>create_plugin_dict(a:000))
            let s:plugins[l:plugin]['enabled'] = 0
            call delete(expand(g:vivid_path . '/' . l:plugin), 'rf')
            echomsg 'Removed: ' l:plugin
        endfor
    endif
endfunction

call vivid#add('axvr/Vivid.vim', { 'enabled': 1 })
" vim: set et ts=4 sts=4 sw=4 tw=80 ft=vim ff=unix fenc=utf-8 :
