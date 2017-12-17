" ==============================================================================
" Name:         Vivid.vim
" Author:       Alex Vear
" HomePage:     https://github.com/axvr/Vivid.vim
" Version:      1.0.0
" Licence:      MIT Licence
" ==============================================================================

" TODO add extra safety using 'shellescape()'
" TODO add support for plugins which use git submodules
" TODO allow full install paths to be specified

" Prevent Vivid being loaded multiple times (and users can check if enabled)
if exists('g:loaded_vivid') || !has('packages') || &cp | finish | endif
let g:loaded_vivid = 1

" New central plugin store (dictionary contains a sub-dictionary)
let s:plugins = { 'Vivid.vim': {
            \ 'remote': 'https://git::@github.com/axvr/Vivid.vim.git',
            \ 'enabled': 1,
            \ }, }

" TODO Print more information to the user about updates, etc.
if !exists('g:vivid#verbose') | let g:vivid#verbose = 0 | endif

" Find Vivid install location (fast if nothing has been added to the 'rtp' yet)
let s:where_am_i = split(&runtimepath, ',')
for s:path in s:where_am_i
    if s:path =~# '.Vivid\.vim$'
        let s:install_location = substitute(s:path, '.Vivid\.vim', '', '')
        unlet s:path s:where_am_i
        break
    endif
endfor

function! s:check_system_compatibility()
    if !executable('git')
        echomsg 'Error: Git is not installed on this system.'
        finish
    endif
endfunction

" Completion for Vivid commands  TODO significantly improve this
function! vivid#complete(A,L,P)
    return sort(keys(s:plugins))
endfunction

" Generate helptags
function! s:gen_helptags(doc_location) abort
    if isdirectory(a:doc_location)
        execute 'helptags ' . a:doc_location
    endif
endfunction
call s:gen_helptags(expand(s:install_location . '/Vivid.vim/doc/'))

" Add a plugin for Vivid to manage {{{
" Example:
" call vivid#add('tpope/vim-fugitive', {
"     \ 'name': 'fugitive.vim',
"     \ 'enabled': 1,
"     \ } )
" Arguments: 'remote', { 'path': 'string', 'enabled': boolean }
function! vivid#add(remote, ...) abort

    " Create empty dictionary to be added to s:plugins
    let l:new_plugin = {}

    " Check the remote addresses are valid (mostly, can't check everything)
    " TODO add more sources
    if a:remote =~? '\m\C^https:\/\/.\+' || a:remote =~? '\m\C^http:\/\/.\+'
        let l:new_plugin['remote'] = a:remote
    elseif a:remote =~? '\m\C^.\+\/.\+'
        let l:new_plugin['remote'] = 'https://git::@github.com/' .
                    \ a:remote . '.git'
    else
        echomsg 'Vivid: Remote address creation fail:' a:remote
        return
    endif

    " Validate arguments given
    if !empty(a:000) && type(a:1) == v:t_dict
        let l:validate = 1
    else | let l:validate = 0
    endif

    " Generate the required local path if none were given
    if l:validate == 1 && has_key(a:1, 'name')
        let l:name = a:1['name']
    else
        let l:name = split(l:new_plugin['remote'], '/')
        let l:name = substitute(l:name[-1], '\m\C\.git$', '', '')
    endif

    " Merge the given dictionary to the calculated dictionary
    if l:validate == 1
        call extend(l:new_plugin, a:1)
    endif
    " Ensure 'enabled' is set to 0 so it can be enabled with low complexity
    let l:new_plugin['enabled'] = 0

    " Add the new plugin to the plugin dictionary
    if !has_key(s:plugins, l:name)
        let s:plugins[l:name] = l:new_plugin
    endif

    " Enable plugin (if auto-enable was selected)
    if l:validate == 1 && has_key(a:1, 'enabled') && a:1['enabled'] == 1
        call vivid#enable(l:name)
    endif

    return
endfunction  " }}}

" Allows the user to check if a plugin is enabled or not
" return values:  1 == enabled, 0 == disabled or not managed by Vivid
function! vivid#enabled(plugin_name) abort
    if has_key(s:plugins, a:plugin_name)
        return s:plugins[a:plugin_name]['enabled']
    else | return 0
    endif
endfunction

" Usage: let l:var = s:pick_a_dictionary(a:000)
function! s:pick_a_dictionary(...) abort
    if empty(a:000) || a:000 == [[]]
        return 's:plugins'
    elseif !empty(a:000) && type(a:1) == v:t_list
        let s:manipulate = {}
        for l:item in a:1
            if has_key(s:plugins, l:item) && !has_key(s:manipulate, l:item)
                let s:manipulate[l:item] = s:plugins[l:item]
            endif
        endfor
        return 's:manipulate'
    endif
endfunction

" Install plugins
function! vivid#install(...) abort
    call s:check_system_compatibility()
    let l:dict = s:pick_a_dictionary(a:000)
    for [l:plugin, l:data] in items({l:dict})
        let l:echo_message = 'Vivid: Plugin install -'
        let l:install_path = expand(s:install_location . '/' . l:plugin)
        if !isdirectory(l:install_path)
            let l:cmd = 'git clone --recurse-submodules ' . 
                        \ l:data['remote'] . ' ' . l:install_path
            let l:output = system(l:cmd)
            if l:output =~# '\m\C^Cloning into ' || l:output =~# ''
                echomsg l:echo_message 'Installed:' l:plugin
            else
                echomsg l:echo_message 'Failed:   ' l:plugin
            endif
        else
            echomsg l:echo_message     'Skipped:  ' l:plugin
        endif
    endfor
endfunction

" Update plugins
function! vivid#update(...) abort
    call s:check_system_compatibility()
    let l:dict = s:pick_a_dictionary(a:000)
    for l:plugin in keys({l:dict})
        let l:echo_message = 'Vivid: Plugin update  -'
        let l:plugin_location = expand(s:install_location . '/' . l:plugin)
        let l:cmd = 'git -C ' . l:plugin_location . ' pull --recurse-submodules'
        let l:output = system(l:cmd)

        if l:output =~# '\m\CAlready up-to-date\.' ||
                    \ l:output =~# '\m\CAlready up to date\.'
            echomsg l:echo_message     'Latest:   ' l:plugin
        else
            let l:output = split(l:output)
            if l:output[0] =~# '\m\C^From$'
                echomsg l:echo_message 'Updated:  ' l:plugin
            else
                echomsg l:echo_message 'Failed:   ' l:plugin
            endif
        endif
    endfor
endfunction

" Enable plugins
function! vivid#enable(...) abort
    let l:dict = s:pick_a_dictionary(a:000)
    for l:plugin in keys({l:dict})
        if s:plugins[l:plugin]['enabled'] == 0
            if !isdirectory(s:install_location . '/' . l:plugin)
                call vivid#install(l:plugin)
            endif
            let s:plugins[l:plugin]['enabled'] = 1
            silent execute 'packadd ' . l:plugin
            let l:doc = expand(s:install_location . '/' . l:plugin . '/doc/')
            call s:gen_helptags(l:doc)
        endif
    endfor
    return
endfunction

" TODO Create a list of all dirs
function! s:list_all_files(...) abort
    if has('win64') || has('win32') || has('win16')
        execute 'dir /b ' . s:install_location
    elseif has('unix')
        " TODO  ^check this
        " FIXME (create full 'ls' command)
        execute 'ls ' .s:install_location
    endif
endfunction

" Clean unused plugins
function! vivid#clean(...) abort
    if empty(a:000) || a:000 == [[]]
        " TODO Find dirs which are not managed plugins and remove them
        echomsg 'This feature has not been implemented yet'
    else
        let l:dict = s:pick_a_dictionary(a:000)
        for l:plugin in keys({l:dict})
            call delete(expand(s:install_location . '/' . l:plugin), 'rf')
            let s:plugins[l:plugin]['enabled'] = 0
            echomsg 'Vivid: Plugin clean   - Deleted:  ' l:plugin
        endfor
    endif
endfunction


" vim: set ts=4 sw=4 tw=80 et ft=vim fdm=marker fmr={{{,}}} :
