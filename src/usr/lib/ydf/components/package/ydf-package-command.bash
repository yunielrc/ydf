#
# package-command
#
# Manage packages
#
# Process command line and call service
#

#
# FOR CODE COMPLETION
#

if false; then
  . ../../errors.bash
  . ./ydf-package-service.bash
fi

#
# CONSTANTS
#

#
# FUNCTIONS
#

#
# Constructor
#
# Returns:
#   0 on success, non-zero on error.
#
ydf::package_command::constructor() {
  :
}

#
# Show help for __install command
#
# Output:
#  Writes the help to the stdout
#
ydf::package_command::__install_help() {
  cat <<-HELPMSG
Usage:
${__YDF_SCRIPT_NAME} package install [OPTIONS] <PACKAGES_FILE | PACKAGE [PACKAGE...]>

Install packages from a packages file or packages names.
A packages file is a text file with one package name per line.
A package name is a directory with instructions to install
and configure the package.

Flags:
  -h, --help    Show this help

Options:
  --os          Operating system

HELPMSG
}

#
# Install one or more ydotfile packages
#
# Flags:
#   -h | --help   Show help
#
# Options:
#   --os          Operating system
#
# Arguments:
#   PACKAGE [PACKAGE...]     one or more packages
#
# Output:
#   writes installed package name to stdout
#
# Returns:
#   0 on success, non-zero on error.
#
ydf::package_command::__install() {
  local packages=''
  local os=''

  if [[ $# == 0 ]]; then set -- '-h'; fi

  while [[ $# -gt 0 ]]; do
    case "$1" in
    # flags
    -h | --help)
      ydf::package_command::__install_help
      return 0
      ;;
    # options
    --os)
      readonly os="${2:-}"
      # validate argument
      if [[ -z "$os" ]]; then
        err "No os name specified\n"
        ydf::package_command::__install_help
        return "$ERR_MISSING_ARG"
      fi
      shift 2
      ;;
    # arguments
    *)
      packages="$*"

      if [[ -f "$packages" && "$(file --brief --mime-type "$packages")" == text/* ]]; then
        # remove comments and empty lines, then replace newlines with spaces
        packages="$(sed -e '/^\s*#/d' -e '/^\s*$/d' "$packages" | tr '\n' ' ')"
      fi
      readonly packages
      break
      ;;
    esac
  done

  if [[ -z "$packages" ]]; then
    err "Missing argument 'PACKAGE'\n"
    ydf::package_command::__install_help
    return "$ERR_MISSING_ARG"
  fi

  ydf::package_service::install "$packages" "$os"
}

ydf::package_command::__help() {
  cat <<-HELPMSG
Usage:
${__YDF_SCRIPT_NAME} package COMMAND

Manage packages

Flags:
  -h, --help    Show this help

Commands:
  install   install packages

Run '${__YDF_SCRIPT_NAME} package --help' for more information on a command.
HELPMSG
}

ydf::package_service::run_cmd() {
  if [[ $# == 0 ]]; then set -- '-h'; fi

  while [[ $# -gt 0 ]]; do
    case "$1" in
    -h | --help)
      ydf::package_command::__help
      return 0
      ;;
    install)
      shift
      ydf::package_command::__install "$@"
      return $?
      ;;
    *)
      err "Invalid command: ${1}\n"
      ydf::package_command::__help
      return "$ERR_INVAL_ARG"
      ;;
    esac
  done
}
