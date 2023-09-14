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
