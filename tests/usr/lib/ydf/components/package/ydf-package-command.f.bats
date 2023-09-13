load test_helper

# setup() {
#
# }

# teardown() {
#
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

@test "ydf package install --os manjaro, Should fail with missing argument PACKAGE" {

  run ydf package install --os manjaro

  assert_failure
  assert_output --partial "ERROR> Missing argument 'PACKAGE'"
}

# Tests for ydf package install ../2preinstall
@test "ydf package install --os manjaro ../2preinstall, Should succeed With no preinstall script" {
  local -r _package_dir="${TEST_FIXTURES_DIR}/packages"

  run ydf package install --os manjaro "$_package_dir"

  assert_success
  assert_output ""
}

@test "ydf package install --os manjaro ../2preinstall, Should succeed" {
  local -r _package_dir="${TEST_FIXTURES_DIR}/packages/2preinstall"

  run ydf package install --os manjaro "$_package_dir"

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
@test "ydf package install --os manjaro ../3install, Should succeed With no install script" {
  local -r _package_dir="${TEST_FIXTURES_DIR}/packages"

  run ydf package install --os manjaro "$_package_dir"

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