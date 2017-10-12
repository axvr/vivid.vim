" ==============================================================================
" Name:         Vivid.vim
" Author:       Alex Vear
" HomePage:     https://github.com/axvr/Vivid.vim
" Version:      1.0.0
" ==============================================================================

" TODO allow extensions for Vivid (e.g. add async, etc.)
" FIXME make DOS compatible (:h dos  :h shellescape())
" TODO provide compatiblilty with systems without the package feature
" TODO plugins using submodules support
" TODO allow full install paths to be specified

" Prevent Vivid being loaded multiple times (and users can check if enabled)
if exists('g:loaded_vivid') || !has('packages') || &cp | finish | endif
let g:loaded_vivid = 1

" New central plugin store (dictionary contains a sub-dictionary)
" TODO add more options
let s:plugins = { 'Vivid.vim': {
            \ 'remote': 'https://git::@github.com/axvr/Vivid.vim.git',
            \ 'enabled': 1,
            \ }, }

" Print more information to the user about updates, etc.
if !exists('g:vivid#verbose')   | let g:vivid#verbose = 0   | endif

" Find Vivid install location (fast if nothing has been added to the 'rtp' yet)
let s:where_am_i = split(&runtimepath, ',')
for s:path in s:where_am_i
    if s:path =~# '.Vivid\.vim$'
        let s:install_location = substitute(s:path, '.Vivid\.vim', '', '')
        unlet s:path s:where_am_i
        break
    endif
endfor

" Completion for Vivid commands  TODO significantly improve this
function! vivid#complete(A,L,P)
    return sort(keys(s:plugins))
endfunction

" Generate helptags FIXME needs optimising, adapting & improving
function! s:gen_helptags(doc) abort
    if isdirectory(a:doc)
        execute 'helptags ' . a:doc
    endif
endfunction
call s:gen_helptags(expand(s:install_location . '/Vivid.vim/doc/'))
" FIXME ^ dos compatible and optimise

" Add a plugin for Vivid to manage {{{
" Example:
" call vivid#add('tpope/vim-fugitive', {
"     \ 'path': 'fugitive.vim',
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
        let l:new_plugin['remote'] = 'https://git::@github.com/' . a:remote . '.git'
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
    if l:validate == 1 && has_key(a:1, 'path')
        let l:path = a:1['path']
    else
        let l:path = split(l:new_plugin['remote'], '/')
        let l:path = substitute(l:path[-1], '\m\C\.git$', '', '')
    endif

    " Merge the given dictionary to the calculated dictionary
    if l:validate == 1
        call extend(l:new_plugin, a:1)
    endif
    " Ensure 'enabled' is set to 0 so it can be enabled with low complexity
    let l:new_plugin['enabled'] = 0

    " Add the new plugin to the plugin dictionary
    if !has_key(s:plugins, l:path)
        let s:plugins[l:path] = l:new_plugin
    endif

    " Enable plugin (if auto-enable was selected)
    if l:validate == 1 && has_key(a:1, 'enabled') && a:1['enabled'] == 1
        call vivid#enable(l:path)
    endif

    return
endfunction  " }}}

" Allows the user to check if a plugin is enabled or not
" return values:  1 == enabled, 0 == disabled or not managed by Vivid
function! vivid#enabled(plugin_path) abort
    if has_key(s:plugins, a:plugin_path)
        return s:plugins[a:plugin_path]['enabled']
    else | return 0
    endif
endfunction

" Usage: let l:var = s:pick_a_dictionary(a:000)
function! s:pick_a_dictionary(...) abort
    if empty(a:000) || a:000 == [[]]
        return 's:plugins'
    else
        let s:manipulate = {}
        for l:item in a:1  " TODO validate a:1
            if has_key(s:plugins, l:item) && !has_key(s:manipulate, l:item)
                let s:manipulate[l:item] = s:plugins[l:item]
            endif
        endfor
        return 's:manipulate'
    endif
endfunction

" Install plugins
function! vivid#install(...) abort
    let l:dict = s:pick_a_dictionary(a:000)
    for [l:key, l:value] in items({l:dict})
        let l:echo_message = 'Vivid: Plugin install -'
        let l:install_path = expand(s:install_location . '/' . l:key)
        if !isdirectory(l:install_path)
            let l:cmd = 'git clone ' . l:value['remote'] . ' ' . l:install_path
            let l:output = system(l:cmd)
            if l:output =~# '\m\C^Cloning into '  " TODO check clone message
                echomsg l:echo_message 'Installed:' l:key
            else
                echomsg l:echo_message 'Failed:   ' l:key
            endif
        else
            echomsg l:echo_message     'Skipped:  ' l:key
        endif
    endfor
endfunction

" Update plugins
function! vivid#update(...) abort
    let l:dict = s:pick_a_dictionary(a:000)
    for l:key in keys({l:dict})
        let l:echo_message = 'Vivid: Plugin update  -'
        let l:plugin_location = expand(s:install_location . '/' . l:key)
        let l:cmd = 'git -C ' . l:plugin_location . ' pull'
        let l:output = system(l:cmd)

        if l:output =~# '\m\CAlready up-to-date\.'
            echomsg l:echo_message     'Latest:   ' l:key
        else
            let l:output = split(l:output)
            if l:output[0] =~# '\m\C^From$'
                echomsg l:echo_message 'Updated:  ' l:key
            else
                echomsg l:echo_message 'Failed:   ' l:key
            endif
        endif
    endfor
endfunction

" Enable plugins
function! vivid#enable(...) abort
    let l:dict = s:pick_a_dictionary(a:000)
    for l:key in keys({l:dict})
        if {l:dict}[l:key]['enabled'] == 0
            if !isdirectory(s:install_location . '/' . l:key)
                call vivid#install(l:key)
            endif
            let s:plugins[l:key]['enabled'] = 1
            silent execute 'packadd ' . l:key
            let l:doc = expand(s:install_location . '/' . l:key . '/doc/')
            call s:gen_helptags(l:doc)
        endif
    endfor
    return
endfunction

" TODO Clean unused plugins
"function! vivid#clean(...) abort
"    let l:dict = s:pick_a_dictionary(a:000)
"    for [l:key, l:value] in items({l:dict})
"        " Do things
"    endfor
"endfunction


" vim: set ts=4 sw=4 tw=80 et ft=vim fdm=marker fmr={{{,}}} :
