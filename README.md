# Vivid.vim

**Vivid is a Vim plugin management solution; designed to work with, not against Vim.**

<!-- Badges made using https://shields.io/ -->
[![Version Badge](https://img.shields.io/badge/Version-v1.0.0-brightgreen.svg)](https://github.com/axvr/Vivid.vim/releases)
[![Licence Badge](https://img.shields.io/badge/Licence-MIT-blue.svg)](https://github.com/axvr/Vivid.vim/blob/master/LICENCE)


[Vivid] is designed to allow [Vim] power users to fine tune exactly when their plugins are loaded into Vim. By default all plugins are disabled; the user can create their own conditions and rules to enable the plugins directly from their ```$MYVIMRC``` file.


## About

[Vivid] aims to give control to [Vim] user's plugin management, allowing users to manage as much or as little of their plugins as they wish. Vivid is also designed to be fast, minimal & efficient.


[Vivid] allows you to:

* Install plugins
* Update plugins
* Enable plugins
* Auto-enable plugins
* Check if a plugin is enabled

Planned features:

* Remove unused plugins
* Auto generates [help tags] for each plugins


---


![Vivid Upgrading Plugins](screenshots/vivid-upgrade.png)


---


## Quick Start

### Dependencies

[Vivid] requires that the [Git] VCS is installed on your system, including [Vim] (8.0+) or [Neovim].

NOTE: Vivid currently does not fully work on Windows, compatibility for it is planned.

NOTE: Vivid currently only works with Git managed plugins.

### Install Vivid

To install Vivid on Vim run this command in a terminal emulator:

```sh
git clone https://github.com/axvr/Vivid.vim ~/.vim/pack/vivid/opt/Vivid.vim
```

To install Vivid on Neovim run this command:

```sh
git clone https://github.com/axvr/Vivid.vim ~/.config/nvim/pack/vivid/opt/Vivid.vim
```

Then to enable Vivid place ``packadd Vivid.vim`` at the top of your ``$MYVIMRC`` file.


### Using Vivid

To enable Vivid the line ``packadd Vivid.vim`` must be added to the top of your ``$MYVIMRC``.

By default Vivid enables no plugins, this is because of it's heavy focus on lazy loading and control. This behaviour can be reversed by including `call vivid#enable()` after adding all of the plugins to Vivid.

NOTE: When using Vivid, never use the ``packloadall`` or the ``packadd`` on any plugin that Vivid is managing. Using these commands will cause Vivid to break. The exception is the ``packadd Vivid.vim`` at the beginning of the ``$MYVIMRC``.

#### Adding Plugins

Vivid will manage any plugins which are defined using the ``vivid#add`` function. Vivid provides many options when adding plugins.

```vim
packadd Vivid.vim " Required

" Examples of adding plugins to Vivid
call vivid#add('rhysd/clever-f.vim') " Simple adding from GitHub (same as Vundle and Vim-Plug)
call vivid#add('https://github.com/rhysd/clever-f.vim') " Using full remote address to plugin
call vivid#add('tpope/vim-fugitive', { 'enabled': 1, }) " Add and enable plugin by default
call vivid#add('rhysd/clever-f.vim', { " Other options to provide to Vivid
        \ 'name': 'Clever-f',          " Change the name to use to refer to the pluguin
        \ 'path': 'clever-f.vim.git',  " Change the folder the plugin is in to avoid nameing collisions
        \ 'enabled': 1,                " Auto-enable plugin
        })
```

#### Installing Plugins

Vivid allows you to install plugins so you don't have to install them your self. The ``vivid#install()`` function can be used in two different ways. By providing no arguments to the install function, Vivid will install all Plugins which were added to Vivid. The other way is to provide arguments for the install function (plugin names) and Vivid will install only those plugins. e.g. ``call vivid#install('plugin-name-one', 'plugin-name-two')``

If a plugin is enabled which is not installed, Vivid will automatically install that plugin.

Sometimes a plugin may break, sometimes due user fiddling or even broken Git history. To fix this problem use the ``vivid#clean`` function and provide it the name of the plugin. This will remove all of the plugin information. After doing this install the plugin again.


#### Upgrading Plugins

* Upgrading plugins: `call vivid#upgrade()`, `PluginUpgrade`

#### Enabling Plugins

* Enable plugins: `call vivid#enable()`, `PluginEnable`

#### Check Plugin Status

Vivid allows you to write complex scripts in your ``$MYVIMRC``, one of the features it provides is checking whether a plugin is enabled or not. The simple feature opens many possibilities, such as commands are mapped when the plugin is enabled, or a different config and plugins in Neovim than in Vim when using the same configuration file.

The function is ``vivid#enabled('plugin-name-here')``, and it takes one argument, the name of the plugin to check the status of.

Outputs from this function are as follows:
* `0` : Disabled
* `1` : Enabled
* `-1` : Error (possibly incorrect name, or other reasons)


#### Clean Plugins

*Pending*

<!--
## Example Vim Config

```vim
" Example Vim Config File ($MYVIMRC)
" ==================================

packadd Vivid.vim   " Required

" Code formatting
call vivid#add('rhysd/vim-clang-format')         " Format files using Clang

" Vim enhancements
call vivid#add('rhysd/clever-f.vim',   { 'enabled': 1, })
call vivid#add('jiangmiao/auto-pairs', { 'enabled': 1, }) " Smart brackets and quotes
if has('nvim')
    call vivid#add('majutsushi/tagbar')    " Display Tags of a File Easily     <- :help tagbar
endif

augroup clang
    au!
    autocmd FileType c,h,cpp,hpp,cc,objc
            \ call vivid#enable('vim-clang-format') 
    if vivid#enabled('vim-clang-format') == 1
        autocmd FileType c,h,cpp,hpp,cc,objc
                \ nnoremap <buffer><Leader>cf :<C-u>ClangFormat<CR>
        autocmd FileType c,h,cpp,hpp,cc,objc
                \ vnoremap <buffer><Leader>cf :ClangFormat<CR>

        " Clang Format Config
        " TODO Java, JavaScript, Obj-C, C
        autocmd FileType c,h,cpp,hpp,cc,objc
                \ let g:clang_format#code_style = 'google'
        autocmd FileType c,h,cpp,hpp,cc,objc
                \ let g:clang_format#detect_style_file = 1
    endif

augroup END

" Clever-f Config
let g:clever_f_smart_case = 1
let g:clever_f_across_no_line = 1
```
-->

[Vivid]:https://github.com/axvr/Vivid.vim
[Git]:http://git-scm.com
[Vim]:http://www.vim.org
[Neovim]:https://neovim.io
[runtime path]:http://vimdoc.sourceforge.net/htmldoc/options.html#%27runtimepath%27
[help tags]:http://vimdoc.sourceforge.net/htmldoc/helphelp.html#:helptags


