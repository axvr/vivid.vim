# Vivid.vim

**Vivid is a Vim plugin management solution; designed to work with, not against
Vim.**

<!-- Badges made using https://shields.io/ -->
[![Version Badge](https://img.shields.io/badge/Version-v1.0.0--rc.1-brightgreen.svg)](https://github.com/axvr/Vivid.vim/releases)
[![Licence Badge](https://img.shields.io/badge/Licence-MIT-blue.svg)](https://github.com/axvr/Vivid.vim/blob/master/LICENCE)


## About Vivid

**Vivid is a [Vim] plugin manager** built to be minimal, fast and efficient.
Vivid is designed to allow Vim users to fine tune exactly when their plugins are
loaded into Vim. The user is encouraged to use the tools provided by Vivid to
define custom rules for managing their plugins, whilst keeping the process as
simple as possible.

**Designed to be [extensible]()**, additional plugins can be added to change the
default behaviour of Vivid, or add additional features and tools (**WIP**).

**Vivid can be integrated into other plugins**, through the "[*Vivid Layer
Framework*]()" (**WIP**). This allows the creation of more powerful and faster
plugins, with much simpler implementation. The *VLF* essentially allows plugins
to manage other plugins, independent of what plugin manager the user chose to
use. This is possible with very little overhead because of its sheer speed, and
tiny size.


---

![Vivid Updating Plugins](https://github.com/axvr/codedump/raw/master/project-assets/Vivid.vim/vivid-update.png)

---


## Quick Start

See the [Vivid wiki] for more information, examples and the
[FAQ](https://github.com/axvr/Vivid.vim/wiki/FAQ). For convenience the titles of
each section below contain links to the relevant wiki sections.

### [Dependencies](https://github.com/axvr/Vivid.vim/wiki/Installing-Vivid#required-dependencies)

Vivid requires that the [Git](https://git-scm.com) VCS is installed on your
system, and [Vim] \(8.0+\) or [Neovim](https://neovim.io).

**NOTE**: Vivid only works with Git managed plugins. If you must have support
for other VCSs and archives feel free to create an extension to add these
features to Vivid.


### [Install Vivid](https://github.com/axvr/Vivid.vim/wiki/Installing-Vivid#how-to-install-vivid)

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


#### [Adding Plugins](https://github.com/axvr/Vivid.vim/wiki/Managing-Plugins#adding-plugins)

To add plugins for Vivid to manage, use the `Plugin` command (or `vivid#add`
function). Vivid provides options which can be set when adding plugins. For info
on how to use these options refer to the "[Plugin
Options](https://github.com/axvr/Vivid.vim/wiki/Managing-Plugins#plugin-options)"
section of the Wiki.

```vim
packadd Vivid.vim  " Required

" Examples of adding plugins to Vivid
Plugin 'tpope/vim-fugitive'                     " Simplified GitHub address
Plugin 'https://github.com/tpope/vim-fugitive'  " Using full remote address to plugin
Plugin 'tpope/vim-fugitive', { 'enabled': 1 }   " Add and enable plugin by default
```


#### [Installing Plugins](https://github.com/axvr/Vivid.vim/wiki/Managing-Plugins#installing-plugins)

<!-- TODO maybe mention the "Principle of least astonishment" -->
Vivid applies a "[Do What I Mean](https://en.wikipedia.org/wiki/DWIM)" approach
to plugin management. This means that when you enable a plugin, Vivid assumes
that you want that plugin enabled, despite whether it has actually been
installed. So when a plugin is enabled, Vivid will automatically install (if it
hasn't already), then it will preceed to enable it.

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

Obviously Vivid (with its lazy loading defaults), would have to provide a way
for the user to enable their plugins. A simple interface is provided for this,
as the `PluginEnable` command (and `vivid#enable` function).

For additional information on enabling plugins (and extra examples), check out
the "[Enabling Plugins]" section of the [Vivid wiki].

```vim
" Enable specified plugins: vim-fugitive and committia
:PluginEnable vim-fugitive committia.vim

" Enable all plugins (Not recommended)
:PluginEnable
```

This is an example of a possible use case, for TypeScript development:

```vim
Plugin 'leafgarland/typescript-vim'
Plugin 'Quramy/tsuquyomi'

autocmd! FileType typescript call vivid#enable('typescript-vim', 'tsuquyomi')
autocmd! BufRead,BufNewFile *.ts setlocal filetype=typescript
```


#### [Check Plugin Status](https://github.com/axvr/Vivid.vim/wiki/Managing-Plugins#check-plugin-status)

Sometimes it is useful to check whether a plugin has been enabled, but the
problem is that not every plugin sets a `g:loaded_plugin_name` variable. Because
of this Vivid provides a simple function to query the status of a plugin.

The function is `vivid#enabled`, and it takes only one argument, the name of the
plugin to check the status of. This function returns a boolean result. `0`:
Disabled or not managed, and `1`: Enabled.

Example use case of configuring the git commit window:

```vim
Plugin 'rhysd/committia.vim'

function! s:configure_committia() abort
    if vivid#enabled('committia.vim') &&
                \ expand('%:t') =~# '\m\C__committia_\(diff\|status\)__'
        setlocal nocursorline colorcolumn=
    endif
endfunction

autocmd BufReadPre COMMIT_EDITMSG call vivid#enable('committia.vim')
autocmd FileType diff,gitcommit call <SID>configure_committia()
```


#### [Cleaning Plugins](https://github.com/axvr/Vivid.vim/wiki/Managing-Plugins#cleaning-plugins)

By making use of the `PluginClean` command (or `vivid#clean` function), it is
possible to remove in use plugins and remove all of the unused plugins. from the
plugin directory on yor system.

```vim
" Remove all unmanaged plugins
:PluginClean

" Delete specific managed plugins
:PluginClean vim-fugitive committia.vim
```


<!-- Links -->

[Vim]:https://www.vim.org
[Vivid wiki]:https://github.com/axvr/Vivid.vim/wiki
[Using Vivid]:https://github.com/axvr/Vivid.vim/wiki/Managing-Plugins
[Enabling Plugins]:https://github.com/axvr/Vivid.vim/wiki/Managing-Plugins#enabling-plugins
