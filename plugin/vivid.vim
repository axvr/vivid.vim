" ==============================================================================
" Name:         Vivid.vim
" Author:       Alex Vear
" HomePage:     https://github.com/axvr/Vivid.vim
" Licence:      MIT Licence
" ==============================================================================

command! -nargs=+ -bar Plugin call vivid#add(<args>)

command! -nargs=* -bar -bang -complete=customlist,vivid#complete PluginInstall
            \ call vivid#install(<f-args>)

command! -nargs=* -bar -bang -complete=customlist,vivid#complete PluginEnable
            \ call vivid#enable(<f-args>)

command! -nargs=* -bar -bang -complete=customlist,vivid#complete PluginUpdate
            \ call vivid#update(<f-args>)


" vim: set ts=4 sw=4 tw=80 et ft=vim fdm=marker fmr={{{,}}} :
