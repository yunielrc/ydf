load test_helper

# setup_file() {
#
# }

# setup() {
#
# }

# teardown() {
#
# }

# Tests for ydf
@test "ydf, Should show help" {

  run ydf

  assert_success
  assert_output --partial 'Usage:
ydf COMMAND'
}

@test "ydf package, Should show help" {

  run ydf package

  assert_success
  assert_output --partial 'Usage:
ydf package COMMAND'
}

@test "ydf invalid, Should fail with invalid command" {

  run ydf invalid

  assert_failure
  assert_output --partial 'ERROR> Invalid command: invalid'
}
