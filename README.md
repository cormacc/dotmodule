# Dotmodule

## Overview

This is a simple management helper for modular dotfile repositories.

It decorates [GNU Stow](https://www.gnu.org/software/stow/) with a couple of minor but useful (to me) features:
- Pre- and post- installation scripts (e.g. to check out other projects from git -- i.e. spacemacs)
- Shared directory configuration via an optional config file (to safeguard against collisions between GNU Stow and other applications -- more detail below)
- Defining a subset of 'core' modules to be installed on all systems

This can be used with an existing stow link farm as-is, adding use of new features as needed on a per-module basis.

The (optional) configuration file is `dotmodule.collection`, a file in YAML format located at the collection root.
It is only required if defining shared folders and/or a core module set.

## Installation

    $ gem install dotmodule

## Usage

### Basic usage

Organise your dotfiles in modules, one per directory (i.e. a standard link farm for GNU Stow). Given a dotmodule collection at ~/dotfiles...

```
$ cd ~/dotfiles
 
$ dotmodule install

 Collection root:    /home/cormacc/dotfiles
 Default target:     /home/cormacc

 Shared target subdirectories:
   bin, .config, .profile.d

 Modules:
   i3, vscode, fish, ruby, zsh, emacs, xorg, base, ssh, macbook

 Core modules:
   base, zsh, emacs, ssh, ruby


No module argument passed. Install (c)ore/(a)ll/(n)one? [n]: c
Installing 5 modules ...
.. Module base ..
.. Module zsh ..
.. Module emacs ..
... running hook 'pre': '/home/cormacc/dotfiles/emacs-pre'
.... WARNING: ~/.emacs.d found -- skipping spacemacs checkout
.. Module ssh ..
.. Module ruby ..

```    

N.B. Shared target subdirectories and core modules will be blank, unless configured in the optional collection config file

To install a specific module or modules

    $dotmodule install MODULE_NAME

or

    $dotmodule install MODULE_NAME, ANOTHER_MODULE_NAME

To display module collection parameters

    $dotmodule info


### Pre- and post-installation hooks (Optional)

Any file in the farm root matching the pattern '<modulename>-pre' or '<modulename>-post' will be treated as a pre- or post-
installation hook and executed before/after GNU stow. I use an 'emacs-pre' hook to clone the spacemacs repository. Similarly, could use a pre or post hook to copy your ssh keys from somewhere else (as you probably don't want them in a public dotfile repo).


### Shared folders (Optional)

GNU Stow is clever at managing collisions between modules in a link farm, however we can run into issues when constructing symlinks into directory trees that are used by multiple applications -- e.g. `~/.config` -- resulting in unwanted data in your dotfile repo. To guard against this, you can declare these shared directories as a YAML list in a file called `dotmodule.collection` located at the root of your dotfile repository.

```yaml
:shared_directories:
  - bin
  - .config
  - .profile.d
  - this/also/works/with/nested/paths
```

The `dotmodule` gem will ensure these directories are created before installing any modules to prevent GNU Stow from creating them as links into your dotfile repository instead.

### Core modules (Optional)

This is purely a convenience -- allowing you to quickly install essential modules without having to remove modules that are platform-specific you're not using any more but may again at a later date from your repo. These core modules are also defined in `dotmodule.collection`

```yaml
:core_modules:
  - base
  - zsh
  - emacs
  - ssh
  - ruby
```

### Examples

See [my dotfiles](https://github.com/cormacc/dotfiles) for an example.


## Development / improvements

This is a pretty basic gem.

The majority of the functionality is defined in [DotModule::Collection](lib/dotmodule.rb)

This is wrapped in a basic [CLI](lib/dotmodule/CLI.rb) using [Thor](https://github.com/erikhuda/thor).

Unlike GNU Stow, the installation target directory is always the user home directory (internally, `Dir.home`) rather than the parent directory of the module collection.  `DotModule::Collection` is setup to allow explicit target specification, but the CLI wrapper doesn't yet,
as I don't currently need it to. That said, it would probably only take slightly more time to change that than it has to write this paragraph :)

If you add to a module, you can just `dotmodule install` it again. However if you remove content you need to clean out stale links manually. Might be worth adding some logic to detect/delete stale links, and/or uninstall a module.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/cormacc/dotmodule.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

