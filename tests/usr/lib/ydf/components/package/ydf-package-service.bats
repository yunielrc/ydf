load test_helper

setup() {
  ydf::package_service::constructor "$YDF_PACKAGE_SERVICE_DEFAULT_OS"
  export __YDF_PACKAGE_SERVICE_DEFAULT_OS
}

# teardown() {
#
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
  local -r _os_name='ubuntu'

  run ydf::package_service::get_instructions_names "$_os_name"

  assert_success
  assert_output --partial 'preinstall'
}

# Tests for ydf::package_service::__instruction_preinstall()
@test "ydf::package_service::__instruction_preinstall() Should succeed if there is no preinstall script" {

  # cd "${TEST_FIXTURES_DIR}/packages/1freedom"

  run ydf::package_service::__instruction_preinstall

  assert_success
  assert_output ''
}

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

@test "ydf::package_service::install_one_from_dir() Should succeed if all instructions are success" {
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
    echo preinstall
  }

  run ydf::package_service::install_one_from_dir "$_package_dir"

  assert_success
  assert_output "instruction1
preinstall"
}
