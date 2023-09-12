#
# ydf-package-service
#
# Manage packages
#

#
# FOR CODE COMPLETION
#

if false; then
  . ../../errors.bash
  . ../../utils.bash
  . ./ydf-package-entity.bash
fi

#
# CONSTANTS
#

# declare -rA __YDF_PACKAGE_SERVICE_INSTRUCTIONS=(
#   [common]="pre_install install post_install home homeln homecp homecps homecat root rootcp rootcps rootln rootcat flatpack dconf.ini plugin_zsh docker_compose"
#   [manjaro]="pacman yay"
#   [ubuntu]="apt"
# )

readonly __YDF_PACKAGE_SERVICE_INSTRUCTIONS_COMMON='home homeln homecp homecps homecat root rootcp rootcps rootln rootcat flatpack dconf.ini plugin_zsh docker_compose'
readonly __YDF_PACKAGE_SERVICE_INSTRUCTIONS_MANJARO="pre_install pacman yay install post_install ${__YDF_PACKAGE_SERVICE_INSTRUCTIONS_COMMON}"
readonly __YDF_PACKAGE_SERVICE_INSTRUCTIONS_UBUNTU="pre_install apt install post_install ${__YDF_PACKAGE_SERVICE_INSTRUCTIONS_COMMON}"

#
# FUNCTIONS
#

#
# Constructor
#
# default_os  string  default os
#
# Returns:
#   0 on success, non-zero on error.
#
ydf::package_service::constructor() {
  readonly __YDF_PACKAGE_SERVICE_DEFAULT_OS="$1"
}

ydf::package_service::__instruction_iname() {
  :
}

#
# Install a ydotfile package from a directory
#
# Arguments:
#   package_dir   string    package directory
#   os_name       string    os name
#
# Output:
#  writes installed package name to the stdout
#
# Returns:
#   0 on success, non-zero on error.
#
ydf::package_service::install_one_from_dir() {
  local -r package_dir="$1"
  local -r os_name="${2:-"$__YDF_PACKAGE_SERVICE_DEFAULT_OS"}"

  # validate arguments
  if [[ ! -d "$package_dir" ]]; then
    err "Directory '${package_dir}' doesn't exist"
    return "$ERR_NO_DIR"
  fi

  local inst_specific
  inst_specific="__YDF_PACKAGE_SERVICE_INSTRUCTIONS_${os_name^^}"
  readonly inst_specific

  local -a instructions_arr
  # shellcheck disable=SC2206,SC2317
  instructions_arr=(${!inst_specific})
  readonly instructions_arr

  for iname in "${instructions_arr[@]}"; do
    local ifunction="ydf::package_service::__instruction_${iname}"

    "$ifunction" "$package_dir" || {
      err "Executing instruction '${iname}' on '${package_dir}'"
      return "$ERR_YPS_INSTRUCTION_FAIL"
    }
  done
}

#
# Install a ydotfile package
#
# Arguments:
#   package_name   string     package name
#
# Output:
#  writes installed package name to the stdout
#
# Returns:
#   0 on success, non-zero on error.
#
ydf::package_service::install_one() {
  :
}

#
# Install one or many ydotfile packages
#
# Arguments:
#   packages_names   string[]   packages names
#
# Output:
#  writes installed packages names to the stdout
#
# Returns:
#   0 on success, non-zero on error.
#
ydf::package_service::install() {
  ydf::package_service::install_one_from_dir "$@"
}
