if false; then
  source ./errors.bash
fi

err() {
  echo -e "ERROR> $*" >&2
}

warn() {
  echo -e "WARNING> $*" >&2
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

#
# Concat files with mark
#
# Arguments:
#   src_file  string  source file
#   dest_file string  destination file
#
# Output:
#   Writes error messages to stderr
#
# Returns:
#   0 on success, non-zero on error.
#
ydf::utils::mark_concat() {
  local -r src_file="$1"
  local -r dest_file="$2"
  # validate arguments
  if [[ ! -f "$src_file" ]]; then
    err "File src '${src_file}' doesn't exist"
    return "$ERR_INVAL_ARG"
  fi
  if [[ ! -f "$dest_file" ]]; then
    err "File dest '${dest_file}' doesn't exist"
    return "$ERR_INVAL_ARG"
  fi

  local _user="$USER"

  if [[ ! -w "$dest_file" ]]; then
    _user=root
  fi

  local mark
  mark="$(grep -Pom1 '@CAT_SECTION_(\w|\d)*' "$src_file")" || :
  readonly mark

  if [[ -n "$mark" ]]; then
    # remove previous added section
    sudo -u "$_user" sed -i "/${mark}\s*$/,/:${mark}\s*$/d" "$dest_file" || {
      err "Failed to remove previous added section"
      return "$ERR_FAILED"
    }
  fi
  # shellcheck disable=SC2024
  sudo -u "$_user" tee -a "$dest_file" <"$src_file"
}
