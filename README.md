# Vivid.vim

**Vivid is a Vim plugin management solution; designed to work with, not against Vim.**

<!-- Badges made using https://shields.io/ -->
[![Version Badge](https://img.shields.io/badge/Version-v1.0.0-brightgreen.svg)](https://github.com/axvr/Vivid.vim/releases)
[![Licence Badge](https://img.shields.io/badge/Licence-MIT-blue.svg)](https://github.com/axvr/Vivid.vim/blob/master/LICENCE)


[Vivid] is designed to allow [Vim] power users to fine tune exactly when their plugins are loaded into Vim. By default all plugins are disabled; the user can create their own conditions and rules to enable the plugins directly from their ```$MYVIMRC``` file.


## About

[Vivid] aims to give back control to [Vim] user's plugin management, allowing users to manage as much or as little of their plugins as they wish. Vivid is also designed to be fast, minimal & efficient.


[Vivid] allows you to:

* Install plugins
* Enable plugins
* Auto-enable plugins
* Check if a plugin is enabled

Planned features:

* Update plugins
* Remove unused plugins
* Auto generates [help tags] for each plugins


<!-- Image goes here -->


---


## Quick Start

### Dependencies

[Vivid] requires that the [Git] VCS is installed on your system, including [Vim] (8.0+) or [Neovim].

NOTE: Vivid currently does not fully work on Windows, compatibility for it is planned.

### Install Vivid

To install Vivid run this command in a terminal emulator:

``git clone https://github.com/axvr/Vivid.vim ~/.vim/pack/vivid/opt/Vivid.vim``

Then to enable Vivid place ``packadd Vivid.vim`` at the top of your ``$MYVIMRC`` file.

#### Vivid auto-install script

This can be placed at the top of a ``$MYVIMRC`` to install Vivid when on a UNIX based computer, which does not have Vivid installed already. This makes your ``$MYVIMRC`` file more portable, and allow for instant use on other systems.

```vim
if !filereadable(expand($HOME . '/.vim/pack/vivid/opt/Vivid.vim/autoload/vivid.vim'))
    echomsg "Installing Vivid.vim"
    silent !git clone https://github.com/axvr/Vivid.vim.git ~/.vim/pack/vivid/opt/Vivid.vim
endif
```

The same but for Neovim:

```vim
if !filereadable(expand($HOME . '/.config/nvim/pack/vivid/opt/Vivid.vim/autoload/vivid.vim'))
    echomsg "Installing Vivid.vim"
    silent !git clone https://github.com/axvr/Vivid.vim.git ~/.config/nvim/pack/vivid/opt/Vivid.vim
endif
```


### Using Vivid

NOTE: By default Vivid enables no plugins, this is because of it's heavy focus on lazy loading and control. This behaviour can be reversed by including `call vivid#enable()` after adding all of the plugins to Vivid.

NOTE: Vivid currently only works with Git managed plugins.

NOTE: When using Vivid, never use ``packloadall``, and never use ``packadd`` on any plugin that Vivid is managing. Using these command will cause Vivid to break.

#### Adding Plugins

Vivid will manage any plugins which are defined using the ``vivid#add`` function. Vivid provides many options when adding plugins.

```vim
packadd Vivid.vim " Required

" Examples of adding plugins to Vivid
call vivid#add('rhysd/clever-f.vim') " Simple adding from GitHub (same as Vundle and Vim-Plug)
call vivid#add('https://github.com/rhysd/clever-f.vim') " Using full remote address to plugin
call vivid#add('rhysd/clever-f.vim', { 'enabled': 1, }) " Add and enable plugin by default
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

#### Enabling Plugins

* Enable plugins: ``call vivid#enable()``

#### Check Plugin Status

Vivid allows you to write complex scripts in your ``$MYVIMRC``, one of the features it provides is checking whether a plugin is enabled or not. The simple feature opens many possibilities, such as commands are mapped when the plugin is enabled, or a different config and plugins in Neovim than in Vim when using the same configuration file.

The function is ``vivid#enabled('plugin-name-here')``, and it takes one argument, the name of the plugin to check the status of.

#### Clean Plugins

*Pending*


[Vivid]:https://github.com/axvr/Vivid.vim
[Git]:http://git-scm.com
[Vim]:http://www.vim.org
[Neovim]:https://neovim.io
[runtime path]:http://vimdoc.sourceforge.net/htmldoc/options.html#%27runtimepath%27
[help tags]:http://vimdoc.sourceforge.net/htmldoc/helphelp.html#:helptags


