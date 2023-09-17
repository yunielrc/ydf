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
