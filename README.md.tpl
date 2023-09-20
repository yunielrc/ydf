# Dotfiles

## About

A dotfiles manager+

## Tested OS

It's tested on the following OS:

### Manjaro

Runtime Dependencies:

```sh
${MANJARO_PACKAGES_RUN}
```

⚠️ It should work on any linux distribution, but it has not been tested.

### Install

Clone the repository and switch to ydf directory

```sh
git clone https://github.com/yunielrc/ydf.git && cd ydf
```

#### Install on Manjaro

Install runtime dependencies and ydf on home directory

```sh
make install-run-manjaro && make install-tohome
```

For any other linux distribution install runtime dependencies manually and execute the following command

```sh
make install-tohome
```

## Configure

Edit the config file:

- If your OS is manjaro set the variable `YDF_PACKAGE_SERVICE_DEFAULT_OS` to manjaro. If you have any other distro OS don't set this variable.

```sh
vim ~/.ydf.env
```

## YDF Package

### What is a YDF Package (YP)?

A `YP` is a directory that contains directories and files which some of then has
a special meaning for the `YP` interpreter (ydf in this case).

### Which are the directories and files with special meaning?

These is an example of a package with 18 directories and files with special meaning,
those are instructions that work on any linux distribution:

```sh
package1
├── preinstall           # script executed before install
├── install              # script executed on install
├── @flatpak             # install <package1> with flatpak
├── @snap                # install <package1> with snap
├── docker-compose.yml   # run docker compose up -d
├── package1.plugin.zsh  # install yzsh plugin
├── homeln/              # create symlinks for first level files inside it in home directory
├── homelnr/             # create symlinks for all files inside it in home directory
├── homecp/              # copy all files to home directory
├── rootcp/              # copy all files to root directory
├── homecat/             # concatenate all files to the existing one in home directory
├── rootcat/             # concatenate all files to the existing one in root directory
├── homecps/             # evaluate variables in files and copy them to home directory
├── rootcps/             # evaluate variables in files and copy them to root directory
├── homecats/            # evaluate variables in files and concatenate them to the existing one in home directory
├── rootcats/            # evaluate variables in files and concatenate them to the existing one in root directory
├── dconf.ini            # load dconf settings
└── postinstall          # script executed after all instructions
```

The instructions can be grouped in 4 categories:

- Scripts instructions: `preinstall`, `install`, `postinstall`.
  These instructions are shell scripts that are executed by bash.

- Package manager instructions: `@flatpak`, `@snap`.
  These instrucions are plain text files, the file can have inside one line with
  the package name or a list of packages names that are going to be installed.
  The file can be empty, in this case the package name (`package1`) is going to be used.

- Directory instructions: `homeln`, `homelnr`, `homecp`, `rootcp`, `homecat`,
  `rootcat`, `homecps`, `rootcps`, `homecats`, `rootcats`.
  These instructions are directories that contains files that are going to be
  copied, concatenated or symlinked to the home or root directory. For those
  that end with `s` all the variables inside each file are substituted with the
  values defined in the `envsubst.env` file that is inside the YDF Package Directory.

- Tool files instructions: `docker-compose.yml`, `dconf.ini`, `package1.plugin.zsh`.
  These instructions are files that are going to be used by a tool. For example
  `docker-compose.yml` is going to be used by docker compose.
  The `package1.plugin.zsh` is a plugin that is going to be installed inside the
  YZSH data directory and used by YZSH.

There are 2 more instructions that only work for manjaro linux:

```sh
package2
├── @pacman
└── @yay
```

You can check out some examples of `YP` at: `tests/fixtures/packages`

## What is a YDF Package Directory (YPD)

A `YPD` is a directory that contains a list of `YP` and an `envsubst.env` file
that is used to substitute variables in the files inside of Directory
instructions that end with `s`. This directory is where the `interpreter` is going to
look for YDF packages to execute.

## Usage

Reload your shell to load the new PATH.

```sh
exec $SHELL
```

....
