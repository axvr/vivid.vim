# Vivid.vim

**Vivid is a Vim plugin management solution; designed to work with, not against
Vim.**

<!-- Badges made using https://shields.io/ -->
[![Version Badge](https://img.shields.io/badge/Version-v1.0.0--alpha.3-brightgreen.svg)](https://github.com/axvr/Vivid.vim/releases)
[![Licence Badge](https://img.shields.io/badge/Licence-MIT-blue.svg)](https://github.com/axvr/Vivid.vim/blob/master/LICENCE)


## About Vivid

**Vivid is a [Vim] plugin manager** built to be minimal, fast and efficient.
Vivid is designed to allow Vim users to fine tune exactly when their plugins are
loaded into Vim. The user is encouraged to use the tools provided by Vivid to
define custom rules for managing their plugins, whilst keeping the process as
simple as possible.

**Designed to be extensible**, additional plugins can be added to change the
default behaviour of Vivid, or add additional features and tools (**WIP**).

**Vivid can be integrated into other plugins**, through the "*Vivid Layer
Framework*" (**WIP**). This allows the creation of more powerful and faster
plugins, with much simpler implementation. The *VLF* essentially allows plugins
to manage other plugins, independent of what plugin manager the user chose to
use. This is possible with very little overhead because of its sheer speed, and
tiny size.


---

![Vivid Updating Plugins](https://github.com/axvr/codedump/raw/master/project-assets/Vivid.vim/vivid-update.png)

---


## Quick Start

See the [Vivid wiki] for more information, examples and the [FAQ].

### [Dependencies](https://github.com/axvr/Vivid.vim/wiki/Installing-Vivid#what-dependencies-does-vivid-require)

Vivid requires that the [Git](https://git-scm.com) VCS is installed on your
system, and [Vim] \(8.0+\) or [Neovim](https://neovim.io).

**NOTE**: Vivid only works with Git managed plugins. If you must have support
for other VCSs and archives feel free to create an extension to add these
features to Vivid.


### [Install Vivid](https://github.com/axvr/Vivid.vim/wiki/Installing-Vivid#how-do-i-install-vivid)

To install Vivid on Vim run this command in a terminal emulator:

```sh
git clone https://github.com/axvr/Vivid.vim ~/.vim/pack/vivid/opt/Vivid.vim
```

Then to enable Vivid place `packadd Vivid.vim` in your Vim config (before any
plugin definitions). It's that easy no other boilerplate code is required.

**NOTE**: For Microsoft Windows you may have to modify the `packpath` option so
that Vim can find Vivid. See `:h 'packpath'`.


### [Using Vivid]

By default Vivid will not enable any plugins, this is because of it's heavy
focus on lazy loading. However this behaviour can be reversed by including
`PluginEnable` after adding all of the plugins to Vivid, but this is
discouraged.

**NOTE**: When using Vivid, avoid using the `packloadall` or `packadd` commands
on any plugin that is being managed. The exception is the `packadd Vivid.vim`
before any plugin config.

#### [Adding Plugins]

To add plugins for Vivid to manage, use the `Plugin` command (or `vivid#add`
function). Vivid provides options which can be set when adding plugins. For info
on how to use these options see the "[Adding Plugins]" section of the Wiki.

```vim
packadd Vivid.vim  " Required

" Examples of adding plugins to Vivid
Plugin 'tpope/vim-fugitive'                     " Simplified GitHub address
Plugin 'https://github.com/tpope/vim-fugitive'  " Using full remote address to plugin
Plugin 'tpope/vim-fugitive', { 'enabled': 1 }   " Add and enable plugin by default
```


#### [Installing Plugins](https://github.com/axvr/Vivid.vim/wiki/Managing-Plugins#installing-plugins)

Vivid follows the "Do what I mean" approach (similar to
[Perl](https://www.perl.org)). This means that when you enable a plugin, Vivid
assumes that you want that plugin enabled, despite whether it is installed or
not. So Vivid will install the plugin automatically then enable it.

The install of plugins can also be done manually through the use of the
`PluginInstall` command (or `vivid#install` function).

```vim
" To install only the vim-fugitive and committia plugins
:PluginInstall vim-fugitive committia.vim

" To install all plugins
:PluginInstall
```


#### [Updating Plugins](https://github.com/axvr/Vivid.vim/wiki/Managing-Plugins#updating-plugins)

Plugins can be updated by Vivid. This is done by using the `PluginUpdate`
command (or the `vivid#update` function).

```vim
" Update only specified plugins
:PluginUpdate vim-fugitive committia.vim

" Update all plugins
:PluginUpdate
```


#### [Enabling Plugins]

The biggest feature of Vivid is the "lazy loading" controls it provides, which
surprisingly is not that many.

As you may already know, by default Vivid loads no plugins, and encourages the
user to write their own custom rules for when plugins should be enabled. Vivid
provides a simple command and function which can be used to create these rules.

The command:

```vim
" Enable specified plugins: vim-fugitive and committia
:PluginEnable vim-fugitive committia.vim

" Enable all plugins (Vundle like behaviour)
:PluginEnable
```

The function:

```vim
" Enable specified plugins: vim-fugitive and committia
:call vivid#enable('vim-fugitive', 'committia.vim')

" Enable all plugins (Vundle like behaviour)
:call vivid#enable()
```

This is an example of a possible use case in a vimrc:

```vim
augroup clang
    autocmd!
    " Automatically enable clang specific plugins when in a clang file
    autocmd FileType c,h,cpp,hpp,cc,objc call vivid#enable('vim-clang-format', 'vim-cpp-enhanced-highlight')
augroup END
```


#### Check Plugin Status

Vivid allows you to write complex scripts in your `$MYVIMRC`, one of the
features it provides is checking whether a plugin is enabled or not. The simple
feature opens many possibilities, such as commands are mapped when the plugin is
enabled, or a different config and plugins in Neovim than in Vim when using the
same configuration file.

This is a much needed feature as not all plugins set the `g:loaded_plugin_name`
variable.

The function is `vivid#enabled('plugin-name-here')`, and it takes only one
argument, the name of the plugin to check the status of.

Outputs from this function are as follows:
* `0` : Disabled or not added for Vivid to manage
* `1` : Enabled

Example of plugin status checking in a vimrc

```vim
" Add Git branch to Vim statusline if vim-fugitive is on and
" is in a git controlled repo to avoid any errors
function! GitBranch() abort
    if vivid#enabled('vim-fugitive') && fugitive#head() != ''
        return '  ' . fugitive#head() . ' '
    else | return ''
    endif
endfunction
set statusline=%#LineNr#%{GitBranch()}   " Git branch name
```


#### Clean Plugins

*This feature is currently a work in progress*


<!-- Links -->

[Vim]:https://www.vim.org
[Vivid wiki]:https://github.com/axvr/Vivid.vim/wiki
[Using Vivid]:https://github.com/axvr/Vivid.vim/wiki/Managing-Plugins
[Adding Plugins]:https://github.com/axvr/Vivid.vim/wiki/Managing-Plugins#adding-plugins-to-manage
[Enabling Plugins]:https://github.com/axvr/Vivid.vim/wiki/Managing-Plugins#enabling-plugins
[FAQ]:https://github.com/axvr/Vivid.vim/wiki/FAQ
[Vivid's origins]:https://github.com/axvr/Vivid-Legacy.vim
[Vundle]:https://github.com/VundleVim/Vundle.vim

