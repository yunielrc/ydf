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
${__YDF_SCRIPT_NAME} package install PACKAGE [PACKAGE...]

Install packages

Flags:
  -h, --help    Show this help

HELPMSG
}

#
# Install one or more ydotfile packages
#
# Flags:
#   -h | --help   Show help
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

  if [[ $# == 0 ]]; then set -- '-h'; fi

  while [[ $# -gt 0 ]]; do
    case "$1" in
    # flags
    -h | --help)
      ydf::package_command::__install_help
      return 0
      ;;
    # arguments
    *)
      readonly packages="$*"
      break
      ;;
    esac
  done

  if [[ -z "$packages" ]]; then
    err "Missing argument 'PACKAGE'\n"
    ydf::package_command::__install_help
    return "$ERR_MISSING_ARG"
  fi

  ydf::package_service::install "$packages"
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
