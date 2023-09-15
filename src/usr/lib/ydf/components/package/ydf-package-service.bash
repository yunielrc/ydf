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

# readonly __YDF_PACKAGE_SERVICE_INSTRUCTIONS_COMMON='home homeln homecp homecps homecat root rootcp rootcps rootln rootcat flatpack dconf.ini plugin_zsh docker_compose'
# readonly __YDF_PACKAGE_SERVICE_INSTRUCTIONS_MANJARO="preinstall pacman yay install postinstall ${__YDF_PACKAGE_SERVICE_INSTRUCTIONS_COMMON}"
# readonly __YDF_PACKAGE_SERVICE_INSTRUCTIONS_UBUNTU="preinstall apt install postinstall ${__YDF_PACKAGE_SERVICE_INSTRUCTIONS_COMMON}"

readonly __YDF_PACKAGE_SERVICE_INSTRUCTIONS_COMMON=''
readonly __YDF_PACKAGE_SERVICE_INSTRUCTIONS_MANJARO="preinstall install @pacman @yay @flatpak postinstall ${__YDF_PACKAGE_SERVICE_INSTRUCTIONS_COMMON}"
# readonly __YDF_PACKAGE_SERVICE_INSTRUCTIONS_UBUNTU="preinstall install postinstall ${__YDF_PACKAGE_SERVICE_INSTRUCTIONS_COMMON}"

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

#
# Get instructions names
#
# Arguments:
#   [os_name]   string    os name
#
# Output:
#  writes instructions_names (string) to the stdout
#
# Returns:
#   0 on success, non-zero on error.
#
ydf::package_service::get_instructions_names() {
  local -r os_name="${1:-"$__YDF_PACKAGE_SERVICE_DEFAULT_OS"}"

  local instr
  instr="__YDF_PACKAGE_SERVICE_INSTRUCTIONS_${os_name^^}"

  if [[ -z "${!instr:-}" ]]; then
    err "There is no instructions for os: ${os_name}"
    return "$ERR_INVAL_ARG"
  fi

  echo "${!instr}"
}

#
# Execute preinstall script
#
#
# Returns:
#   0 on success, non-zero on error.
#
ydf::package_service::__instruction_preinstall() {
  bash ./preinstall
}

#
# Execute install script
#
#
# Returns:
#   0 on success, non-zero on error.
#
ydf::package_service::__instruction_install() {
  bash ./install
}

#
# Execute postinstall script
#
#
# Returns:
#   0 on success, non-zero on error.
#
ydf::package_service::__instruction_postinstall() {
  bash ./postinstall
}

#
# Execute @pacman instruction
#
# Arguments:
#   pkg_name  string    package name
#
# Returns:
#   0 on success, non-zero on error.
#
ydf::package_service::__instruction_@pacman() {
  local -r pkg_name="$1"
  # select the first no empty line
  local -r pacman_pkg_name="$(ydf::utils::print_1line <@pacman)"

  sudo pacman -Syu --noconfirm --needed "${pacman_pkg_name:-"$pkg_name"}"
}

#
# Execute @yay instruction
#
# Arguments:
#   pkg_name  string    package name
#
# Returns:
#   0 on success, non-zero on error.
#
ydf::package_service::__instruction_@yay() {
  local -r pkg_name="$1"
  # select the first no empty line
  local -r yay_pkg_name="$(ydf::utils::print_1line <@yay)"

  sudo yay -Syu --noconfirm --needed "${yay_pkg_name:-"$pkg_name"}"
}

#
# Execute @flatpak instruction
#
# Arguments:
#   pkg_name  string    package name
#
# Returns:
#   0 on success, non-zero on error.
#
ydf::package_service::__instruction_@flatpak() {
  local -r pkg_name="$1"
  # select the first no empty line
  local -r flatpak_pkg_name="$(ydf::utils::print_1line <@flatpak)"

  sudo -H flatpak install --assumeyes --noninteractive flathub "${flatpak_pkg_name:-"$pkg_name"}"
}

#
# Install a ydotfile package from a directory
#
# Arguments:
#   package_dir   string    package directory
#   [os_name]     string    os name
#
# Output:
#  writes installed package name to the stdout
#
# Returns:
#   0 on success, non-zero on error.
#
ydf::package_service::install_one_from_dir() {
  local -r package_dir="$1"
  local -r os_name="${2:-}"

  # validate arguments
  if [[ ! -d "$package_dir" ]]; then
    err "Directory '${package_dir}' doesn't exist"
    return "$ERR_NO_DIR"
  fi

  local instr
  instr="$(ydf::package_service::get_instructions_names "$os_name")" || {
    err "Getting instructions names for os: ${os_name}"
    return "$ERR_YPS_GENERAL"
  }
  readonly instr

  if [[ -z "$instr" ]]; then
    err "There is no instructions"
    return "$ERR_INVAL_VALUE"
  fi

  local -a instr_arr
  # shellcheck disable=SC2206,SC2317
  instr_arr=($instr)
  readonly instr_arr

  local -r pkg_name="${package_dir##*/}"

  (
    cd "$package_dir" 2>/dev/null || {
      err "Changing the current directory to ${package_dir}"
      return "$ERR_CHANGING_WORKDIR"
    }

    for _instr in "${instr_arr[@]}"; do
      local ifunction="ydf::package_service::__instruction_${_instr}"

      if [[ ! -f "./${_instr}" ]]; then
        continue
      fi

      "$ifunction" "$pkg_name" || {
        err "Executing instruction '${_instr}' on '${package_dir}'"
        return "$ERR_YPS_INSTRUCTION_FAIL"
      }
    done
  )
}

#
# Install a ydotfile package
#
# Arguments:
#   package_name   string     package name
#   [os_name]      string     operating system
#
# Output:
#  writes installed package name to the stdout
#
# Returns:
#   0 on success, non-zero on error.
#
ydf::package_service::install_one() {
  ydf::package_service::install_one_from_dir "$@"
}

#
# Install one or many ydotfile packages
#
# Arguments:
#   packages_names   string[]   packages names
#   [os_name]        string     operating system
#
# Output:
#  writes installed packages names to the stdout
#
# Returns:
#   0 on success, non-zero on error.
#
ydf::package_service::install() {
  ydf::package_service::install_one "$@"
}
