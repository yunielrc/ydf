err() {
  echo -e "ERROR> $*" >&2
}

ech() {
  echo -e "$*"
}

#
# Print the first non-empty line from stdin
#
# STDIN:
#   text
#
# Arguments:
#   NONE
#
# Output:
#  writes the first non-empty line (string) to stdout
#
# Returns:
#   0 on success, non-zero on error.
#
ydf::utils::print_1line() {
  grep -Pom1 '(\S+\s*)+\S+' || :
}
