# Vivid.vim

**Vivid is a Vim plugin management solution; designed to work with, not against
Vim.**

<!-- Badges made using https://shields.io/ -->
[![Version Badge](https://img.shields.io/badge/Version-v1.0.0-brightgreen.svg)](https://github.com/axvr/Vivid.vim/releases)
[![Licence Badge](https://img.shields.io/badge/Licence-MIT-blue.svg)](https://github.com/axvr/Vivid.vim/blob/master/LICENCE)


[Vivid] is designed to allow [Vim] power users to fine tune exactly when their
plugins are loaded into Vim. By default all plugins are disabled; the user can
create their own conditions and rules to enable the plugins directly from their
`$MYVIMRC` file.


## About

[Vivid] aims to give control to [Vim] user's plugin management, allowing users
to manage as much or as little of their plugins as they wish. Vivid is also
designed to be fast, minimal & efficient.


[Vivid] allows you to:

* Install plugins
* Update plugins
* Enable plugins
* Auto-enable plugins
* Check if a plugin is enabled
* Auto generate [help tags] for each plugins
* Change the directory plugins are installed to

Planned features:

* Remove unused plugins
* Async update and install of plugins
* Local plugin repositories (file://)
* Freeze plugins to a specific version or commit
* Update by tags
* Update from a chosen branch
* Vim help doc (similar to the [Vivid wiki])
* More verbose processes (can be toggled on or off)


---

![Vivid Updating Plugins](https://github.com/axvr/codedump/raw/master/project-assets/Vivid.vim/vivid-update.png)

---


## Quick Start

See the [Vivid wiki] for more information, examples and a [FAQ].

### [Dependencies](https://github.com/axvr/Vivid.vim/wiki/Installing-Vivid#what-dependencies-does-vivid-require)

[Vivid] requires that the [Git] VCS is installed on your system, including [Vim]
(8.0+) or [Neovim].

**NOTE:** Vivid only works with Git managed plugins.


### [Install Vivid]

To install Vivid on Vim run this command in a terminal emulator:

```bash
git clone https://github.com/axvr/Vivid.vim ~/.vim/pack/vivid/opt/Vivid.vim
```

Alternatively, you can install Vivid for Neovim by running this command:

```bash
git clone https://github.com/axvr/Vivid.vim ~/.config/nvim/pack/vivid/opt/Vivid.vim
```

Then to enable Vivid place `packadd Vivid.vim` at the top of your `$MYVIMRC`
file. No other boilerplate code is required in your Vim config.


### [Using Vivid]

To enable Vivid the line `packadd Vivid.vim` must be added to your `$MYVIMRC`
before any plugin definitions or plugin settings.

By default Vivid enables no plugins, this is because of it's heavy focus on lazy
loading and control. This behaviour can be reversed by including `call
vivid#enable()` or `PluginEnable` after adding all of the plugins to Vivid.

Most actions that Vivid can perform have two methods of use, functions and
commands. It is recommended to use functions in Vim scripts and commands when
using command mode.

**NOTE:** When using Vivid, never use the `packloadall` or the `packadd` on any
plugin that Vivid is managing. Using these commands will cause Vivid to break
for that session. The exception is the `packadd Vivid.vim` before any plugin
config.

#### Adding Plugins

Vivid will manage any plugins which are defined using the `vivid#add` function,
or the `Plugin` command. Vivid provides many options when adding plugins. The
commands are based off of the [Vundle] commands (where [Vivid's origins] lie)

Using the function:

```vim
packadd Vivid.vim  " Required

" Examples of adding plugins to Vivid (using the function)
call vivid#add('tpope/vim-fugitive')            " Simple adding from GitHub (same as Vundle and Vim-Plug)
call vivid#add('https://github.com/tpope/vim-fugitive') " Using full remote address to plugin
call vivid#add('tpope/vim-fugitive', { 'enabled': 1, }) " Add and enable plugin by default
call vivid#add('tpope/vim-fugitive', {          " Other options to provide to Vivid
        \ 'name': 'fugitive.vim',               " Set the name to refer to the plugin by
        \ 'enabled': 1,                         " Auto-enable plugin, can be set to 1 or 0, the default is 0
        \ })
```

Using the command:

```vim
packadd Vivid.vim  " Required

" Examples of adding plugins to Vivid (using the command)
Plugin 'tpope/vim-fugitive'                     " Simple adding from GitHub (same as Vundle and Vim-Plug)
Plugin 'https://github.com/tpope/vim-fugitive'  " Using full remote address to plugin
Plugin 'tpope/vim-fugitive', { 'enabled': 1, }  " Add and enable plugin by default
Plugin 'tpope/vim-fugitive', {                  " Other options to provide to Vivid
        \ 'name': 'fugitive.vim',               " Set the name to refer to the plugin by
        \ 'enabled': 1,                         " Auto-enable plugin, can be set to 1 or 0, the default is 0
        \ }
```

#### Automatic Plugin Naming

Whenever plugins are specified Vivid uses the names provided when added using
the `name` option. If none were provided the plugin name is generated by Vivid
to being the last section of the URL without `.git` on the end of it.

Examples of automatic plugin naming:

```vim
Plugin 'tpope/vim-fugitive'   " Name would be: vim-fugitive
Plugin 'rhysd/committia.vim'  " Name would be: committia.vim
Plugin 'https://github.com/wellle/targets.vim.git'  " Name would be: targets.vim
```


#### Installing Plugins

Vivid has a built in plugin install feature so you don't need to manually clone
the plugins, and create git submodules for them.

Vivid can install plugins using one of the 3 method: commands, functions, or
when needed.

The command method can have plugins specified, if plugins are not specified it
will install all plugins.

```vim
" To install the vim-fugitive and committia plugins
:PluginInstall vim-fugitive committia.vim

" To install all plugins
:PluginInstall
```

The function method can also have plugins specified, and again if plugins are
not specified, it will install all plugins which were added for Vivid to manage.

```vim
" To install the vim-fugitive and committia plugins
:call vivid#install('vim-fugitive', 'committia.vim')

" To install all plugins
:call vivid#install()
```

The final method of installing plugins is by enabling them, if the plugin cannot
be found Vivid will automatically install it.

```vim
:PluginEnable vim-fugitive committia.vim
```


#### Updating Plugins

Vivid is capable of updating your plugins. It can update them all or only update
specific specified plugins.

Command method:

```vim
" Update specified plugins: vim-fugitive and committia
:PluginUpdate vim-fugitive committia.vim

" Update all plugins
:PluginUpdate
```

Function method:

```vim
" Update specified plugins: vim-fugitive and committia
:call vivid#update('vim-fugitive', 'committia.vim')

" Update all plugins
:call vivid#update()
```


#### Enabling Plugins

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

<!-- Add to wiki -->
<!-- Sometimes a plugin may break, sometimes due user modding of code or a
broken Git history. To fix this problem see the plugin cleaning section of this
document. -->

