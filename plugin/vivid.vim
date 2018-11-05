" ==============================================================================
" Name:         Vivid.vim
" Author:       Alex Vear
" HomePage:     https://github.com/axvr/Vivid.vim
" Licence:      MIT Licence
" ==============================================================================

command! -nargs=+ -bar Plugin call vivid#add(<args>)
command! -nargs=* -bar -complete=customlist,vivid#complete PluginInstall call vivid#install(<f-args>)
command! -nargs=* -bar -complete=customlist,vivid#complete PluginEnable  call vivid#enable(<f-args>)
command! -nargs=* -bar -complete=customlist,vivid#complete PluginUpdate  call vivid#update(<f-args>)
command! -nargs=* -bar -complete=customlist,vivid#complete PluginClean   call vivid#clean(<f-args>)

" vim: set et ts=4 sts=4 sw=4 tw=80 ft=vim ff=unix fenc=utf-8 :
