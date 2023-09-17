load test_helper

setup() {
  ydf::package_service::constructor \
    "$YDF_PACKAGE_SERVICE_DEFAULT_OS" \
    "$YDF_YZSH_DATA_DIR" \
    "$YDF_YZSH_GEN_CONFIG_FILE"

  export __YDF_PACKAGE_SERVICE_DEFAULT_OS \
    __YDF_YZSH_DATA_DIR \
    __YDF_YZSH_GEN_CONFIG_FILE


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
@test "ydf::package_service::install_one_from_dir() Should fail if package_dir directory doesn't exist" {
  local -r _package_dir='asdjflk3408rgsjl'

  run ydf::package_service::install_one_from_dir "$_package_dir"

  assert_failure
  assert_output "ERROR> Directory 'asdjflk3408rgsjl' doesn't exist"
}

@test "ydf::package_service::install_one_from_dir() Should fail if get_instructions_names fails" {
  local -r _package_dir="$BATS_TEST_TMPDIR"

  ydf::package_service::get_instructions_names() {
    assert_equal "$*" ''

    return 1
  }

  run ydf::package_service::install_one_from_dir "$_package_dir"

  assert_failure
  assert_output "ERROR> Getting instructions names for os: "
}

@test "ydf::package_service::install_one_from_dir() Should fail if there is no instructions" {
  local -r _package_dir="$BATS_TEST_TMPDIR"

  ydf::package_service::get_instructions_names() {
    assert_equal "$*" ''
  }

  run ydf::package_service::install_one_from_dir "$_package_dir"

  assert_failure
  assert_output "ERROR> There is no instructions"
}

@test "ydf::package_service::install_one_from_dir() Should fail if changing dir fails" {
  local -r _package_dir="$BATS_TEST_TMPDIR"
  chmod 000 "$_package_dir"

  ydf::package_service::get_instructions_names() {
    assert_equal "$*" ''

    echo preinstall
  }

  run ydf::package_service::install_one_from_dir "$_package_dir"

  assert_failure
  assert_output --partial "ERROR> Changing the current directory to "
}

@test "ydf::package_service::install_one_from_dir() Should fail if at least one instruction fails" {
  local -r _package_dir="${TEST_FIXTURES_DIR}/packages/0freedom-fail"

  ydf::package_service::get_instructions_names() {
    assert_equal "$*" ''

    echo 'instruction1 preinstall'
  }
  ydf::package_service::__instruction_instruction1() {
    assert_equal "$*" ''
    echo instruction1
  }

  ydf::package_service::__instruction_preinstall() {
    assert_equal "$*" ''
    return 1
  }

  run ydf::package_service::install_one_from_dir "$_package_dir"

  assert_failure
  assert_output --regexp "ERROR> Executing instruction 'preinstall' on '.*/0freedom-fail'"
}

@test "ydf::package_service::install_one_from_dir() Should execute only instructions with files" {
  local -r _package_dir="${TEST_FIXTURES_DIR}/packages/0freedom-fail"

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
  run ydf::package_service::install_one_from_dir "$_package_dir"

  assert_success
  assert_output "docker_compose
preinstall"
}

@test "ydf::package_service::install_one_from_dir() Should succeed if all instructions are success" {
  local -r _package_dir="${TEST_FIXTURES_DIR}/packages/0freedom-fail"

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

  run ydf::package_service::install_one_from_dir "$_package_dir"

  assert_success
  assert_output "preinstall
postinstall
docker_compose"
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
  if ! command -v pacman &> /dev/null; then
    skip "pacman is not installed"
  fi

  cd "${TEST_FIXTURES_DIR}/packages/5dust@pacman"

  run ydf::package_service::__instruction_@pacman '5dust@pacman'

  assert_success
  assert_output --regexp "dust"
}

# Tests for ydf::package_service::__instruction_@yay()
@test "ydf::package_service::__instruction_@yay() Should succeed" {

  if ! command -v yay &> /dev/null; then
    skip "yay is not installed"
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
@test "ydf::package_service::__instruction_homecat() Should skip if dest_file doesn't exist" {

  cd "${TEST_FIXTURES_DIR}/packages/15homecat"

  run ydf::package_service::__instruction_homecat '15homecat'

  assert_success
  assert_output "WARNING> Skipped homecat, file '/home/vedv/.my/file1' doesn't exist
WARNING> Skipped homecat, file '/home/vedv/.my/dir1/file11' doesn't exist
WARNING> Skipped homecat, file '/home/vedv/.my-config.env' doesn't exist"
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

  cd "${TEST_FIXTURES_DIR}/packages/15homecat"

  run ydf::package_service::__instruction_homecat '15homecat'

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

# Tests for ydf::package_service::__instruction_rootcat()
@test "ydf::package_service::__instruction_rootcat() Should skip if dest_file doesn't exist" {

  cd "${TEST_FIXTURES_DIR}/packages/16rootcat"

  run ydf::package_service::__instruction_rootcat '16rootcat'

  assert_success
  assert_output "WARNING> Skipped rootcat, file '/.my/file1' doesn't exist
WARNING> Skipped rootcat, file '/.my/dir1/file11' doesn't exist
WARNING> Skipped rootcat, file '/.my-config.env' doesn't exist"
}

@test "ydf::package_service::__instruction_rootcat() Should fail if mark_concat fail" {

  sudo cp -r "${TEST_FIXTURES_DIR}/dirs/.my" /

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

  cd "${TEST_FIXTURES_DIR}/packages/16rootcat"

  run ydf::package_service::__instruction_rootcat '16rootcat'

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
