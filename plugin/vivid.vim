" ==============================================================================
" Name:         Vivid.vim
" Author:       Alex Vear
" HomePage:     https://github.com/axvr/Vivid.vim
" Readme:       https://github.com/axvr/Vivid.vim/blob/master/README.md
" ==============================================================================

command! -nargs=+ -bar Plugin
            \ call vivid#add(<args>)

" TODO add completion
command! -nargs=* -bang PluginInstall
            \ call s:install_validate('!' == '<bang>', <f-args>)


function! s:install_validate(bang, ...)
    if a:bang
        call vivid#install()
    elseif a:0 == 0
        echo "No arguments given"
    else
        for l:plugin in a:000
            call vivid#install(l:plugin)
        endfor
    endif
endfunction


" TODO add completion
command! -nargs=* -bang PluginEnable
            \ call s:enable_validate('!' == '<bang>', <f-args>)


function! s:enable_validate(bang, ...)
    if a:bang
        call vivid#enable()
    elseif a:0 == 0
        echo "No arguments given"
    else
        for l:plugin in a:000
            call vivid#enable(l:plugin)
        endfor
    endif
endfunction


" TODO PluginClean, PluginUpgrade


" vim: set ts=4 sw=4 tw=80 et :
