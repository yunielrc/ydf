<div align="center">
  <a href="" rel="noopener">
    <img src="media/ydf.png" width="96px" alt="ydf" />

# ydf

  </a>

**_A disruptive dotfiles manager+_**
</div>

<a href="https://www.producthunt.com/posts/ydf?utm_source=badge-featured&utm_medium=badge&utm_souce=badge-ydf" target="_blank"><img src="https://api.producthunt.com/widgets/embed-image/v1/featured.svg?post_id=416013&theme=light" alt="ydf - A&#0032;disruptive&#0032;dotfiles&#0032;manager&#0043; | Product Hunt" style="width: 250px; height: 54px;" width="250" height="54" /></a>

<img width=95%  src="media/ydf-packages.png" alt="ydf-packages">

## Table of Contents

Click on the menu right before `README.md` as shown in the image below.

<img width=300px src="media/toc.png" alt="toc"/>

## About

Are you tired of dealing with dotfiles of tools you are not using, are you tired
of installing a bunch of messy and dirty configs and executing an
elephant script.

This solution brings you a simple way to declare and install idempotently the tools
you need along with its configurations, following the principles of high cohesion
and low coupling. Turn the chaos to order, if you install the configuration, you
install the tool because those belong to the same `package`.

With this solution you can create multiple selections of packages for your different
needs, for example, you can create a `packages selection` for your laptop, desktop,
servers, different operating systems, etc.

Declaring your working environment give you some benefits: transparency and control
over it, allowing you to easily reproduce it on a new machine or fresh OS, you can
share it with others, so they can reproduce your working environment, you can
versioning it with git.

> What you write you can read, share, save and reproduce, it is simply there, it exists.

## Tested OS

It's tested on the following OS:

### Manjaro

Runtime Dependencies:

```sh
${MANJARO_PACKAGES_RUN}
```

Optional Dependencies:

```sh
${MANJARO_PACKAGES_OPT}
```

### Ubuntu

Runtime Dependencies:

```sh
${UBUNTU_PACKAGES_RUN}
```

Optional Dependencies:

```sh
${UBUNTU_PACKAGES_OPT}
```

⚠️ It should work on any other linux distribution, but it has not been tested.

## Install

Install `git`, `make` and `vim`

Clone the repository and switch to ydf directory

```sh
git clone https://github.com/yunielrc/ydf.git && cd ydf
```

Select the latest stable version

```sh
git checkout "$(git tag --sort='version:refname' | grep -Po '^v\d+\.\d+\.\d+$' | tail -n 1)"
```

### Install on Manjaro

Install optional dependencies and ydf on home directory

```sh
make install-opt-manjaro && make install-tohome
```

### Install on Ubuntu

Install optional dependencies and ydf on home directory

```sh
make install-opt-ubuntu && make install-tohome
```

### Install on Any Linux Distro (Minimal installation)

Minimal installation without optional dependencies

```sh
make install-tohome
```

⚠️ Attention: Instructions that rely on optional dependencies can't be used
   with the minimal installation. For each instruction you want to use install
   its dependency.

Instruction | Optional dependency
---------|----------
 `@snap` | snapd
 `docker-compose.yml` | docker, docker-compose
 `@yay` | yay
 `*.plugin.zsh` | yzsh
 `*.theme.zsh` | yzsh

## Configure

Edit the config file:

- Set the variable `YDF_PACKAGE_SERVICE_DEFAULT_OS` to `manjaro` or `ubuntu`
  according to your distro. If you have any other distro don't set this variable.

```sh
vim ~/.ydf.env
```

## YDF Package

### What is a package?

A `package` is a directory containing files and directories in which some have
a special meaning for the `interpreter`. ydf is an `interpreter`.

### What are the directories and files with special meaning?

Here is an example of a `package` with 19 directories and files with special
meaning, those are `instructions` that work on any linux distribution:

```sh
package1
├── preinstall           # Script executed before all instructions
├── @flatpak             # Install <package1> with flatpak
├── @snap                # Install <package1> with snap
├── install              # Script executed on install
├── docker-compose.yml   # Run docker compose up -d
├── package1.plugin.zsh  # Install yzsh plugin
├── package1.theme.zsh   # Install yzsh theme
├── homeln/              # Create symlinks on home for the first level files and
|                        # directories inside this directory
├── homelnr/             # Create symlinks on home for all files inside this
|                        # directory
├── homecp/              # Copy all files to home directory
├── rootcp/              # Copy all files to root directory
├── homecat/             # Concatenate all files with those existing in home
├── rootcat/             # Concatenate all files with those existing in root
├── homecps/             # Evaluate variables in files and copy them to home
├── rootcps/             # Evaluate variables in files and copy them to root
├── homecats/            # Evaluate variables in files and concatenates them with
|                        # those existing in home
├── rootcats/            # Evaluate variables in files and concatenates them with
|                        # those existing in root
├── dconf.ini            # Load dconf settings
└── postinstall          # Script executed after all instructions
```

The `instructions` can be grouped in 4 categories:

- Scripts instructions: `preinstall`, `install`, `postinstall`.
These instructions are shell scripts that are executed by bash.

- Package manager instructions: `@flatpak`, `@snap`.
These instrucions are plain text files, the file can have inside one or more package
names that are going to be installed. The file can be empty, in this case the package
`package1` is going to be installed.

- Directory instructions: `homeln`, `homelnr`, `homecp`, `rootcp`, `homecat`,
`rootcat`, `homecps`, `rootcps`, `homecats`, `rootcats`.
These instructions are directories that contains files that are going to be
symlinked, copied or concatenated to the home or root directory. For those
that end with `s` all the variables inside each file are substituted with the
values defined in the `envsubst.env` file that is inside the `packages directory`.

- Tool files instructions: `docker-compose.yml`, `dconf.ini`, `package1.plugin.zsh`,
`package1.theme.zsh`.
These instructions are files that are going to be used by a tool. For example
`docker-compose.yml` is going to be used by docker compose.
The `package1.plugin.zsh` is a plugin that is going to be installed inside the
YZSH data directory and used by YZSH.

These `instructions` only work for manjaro linux:

```sh
package2
├── @pacman
└── @yay
```

These `instructions` only work for ubuntu:

```sh
package3
├── @apt
└── @apt-get
```

👉 If you want support for others package managers you can open an issue or
create a pull request.

You can check out some examples of `packages` at: `tests/fixtures/packages`

### What is a YDF Packages Directory

A `packages directory` is a directory that contains a list of `packages` and the
`envsubst.env` file, besides it can have one or more `packages selection` files.

Here is an example of a `packages directory`:

```sh
~/.ydf-packages       # packages directory
├── bat/              # package
├── bmon/             # package
├── htop/             # package
├── aws-cli-v2/       # package
├── mpv/              # package
├── ....              # package
├── envsubst.env      # substitution variables
├── pc-gaming.pkgs    # packages selection
├── laptop-work.pkgs   # packages selection
└── ....              # packages selection
```

👉 You can check out my `packages directory` at: <https://github.com/yunielrc/.ydf-packages>

The `envsubst.env` file has the variables that are evaluated in the files inside
of `Directory instructions` that end with `s`.

The `packages selection` are plain text files that contains a list of `packages`
one per line.

The `packages directory` is where the `interpreter` is going to look for
`packages`, `envsubst.env` and `packages selection`.

## Usage

Reload your shell to load the new PATH.

```sh
exec $SHELL
```

Show the help

```sh
ydf --help
```

```sh
# command output:
${YDF_HELP}
```

### Add packages to your packages directory

Before adding a `package` to your `packages directory` you must create a git
repository.

```sh
cd ~/.ydf-packages
git init
git remote add origin git@github.com:<your_user>/.ydf-packages.git
```

Open the `packages directory` in your favorite code editor .

```sh
code ~/.ydf-packages
```

Create a `package` and add `instructions` to it.

Add variables to the `~/.ydf-packages/envsubst.env` if apply.

Test that the `package` works.

```sh
ydf package install <package>
```

Verify that the software was installed and configured correctly.

Create a `packages selection` if apply and add the package.

```sh
echo "<package>" >> ~/.ydf-packages/<packages_selection>.pkgs
```

Commit the changes.

```sh
cd ~/.ydf-packages
git add .
git commit -m "Add <package>"
git push -u origin master
```

### Install packages

When you reinstall your OS or on a new machine you can install all your
packages with:

```sh
ydf package install <packages_selection>.pkgs
```

👉 You can test the installation of the packages on a virtual machine before
   install them on a real one.

It's recommended to check out `vedv` at <https://github.com/yunielrc/vedv>
for working with virtual machines.

## Contributing

Contributions, issues and feature requests are welcome!

### Manjaro dev dependencies

```sh
${MANJARO_PACKAGES_DEV}
```

### Ubuntu dev dependencies

```sh
${UBUNTU_PACKAGES_DEV}
```

### Configure dev environment

#### Copy config samples

```sh
cp .env.sample .env
cp .ydf.env.sample .ydf.env
```

Edit the config file .env:

- Set the variable `HOST_OS` to `manjaro` or `ubuntu` according to your distro.
  If you have any other distro don't set this variable.

- Set the variable `TEST_OS` to `manjaro` or `ubuntu` according to distro that
  It's going to be tested.

```sh
vim ~/.env
```

#### Install dependencies for Manjaro

The command below install optional and development dependencies for Manjaro

```sh
make install-opt-manjaro && make install-dev-manjaro
```

#### Install dependencies for Ubuntu

The command below install optional and development dependencies for Ubuntu

```sh
make install-opt-ubuntu && make install-dev-ubuntu
```

#### Install on Any Linux Distro

For any other linux distribution install optional and development dependencies
manually.

#### Configure vedv

Check out: <https://github.com/yunielrc/vedv#configure>

### Workflow

#### Code

Write your code

#### Run Tests

The first time the image need to be downloaded and builded for development,
this process take a while, below are shown the download and build time for the
supported Linux distros at 90Mbps:

Distro  | download    | build
--------|-------------|----------
manjaro | 5m 9.11s    | 13m 4.74s
ubuntu  | 10m 13.611s | 8m 33.755s

Run Unit Testing for one component

```sh
make test-suite u="$(fd utils.bats)"
```

Run Unit Testing for one function

```sh
make test-name n='text_file_to_words' u="$(fd utils.bats)"
```

Run Integration Testing for one function

```sh
make test-name n='install_one_from_dir' u="$(fd ydf-package-service.i.bats)"
```

Run Functional Testing for one function

```sh
make test-name n='20homecats' u="$(fd ydf-package-command.f.bats)"
```

Run All Unit Tests

```sh
make test-unit
# 2.331s on manjaro
# 2.304s on ubuntu
```

Run All Integration Tests

```sh
make test-integration
# 53.475s on manjaro
# 1m 11.739s on ubuntu
```

Run All Functional Tests

```sh
make test-functional
# 1m 52.301s on manjaro
# 1m 31.900s on ubuntu
```

Run All tests

```sh
make test-all
# 1m 43.793s on manjaro
# 2m 17.157s on ubuntu
```

#### Commit

This project uses [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/).

For commiting use the command below

```sh
make commit
```

## Show your support

Give a ⭐️ if this project helped you!
