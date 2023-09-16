load test_helper

setup() {

  if [[ -f /home/vedv/.yzsh-gen.env ]]; then
    rm -f /home/vedv/.yzsh-gen.env
  fi

  if [[ -d /home/vedv/.yzsh/plugins/local ]]; then
    rm -rf /home/vedv/.yzsh/plugins/local
  fi
  mkdir /home/vedv/.yzsh/plugins/local
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

# Tests for ydf package install
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
