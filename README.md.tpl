# Dotfiles

## About

A simple dotfiles manager

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

Copy the config to your home directory

```sh
cp ~/.root/etc/skel/.ydf.env ~/
```

Edit the config file:

- If your OS is manjaro set the variable `YDF_PACKAGE_SERVICE_DEFAULT_OS` to manjaro. If you have other OS  don't set this variable.

- If you are using yzsh framework:

  - If you have a yzsh data repository but is not downloaded, set the variable `YDF_YZSH_DATA_REPOSITORY_URL`.

  - Or If you have your yzsh data repository already downloaded set the variable `YDF_YZSH_DATA_DIR`.

```sh
vim ~/.ydf.env
```

## Usage

....
