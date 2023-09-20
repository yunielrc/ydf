if false; then
  source ./errors.bash
fi

__YDF_UTILS_NO_MSG=false

#
# Constructor
#
# Arguments:
#   no_msg  bool  don't print msg messages
#
ydf::utils::constructor() {
  readonly __YDF_UTILS_NO_MSG="${1:-false}"
}

err() {
  echo -e "ERROR> $*" >&2
}

warn() {
  echo -e "WARNING> $*" >&2
}

msg() {
  if [[ "$__YDF_UTILS_NO_MSG" == true ]]; then
    return 0
  fi
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
  # TODO: src_file must be a text file
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
  # TODO: add >/dev/null to avoid printing added lines to stdout
  sudo -u "$_user" tee -a "$dest_file" <"$src_file"
}

#
# Concat files with envar substitution
#
# Arguments:
#   src_file  string  source file
#   dest_file string  destination file
#   env_file  string  environment file
#
# Output:
#   Writes error messages to stderr
#
# Returns:
#   0 on success, non-zero on error.
#
ydf::utils::copy_with_envar_sub() {
  local -r src_file="$1"
  local -r dest_file="$2"
  local -r env_file="$3"
  # validate arguments
  if [[ ! -f "$src_file" ]]; then
    err "File src '${src_file}' doesn't exist"
    return "$ERR_INVAL_ARG"
  fi
  if [[ "$(file --brief --mime-type "$src_file")" != text/* ]]; then
    err "File src '${src_file}' is not a text file"
    return "$ERR_INVAL_ARG"
  fi
  if [[ -z "$dest_file" ]]; then
    err "Argument dest_file '${dest_file}' can't be empty"
    return "$ERR_INVAL_ARG"
  fi
  if [[ ! -f "$env_file" ]]; then
    err "File env '${env_file}' doesn't exist"
    return "$ERR_INVAL_ARG"
  fi

  local _user="$USER"
  local -r dest_file_dir="$(dirname "$dest_file")"

  if [[ -d "$dest_file_dir" && ! -w "$dest_file_dir" ]] ||
    mkdir -p "$dest_file_dir" 2>&1 | grep -q 'Permission denied'; then
    _user=root
    sudo mkdir -p "$dest_file_dir" || {
      err "Failed to create directory '${dest_file_dir}'"
      return "$ERR_FILE_CREATION"
    }
  fi
  readonly _user

  # env -i ... start with an empty environment to avoid unexpected substitutions
  env -i -S bash -c "set -o allexport; source '${env_file}'; envsubst <'${src_file}'" |
    sudo -u "$_user" tee "$dest_file" >/dev/null
}

#
# Concat files with mark envar substitution
#
# Arguments:
#   src_file  string  source file
#   dest_file string  destination file
#   env_file  string  environment file
#
# Output:
#   Writes error messages to stderr
#
# Returns:
#   0 on success, non-zero on error.
#
ydf::utils::mark_concat_with_envar_sub() {
  local -r src_file="$1"
  local -r dest_file="$2"
  local -r env_file="$3"
  # validate arguments
  if [[ ! -f "$src_file" ]]; then
    err "File src '${src_file}' doesn't exist"
    return "$ERR_INVAL_ARG"
  fi
  if [[ "$(file --brief --mime-type "$src_file")" != text/* ]]; then
    err "File src '${src_file}' is not a text file"
    return "$ERR_INVAL_ARG"
  fi
  if [[ ! -f "$dest_file" ]]; then
    err "File dest '${dest_file}' doesn't exist"
    return "$ERR_INVAL_ARG"
  fi
  if [[ ! -f "$env_file" ]]; then
    err "File env '${env_file}' doesn't exist"
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
  env -i -S bash -c "set -o allexport; source '${env_file}'; envsubst <'${src_file}'" |
    sudo -u "$_user" tee --append "$dest_file" >/dev/null

}

#
# Execute a function for each element
#
# Arguments:
#   elements  string  elements
#   func      string  function name
#
# Output:
#   Writes function output to stdout
#
# Returns:
#   0 on success, non-zero on error.
#
ydf::utils::for_each() {
  local -r elements="$1"
  local -r func="$2"
  # validate arguments
  if [[ -z "$elements" ]]; then
    return 0
  fi
  if [[ -z "$func" ]]; then
    err "Argument function can't be empty"
    return "$ERR_INVAL_ARG"
  fi

  local -a elements_arr
  # shellcheck disable=SC2206,SC2317
  elements_arr=($elements)
  readonly elements_arr

  local el

  for el in "${elements_arr[@]}"; do
    eval "$func" "'${el}'" || {
      err "Executing function for element '${el}'"
      return "$ERR_FAILED"
    }
  done
}

#
# Print all words from a text file in one line
#
# Arguments:
#   file  string  text file
#
# Output:
#   Writes words to stdout
#
# Returns:
#   0 on success, non-zero on error.
#
ydf::utils::text_file_to_words() {
  sed -e '/^\s*#/d' -e '/^\s*$/d' "$1" | tr '\n' ' '
}
