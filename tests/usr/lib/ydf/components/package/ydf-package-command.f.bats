# shellcheck disable=SC2153
load test_helper

setup() {
  export YDF_PACKAGE_SERVICE_DEFAULT_OS="$TEST_OS"
  export E_YDF_PACKAGE_SERVICE_DEFAULT_OS="$TEST_OS"

  export E_YDF_UTILS_NO_MSG=true

  if [[ -f "$TEST_HOME_DIR"/.yzsh-gen.env ]]; then
    rm -f "$TEST_HOME_DIR"/.yzsh-gen.env
  fi

  if [[ -d "$TEST_HOME_DIR"/.yzsh/plugins/local ]]; then
    rm -rf "$TEST_HOME_DIR"/.yzsh/plugins/local
  fi
  mkdir "$TEST_HOME_DIR"/.yzsh/plugins/local

  if [[ -d "$TEST_HOME_DIR"/.yzsh/themes/local ]]; then
    rm -rf "$TEST_HOME_DIR"/.yzsh/themes/local
  fi
  mkdir "$TEST_HOME_DIR"/.yzsh/themes/local

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
    assert_output --partial 'ydf package install [OPTIONS] <PKGS_SELECTION_FILE | PACKAGE [PACKAGE...]>'
  done
}

@test "ydf package install --os, Should fail with missing argument os" {

  run ydf package install --os

  assert_failure
  assert_output --partial 'ERROR> No os name specified'
}

@test "ydf package install --os _OS_ --packages-dir, Should fail with missing argument packages-dir" {

  run ydf package install \
    --os "$YDF_PACKAGE_SERVICE_DEFAULT_OS" \
    --packages-dir

  assert_failure
  assert_output --partial 'ERROR> No packages dir specified'
}

@test "ydf package install --os _OS_, Should fail with missing argument PACKAGE" {

  run ydf package install \
    --os "$YDF_PACKAGE_SERVICE_DEFAULT_OS" \
    --packages-dir "$YDF_PACKAGE_SERVICE_PACKAGES_DIR"

  assert_failure
  assert_output --partial "ERROR> Missing argument 'PACKAGE'"
}

# Tests for ydf package install 1liberty
@test "ydf package install --os ... 1liberty, Should install pkg from defined packages dir" {

  ydf::package_service::install() {
    assert_equal "$*" ""
  }

  run ydf package install \
    --os "$YDF_PACKAGE_SERVICE_DEFAULT_OS" \
    --packages-dir "${TEST_FIXTURES_DIR}/packages2" \
    1liberty

  assert_success
  assert_output "
1liberty: preinstall succeed
1liberty: postinstall"
}

# Tests for ydf package install 2preinstall
@test "ydf package install --os _OS_ 0empty, Should succeed With no preinstall script" {
  local -r _package_name="0empty"

  run ydf package install --os "$YDF_PACKAGE_SERVICE_DEFAULT_OS" "$_package_name"

  assert_success
  assert_output ""
}

@test "ydf package install --os _OS_ 2preinstall, Should succeed" {
  local -r _package_name="2preinstall"

  run ydf package install --os "$YDF_PACKAGE_SERVICE_DEFAULT_OS" "$_package_name"

  assert_success
  assert_output "
preinstall: preinstall succeed"
}

@test "ydf package install 2preinstall, Should succeed" {
  local -r _package_name="2preinstall"

  run ydf package install "$_package_name"

  assert_success
  assert_output "
preinstall: preinstall succeed"
}

# Tests for ydf package install 3install
@test "ydf package install --os _OS_ 3install, Should succeed With no install script" {
  local -r _package_name="0empty"

  run ydf package install --os "$YDF_PACKAGE_SERVICE_DEFAULT_OS" "$_package_name"

  assert_success
  assert_output ""
}

@test "ydf package install 3install, Should succeed" {
  local -r _package_name="3install"

  run ydf package install "$_package_name"

  assert_success
  assert_output "
3install: preinstall succeed
3install: install succeed"
}

# Tests for ydf package install 4postinstall
@test "ydf package install 4postinstall, Should succeed" {
  local -r _package_name="4postinstall"

  run ydf package install "$_package_name"

  assert_success
  assert_output "
4postinstall: preinstall succeed
4postinstall: install succeed
4postinstall: postinstall succeed"
}

# Tests for ydf package install 5dust@pacman
@test "ydf package install 5dust@pacman, Should succeed" {
  if [[ "$YDF_PACKAGE_SERVICE_DEFAULT_OS" != manjaro ]]; then
    skip "Only for manjaro"
  fi

  local -r _package_name="5dust@pacman"

  run ydf package install "$_package_name"

  assert_success
  assert_output --regexp "5dust@pacman: preinstall succeed
.*
5dust@pacman: install succeed
5dust@pacman: postinstall succeed"

  run command -v dust

  assert_success
  assert_output "/usr/bin/dust"
}

@test "ydf package install bat, Should succeed Without package name in @pacman" {
  if [[ "$YDF_PACKAGE_SERVICE_DEFAULT_OS" != manjaro ]]; then
    skip "Only for manjaro"
  fi
  local -r _package_name="bat"

  run ydf package install "$_package_name"

  assert_success
  assert_output --regexp "bat: preinstall succeed
.*
bat: install succeed
bat: postinstall succeed"

  run command -v bat

  assert_success
  assert_output "/usr/bin/bat"
}

# Tests for ydf package install 6nnn@yay
@test "ydf package install 6nnn@yay, Should succeed" {
  if [[ "$YDF_PACKAGE_SERVICE_DEFAULT_OS" != manjaro ]]; then
    skip "Only for manjaro"
  fi
  local -r _package_name="6nnn@yay"

  run ydf package install "$_package_name"

  assert_success
  assert_output --regexp "6nnn@yay: preinstall succeed
.*
6nnn@yay: install succeed
6nnn@yay: postinstall succeed"

  run command -v nnn

  assert_success
  assert_output "/usr/bin/nnn"
}

@test "ydf package install rustscan, Should succeed Without package name in @yay" {
  if [[ "$YDF_PACKAGE_SERVICE_DEFAULT_OS" != manjaro ]]; then
    skip "Only for manjaro"
  fi
  local -r _package_name="rustscan"

  run ydf package install "$_package_name"

  assert_success
  assert_output --regexp "rustscan: preinstall succeed
.*
rustscan: install succeed
rustscan: postinstall succeed"

  run command -v rustscan

  assert_success
  assert_output "/usr/bin/rustscan"
}

# Tests for ydf package install 7micenter@flathub
@test "ydf package install 7micenter@flathub, Should succeed" {
  local -r _package_name="7micenter@flathub"

  run ydf package install "$_package_name"

  assert_success
  assert_output --regexp "7micenter@flathub: preinstall succeed
.*
.*io.missioncenter.MissionCenter.*
7micenter@flathub: install succeed
7micenter@flathub: postinstall succeed"

  __run_wrapper() {
    # shellcheck disable=SC2317
    flatpak list --app | grep io.missioncenter.MissionCenter
  }

  run __run_wrapper

  assert_success
  assert_output --partial "io.missioncenter.MissionCenter"
}

@test "ydf package install com.github.tchx84.Flatseal, Should succeed Without package name in @flatpak" {
  local -r _package_name="com.github.tchx84.Flatseal"

  run ydf package install "$_package_name"

  assert_success
  assert_output --regexp "com.github.tchx84.Flatseal: preinstall succeed
.*app/com.github.tchx84.Flatseal.*
com.github.tchx84.Flatseal: install succeed
com.github.tchx84.Flatseal: postinstall succeed"

  __run_wrapper() {
    flatpak list --app | grep com.github.tchx84.Flatseal
  }

  run __run_wrapper

  assert_success
  assert_output --partial "com.github.tchx84.Flatseal"
}

# Tests for ydf package install 8go@snap
@test "ydf package install 8go@snap, Should succeed" {
  local -r _package_name="8go@snap"

  run ydf package install "$_package_name"

  assert_success
  assert_output --regexp "8go@snap: preinstall succeed
.*
8go@snap: install succeed
8go@snap: postinstall succeed"

  run command -v go

  assert_success
  assert_output --partial "/bin/go"
}

@test "ydf package install multipass, Should succeed Without package name in @snap" {
  local -r _package_name="multipass"

  run ydf package install "$_package_name"

  assert_success
  assert_output --regexp "multipass .* installed"

  run command -v multipass

  assert_success
  assert_output --partial "/bin/multipass"
}

# Tests for ydf package install
@test "ydf package install ./9hello-world@dockercomp Should succeed" {
  skip 'it must be a manjaro rolling release problem'
  # Error response from daemon: failed to create endpoint hello_world on network 9hello-worlddockercomp_default: failed to add the host (veth00e7765) <=> sandbox (veth3a9fa13) pair interfaces: operation not supported
  local -r _package_name="9hello-world@dockercomp"

  run ydf package install "$_package_name"

  assert_success
  assert_output --partial "Container hello_world  Started"

  run docker container ls -qaf "name=hello_world"

  assert_success
  assert [ -n "$output" ]
}

# Tests for ydf package install ./10ydfplugin
@test "ydf package install ./10ydfplugin Should succeed" {
  local -r _package_name="10ydfplugin"

  run ydf package install "$_package_name"

  assert_success
  assert_output "
'${TEST_HOME_DIR}/.yzsh/plugins/local/10ydfplugin.plugin.zsh' -> '${TEST_WORKING_DIR}/tests/fixtures/packages/10ydfplugin/10ydfplugin.plugin.zsh'"

  assert [ -L "${TEST_HOME_DIR}/.yzsh/plugins/local/10ydfplugin.plugin.zsh" ]
  assert [ -f "${TEST_HOME_DIR}/.yzsh/plugins/local/10ydfplugin.plugin.zsh" ]

  run grep "YZSH_PLUGINS+=(10ydfplugin)" "$YDF_YZSH_GEN_CONFIG_FILE"

  assert_success
  assert_output "YZSH_PLUGINS+=(10ydfplugin)"
}

# Tests for ydf package install ./11homeln
@test "ydf package install ./11homeln Should succeed" {
  local -r _package_name="11homeln"

  run ydf package install "$_package_name"

  assert_success
  assert_output "
'${TEST_HOME_DIR}/.my' -> '${TEST_WORKING_DIR}/tests/fixtures/packages/11homeln/homeln/.my'
'${TEST_HOME_DIR}/.my-config.env' -> '${TEST_WORKING_DIR}/tests/fixtures/packages/11homeln/homeln/.my-config.env'"

  assert [ -L "${TEST_HOME_DIR}/.my" ]
  assert [ -d "${TEST_HOME_DIR}/.my" ]
  assert [ -L "${TEST_HOME_DIR}/.my-config.env" ]
  assert [ -f "${TEST_HOME_DIR}/.my-config.env" ]

  rm "${TEST_HOME_DIR}/.my" "${TEST_HOME_DIR}/.my-config.env"
}

# Tests for ydf package install ./12homelnr
@test "ydf package install ./12homelnr Should succeed" {
  local -r _package_name="12homelnr"

  run ydf package install "$_package_name"

  assert_success
  #   assert_output "
  # '${TEST_WORKING_DIR}/tests/fixtures/packages/12homelnr/homelnr/.my' -> '${TEST_HOME_DIR}/.my'
  # '${TEST_WORKING_DIR}/tests/fixtures/packages/12homelnr/homelnr/.my/dir1' -> '${TEST_HOME_DIR}/.my/dir1'
  # '${TEST_WORKING_DIR}/tests/fixtures/packages/12homelnr/homelnr/.my/dir1/file11' -> '${TEST_HOME_DIR}/.my/dir1/file11'
  # '${TEST_WORKING_DIR}/tests/fixtures/packages/12homelnr/homelnr/.my/file1' -> '${TEST_HOME_DIR}/.my/file1'
  # '${TEST_WORKING_DIR}/tests/fixtures/packages/12homelnr/homelnr/.my/file2' -> '${TEST_HOME_DIR}/.my/file2'
  # '${TEST_WORKING_DIR}/tests/fixtures/packages/12homelnr/homelnr/.my-config.env' -> '${TEST_HOME_DIR}/.my-config.env'"

  assert [ ! -L "${TEST_HOME_DIR}/.my" ]
  assert [ -d "${TEST_HOME_DIR}/.my" ]

  assert [ ! -L "${TEST_HOME_DIR}/.my/dir1" ]
  assert [ -d "${TEST_HOME_DIR}/.my/dir1" ]

  assert [ -L "${TEST_HOME_DIR}/.my/dir1/file11" ]
  assert [ -f "${TEST_HOME_DIR}/.my/dir1/file11" ]

  assert [ -L "${TEST_HOME_DIR}/.my/file1" ]
  assert [ -f "${TEST_HOME_DIR}/.my/file1" ]

  assert [ -L "${TEST_HOME_DIR}/.my/file2" ]
  assert [ -f "${TEST_HOME_DIR}/.my/file2" ]

  assert [ -L "${TEST_HOME_DIR}/.my-config.env" ]
  assert [ -f "${TEST_HOME_DIR}/.my-config.env" ]

  rm -r "${TEST_HOME_DIR}/.my" "${TEST_HOME_DIR}/.my-config.env"
}

# Tests for ydf package install ./13homecp
@test "ydf package install ./13homecp Should succeed" {
  local -r _package_name="13homecp"

  run ydf package install "$_package_name"

  assert_success
  #   assert_output "
  # '${TEST_WORKING_DIR}/tests/fixtures/packages/13homecp/homecp/.my' -> '${TEST_HOME_DIR}/.my'
  # '${TEST_WORKING_DIR}/tests/fixtures/packages/13homecp/homecp/.my/dir1' -> '${TEST_HOME_DIR}/.my/dir1'
  # '${TEST_WORKING_DIR}/tests/fixtures/packages/13homecp/homecp/.my/dir1/file11' -> '${TEST_HOME_DIR}/.my/dir1/file11'
  # '${TEST_WORKING_DIR}/tests/fixtures/packages/13homecp/homecp/.my/file1' -> '${TEST_HOME_DIR}/.my/file1'
  # '${TEST_WORKING_DIR}/tests/fixtures/packages/13homecp/homecp/.my/file2' -> '${TEST_HOME_DIR}/.my/file2'
  # '${TEST_WORKING_DIR}/tests/fixtures/packages/13homecp/homecp/.my-config.env' -> '${TEST_HOME_DIR}/.my-config.env'"

  assert [ ! -L "${TEST_HOME_DIR}/.my" ]
  assert [ -d "${TEST_HOME_DIR}/.my" ]

  assert [ ! -L "${TEST_HOME_DIR}/.my/dir1" ]
  assert [ -d "${TEST_HOME_DIR}/.my/dir1" ]

  assert [ ! -L "${TEST_HOME_DIR}/.my/dir1/file11" ]
  assert [ -f "${TEST_HOME_DIR}/.my/dir1/file11" ]

  assert [ ! -L "${TEST_HOME_DIR}/.my/file1" ]
  assert [ -f "${TEST_HOME_DIR}/.my/file1" ]

  assert [ ! -L "${TEST_HOME_DIR}/.my/file2" ]
  assert [ -f "${TEST_HOME_DIR}/.my/file2" ]

  assert [ ! -L "${TEST_HOME_DIR}/.my-config.env" ]
  assert [ -f "${TEST_HOME_DIR}/.my-config.env" ]

  rm -r "${TEST_HOME_DIR}/.my" "${TEST_HOME_DIR}/.my-config.env"
}

# Tests for ydf package install ./14rootcp
@test "ydf package install ./14rootcp Should succeed" {
  local -r _package_name="14rootcp"

  run ydf package install "$_package_name"

  assert_success
  #   assert_output "
  # '${TEST_WORKING_DIR}/tests/fixtures/packages/14rootcp/rootcp/.my' -> '/.my'
  # '${TEST_WORKING_DIR}/tests/fixtures/packages/14rootcp/rootcp/.my/dir1' -> '/.my/dir1'
  # '${TEST_WORKING_DIR}/tests/fixtures/packages/14rootcp/rootcp/.my/dir1/file11' -> '/.my/dir1/file11'
  # '${TEST_WORKING_DIR}/tests/fixtures/packages/14rootcp/rootcp/.my/file1' -> '/.my/file1'
  # '${TEST_WORKING_DIR}/tests/fixtures/packages/14rootcp/rootcp/.my/file2' -> '/.my/file2'
  # '${TEST_WORKING_DIR}/tests/fixtures/packages/14rootcp/rootcp/.my-config.env' -> '/.my-config.env'"

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
  local -r _package_name="15homecat"
  cp -r "${TEST_FIXTURES_DIR}/dirs/.my" ~/
  touch "${TEST_HOME_DIR}/.my-config.env"

  run ydf package install "$_package_name"

  assert_success
  assert_output ""

  run cat "${TEST_HOME_DIR}/.my/file1"

  assert_success
  assert_output "file1
added line1 to file1

added line2 to file1"

  run cat "${TEST_HOME_DIR}/.my/dir1/file11"

  assert_success
  assert_output "file11
# @CAT_SECTION_HOME_CAT

added line1 to file11
added line2 to file11

# :@CAT_SECTION_HOME_CAT"

  run cat "${TEST_HOME_DIR}/.my/file2"

  assert_success
  assert_output "file2"
}

# Tests for ydf package install ./16rootcat
@test "ydf package install ./16rootcat Should succeed" {
  local -r _package_name="16rootcat"
  sudo cp -r "${TEST_FIXTURES_DIR}/dirs/.my" /
  sudo touch /.my-config.env

  run ydf package install "$_package_name"

  assert_success
  assert_output ""

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
  local -r _package_name="17homecps"

  run ydf package install "$_package_name"

  assert_success
  assert_output ""

  run cat "${TEST_HOME_DIR}/.my/file1"

  assert_success
  assert_output "line 1

line 3"

  run cat "${TEST_HOME_DIR}/.my/dir1/file11"

  assert_success
  assert_output 'line 1

file11_1: "file11_1"

file11_2: file11 2





line 11'

  run cat "${TEST_HOME_DIR}/.my-config.env"

  assert_success
  assert_output 'line 1

my_config1: "my_config1"

my_config2: my config2





line 11'

  run ls -la "${TEST_HOME_DIR}/.my"

  assert_success
  assert_output --regexp ".* ${TEST_USER} ${TEST_GROUP} .* \.
.* ${TEST_USER} ${TEST_GROUP} .* \.\.
.* ${TEST_USER} ${TEST_GROUP} .* dir1
.* ${TEST_USER} ${TEST_GROUP}  .* file1"

  run ls -la "${TEST_HOME_DIR}/.my/file1" \
    "${TEST_HOME_DIR}/.my/dir1/file11" "${TEST_HOME_DIR}/.my-config.env"

  assert_success
  assert_output --regexp ".* ${TEST_USER} ${TEST_GROUP} .* ${TEST_HOME_DIR}/.my-config.env
.* ${TEST_USER} ${TEST_GROUP} .* ${TEST_HOME_DIR}/.my/dir1/file11
.* ${TEST_USER} ${TEST_GROUP} .* ${TEST_HOME_DIR}/.my/file1"
}

# Tests for ydf package install ./18rootcps
@test "ydf package install ./18rootcps Should succeed" {
  local -r _package_name="18rootcps"

  run ydf package install "$_package_name"

  assert_success
  assert_output ""

  run cat /.my/file1

  assert_success
  assert_output "line 1

line 3"

  run cat /.my/dir1/file11

  assert_success
  assert_output 'line 1

file11_1: "file11_1"

file11_2: file11 2





line 11'

  run cat /.my-config.env

  assert_success
  assert_output 'line 1

my_config1: "my_config1"

my_config2: my config2





line 11'

  run ls -la /.my

  assert_success
  assert_output --regexp ".* root root .* \.
.* root root .* \.\.
.* root root .* dir1
.* root root  .* file1"

  run ls -la /.my/file1 \
    /.my/dir1/file11 /.my-config.env

  assert_success
  assert_output --regexp ".* root root .* /.my-config.env
.* root root .* /.my/dir1/file11
.* root root .* /.my/file1"
}

# Tests for ydf package install ./19dconf
@test "ydf package install ./19dconf Should succeed" {
  if [[ "$TEST_CI" == true ]]; then
    skip "Not for CI"
  fi

  local -r _package_name="19dconf"

  run ydf package install "$_package_name"

  assert_success
  assert_output ""

  run dconf dump /org/gnome/desktop/peripherals/mouse/

  assert_success
  assert_output "[/]
speed=0.5"
}

# Tests for ydf package install ./20homecats
@test "ydf package install ./20homecats Should succeed" {
  local -r _package_name="20homecats"
  cp -r "${TEST_FIXTURES_DIR}/dirs/.my" ~/
  touch "${TEST_HOME_DIR}/.my-config.env"

  run ydf package install "$_package_name"

  assert_success
  assert_output ""

  run cat "${TEST_HOME_DIR}/.my/file1"

  assert_success
  assert_output "file1
added line1 to file1

added line2 to file1"

  run cat "${TEST_HOME_DIR}/.my/dir1/file11"

  assert_success
  assert_output 'file11
# @CAT_SECTION_HOME_CAT

line 1

file11_1: "file11_1"

file11_2: file11 2





line 11

# :@CAT_SECTION_HOME_CAT'

  run ls -la "${TEST_HOME_DIR}/.my"

  assert_success
  assert_output --regexp ".* ${TEST_USER} ${TEST_GROUP} .* \.
.* ${TEST_USER} ${TEST_GROUP} .* \.\.
.* ${TEST_USER} ${TEST_GROUP} .* dir1
.* ${TEST_USER} ${TEST_GROUP}  .* file1"

  run ls -la "${TEST_HOME_DIR}/.my/file1" \
    "${TEST_HOME_DIR}/.my/dir1/file11"

  assert_success
  assert_output --regexp ".* ${TEST_USER} ${TEST_GROUP} .* ${TEST_HOME_DIR}/.my/dir1/file11
.* ${TEST_USER} ${TEST_GROUP} .* ${TEST_HOME_DIR}/.my/file1"
}

# Tests for ydf package install ./21rootcats
@test "ydf package install ./21rootcats Should succeed" {
  local -r _package_name="21rootcats"
  sudo cp -r "${TEST_FIXTURES_DIR}/dirs/.my" /
  sudo touch /.my-config.env

  run ydf package install \
    --packages-dir "$YDF_PACKAGE_SERVICE_PACKAGES_DIR" \
    "$_package_name"

  assert_success
  assert_output ""

  run cat /.my/file1

  assert_success
  assert_output "file1
added line1 to file1

added line2 to file1"

  run cat /.my/dir1/file11

  assert_success
  assert_output 'file11
# @CAT_SECTION_HOME_CAT

line 1

file11_1: "file11_1"

file11_2: file11 2





line 11

# :@CAT_SECTION_HOME_CAT'

  run ls -la /.my

  assert_success
  assert_output --regexp ".* root root .* \.
.* root root .* \.\.
.* root root .* dir1
.* root root  .* file1"

  run ls -la /.my/file1 \
    /.my/dir1/file11

  assert_success
  assert_output --regexp ".* root root .* /.my/dir1/file11
.* root root .* /.my/file1"
}

# Tests for ydf package install bat rustscan
@test "ydf package install 1freedom 2preinstall, Should install multiple packages" {

  run ydf package install 1freedom 2preinstall

  assert_success
  assert_output "
preinstall succeed
postinstall

preinstall: preinstall succeed"
}

# Tests for ydf package install bat rustscan
@test "ydf package install ./selection, Should install multiple packages" {

  run ydf package install ./selection

  assert_success
  assert_output "
preinstall succeed
postinstall

preinstall: preinstall succeed"
}

# Tests for ydf package install ./24ydftheme
@test "ydf package install ./24ydftheme Should succeed" {
  local -r _package_name="24ydftheme"

  run ydf package install "$_package_name"

  assert_success
  assert_output "
'${TEST_HOME_DIR}/.yzsh/themes/local/24ydftheme.theme.zsh' -> '${TEST_WORKING_DIR}/tests/fixtures/packages/24ydftheme/24ydftheme.theme.zsh'"

  assert [ -L "${TEST_HOME_DIR}/.yzsh/themes/local/24ydftheme.theme.zsh" ]
  assert [ -f "${TEST_HOME_DIR}/.yzsh/themes/local/24ydftheme.theme.zsh" ]
}

# Tests for ydf package install 25bat@apt
@test "ydf package install 25bat@apt Should succeed" {
  if [[ "$YDF_PACKAGE_SERVICE_DEFAULT_OS" != ubuntu ]]; then
    skip "Only for ubuntu"
  fi

  sudo -E DEBIAN_FRONTEND=noninteractive apt remove -y bat

  local -r _package_name="25bat@apt"

  run ydf package install "$_package_name"

  assert_success
  assert_output --partial "Setting up bat"

  run apt -qq list --installed bat

  assert_success
  assert_output --partial "bat/"
}

# Tests for ydf package install bat
@test "ydf package install bat Should succeed with @apt" {
  if [[ "$YDF_PACKAGE_SERVICE_DEFAULT_OS" != ubuntu ]]; then
    skip "Only for ubuntu"
  fi

  sudo -E DEBIAN_FRONTEND=noninteractive apt remove -y bat

  local -r _package_name="bat"

  run ydf package install "$_package_name"

  assert_success
  assert_output --partial "Setting up bat"

  run apt -qq list --installed bat

  assert_success
  assert_output --partial "bat/"
}

# Tests for ydf package install 26exa@apt-get
@test "ydf package install 26exa@apt-get Should succeed with @apt-get" {
  if [[ "$YDF_PACKAGE_SERVICE_DEFAULT_OS" != ubuntu ]]; then
    skip "Only for ubuntu"
  fi

  sudo -E DEBIAN_FRONTEND=noninteractive apt remove -y exa

  local -r _package_name="26exa@apt-get"

  run ydf package install "$_package_name"

  assert_success
  assert_output --partial "Setting up exa"

  run apt -qq list --installed exa

  assert_success
  assert_output --partial "exa/"
}

# Tests for ydf package install exa
@test "ydf package install exa Should succeed with @apt-get" {
  if [[ "$YDF_PACKAGE_SERVICE_DEFAULT_OS" != ubuntu ]]; then
    skip "Only for ubuntu"
  fi

  sudo -E DEBIAN_FRONTEND=noninteractive apt remove -y exa

  local -r _package_name="exa"

  run ydf package install "$_package_name"

  assert_success
  assert_output --partial "Setting up exa"

  run apt -qq list --installed exa

  assert_success
  assert_output --partial "exa/"
}

# Tests for ydf package list
@test "ydf package list, Should show help" {

  for p in -h --help; do
    run ydf package list $p

    assert_success
    assert_output --partial 'ydf package list [OPTIONS]'
  done
}

@test "ydf package list  --packages-dir, Should fail with missing argument packages-dir" {

  run ydf package list --packages-dir

  assert_failure
  assert_output --partial 'ERROR> No packages dir specified'
}

@test "ydf package list  --packages-dir, Should fail If packages-dir doesn't exist" {

  run ydf package list --packages-dir 'asdfadf324325623afddwg11'

  assert_failure
  assert_output "ERROR> Packages directory 'asdfadf324325623afddwg11' doesn't exist"
}

@test "ydf package list, Should list packages" {

  export E_YDF_PACKAGE_SERVICE_PACKAGES_DIR="${TEST_FIXTURES_DIR}/packages3"

  run ydf package list

  assert_success
  assert_output "pkg1
pkg2
pkg3"
}

@test "ydf package list --packages-dir ..., Should list packages with" {

  run ydf package list --packages-dir "${TEST_FIXTURES_DIR}/packages3"

  assert_success
  assert_output "pkg1
pkg2
pkg3"
}
