load test_helper

setup() {

  if [[ -f /home/vedv/.yzsh-gen.env ]]; then
    rm -f /home/vedv/.yzsh-gen.env
  fi

  if [[ -d /home/vedv/.yzsh/plugins/local ]]; then
    rm -rf /home/vedv/.yzsh/plugins/local
  fi
  mkdir /home/vedv/.yzsh/plugins/local

  if [[ -d /.my ]]; then
    sudo rm -r /.my
  fi

  if [[ -f /.my-config.env ]]; then
    sudo rm /.my-config.env
  fi

  if [[ -d ~/.my ]]; then
    rm -r ~/.my
  fi

  if [[ -f ~/.my-config.env ]]; then
    rm ~/.my-config.env
  fi
}

# teardown() {

# }

# Tests for ydf package
@test "ydf package, Should show help" {

  for p in '' -h --help; do
    run ydf package $p

    assert_success
    assert_output --partial 'Usage:
ydf package COMMAND'
  done
}

# Tests for ydf package install
@test "ydf package install, Should show help" {

  for p in '' -h --help; do
    run ydf package install $p

    assert_success
    assert_output --partial 'ydf package install [OPTIONS] PACKAGE [PACKAGE...]'
  done
}

@test "ydf package install --os, Should fail with missing argument os" {

  run ydf package install --os

  assert_failure
  assert_output --partial 'ERROR> No os name specified'
}

@test "ydf package install --os _OS_, Should fail with missing argument PACKAGE" {

  run ydf package install --os "$YDF_PACKAGE_SERVICE_DEFAULT_OS"

  assert_failure
  assert_output --partial "ERROR> Missing argument 'PACKAGE'"
}

# Tests for ydf package install ../2preinstall
@test "ydf package install --os _OS_ ../2preinstall, Should succeed With no preinstall script" {
  local -r _package_dir="${TEST_FIXTURES_DIR}/packages"

  run ydf package install --os "$YDF_PACKAGE_SERVICE_DEFAULT_OS" "$_package_dir"

  assert_success
  assert_output ""
}

@test "ydf package install --os _OS_ ../2preinstall, Should succeed" {
  local -r _package_dir="${TEST_FIXTURES_DIR}/packages/2preinstall"

  run ydf package install --os "$YDF_PACKAGE_SERVICE_DEFAULT_OS" "$_package_dir"

  assert_success
  assert_output "preinstall: preinstall succeed"
}

@test "ydf package install ../2preinstall, Should succeed" {
  local -r _package_dir="${TEST_FIXTURES_DIR}/packages/2preinstall"

  run ydf package install "$_package_dir"

  assert_success
  assert_output "preinstall: preinstall succeed"
}

# Tests for ydf package install ../3install
@test "ydf package install --os _OS_ ../3install, Should succeed With no install script" {
  local -r _package_dir="${TEST_FIXTURES_DIR}/packages/0empty"

  run ydf package install --os "$YDF_PACKAGE_SERVICE_DEFAULT_OS" "$_package_dir"

  assert_success
  assert_output ""
}

@test "ydf package install ../3install, Should succeed" {
  local -r _package_dir="${TEST_FIXTURES_DIR}/packages/3install"

  run ydf package install "$_package_dir"

  assert_success
  assert_output "3install: preinstall succeed
3install: install succeed"
}

# Tests for ydf package install ../4postinstall
@test "ydf package install ../4postinstall, Should succeed" {
  local -r _package_dir="${TEST_FIXTURES_DIR}/packages/4postinstall"

  run ydf package install "$_package_dir"

  assert_success
  assert_output "4postinstall: preinstall succeed
4postinstall: install succeed
4postinstall: postinstall succeed"
}

# Tests for ydf package install ../5dust@pacman
@test "ydf package install ../5dust@pacman, Should succeed" {
  local -r _package_dir="${TEST_FIXTURES_DIR}/packages/5dust@pacman"

  run ydf package install "$_package_dir"

  assert_success
  assert_output --regexp "5dust@pacman: preinstall succeed
.*
5dust@pacman: install succeed
5dust@pacman: postinstall succeed"

  run command -v dust

  assert_success
  assert_output "/usr/bin/dust"
}

@test "ydf package install ../bat, Should succeed Without package name in @pacman" {
  local -r _package_dir="${TEST_FIXTURES_DIR}/packages/bat"

  run ydf package install "$_package_dir"

  assert_success
  assert_output --regexp "bat: preinstall succeed
.*
bat: install succeed
bat: postinstall succeed"

  run command -v bat

  assert_success
  assert_output "/usr/bin/bat"
}

# Tests for ydf package install ../6nnn@yay
@test "ydf package install ../6nnn@yay, Should succeed" {
  local -r _package_dir="${TEST_FIXTURES_DIR}/packages/6nnn@yay"

  run ydf package install "$_package_dir"

  assert_success
  assert_output --regexp "6nnn@yay: preinstall succeed
.*
6nnn@yay: install succeed
6nnn@yay: postinstall succeed"

  run command -v nnn

  assert_success
  assert_output "/usr/bin/nnn"
}

@test "ydf package install ../rustscan, Should succeed Without package name in @yay" {
  local -r _package_dir="${TEST_FIXTURES_DIR}/packages/rustscan"

  run ydf package install "$_package_dir"

  assert_success
  assert_output --regexp "rustscan: preinstall succeed
.*
rustscan: install succeed
rustscan: postinstall succeed"

  run command -v rustscan

  assert_success
  assert_output "/usr/bin/rustscan"
}

# Tests for ydf package install ../7micenter@flathub
@test "ydf package install ../7micenter@flathub, Should succeed" {
  local -r _package_dir="${TEST_FIXTURES_DIR}/packages/7micenter@flathub"

  run ydf package install "$_package_dir"

  assert_success
  assert_output --regexp "7micenter@flathub: preinstall succeed
7micenter@flathub: install succeed
.*
.*io.missioncenter.MissionCenter.*
7micenter@flathub: postinstall succeed"

  __run_wrapper() {
    flatpak list --app | grep io.missioncenter.MissionCenter
  }

  run  __run_wrapper

  assert_success
  assert_output --partial "io.missioncenter.MissionCenter"
}

@test "ydf package install ../com.github.tchx84.Flatseal, Should succeed Without package name in @flatpak" {
  local -r _package_dir="${TEST_FIXTURES_DIR}/packages/com.github.tchx84.Flatseal"

  run ydf package install "$_package_dir"

  assert_success
  assert_output --regexp "com.github.tchx84.Flatseal: preinstall succeed
com.github.tchx84.Flatseal: install succeed
.*app/com.github.tchx84.Flatseal.*
com.github.tchx84.Flatseal: postinstall succeed"

  __run_wrapper() {
    flatpak list --app | grep com.github.tchx84.Flatseal
  }

  run __run_wrapper

  assert_success
  assert_output --partial "com.github.tchx84.Flatseal"
}

# Tests for ydf package install ../8go@snap
@test "ydf package install ../8go@snap, Should succeed" {
  local -r _package_dir="${TEST_FIXTURES_DIR}/packages/8go@snap"

  run ydf package install "$_package_dir"

  assert_success
  assert_output --regexp "8go@snap: preinstall succeed
8go@snap: install succeed
.*
8go@snap: postinstall succeed"

  run command -v go

  assert_success
  assert_output --partial "/bin/go"
}

@test "ydf package install ../multipass, Should succeed Without package name in @snap" {
  local -r _package_dir="${TEST_FIXTURES_DIR}/packages/multipass"

  run ydf package install "$_package_dir"

  assert_success
  assert_output --regexp "multipass .* installed"

  run command -v multipass

  assert_success
  assert_output --partial "/bin/multipass"
}

# Tests for ydf package install
@test "ydf package install ./9hello-world@dockercomp Should succeed" {
  local -r _package_dir="${TEST_FIXTURES_DIR}/packages/9hello-world@dockercomp"

  run ydf package install "$_package_dir"

  assert_success
  assert_output --partial "Container hello_world  Started"

  run docker container ls -qaf "name=hello_world"

  assert_success
  assert [ -n "$output" ]
}

# Tests for ydf package install ./10ydfplugin
@test "ydf package install ./10ydfplugin Should succeed" {
  local -r _package_dir="${TEST_FIXTURES_DIR}/packages/10ydfplugin"

  run ydf package install "$_package_dir"

  assert_success
  assert_output "'/home/vedv/.yzsh/plugins/local/10ydfplugin.plugin.zsh' -> '/home/vedv/ydf/tests/fixtures/packages/10ydfplugin/10ydfplugin.plugin.zsh'"

  assert [ -L '/home/vedv/.yzsh/plugins/local/10ydfplugin.plugin.zsh' ]
  assert [ -f '/home/vedv/.yzsh/plugins/local/10ydfplugin.plugin.zsh' ]

  run grep "YZSH_PLUGINS+=(10ydfplugin)" "$YDF_YZSH_GEN_CONFIG_FILE"

  assert_success
  assert_output "YZSH_PLUGINS+=(10ydfplugin)"
}

# Tests for ydf package install ./11homeln
@test "ydf package install ./11homeln Should succeed" {
  local -r _package_dir="${TEST_FIXTURES_DIR}/packages/11homeln"

  run ydf package install "$_package_dir"

  assert_success
  assert_output "'/home/vedv/.my' -> '/home/vedv/ydf/tests/fixtures/packages/11homeln/homeln/.my'
'/home/vedv/.my-config.env' -> '/home/vedv/ydf/tests/fixtures/packages/11homeln/homeln/.my-config.env'"

  assert [ -L '/home/vedv/.my' ]
  assert [ -d '/home/vedv/.my' ]
  assert [ -L '/home/vedv/.my-config.env' ]
  assert [ -f '/home/vedv/.my-config.env' ]

  rm /home/vedv/.my /home/vedv/.my-config.env
}

# Tests for ydf package install ./12homelnr
@test "ydf package install ./12homelnr Should succeed" {
  local -r _package_dir="${TEST_FIXTURES_DIR}/packages/12homelnr"

  run ydf package install "$_package_dir"

  assert_success
  assert_output "'/home/vedv/ydf/tests/fixtures/packages/12homelnr/homelnr/.my' -> '/home/vedv/.my'
'/home/vedv/ydf/tests/fixtures/packages/12homelnr/homelnr/.my/dir1' -> '/home/vedv/.my/dir1'
'/home/vedv/ydf/tests/fixtures/packages/12homelnr/homelnr/.my/dir1/file11' -> '/home/vedv/.my/dir1/file11'
'/home/vedv/ydf/tests/fixtures/packages/12homelnr/homelnr/.my/file1' -> '/home/vedv/.my/file1'
'/home/vedv/ydf/tests/fixtures/packages/12homelnr/homelnr/.my/file2' -> '/home/vedv/.my/file2'
'/home/vedv/ydf/tests/fixtures/packages/12homelnr/homelnr/.my-config.env' -> '/home/vedv/.my-config.env'"

  assert [ ! -L '/home/vedv/.my' ]
  assert [ -d '/home/vedv/.my' ]

  assert [ ! -L '/home/vedv/.my/dir1' ]
  assert [ -d '/home/vedv/.my/dir1' ]

  assert [ -L '/home/vedv/.my/dir1/file11' ]
  assert [ -f '/home/vedv/.my/dir1/file11' ]

  assert [ -L '/home/vedv/.my/file1' ]
  assert [ -f '/home/vedv/.my/file1' ]

  assert [ -L '/home/vedv/.my/file2' ]
  assert [ -f '/home/vedv/.my/file2' ]

  assert [ -L '/home/vedv/.my-config.env' ]
  assert [ -f '/home/vedv/.my-config.env' ]

  rm -r /home/vedv/.my /home/vedv/.my-config.env
}

# Tests for ydf package install ./13homecp
@test "ydf package install ./13homecp Should succeed" {
  local -r _package_dir="${TEST_FIXTURES_DIR}/packages/13homecp"

  run ydf package install "$_package_dir"

  assert_success
  assert_output "'/home/vedv/ydf/tests/fixtures/packages/13homecp/homecp/.my' -> '/home/vedv/.my'
'/home/vedv/ydf/tests/fixtures/packages/13homecp/homecp/.my/dir1' -> '/home/vedv/.my/dir1'
'/home/vedv/ydf/tests/fixtures/packages/13homecp/homecp/.my/dir1/file11' -> '/home/vedv/.my/dir1/file11'
'/home/vedv/ydf/tests/fixtures/packages/13homecp/homecp/.my/file1' -> '/home/vedv/.my/file1'
'/home/vedv/ydf/tests/fixtures/packages/13homecp/homecp/.my/file2' -> '/home/vedv/.my/file2'
'/home/vedv/ydf/tests/fixtures/packages/13homecp/homecp/.my-config.env' -> '/home/vedv/.my-config.env'"

  assert [ ! -L '/home/vedv/.my' ]
  assert [ -d '/home/vedv/.my' ]

  assert [ ! -L '/home/vedv/.my/dir1' ]
  assert [ -d '/home/vedv/.my/dir1' ]

  assert [ ! -L '/home/vedv/.my/dir1/file11' ]
  assert [ -f '/home/vedv/.my/dir1/file11' ]

  assert [ ! -L '/home/vedv/.my/file1' ]
  assert [ -f '/home/vedv/.my/file1' ]

  assert [ ! -L '/home/vedv/.my/file2' ]
  assert [ -f '/home/vedv/.my/file2' ]

  assert [ ! -L '/home/vedv/.my-config.env' ]
  assert [ -f '/home/vedv/.my-config.env' ]

  rm -r /home/vedv/.my /home/vedv/.my-config.env
}

# Tests for ydf package install ./14rootcp
@test "ydf package install ./14rootcp Should succeed" {
  local -r _package_dir="${TEST_FIXTURES_DIR}/packages/14rootcp"

  run ydf package install "$_package_dir"

  assert_success
  assert_output "'/home/vedv/ydf/tests/fixtures/packages/14rootcp/rootcp/.my' -> '/.my'
'/home/vedv/ydf/tests/fixtures/packages/14rootcp/rootcp/.my/dir1' -> '/.my/dir1'
'/home/vedv/ydf/tests/fixtures/packages/14rootcp/rootcp/.my/dir1/file11' -> '/.my/dir1/file11'
'/home/vedv/ydf/tests/fixtures/packages/14rootcp/rootcp/.my/file1' -> '/.my/file1'
'/home/vedv/ydf/tests/fixtures/packages/14rootcp/rootcp/.my/file2' -> '/.my/file2'
'/home/vedv/ydf/tests/fixtures/packages/14rootcp/rootcp/.my-config.env' -> '/.my-config.env'"

  assert [ ! -L '/.my' ]
  assert [ -d '/.my' ]

  assert [ ! -L '/.my/dir1' ]
  assert [ -d '/.my/dir1' ]

  assert [ ! -L '/.my/dir1/file11' ]
  assert [ -f '/.my/dir1/file11' ]

  assert [ ! -L '/.my/file1' ]
  assert [ -f '/.my/file1' ]

  assert [ ! -L '/.my/file2' ]
  assert [ -f '/.my/file2' ]

  assert [ ! -L '/.my-config.env' ]
  assert [ -f '/.my-config.env' ]

  sudo rm -r /.my /.my-config.env
}

# Tests for ydf package install ./15homecat
@test "ydf package install ./15homecat Should succeed" {
  local -r _package_dir="${TEST_FIXTURES_DIR}/packages/15homecat"
  cp -r "${TEST_FIXTURES_DIR}/dirs/.my" ~/

  run ydf package install "$_package_dir"

  assert_success
  assert_output "WARNING> Skipped homecat, file '/home/vedv/.my-config.env' doesn't exist"

  run cat /home/vedv/.my/file1

  assert_success
  assert_output "file1
added line1 to file1

added line2 to file1"

  run cat /home/vedv/.my/dir1/file11

  assert_success
  assert_output "file11
# @CAT_SECTION_HOME_CAT

added line1 to file11
added line2 to file11

# :@CAT_SECTION_HOME_CAT"

  run cat /home/vedv/.my/file2

  assert_success
  assert_output "file2"
}

# Tests for ydf package install ./16rootcat
@test "ydf package install ./16rootcat Should succeed" {
  local -r _package_dir="${TEST_FIXTURES_DIR}/packages/16rootcat"
  sudo cp -r "${TEST_FIXTURES_DIR}/dirs/.my" /

  run ydf package install "$_package_dir"

  assert_success
  assert_output "WARNING> Skipped rootcat, file '/.my-config.env' doesn't exist"

  run cat /.my/file1

  assert_success
  assert_output "file1
added line1 to file1

added line2 to file1"

  run cat /.my/dir1/file11

  assert_success
  assert_output "file11
# @CAT_SECTION_HOME_CAT

added line1 to file11
added line2 to file11

# :@CAT_SECTION_HOME_CAT"

  run cat /.my/file2

  assert_success
  assert_output "file2"
}


# Tests for ydf package install ./17homecps
@test "ydf package install ./17homecps Should succeed" {
  local -r _package_dir="${TEST_FIXTURES_DIR}/packages/17homecps"

  run ydf package install "$_package_dir"

    assert_success
  assert_output ""

  run cat /home/vedv/.my/file1

  assert_success
  assert_output "line 1

line 3"

  run cat /home/vedv/.my/dir1/file11

  assert_success
  assert_output 'line 1

file11_1: "file11_1"

file11_2: file11 2





line 11'

  run cat /home/vedv/.my-config.env

  assert_success
  assert_output 'line 1

my_config1: "my_config1"

my_config2: my config2





line 11'

  run ls -la /home/vedv/.my

  assert_success
  assert_output --regexp ".* vedv vedv .* \.
.* vedv vedv .* \.\.
.* vedv vedv .* dir1
.* vedv vedv  .* file1"

  run ls -la /home/vedv/.my/file1 \
    /home/vedv/.my/dir1/file11 /home/vedv/.my-config.env

  assert_success
  assert_output --regexp ".* vedv vedv .* /home/vedv/.my-config.env
.* vedv vedv .* /home/vedv/.my/dir1/file11
.* vedv vedv .* /home/vedv/.my/file1"
}
