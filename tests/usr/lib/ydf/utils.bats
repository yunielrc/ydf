load test_helper

# setup() {
#
# }

# teardown() {
#
# }

# Tests for ydf::utils::print_1line()
@test "ydf::utils::print_1line() Should print nothing" {

  run ydf::utils::print_1line </dev/null

  assert_success
  assert_output ""
}

@test "ydf::utils::print_1line() Should print packages" {

  run ydf::utils::print_1line <<EOF

dust htop

EOF

  assert_success
  assert_output "dust htop"
}

# Tests for ydf::utils::mark_concat()
@test "ydf::utils::mark_concat() Should fail If src_file doesn't exist" {
  local -r _src_file=""
  local -r _dest_file=""

  run ydf::utils::mark_concat "$_src_file" "$_dest_file"

  assert_failure
  assert_output "ERROR> File src '' doesn't exist"
}

@test "ydf::utils::mark_concat() Should fail If dest_file doesn't exist" {
  local -r _src_file="$(mktemp)"
  local -r _dest_file=""

  run ydf::utils::mark_concat "$_src_file" "$_dest_file"

  assert_failure
  assert_output "ERROR> File dest '' doesn't exist"
}

@test "ydf::utils::mark_concat() Should succeed With user root and without mark" {
  cp -r "${TEST_FIXTURES_DIR}/dirs/.my" "$BATS_TEST_TMPDIR"

  local -r _src_file="${TEST_FIXTURES_DIR}/packages/15homecat/homecat/.my/file1"
  local -r _dest_file="${BATS_TEST_TMPDIR}/.my/file1"

  chmod -w "$_dest_file"

  sudo() {
    # sed can not be called without mark
    if [[ "$*" == *"sed -i /\s*$/,/:\s*$/d"* ]]; then
      return 1
    fi
    command sudo "$@"
  }

  run ydf::utils::mark_concat "$_src_file" "$_dest_file"

  assert_success
  assert_output "added line1 to file1

added line2 to file1"

  run cat "$_dest_file"

  assert_success
  assert_output "file1
added line1 to file1

added line2 to file1"
}

@test "ydf::utils::mark_concat() Should fail if sed fails" {
  cp -r "${TEST_FIXTURES_DIR}/dirs/.my" "$BATS_TEST_TMPDIR"

  local -r _src_file="${TEST_FIXTURES_DIR}/packages/15homecat/homecat/.my/dir1/file11"
  local -r _dest_file="${BATS_TEST_TMPDIR}/.my/dir1/file11"

  chmod -w "$_dest_file"

  sudo() {
    # sed must be called with mark
    if [[ "$*" == *"sed -i /@CAT_SECTION_HOME_CAT\s*$/,/:@CAT_SECTION_HOME_CAT\s*$/d"* ]]; then
      return 1
    fi
    command sudo "$@"
  }

  run ydf::utils::mark_concat "$_src_file" "$_dest_file"

  assert_failure
  assert_output "ERROR> Failed to remove previous added section"
}

@test "ydf::utils::mark_concat() Should succeed With user root and with mark" {
  cp -r "${TEST_FIXTURES_DIR}/dirs/.my" "$BATS_TEST_TMPDIR"

  local -r _src_file="${TEST_FIXTURES_DIR}/packages/15homecat/homecat/.my/dir1/file11"
  local -r _dest_file="${BATS_TEST_TMPDIR}/.my/dir1/file11"

  chmod -w "$_dest_file"

  sudo() {
    # sed must be called with mark
    if [[ "$*" != *"-u root"* ]]; then
      return 1
    fi
    command sudo "$@"
  }

  run ydf::utils::mark_concat "$_src_file" "$_dest_file"

  assert_success
  assert_output "# @CAT_SECTION_HOME_CAT

added line1 to file11
added line2 to file11

# :@CAT_SECTION_HOME_CAT"

  run cat "$_dest_file"

  assert_success
  assert_output "file11
# @CAT_SECTION_HOME_CAT

added line1 to file11
added line2 to file11

# :@CAT_SECTION_HOME_CAT"
}

@test "ydf::utils::mark_concat() Should succeed With mark" {
  cp -r "${TEST_FIXTURES_DIR}/dirs/.my" "$BATS_TEST_TMPDIR"

  local -r _src_file="${TEST_FIXTURES_DIR}/packages/15homecat/homecat/.my/dir1/file11"
  local -r _dest_file="${BATS_TEST_TMPDIR}/.my/dir1/file11"

  sudo() {
    # sed must be called with mark
    if [[ "$*" != *"-u vedv"* ]]; then
      return 1
    fi
    command sudo "$@"
  }

  run ydf::utils::mark_concat "$_src_file" "$_dest_file"

  assert_success
  assert_output "# @CAT_SECTION_HOME_CAT

added line1 to file11
added line2 to file11

# :@CAT_SECTION_HOME_CAT"

  run cat "$_dest_file"

  assert_success
  assert_output "file11
# @CAT_SECTION_HOME_CAT

added line1 to file11
added line2 to file11

# :@CAT_SECTION_HOME_CAT"
}

@test "ydf::utils::mark_concat() Should not duplicate file content When mark is present" {
  cp -r "${TEST_FIXTURES_DIR}/dirs/.my" "$BATS_TEST_TMPDIR"

  local -r _src_file="${TEST_FIXTURES_DIR}/packages/15homecat/homecat/.my/dir1/file11"
  local -r _dest_file="${BATS_TEST_TMPDIR}/.my/dir1/file11"

  sudo() {
    # sed must be called with mark
    if [[ "$*" != *"-u vedv"* ]]; then
      return 1
    fi
    command sudo "$@"
  }

  run ydf::utils::mark_concat "$_src_file" "$_dest_file"

  assert_success
  assert_output "# @CAT_SECTION_HOME_CAT

added line1 to file11
added line2 to file11

# :@CAT_SECTION_HOME_CAT"

  run cat "$_dest_file"

  assert_success
  assert_output "file11
# @CAT_SECTION_HOME_CAT

added line1 to file11
added line2 to file11

# :@CAT_SECTION_HOME_CAT"

  run ydf::utils::mark_concat "$_src_file" "$_dest_file"

  assert_success
  assert_output "# @CAT_SECTION_HOME_CAT

added line1 to file11
added line2 to file11

# :@CAT_SECTION_HOME_CAT"

  run cat "$_dest_file"

  assert_success
  assert_output "file11
# @CAT_SECTION_HOME_CAT

added line1 to file11
added line2 to file11

# :@CAT_SECTION_HOME_CAT"
}

@test "ydf::utils::mark_concat() Should duplicate file content When no mark" {
  cp -r "${TEST_FIXTURES_DIR}/dirs/.my" "$BATS_TEST_TMPDIR"

  local -r _src_file="${TEST_FIXTURES_DIR}/packages/15homecat/homecat/.my/file1"
  local -r _dest_file="${BATS_TEST_TMPDIR}/.my/file1"

  sudo() {
    # sed must be called with mark
    if [[ "$*" != *"-u vedv"* ]]; then
      return 1
    fi
    command sudo "$@"
  }

  run ydf::utils::mark_concat "$_src_file" "$_dest_file"

  assert_success
  assert_output "added line1 to file1

added line2 to file1"

  run cat "$_dest_file"

  assert_success
  assert_output "file1
added line1 to file1

added line2 to file1"

  run ydf::utils::mark_concat "$_src_file" "$_dest_file"

  assert_success
  assert_output "added line1 to file1

added line2 to file1"

  run cat "$_dest_file"

  assert_success
  assert_output "file1
added line1 to file1

added line2 to file1
added line1 to file1

added line2 to file1"
}


# Tests for ydf::utils::copy_with_envar_sub()
@test "ydf::utils::copy_with_envar_sub() Should fail If src_file doesn't exist" {
  local -r _src_file=""
  local -r _dest_file=""
  local -r env_file=""

  run ydf::utils::copy_with_envar_sub \
    "$_src_file" "$_dest_file" "$env_file"

  assert_failure
  assert_output "ERROR> File src '' doesn't exist"
}

@test "ydf::utils::copy_with_envar_sub() Should fail If src_file is not a text file" {
  local -r _src_file="$(mktemp)"
  local -r _dest_file=""
  local -r env_file=""

  run ydf::utils::copy_with_envar_sub \
    "$_src_file" "$_dest_file" "$env_file"

  assert_failure
  assert_output --regexp "ERROR> File src '.*' is not a text file"
}

@test "ydf::utils::copy_with_envar_sub() Should fail If dest_file is empty" {
  local -r _src_file="$(mktemp)"
  local -r _dest_file=""
  local -r env_file=""

  echo "line 1" >"$_src_file"

  run ydf::utils::copy_with_envar_sub \
    "$_src_file" "$_dest_file" "$env_file"

  assert_failure
  assert_output "ERROR> Argument dest_file '' can't be empty"
}

@test "ydf::utils::copy_with_envar_sub() Should fail If env_file doesn't exist" {
  local -r _src_file="$(mktemp)"
  local -r _dest_file="/tmp/dest_file"
  local -r env_file=""

  echo "line 1" >"$_src_file"

  run ydf::utils::copy_with_envar_sub \
    "$_src_file" "$_dest_file" "$env_file"

  assert_failure
  assert_output "ERROR> File env '' doesn't exist"
}

@test "ydf::utils::copy_with_envar_sub() Should fail If mkdir fails" {
  local -r _src_file="${TEST_FIXTURES_DIR}/packages/17homecps/homecps/.my-config.env"
  local -r _dest_file="/.my/.my-config.env"
  local -r env_file="${TEST_FIXTURES_DIR}/packages/envsubst.env"

  sudo() {
    case "$*" in
      mkdir* )
        return 1
        ;;
      * )
        command sudo "$@"
        ;;
    esac
  }

  run ydf::utils::copy_with_envar_sub \
    "$_src_file" "$_dest_file" "$env_file"

  assert_failure
  assert_output "ERROR> Failed to create directory '/.my'"
}

@test "ydf::utils::copy_with_envar_sub() Should succeed with root user" {
  local -r _src_file="${TEST_FIXTURES_DIR}/packages/17homecps/homecps/.my-config.env"
  local -r _dest_file="/.my/.my-config.env"
  local -r env_file="${TEST_FIXTURES_DIR}/packages/envsubst.env"

  run ydf::utils::copy_with_envar_sub \
    "$_src_file" "$_dest_file" "$env_file"

  assert_success
  assert_output ""

  run cat "$_dest_file"

  assert_success
  assert_output 'line 1

my_config1: "my_config1"

my_config2: my config2





line 11'

  run ls -la "$_dest_file"

  assert_success
  assert_output --partial "root root"
}

@test "ydf::utils::copy_with_envar_sub() Should succeed" {
  local -r _src_file="${TEST_FIXTURES_DIR}/packages/17homecps/homecps/.my-config.env"
  local -r _dest_file=~/.my-config.env
  local -r env_file="${TEST_FIXTURES_DIR}/packages/envsubst.env"

  sudo() {
    assert_equal "$*" '-u vedv tee /home/vedv/.my-config.env'
    command sudo "$@"
  }

  run ydf::utils::copy_with_envar_sub \
    "$_src_file" "$_dest_file" "$env_file"

  assert_success
  assert_output ""

  run cat "$_dest_file"

  assert_success
  assert_output 'line 1

my_config1: "my_config1"

my_config2: my config2





line 11'

  run ls -la "$_dest_file"

  assert_success
  assert_output --partial "vedv vedv"
}

# Tests for ydf::utils::mark_concat_with_envar_sub()
@test "ydf::utils::mark_concat_with_envar_sub() Should fail If src_file doesn't exist" {
  local -r _src_file=""
  local -r _dest_file=""
  local -r _env_file=""


  run ydf::utils::mark_concat_with_envar_sub "$_src_file" "$_dest_file" "$_env_file"

  assert_failure
  assert_output "ERROR> File src '' doesn't exist"
}

@test "ydf::utils::mark_concat_with_envar_sub() Should fail If src_file is not a text file" {
  local -r _src_file="$(mktemp)"
  local -r _dest_file=""
  local -r _env_file=""


  run ydf::utils::mark_concat_with_envar_sub "$_src_file" "$_dest_file" "$_env_file"

  assert_failure
  assert_output --regexp "ERROR> File src '.*' is not a text file"
}

@test "ydf::utils::mark_concat_with_envar_sub() Should fail If dest_file doesn't exist" {
  local -r _src_file="$(mktemp)"
  local -r _dest_file=""
  local -r _env_file=""
  echo "line 1" >"$_src_file"

  run ydf::utils::mark_concat_with_envar_sub "$_src_file" "$_dest_file" "$_env_file"

  assert_failure
  assert_output "ERROR> File dest '' doesn't exist"
}

@test "ydf::utils::mark_concat_with_envar_sub() Should fail If env_file doesn't exist" {
  local -r _src_file="$(mktemp)"
  local -r _dest_file="$(mktemp)"
  local -r _env_file=""
  echo "line 1" >"$_src_file"

  run ydf::utils::mark_concat_with_envar_sub "$_src_file" "$_dest_file" "$_env_file"

  assert_failure
  assert_output "ERROR> File env '' doesn't exist"
}

@test "ydf::utils::mark_concat_with_envar_sub() Should succeed With user root and without mark" {
  cp -r "${TEST_FIXTURES_DIR}/dirs/.my" "$BATS_TEST_TMPDIR"

  local -r _src_file="${TEST_FIXTURES_DIR}/packages/20homecats/homecats/.my/file1"
  local -r _dest_file="${BATS_TEST_TMPDIR}/.my/file1"
  local -r _env_file="${TEST_FIXTURES_DIR}/packages/envsubst.env"

  chmod -w "$_dest_file"

  sudo() {
    # sed can not be called without mark
    if [[ "$*" == *"sed -i /\s*$/,/:\s*$/d"* ]]; then
      return 1
    fi
    command sudo "$@"
  }

  run ydf::utils::mark_concat_with_envar_sub "$_src_file" "$_dest_file" "$_env_file"

  assert_success
  assert_output ""

  run cat "$_dest_file"

  assert_success
  assert_output "file1
added line1 to file1

added line2 to file1"
}

@test "ydf::utils::mark_concat_with_envar_sub() Should fail if sed fails" {
  cp -r "${TEST_FIXTURES_DIR}/dirs/.my" "$BATS_TEST_TMPDIR"

  local -r _src_file="${TEST_FIXTURES_DIR}/packages/20homecats/homecats/.my/dir1/file11"
  local -r _dest_file="${BATS_TEST_TMPDIR}/.my/dir1/file11"
  local -r _env_file="${TEST_FIXTURES_DIR}/packages/envsubst.env"


  chmod -w "$_dest_file"

  sudo() {
    # sed must be called with mark
    if [[ "$*" == *"sed -i /@CAT_SECTION_HOME_CAT\s*$/,/:@CAT_SECTION_HOME_CAT\s*$/d"* ]]; then
      return 1
    fi
    command sudo "$@"
  }

  run ydf::utils::mark_concat_with_envar_sub "$_src_file" "$_dest_file" "$_env_file"

  assert_failure
  assert_output "ERROR> Failed to remove previous added section"
}

@test "ydf::utils::mark_concat_with_envar_sub() Should succeed With user root and with mark" {
  cp -r "${TEST_FIXTURES_DIR}/dirs/.my" "$BATS_TEST_TMPDIR"

  local -r _src_file="${TEST_FIXTURES_DIR}/packages/20homecats/homecats/.my/dir1/file11"
  local -r _dest_file="${BATS_TEST_TMPDIR}/.my/dir1/file11"
  local -r _env_file="${TEST_FIXTURES_DIR}/packages/envsubst.env"

  chmod -w "$_dest_file"

  sudo() {
    # sed must be called with mark
    if [[ "$*" != *"-u root"* ]]; then
      return 1
    fi
    command sudo "$@"
  }

  run ydf::utils::mark_concat_with_envar_sub "$_src_file" "$_dest_file" "$_env_file"

  assert_success
  assert_output ""

  run cat "$_dest_file"

  assert_success
  assert_output 'file11
# @CAT_SECTION_HOME_CAT

line 1

file11_1: "file11_1"

file11_2: file11 2





line 11

# :@CAT_SECTION_HOME_CAT'
}

@test "ydf::utils::mark_concat_with_envar_sub() Should succeed With mark" {
  cp -r "${TEST_FIXTURES_DIR}/dirs/.my" "$BATS_TEST_TMPDIR"

  local -r _src_file="${TEST_FIXTURES_DIR}/packages/20homecats/homecats/.my/dir1/file11"
  local -r _dest_file="${BATS_TEST_TMPDIR}/.my/dir1/file11"
  local -r _env_file="${TEST_FIXTURES_DIR}/packages/envsubst.env"

  sudo() {
    # sed must be called with mark
    if [[ "$*" != *"-u vedv"* ]]; then
      return 1
    fi
    command sudo "$@"
  }

  run ydf::utils::mark_concat_with_envar_sub "$_src_file" "$_dest_file" "$_env_file"

  assert_success
  assert_output ""

  run cat "$_dest_file"

  assert_success
  assert_output 'file11
# @CAT_SECTION_HOME_CAT

line 1

file11_1: "file11_1"

file11_2: file11 2





line 11

# :@CAT_SECTION_HOME_CAT'
}

@test "ydf::utils::mark_concat_with_envar_sub() Should not duplicate file content When mark is present" {
  cp -r "${TEST_FIXTURES_DIR}/dirs/.my" "$BATS_TEST_TMPDIR"

  local -r _src_file="${TEST_FIXTURES_DIR}/packages/20homecats/homecats/.my/dir1/file11"
  local -r _dest_file="${BATS_TEST_TMPDIR}/.my/dir1/file11"
  local -r _env_file="${TEST_FIXTURES_DIR}/packages/envsubst.env"

  sudo() {
    # sed must be called with mark
    if [[ "$*" != *"-u vedv"* ]]; then
      return 1
    fi
    command sudo "$@"
  }

  run ydf::utils::mark_concat_with_envar_sub "$_src_file" "$_dest_file" "$_env_file"

  assert_success
  assert_output ""

  run cat "$_dest_file"

  assert_success
  assert_output 'file11
# @CAT_SECTION_HOME_CAT

line 1

file11_1: "file11_1"

file11_2: file11 2





line 11

# :@CAT_SECTION_HOME_CAT'

  run ydf::utils::mark_concat_with_envar_sub "$_src_file" "$_dest_file" "$_env_file"

  assert_success
  assert_output ""

  run cat "$_dest_file"

  assert_success
  assert_output 'file11
# @CAT_SECTION_HOME_CAT

line 1

file11_1: "file11_1"

file11_2: file11 2





line 11

# :@CAT_SECTION_HOME_CAT'
}

@test "ydf::utils::mark_concat_with_envar_sub() Should duplicate file content When no mark" {
  cp -r "${TEST_FIXTURES_DIR}/dirs/.my" "$BATS_TEST_TMPDIR"

  local -r _src_file="${TEST_FIXTURES_DIR}/packages/20homecats/homecats/.my/file1"
  local -r _dest_file="${BATS_TEST_TMPDIR}/.my/file1"
  local -r _env_file="${TEST_FIXTURES_DIR}/packages/envsubst.env"

  sudo() {
    # sed must be called with mark
    if [[ "$*" != *"-u vedv"* ]]; then
      return 1
    fi
    command sudo "$@"
  }

  run ydf::utils::mark_concat_with_envar_sub "$_src_file" "$_dest_file" "$_env_file"

  assert_success
  assert_output ""

  run cat "$_dest_file"

  assert_success
  assert_output "file1
added line1 to file1

added line2 to file1"

  run ydf::utils::mark_concat_with_envar_sub "$_src_file" "$_dest_file" "$_env_file"

  assert_success
  assert_output ""

  run cat "$_dest_file"

  assert_success
  assert_output "file1
added line1 to file1

added line2 to file1
added line1 to file1

added line2 to file1"
}

# Tests for ydf::utils::for_each()
@test "ydf::utils::for_each() Should succed Without elements" {
  local -r _elements=""
  local -r _func=""

  run ydf::utils::for_each "$_elements" "$_func"

  assert_success
  assert_output ""
}

@test "ydf::utils::for_each() Should fail Without function" {
  local -r _elements="e1 e2"
  local -r _func=""

  run ydf::utils::for_each "$_elements" "$_func"

  assert_failure
  assert_output "ERROR> Argument function can't be empty"
}

@test "ydf::utils::for_each() Should fail If one execution fails" {
  local -r _elements="e1 e2 e3"
  local -r _func="func1"

  func1() {
    case "$*" in
      e1 )
        return 0
      ;;
      e2 )
        return 1
      ;;
      e3 )
        return 0
      ;;
      * )
        return 0
      ;;
    esac
  }

  run ydf::utils::for_each "$_elements" "$_func"

  assert_failure
  assert_output "ERROR> Executing function for element 'e2'"
}

@test "ydf::utils::for_each() Should succeed" {
  local -r _elements="e1 e2 e3"
  local -r _func="func1"

  func1() {
    case "$*" in
      e1 | e2 | e3 )
        return 0
      ;;
      * )
        return 1
      ;;
    esac
  }

  run ydf::utils::for_each "$_elements" "$_func"

  assert_success
  assert_output ""
}

# Tests for ydf::utils::text_file_to_words()
@test "ydf::utils::text_file_to_words() Should fail If file doesn't exist" {
  local -r _file="${TEST_FIXTURES_DIR}/packages/selection2"

  run ydf::utils::text_file_to_words "$_file"

  assert_success
  assert_output "1freedom 2preinstall "
}
