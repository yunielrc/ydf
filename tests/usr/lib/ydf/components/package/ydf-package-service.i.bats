# shellcheck disable=SC2317,SC2153
load test_helper

setup() {

  ydf::package_service::constructor \
    "$YDF_PACKAGE_SERVICE_DEFAULT_OS" \
    "$YDF_YZSH_DATA_DIR" \
    "$YDF_YZSH_GEN_CONFIG_FILE" \
    "${TEST_FIXTURES_DIR}/packages/envsubst.env" \
    "${TEST_FIXTURES_DIR}/packages"

  export __YDF_PACKAGE_SERVICE_DEFAULT_OS \
    __YDF_YZSH_DATA_DIR \
    __YDF_YZSH_GEN_CONFIG_FILE \
    __YDF_PACKAGE_SERVICE_ENVSUBST_FILE \
    __YDF_PACKAGE_SERVICE_PACKAGES_DIR

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

# Tests for ydf::package_service::get_instructions_names()
@test "ydf::package_service::get_instructions_names() Should list instructions names for default_os" {

  run ydf::package_service::get_instructions_names

  assert_success
  assert_output --partial 'preinstall'
}

@test "ydf::package_service::get_instructions_names() Should fail with invalid os_name" {
  local -r _os_name='invalid'

  run ydf::package_service::get_instructions_names "$_os_name"

  assert_failure
  assert_output 'ERROR> There is no instructions for os: invalid'
}

@test "ydf::package_service::get_instructions_names() Should succeed" {
  local -r _os_name='manjaro'

  run ydf::package_service::get_instructions_names "$_os_name"

  assert_success
  assert_output --partial 'preinstall'
}

# Tests for ydf::package_service::__instruction_preinstall()
@test "ydf::package_service::__instruction_preinstall() Should succeed if preinstall script succeed" {

  cd "${TEST_FIXTURES_DIR}/packages/1freedom"

  run ydf::package_service::__instruction_preinstall

  assert_success
  assert_output 'preinstall succeed'
}

@test "ydf::package_service::__instruction_preinstall() Should fail if preinstall script fails" {

  cd "${TEST_FIXTURES_DIR}/packages/0freedom-fail"

  run ydf::package_service::__instruction_preinstall

  assert_failure
  assert_output 'preinstall fails'
}

# Tests for ydf::package_service::install_one_from_dir()
@test "ydf::package_service::install_one_from_dir() Should fail if package doesn't exist" {
  local -r _package_name='asdjflk3408rgsjl'

  run ydf::package_service::install_one_from_dir "$_package_name"

  assert_failure
  assert_output "ERROR> Package 'asdjflk3408rgsjl' doesn't exist in '/home/vedv/ydf/tests/fixtures/packages'"
}

@test "ydf::package_service::install_one_from_dir() Should fail if get_instructions_names fails" {
  local -r _package_name="0freedom-fail"

  ydf::package_service::get_instructions_names() {
    assert_equal "$*" ''

    return 1
  }

  run ydf::package_service::install_one_from_dir "$_package_name"

  assert_failure
  assert_output "ERROR> Getting instructions names for os: "
}

@test "ydf::package_service::install_one_from_dir() Should fail if there is no instructions" {
  local -r _package_name="0freedom-fail"

  ydf::package_service::get_instructions_names() {
    assert_equal "$*" ''
  }

  run ydf::package_service::install_one_from_dir "$_package_name"

  assert_failure
  assert_output "ERROR> There is no instructions"
}

@test "ydf::package_service::install_one_from_dir() Should fail if changing dir fails" {

  local -r _package_name="pkg1"

  mkdir "${BATS_TEST_TMPDIR}/pkg1"
  chmod 000 "${BATS_TEST_TMPDIR}/pkg1"

  ydf::package_service::get_packages_dir() {
    echo "$BATS_TEST_TMPDIR"
  }

  ydf::package_service::get_instructions_names() {
    assert_equal "$*" ''

    echo preinstall
  }

  run ydf::package_service::install_one_from_dir "$_package_name"

  assert_failure
  assert_output --partial ">> INSTALLING: pkg1
>> FAILED. NOT INSTALLED: pkg1
ERROR> Changing current directory to "
}

@test "ydf::package_service::install_one_from_dir() Should fail if at least one instruction fails" {
  local -r _package_name="0freedom-fail"

  ydf::package_service::get_instructions_names() {
    assert_equal "$*" ''

    echo 'instruction1 preinstall'
  }
  ydf::package_service::__instruction_instruction1() {
    assert_equal "$*" ''
    echo instruction1
  }

  ydf::package_service::__instruction_preinstall() {
    assert_equal "$*" '0freedom-fail'
    return 1
  }

  run ydf::package_service::install_one_from_dir "$_package_name"

  assert_failure
  assert_output ">> INSTALLING: 0freedom-fail
>> FAILED. NOT INSTALLED: 0freedom-fail
ERROR> Executing instruction 'preinstall' on '/home/vedv/ydf/tests/fixtures/packages/0freedom-fail'"
}

@test "ydf::package_service::install_one_from_dir() Should execute only instructions with files" {
  local -r _package_name="0freedom-fail"

  ydf::package_service::get_instructions_names() {
    assert_equal "$*" ''

    echo 'docker_compose:docker-compose.yml instruction1 preinstall homeln/ install'
  }
  ydf::package_service::__instruction_docker_compose() {
    assert_equal "$*" '0freedom-fail'
    echo docker_compose
  }
  ydf::package_service::__instruction_instruction1() {
    assert_equal "$*" '0freedom-fail'
    echo instruction1
  }
  ydf::package_service::__instruction_preinstall() {
    assert_equal "$*" '0freedom-fail'
    echo preinstall
  }
  ydf::package_service::__instruction_homeln() {
    assert_equal "$*" '0freedom-fail'
    echo homeln
  }
  ydf::package_service::__instruction_install() {
    assert_equal "$*" '0freedom-fail'
    echo install
  }
  run ydf::package_service::install_one_from_dir "$_package_name"

  assert_success
  assert_output ">> INSTALLING: 0freedom-fail
docker_compose
preinstall
>> DONE. INSTALLED: 0freedom-fail"
}

@test "ydf::package_service::install_one_from_dir() Should succeed if all instructions are success" {
  local -r _package_name="0freedom-fail"

  ydf::package_service::get_instructions_names() {
    assert_equal "$*" ''

    echo 'preinstall postinstall docker_compose:docker-compose.yml'
  }
  ydf::package_service::__instruction_instruction1() {
    assert_equal "$*" '0freedom-fail'
    echo instruction1
  }

  ydf::package_service::__instruction_preinstall() {
    assert_equal "$*" '0freedom-fail'
    echo preinstall
  }
  ydf::package_service::__instruction_docker_compose() {
    assert_equal "$*" '0freedom-fail'
    echo docker_compose
  }

  run ydf::package_service::install_one_from_dir "$_package_name"

  assert_success
  assert_output ">> INSTALLING: 0freedom-fail
preinstall
postinstall
docker_compose
>> DONE. INSTALLED: 0freedom-fail"
}

@test "ydf::package_service::install_one_from_dir() Should succeed With a defined packages dir" {
  local -r _package_name="1liberty"
  local -r _os_name='manjaro'
  local -r _packages_dir="${TEST_FIXTURES_DIR}/packages2"

  ydf::package_service::get_instructions_names() {
    assert_equal "$*" 'manjaro'

    echo 'preinstall postinstall docker_compose:docker-compose.yml'
  }
  ydf::package_service::__instruction_instruction1() {
    assert_equal "$*" 'INVALID_CALL'
    return 1
  }
  ydf::package_service::__instruction_docker_compose() {
    assert_equal "$*" 'INVALID_CALL'
    return 1
  }

  run ydf::package_service::install_one_from_dir \
    "$_package_name" "$_os_name" "$_packages_dir"

  assert_success
  assert_output ">> INSTALLING: 1liberty
1liberty: preinstall succeed
1liberty: postinstall
>> DONE. INSTALLED: 1liberty"
}

# Tests for ydf::package_service::__instruction_install()
@test "ydf::package_service::__instruction_install() Should succeed if install script succeed" {

  cd "${TEST_FIXTURES_DIR}/packages/3install"

  run ydf::package_service::__instruction_install

  assert_success
  assert_output "3install: install succeed"
}

# Tests for ydf::package_service::__instruction_postinstall()
@test "ydf::package_service::__instruction_postinstall() Should succeed" {

  cd "${TEST_FIXTURES_DIR}/packages/4postinstall"

  run ydf::package_service::__instruction_postinstall

  assert_success
  assert_output "4postinstall: postinstall succeed"
}

# Tests for ydf::package_service::__instruction_@pacman()
@test "ydf::package_service::__instruction_@pacman() Should succeed" {
  if [[ "$YDF_PACKAGE_SERVICE_DEFAULT_OS" != manjaro ]]; then
    skip "Only for manjaro"
  fi

  cd "${TEST_FIXTURES_DIR}/packages/5dust@pacman"

  run ydf::package_service::__instruction_@pacman '5dust@pacman'

  assert_success
  assert_output --regexp "dust"
}

@test "ydf::package_service::__instruction_@pacman() Should succeed with multiples packages" {
  if [[ "$YDF_PACKAGE_SERVICE_DEFAULT_OS" != manjaro ]]; then
    skip "Only for manjaro"
  fi

  cd "${TEST_FIXTURES_DIR}/packages/21multi@pacman"

  run ydf::package_service::__instruction_@pacman '21multi@pacman'

  assert_success

  run pacman -Q dust nnn bat

  assert_success
  assert_output --regexp "dust .*
nnn .*
bat .*"
}

# Tests for ydf::package_service::__instruction_@yay()
@test "ydf::package_service::__instruction_@yay() Should succeed" {

  if [[ "$YDF_PACKAGE_SERVICE_DEFAULT_OS" != manjaro ]]; then
    skip "Only for manjaro"
  fi

  cd "${TEST_FIXTURES_DIR}/packages/6nnn@yay"

  run ydf::package_service::__instruction_@yay '6nnn@yay'

  assert_success
  assert_output --regexp "nnn"
}

# Tests for ydf::package_service::__instruction_@flatpak()
@test "ydf::package_service::__instruction_@flatpak() Should succeed" {

  cd "${TEST_FIXTURES_DIR}/packages/7micenter@flathub"

  run ydf::package_service::__instruction_@flatpak '7micenter@flathub'

  assert_success
  assert_output --partial "io.missioncenter.MissionCenter/x86_64/stable"
}

# Tests for ydf::package_service::__instruction_@snap()
@test "ydf::package_service::__instruction_@snap() Should succeed" {

  cd "${TEST_FIXTURES_DIR}/packages/8go@snap"

  run ydf::package_service::__instruction_@snap '8go@snap'

  assert_success
  assert_output --partial "go"

  run command -v go

  assert_success

  assert_output --partial 'bin/go'
}

# Tests for ydf::package_service::__instruction_docker_compose()
@test "ydf::package_service::__instruction_docker_compose() Should succeed" {
  skip 'it must be a manjaro rolling release problem'
  # Error response from daemon: failed to create endpoint hello_world on network 9hello-worlddockercomp_default: failed to add the host (veth00e7765) <=> sandbox (veth3a9fa13) pair interfaces: operation not supported
  cd "${TEST_FIXTURES_DIR}/packages/9hello-world@dockercomp"

  run ydf::package_service::__instruction_docker_compose '9hello-world@dockercomp'

  assert_success
  assert_output --partial "Container hello_world  Started"

  run docker container ls -qaf "name=hello_world"

  assert_success
  assert [ -n "$output" ]
}

# Tests for ydf::package_service::__instruction_plugin_zsh()
@test "ydf::package_service::__instruction_plugin_zsh() Should fail if ln fails" {
  cd "${TEST_FIXTURES_DIR}/packages/10ydfplugin"

  ln() {
    assert_equal "$*" "-vsf /home/vedv/ydf/tests/fixtures/packages/10ydfplugin/10ydfplugin.plugin.zsh /home/vedv/.yzsh/plugins/local/10ydfplugin.plugin.zsh"
    return 1
  }

  run ydf::package_service::__instruction_plugin_zsh '10ydfplugin'

  assert_failure
  assert_output "ERROR> Creating plugin symlink: /home/vedv/.yzsh/plugins/local/10ydfplugin.plugin.zsh"
}

@test "ydf::package_service::__instruction_plugin_zsh() Should add plugin" {
  cd "${TEST_FIXTURES_DIR}/packages/10ydfplugin"

  run ydf::package_service::__instruction_plugin_zsh '10ydfplugin'

  assert_success
  assert_output "'/home/vedv/.yzsh/plugins/local/10ydfplugin.plugin.zsh' -> '/home/vedv/ydf/tests/fixtures/packages/10ydfplugin/10ydfplugin.plugin.zsh'"

  assert [ -L '/home/vedv/.yzsh/plugins/local/10ydfplugin.plugin.zsh' ]
  assert [ -f '/home/vedv/.yzsh/plugins/local/10ydfplugin.plugin.zsh' ]

  run grep "YZSH_PLUGINS+=(10ydfplugin)" "$YDF_YZSH_GEN_CONFIG_FILE"

  assert_success
  assert_output "YZSH_PLUGINS+=(10ydfplugin)"

  run ydf::package_service::__instruction_plugin_zsh '10ydfplugin'

  assert_success
  assert_output "'/home/vedv/.yzsh/plugins/local/10ydfplugin.plugin.zsh' -> '/home/vedv/ydf/tests/fixtures/packages/10ydfplugin/10ydfplugin.plugin.zsh'
Plugin '10ydfplugin' already added to /home/vedv/.yzsh-gen.env"
}

# Tests for ydf::package_service::__instruction_homeln()
@test "ydf::package_service::__instruction_homeln() Should succeed" {
  cd "${TEST_FIXTURES_DIR}/packages/11homeln"

  run ydf::package_service::__instruction_homeln '11homeln'

  assert_success
  assert_output "'/home/vedv/.my' -> '/home/vedv/ydf/tests/fixtures/packages/11homeln/homeln/.my'
'/home/vedv/.my-config.env' -> '/home/vedv/ydf/tests/fixtures/packages/11homeln/homeln/.my-config.env'"

  assert [ -L '/home/vedv/.my' ]
  assert [ -d '/home/vedv/.my' ]
  assert [ -L '/home/vedv/.my-config.env' ]
  assert [ -f '/home/vedv/.my-config.env' ]

  rm /home/vedv/.my /home/vedv/.my-config.env
}

# Tests for ydf::package_service::__instruction_homelnr()
@test "ydf::package_service::__instruction_homelnr() Should succeed" {
  cd "${TEST_FIXTURES_DIR}/packages/12homelnr"

  run ydf::package_service::__instruction_homelnr '12homelnr'

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

# Tests for ydf::package_service::__instruction_homecp()
@test "ydf::package_service::__instruction_homecp() Should succeed" {
  cd "${TEST_FIXTURES_DIR}/packages/13homecp"

  run ydf::package_service::__instruction_homecp '13homecp'

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

# Tests for ydf::package_service::__instruction_rootcp()
@test "ydf::package_service::__instruction_rootcp() Should succeed" {
  cd "${TEST_FIXTURES_DIR}/packages/14rootcp"

  run ydf::package_service::__instruction_rootcp '14rootcp'

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

# Tests for ydf::package_service::__instruction_homecat()
@test "ydf::package_service::__instruction_homecat() Should fail if dest_file doesn't exist" {
  cd "${TEST_FIXTURES_DIR}/packages/15homecat"

  run ydf::package_service::__instruction_homecat '15homecat'

  assert_failure
  assert_output "ERROR> homecat, file '/home/vedv/.my/file1' doesn't exist"
}

@test "ydf::package_service::__instruction_homecat() Should fail if mark_concat fail" {

  cp -r "${TEST_FIXTURES_DIR}/dirs/.my" ~/

  cd "${TEST_FIXTURES_DIR}/packages/15homecat"

  ydf::utils::mark_concat() {
    assert_equal "$*" "homecat/.my/file1 /home/vedv/.my/file1"
    return 1
  }

  run ydf::package_service::__instruction_homecat '15homecat'

  assert_failure
  assert_output "ERROR> Marking concat for 'homecat/.my/file1' to '/home/vedv/.my/file1'"
}

@test "ydf::package_service::__instruction_homecat() Should succeed" {

  cp -r "${TEST_FIXTURES_DIR}/dirs/.my" ~/
  touch /home/vedv/.my-config.env

  cd "${TEST_FIXTURES_DIR}/packages/15homecat"

  run ydf::package_service::__instruction_homecat '15homecat'

  assert_success
  assert_output ""

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

# Tests for ydf::package_service::__instruction_rootcat()
@test "ydf::package_service::__instruction_rootcat() Should fail if dest_file doesn't exist" {
  cd "${TEST_FIXTURES_DIR}/packages/16rootcat"

  run ydf::package_service::__instruction_rootcat '16rootcat'

  assert_failure
  assert_output "ERROR> rootcat, file '/.my/file1' doesn't exist"
}

@test "ydf::package_service::__instruction_rootcat() Should fail if mark_concat fail" {

  sudo cp -r "${TEST_FIXTURES_DIR}/dirs/.my" /
  sudo touch /.my-config.env

  cd "${TEST_FIXTURES_DIR}/packages/16rootcat"

  ydf::utils::mark_concat() {
    assert_equal "$*" "rootcat/.my/file1 /.my/file1"
    return 1
  }

  run ydf::package_service::__instruction_rootcat '16rootcat'

  assert_failure
  assert_output "ERROR> Marking concat for 'rootcat/.my/file1' to '/.my/file1'"
}

@test "ydf::package_service::__instruction_rootcat() Should succeed" {

  sudo cp -r "${TEST_FIXTURES_DIR}/dirs/.my" /
  sudo touch /.my-config.env

  cd "${TEST_FIXTURES_DIR}/packages/16rootcat"

  run ydf::package_service::__instruction_rootcat '16rootcat'

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

# Tests for ydf::package_service::__recursive_copy_with_envsubst()
@test "ydf::package_service::__recursive_copy_with_envsubst() Should fail Without package_name" {

  cd "${TEST_FIXTURES_DIR}/packages/17homecps"

  local -r _package_name=''
  local -r _instruction=''

  run ydf::package_service::__recursive_copy_with_envsubst \
    "$_package_name" "$_instruction"

  assert_failure
  assert_output "ERROR> Package name must not be empty"
}

@test "ydf::package_service::__recursive_copy_with_envsubst() Should fail With invalid instruction" {

  cd "${TEST_FIXTURES_DIR}/packages/17homecps"

  local -r _package_name='17homecps'
  local -r _instruction='invalid'

  run ydf::package_service::__recursive_copy_with_envsubst \
    "$_package_name" "$_instruction"

  assert_failure
  assert_output "ERROR> Instruction must be 'homecps' or 'rootcps'"

}

@test "ydf::package_service::__recursive_copy_with_envsubst() Should fail If copy_with_envar_sub fails" {

  cd "${TEST_FIXTURES_DIR}/packages/17homecps"

  local -r _package_name='17homecps'
  local -r _instruction='homecps'

  ydf::utils::copy_with_envar_sub() {
    assert_equal "$*" "homecps/.my/file1 /home/vedv/.my/file1 /home/vedv/ydf/tests/fixtures/packages/envsubst.env"
    return 1
  }

  run ydf::package_service::__recursive_copy_with_envsubst \
    "$_package_name" "$_instruction"

  assert_failure
  assert_output "ERROR> Copying with envar substitution file 'homecps/.my/file1' to '/home/vedv/.my/file1'"
}

@test "ydf::package_service::__recursive_copy_with_envsubst() Should succeed" {

  cd "${TEST_FIXTURES_DIR}/packages/17homecps"

  local -r _package_name='17homecps'
  local -r _instruction='homecps'

  run ydf::package_service::__recursive_copy_with_envsubst \
    "$_package_name" "$_instruction"

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

@test "ydf::package_service::__recursive_copy_with_envsubst() Should succeed With user root" {

  cd "${TEST_FIXTURES_DIR}/packages/18rootcps"

  local -r _package_name='18rootcps'
  local -r _instruction='rootcps'

  run ydf::package_service::__recursive_copy_with_envsubst \
    "$_package_name" "$_instruction"

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

# Tests for ydf::package_service::__instruction_homecps()
@test "ydf::package_service::__instruction_homecps() DUMMY" {
  :
}

# Tests for ydf::package_service::__instruction_rootcps()
@test "ydf::package_service::__instruction_rootcps() DUMMY" {
  :
}

# Tests for ydf::package_service::__instruction_dconf_ini()
@test "ydf::package_service::__instruction_dconf_ini() DUMMY" {
  :
}

# Tests for ydf::package_service::__recursive_mark_concat_with_envsubst()
@test "ydf::package_service::__recursive_mark_concat_with_envsubst() Should fail Without package_name" {

  cd "${TEST_FIXTURES_DIR}/packages/20homecats"

  local -r _package_name=''
  local -r _instruction=''

  run ydf::package_service::__recursive_mark_concat_with_envsubst \
    "$_package_name" "$_instruction"

  assert_failure
  assert_output "ERROR> Package name must not be empty"
}

@test "ydf::package_service::__recursive_mark_concat_with_envsubst() Should fail With invalid instruction" {

  cd "${TEST_FIXTURES_DIR}/packages/20homecats"

  local -r _package_name='20homecats'
  local -r _instruction='invalid'

  run ydf::package_service::__recursive_mark_concat_with_envsubst \
    "$_package_name" "$_instruction"

  assert_failure
  assert_output "ERROR> Instruction must be: homecats or rootcats"

}

@test "ydf::package_service::__recursive_mark_concat_with_envsubst() Should fail if dest_file doesn't exist" {

  cd "${TEST_FIXTURES_DIR}/packages/20homecats"

  local -r _package_name='20homecats'
  local -r _instruction='homecats'

  ydf::utils::mark_concat_with_envar_sub() {
    assert_equal "$*" "homecats/.my/file1 /home/vedv/.my/file1 /home/vedv/ydf/tests/fixtures/packages/envsubst.env"
    return 1
  }

  run ydf::package_service::__recursive_mark_concat_with_envsubst \
    "$_package_name" "$_instruction"

  assert_failure
  assert_output "ERROR> homecats, file '/home/vedv/.my/file1' doesn't exist"
}

@test "ydf::package_service::__recursive_mark_concat_with_envsubst() Should fail If mark_concat_with_envar_sub fails" {

  cd "${TEST_FIXTURES_DIR}/packages/20homecats"
  cp -r "${TEST_FIXTURES_DIR}/dirs/.my" ~/
  touch /home/vedv/.my-config.env

  local -r _package_name='20homecats'
  local -r _instruction='homecats'

  ydf::utils::mark_concat_with_envar_sub() {
    assert_equal "$*" "homecats/.my/file1 /home/vedv/.my/file1 /home/vedv/ydf/tests/fixtures/packages/envsubst.env"
    return 1
  }

  run ydf::package_service::__recursive_mark_concat_with_envsubst \
    "$_package_name" "$_instruction"

  assert_failure
  assert_output "ERROR> Concat with envar substitution file 'homecats/.my/file1' to '/home/vedv/.my/file1'"
}

@test "ydf::package_service::__recursive_mark_concat_with_envsubst() Should succeed" {

  cd "${TEST_FIXTURES_DIR}/packages/20homecats"
  cp -r "${TEST_FIXTURES_DIR}/dirs/.my" ~/
  touch /home/vedv/.my-config.env

  local -r _package_name='20homecats'
  local -r _instruction='homecats'

  run ydf::package_service::__recursive_mark_concat_with_envsubst \
    "$_package_name" "$_instruction"

  assert_success
  assert_output ""

  run cat /home/vedv/.my/file1

  assert_success
  assert_output "file1
added line1 to file1

added line2 to file1"

  run cat /home/vedv/.my/dir1/file11

  assert_success
  assert_output 'file11
# @CAT_SECTION_HOME_CAT

line 1

file11_1: "file11_1"

file11_2: file11 2





line 11

# :@CAT_SECTION_HOME_CAT'

  run ls -la /home/vedv/.my

  assert_success
  assert_output --regexp ".* vedv vedv .* \.
.* vedv vedv .* \.\.
.* vedv vedv .* dir1
.* vedv vedv  .* file1"

  run ls -la /home/vedv/.my/file1 \
    /home/vedv/.my/dir1/file11

  assert_success
  assert_output --regexp ".* vedv vedv .* /home/vedv/.my/dir1/file11
.* vedv vedv .* /home/vedv/.my/file1"
}

@test "ydf::package_service::__recursive_mark_concat_with_envsubst() Should succeed With user root" {

  cd "${TEST_FIXTURES_DIR}/packages/21rootcats"
  sudo cp -r "${TEST_FIXTURES_DIR}/dirs/.my" /
  sudo touch /.my-config.env

  local -r _package_name='21rootcats'
  local -r _instruction='rootcats'

  run ydf::package_service::__recursive_mark_concat_with_envsubst \
    "$_package_name" "$_instruction"

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

# Tests for ydf::package_service::__instruction_homecats()
@test "ydf::package_service::__instruction_homecats() DUMMY" {
  :
}

# Tests for ydf::package_service::__instruction_rootcats()
@test "ydf::package_service::__instruction_rootcats() DUMMY" {
  :
}

# Tests for ydf::package_service::install_one()
@test "ydf::package_service::install_one() DUMMY" {
  :
}

# Tests for ydf::package_service::__install_one_batch()
@test "ydf::package_service::__install_one_batch() DUMMY" {
  :
}

# Tests for ydf::package_service::install()
@test "ydf::package_service::install() Should fail without packages_names" {
  local -r _packages_names=""
  local -r _os_name=""
  local -r _packages_dir=""

  run ydf::package_service::install \
    "$_packages_names" "$_os_name" "$_packages_dir"

  assert_failure
  assert_output "ERROR> Packages names must not be empty"
}

@test "ydf::package_service::install() Should succeed" {
  local -r _packages_names="p1 p2 p3"
  local -r _os_name=""
  local -r _packages_dir=""

  ydf::utils::for_each() {
    assert_equal "$*" "p1 p2 p3 ydf::package_service::__install_one_batch '' ''"
  }

  run ydf::package_service::install \
    "$_packages_names" "$_os_name" "$_packages_dir"

  assert_success
  assert_output "> INSTALLING 3 packages
> DONE. INSTALLED 3 packages"
}

@test "ydf::package_service::install() Should fail If at least one package fails" {
  local -r _packages_names="p1 p2 p3"
  local -r _os_name="manjaro"
  local -r _packages_dir="../packages2"

  ydf::utils::for_each() {
    assert_equal "$*" "p1 p2 p3 ydf::package_service::__install_one_batch 'manjaro' '../packages2'"
    return 1
  }

  run ydf::package_service::install \
    "$_packages_names" "$_os_name" "$_packages_dir"

  assert_failure
  assert_output "> INSTALLING 3 packages
> FAILED. INSTALLING packages
ERROR> Installing packages"
}
