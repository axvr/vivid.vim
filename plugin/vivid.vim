" ==============================================================================
" Name:         Vivid.vim
" Author:       Alex Vear
" HomePage:     https://github.com/axvr/Vivid.vim
" Readme:       https://github.com/axvr/Vivid.vim/blob/master/README.md
" ==============================================================================

" TODO add completion for PluginInstall, PluginEnable & PluginUpdate
" TODO PluginClean

command! -nargs=+ -bar Plugin call vivid#add(<args>)

command! -nargs=* -bar -bang PluginInstall
            \ call s:install_validate('!' == '<bang>', <f-args>)

command! -nargs=* -bar -bang PluginEnable
            \ call s:enable_validate('!' == '<bang>', <f-args>)

command! -nargs=* -bar -bang PluginUpdate
            \ call s:update_validate('!' == '<bang>', <f-args>)

function! s:install_validate(bang, ...) abort
    if a:bang
        call vivid#install()
    elseif empty(a:000)
        echo 'No arguments given. To install all plugins run :PluginInstall!'
    else
        for l:plugin in a:000
            call vivid#install(l:plugin)
        endfor
    endif
endfunction

function! s:enable_validate(bang, ...) abort
    if a:bang
        call vivid#enable()
    elseif empty(a:000)
        echo 'No arguments given. To enable all plugins run :PluginEnable!'
    else
        for l:plugin in a:000
            call vivid#enable(l:plugin)
        endfor
    endif
endfunction

function! s:update_validate(bang, ...) abort
    if a:bang
        call vivid#update()
    elseif empty(a:000)
        echo 'No arguments given. To update all plugins run :PluginUpdate!'
    else
        for l:plugin in a:000
            call vivid#update(l:plugin)
        endfor
    endif
endfunction


" vim: set ts=4 sw=4 tw=80 et ft=vim fdm=marker fmr={{{,}}} :
