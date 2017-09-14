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
* Auto generates [help tags] for each plugins

Planned features:

* Remove unused plugins
* Async upgrade and install of plugins
* Windows support
* Local plugin repositories (file://)
* Freeze plugins to a specific version or commit
* Upgrade by tags
* Upgrade from a chosen branch
* Vim help doc (similar to the [Vivid wiki])


---


![Vivid Upgrading Plugins](screenshots/vivid-upgrade.png)


---


## Quick Start

See the [Vivid wiki] for more information, examples and a [FAQ].

### [Dependencies](https://github.com/axvr/Vivid.vim/wiki/Installing-Vivid#what-dependencies-does-vivid-require)

[Vivid] requires that the [Git] VCS is installed on your system, including [Vim] (8.0+) or [Neovim].

NOTE: Vivid only works with Git managed plugins.


### [Install Vivid]

To install Vivid on Vim run this command in a terminal emulator:

```bash
git clone https://github.com/axvr/Vivid.vim ~/.vim/pack/vivid/opt/Vivid.vim
```

Alternatively, you can install Vivid for Neovim by running this command:

```bash
git clone https://github.com/axvr/Vivid.vim ~/.config/nvim/pack/vivid/opt/Vivid.vim
```

Then to enable Vivid place ``packadd Vivid.vim`` at the top of your ``$MYVIMRC`` file. No other boilerplate code is required in your Vim config.


### [Using Vivid]

To enable Vivid the line `packadd Vivid.vim` must be added to your `$MYVIMRC` before any plugin definitions or plugin settings.

By default Vivid enables no plugins, this is because of it's heavy focus on lazy loading and control. This behaviour can be reversed by including `call vivid#enable()` or `PluginEnable!` after adding all of the plugins to Vivid.

NOTE: When using Vivid, never use the ``packloadall`` or the ``packadd`` on any plugin that Vivid is managing. Using these commands will cause Vivid to break for that session. The exception is the ``packadd Vivid.vim`` before any plugin config.

#### Adding Plugins

Vivid will manage any plugins which are defined using the ``vivid#add`` function, or the `Plugin` command. Vivid provides many options when adding plugins. The commands are based off of the [Vundle] commands (where [Vivid's origins] are)

```vim
packadd Vivid.vim " Required

" Examples of adding plugins to Vivid (using the function)
call vivid#add('tpope/vim-fugitive')            " Simple adding from GitHub (same as Vundle and Vim-Plug)
call vivid#add('https://github.com/tpope/vim-fugitive') " Using full remote address to plugin
call vivid#add('tpope/vim-fugitive', { 'enabled': 1, }) " Add and enable plugin by default
call vivid#add('tpope/vim-fugitive', {          " Other options to provide to Vivid
        \ 'name': 'Fugitive',                   " Change the name to use to refer to the pluguin
        \ 'path': 'fugitive.vim',               " Change the folder the plugin is in to avoid nameing collisions
        \ 'enabled': 1,                         " Auto-enable plugin, can be set to 1 or 0, the default is 0
        })


" Examples of adding plugins to Vivid (using the command)
Plugin 'tpope/vim-fugitive'                     " Simple adding from GitHub (same as Vundle and Vim-Plug)
Plugin 'https://github.com/tpope/vim-fugitive'  " Using full remote address to plugin
Plugin 'tpope/vim-fugitive', { 'enabled': 1, }  " Add and enable plugin by default
Plugin 'tpope/vim-fugitive', {                  " Other options to provide to Vivid
        \ 'name': 'Fugitive',                   " Change the name to use to refer to the pluguin
        \ 'path': 'fugitive.vim',               " Change the folder the plugin is in to avoid nameing collisions
        \ 'enabled': 1,                         " Auto-enable plugin, can be set to 1 or 0, the default is 0
        }
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
* `0` : Disabled or not added for Vivid to manage
* `1` : Enabled


#### Clean Plugins

*This feature is currently a work in progress*


<!-- Links -->

[Vivid]:https://github.com/axvr/Vivid.vim
[Git]:http://git-scm.com
[Vim]:http://www.vim.org
[Neovim]:https://neovim.io
[runtime path]:http://vimdoc.sourceforge.net/htmldoc/options.html#%27runtimepath%27
[help tags]:http://vimdoc.sourceforge.net/htmldoc/helphelp.html#:helptags
[Vivid wiki]:https://github.com/axvr/Vivid.vim/wiki
[Dependencies]:https://github.com/axvr/Vivid.vim/wiki/Installing-Vivid#what-dependencies-does-vivid-require
[Install Vivid]:https://github.com/axvr/Vivid.vim/wiki/Installing-Vivid#how-do-i-install-vivid
[Using Vivid]:https://github.com/axvr/Vivid.vim/wiki/Managing-Plugins
[FAQ]:https://github.com/axvr/Vivid.vim/wiki/FAQ
[Vivid's origins]:https://github.com/axvr/Vivid-Legacy.vim
[Vundle]:https://github.com/VundleVim/Vundle.vim

