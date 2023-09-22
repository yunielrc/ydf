#
# ydf-package-service
#
# Manage packages
#

shopt -s dotglob

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
#   [common]="preinstall install postinstall flatpack dconf.ini plugin_zsh docker_compose homeln homelnr homecp homecps homecat rootln rootlnr rootcp rootcps rootcat"
#   [manjaro]="pacman yay"
#   [ubuntu]="apt"
# )

# readonly __YDF_PACKAGE_SERVICE_INSTRUCTIONS_COMMON='preinstall install postinstall flatpack dconf.ini plugin_zsh docker_compose homeln homelnr homecp homecps homecat rootln rootlnr rootcp rootcps rootcat'
# readonly __YDF_PACKAGE_SERVICE_INSTRUCTIONS_MANJARO="preinstall pacman yay install postinstall ${__YDF_PACKAGE_SERVICE_INSTRUCTIONS_COMMON}"
# readonly __YDF_PACKAGE_SERVICE_INSTRUCTIONS_UBUNTU="preinstall apt install postinstall ${__YDF_PACKAGE_SERVICE_INSTRUCTIONS_COMMON}"
# shellcheck disable=SC2016
readonly __YDF_PACKAGE_SERVICE_INSTRUCTIONS_COMMON='install @flatpak @snap docker_compose:docker-compose.yml plugin_zsh:${pkg_name}.plugin.zsh theme_zsh:${pkg_name}.theme.zsh homeln/ homelnr/ homecp/ rootcp/ homecat/ rootcat/ homecps/ rootcps/ homecats/ rootcats/ dconf_ini:dconf.ini postinstall'
# ANY OS
readonly __YDF_PACKAGE_SERVICE_INSTRUCTIONS_ANY="preinstall ${__YDF_PACKAGE_SERVICE_INSTRUCTIONS_COMMON}"
# MANJARO
readonly __YDF_PACKAGE_SERVICE_INSTRUCTIONS_MANJARO="preinstall @pacman @yay ${__YDF_PACKAGE_SERVICE_INSTRUCTIONS_COMMON}"
# readonly __YDF_PACKAGE_SERVICE_INSTRUCTIONS_UBUNTU="preinstall install postinstall ${__YDF_PACKAGE_SERVICE_INSTRUCTIONS_COMMON}"

#
# FUNCTIONS
#

#
# Constructor
#
# Arguments:
#   default_os            string  default os
#   yzsh_data_dir         string  yzsh data dir
#   yzsh_gen_config_file  string  yzsh gen config file
#   envsubst_file         string  envsubst file
#   packages_dir          string  packages dir
#
# Returns:
#   0 on success, non-zero on error.
#
ydf::package_service::constructor() {
  readonly __YDF_PACKAGE_SERVICE_DEFAULT_OS="$1"
  readonly __YDF_YZSH_DATA_DIR="$2"
  readonly __YDF_YZSH_GEN_CONFIG_FILE="$3"
  readonly __YDF_PACKAGE_SERVICE_ENVSUBST_FILE="$4"
  readonly __YDF_PACKAGE_SERVICE_PACKAGES_DIR="$5"
}

#
# Get packages dir
#
# Output:
#  writes packages dir (string) to the stdout
#
# Returns:
#   0 on success, non-zero on error.
#
ydf::package_service::get_packages_dir() {
  echo "$__YDF_PACKAGE_SERVICE_PACKAGES_DIR"
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
ydf::package_service::__instruction_preinstall() (
  set -o allexport
  # shellcheck disable=SC1090
  source "$__YDF_PACKAGE_SERVICE_ENVSUBST_FILE"

  bash ./preinstall
)

#
# Execute install script
#
#
# Returns:
#   0 on success, non-zero on error.
#
ydf::package_service::__instruction_install() (
  set -o allexport
  # shellcheck disable=SC1090
  source "$__YDF_PACKAGE_SERVICE_ENVSUBST_FILE"

  bash ./install
)

#
# Execute postinstall script
#
#
# Returns:
#   0 on success, non-zero on error.
#
ydf::package_service::__instruction_postinstall() (
  set -o allexport
  # shellcheck disable=SC1090
  source "$__YDF_PACKAGE_SERVICE_ENVSUBST_FILE"

  bash ./postinstall
)

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
  local -r pacman_pkg_name="$(ydf::utils::text_file_to_words @pacman)"

  eval sudo -H pacman -Syu --noconfirm --needed "${pacman_pkg_name:-"$pkg_name"}"
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
  local -r yay_pkg_name="$(ydf::utils::text_file_to_words @yay)"

  eval yay -Syu --noconfirm --needed "${yay_pkg_name:-"$pkg_name"}"
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
  local -r flatpak_pkg_name="$(ydf::utils::text_file_to_words @flatpak)"

  eval sudo -H flatpak install --assumeyes --noninteractive flathub "${flatpak_pkg_name:-"$pkg_name"}"
}

#
# Execute @snap instruction
#
# Arguments:
#   pkg_name  string    package name
#
# Returns:
#   0 on success, non-zero on error.
#
ydf::package_service::__instruction_@snap() {
  local -r pkg_name="$1"
  # select the first no empty line
  local -r snap_pkg_name="$(ydf::utils::text_file_to_words @snap)"
  # eval allows include options along with package name
  eval sudo -H snap install "${snap_pkg_name:-"$pkg_name"}"
}

#
# Execute docker_compose instruction
#
# Arguments:
#   pkg_name  string    package name
#
# Returns:
#   0 on success, non-zero on error.
#
ydf::package_service::__instruction_docker_compose() {
  docker compose up -d
}

#
# Execute plugin_zsh instruction
#
# Arguments:
#   pkg_name  string    package name
#
# Returns:
#   0 on success, non-zero on error.
#
ydf::package_service::__instruction_plugin_zsh() {
  local -r package_name="$1"

  local -r plugin_name="${package_name}.plugin.zsh"
  local -r plugin_file="${PWD}/${plugin_name}"
  local -r plugin_dest_file="${__YDF_YZSH_DATA_DIR}/plugins/local/${plugin_name}"

  ln -vsf "$plugin_file" "$plugin_dest_file" || {
    err "Creating plugin symlink: ${plugin_dest_file}"
    return "$ERR_FILE_CREATION"
  }

  if [[ ! -f "$__YDF_YZSH_GEN_CONFIG_FILE" ]] ||
    ! grep -q "YZSH_PLUGINS+=($package_name)" "$__YDF_YZSH_GEN_CONFIG_FILE"; then
    echo "YZSH_PLUGINS+=($package_name)" >>"$__YDF_YZSH_GEN_CONFIG_FILE"
  else
    msg "Plugin '${package_name}' already added to ${__YDF_YZSH_GEN_CONFIG_FILE}"
  fi
}

#
# Execute theme_zsh instruction
#
# Arguments:
#   pkg_name  string    package name
#
# Returns:
#   0 on success, non-zero on error.
#
ydf::package_service::__instruction_theme_zsh() {
  local -r package_name="$1"

  local -r theme_name="${package_name}.theme.zsh"
  local -r theme_file="${PWD}/${theme_name}"
  local -r theme_dest_file="${__YDF_YZSH_DATA_DIR}/themes/local/${theme_name}"

  ln -vsf "$theme_file" "$theme_dest_file" || {
    err "Creating theme symlink: ${theme_dest_file}"
    return "$ERR_FILE_CREATION"
  }
}

#
# Execute homeln instruction
#
# Arguments:
#   pkg_name  string    package name
#
# Returns:
#   0 on success, non-zero on error.
#
ydf::package_service::__instruction_homeln() {
  ln -vsf --backup "${PWD}/homeln/"* ~/
}

#
# Execute homelnr instruction
#
# Arguments:
#   pkg_name  string    package name
#
# Returns:
#   0 on success, non-zero on error.
#
ydf::package_service::__instruction_homelnr() {
  cp -vrf --symbolic-link --backup "${PWD}/homelnr/"* ~/
}

#
# Execute homecp instruction
#
# Arguments:
#   pkg_name  string    package name
#
# Returns:
#   0 on success, non-zero on error.
#
ydf::package_service::__instruction_homecp() {
  cp -vrf --backup "${PWD}/homecp/"* ~/
}

#
# Execute rootcp instruction
#
# Arguments:
#   pkg_name  string    package name
#
# Returns:
#   0 on success, non-zero on error.
#
ydf::package_service::__instruction_rootcp() {
  sudo cp -vrf --backup "${PWD}/rootcp/"* /
}

#
# Execute homecat instruction
#
# Arguments:
#   pkg_name  string    package name
#
# Returns:
#   0 on success, non-zero on error.
#
ydf::package_service::__instruction_homecat() {
  local -r package_name="$1"

  while read -r src_file; do
    local dest_file="${HOME}/${src_file#*/}"

    if [[ ! -f "$dest_file" ]]; then
      err "homecat, file '${dest_file}' doesn't exist"
      return "$ERR_NO_FILE"
    fi

    ydf::utils::mark_concat "$src_file" "$dest_file" >/dev/null || {
      err "Marking concat for '${src_file}' to '${dest_file}'"
      return "$ERR_FAILED"
    }

  done < <(find homecat/ -type f)
}

#
# Execute rootcat instruction
#
# Arguments:
#   pkg_name  string    package name
#
# Returns:
#   0 on success, non-zero on error.
#
ydf::package_service::__instruction_rootcat() {
  local -r package_name="$1"

  while read -r src_file; do
    local dest_file="/${src_file#*/}"

    if [[ ! -f "$dest_file" ]]; then
      err "rootcat, file '${dest_file}' doesn't exist"
      return "$ERR_NO_FILE"
    fi

    ydf::utils::mark_concat "$src_file" "$dest_file" >/dev/null || {
      err "Marking concat for '${src_file}' to '${dest_file}'"
      return "$ERR_FAILED"
    }

  done < <(find rootcat/ -type f)
}

#
# Execute <root|home>cps instruction
#
# Arguments:
#   pkg_name     string    package name
#   instruction  string    instruction name
#
# Returns:
#   0 on success, non-zero on error.
#
ydf::package_service::__recursive_copy_with_envsubst() {
  local -r package_name="$1"
  local -r instruction="$2"
  # validate arguments
  if [[ -z "$package_name" ]]; then
    err "Package name must not be empty"
    return "$ERR_INVAL_ARG"
  fi
  if [[ "$instruction" != @(homecps|rootcps) ]]; then
    err "Instruction must be 'homecps' or 'rootcps'"
    return "$ERR_INVAL_ARG"
  fi

  local dest_dir=~

  if [[ "$instruction" == rootcps ]]; then
    dest_dir=''
  fi
  readonly dest_dir

  while read -r src_file; do
    local dest_file="${dest_dir}/${src_file#*/}"

    ydf::utils::copy_with_envar_sub \
      "$src_file" "$dest_file" "$__YDF_PACKAGE_SERVICE_ENVSUBST_FILE" >/dev/null || {
      err "Copying with envar substitution file '${src_file}' to '${dest_file}'"
      return "$ERR_FAILED"
    }

  done < <(find "$instruction"/ -type f)
}

#
# Execute homecps instruction
#
#
# Arguments:
#   pkg_name  string    package name
#
# Returns:
#   0 on success, non-zero on error.
#
ydf::package_service::__instruction_homecps() {
  ydf::package_service::__recursive_copy_with_envsubst \
    "$1" homecps
}

#
# Execute rootcps instruction
#
#
# Arguments:
#   pkg_name  string    package name
#
# Returns:
#   0 on success, non-zero on error.
#
ydf::package_service::__instruction_rootcps() {
  ydf::package_service::__recursive_copy_with_envsubst \
    "$1" rootcps
}

#
# Execute <root|home>cps instruction
#
# Arguments:
#   pkg_name     string    package name
#   instruction  string    instruction name
#
# Returns:
#   0 on success, non-zero on error.
#
ydf::package_service::__recursive_mark_concat_with_envsubst() {
  local -r package_name="$1"
  local -r instruction="$2"
  # validate arguments
  if [[ -z "$package_name" ]]; then
    err "Package name must not be empty"
    return "$ERR_INVAL_ARG"
  fi
  if [[ "$instruction" != @(homecats|rootcats) ]]; then
    err "Instruction must be: homecats or rootcats"
    return "$ERR_INVAL_ARG"
  fi

  local dest_dir=~

  if [[ "$instruction" == rootcats ]]; then
    dest_dir=''
  fi
  readonly dest_dir

  while read -r src_file; do
    local dest_file="${dest_dir}/${src_file#*/}"

    if [[ ! -f "$dest_file" ]]; then
      err "${instruction}, file '${dest_file}' doesn't exist"
      return "$ERR_NO_FILE"
    fi

    ydf::utils::mark_concat_with_envar_sub \
      "$src_file" "$dest_file" "$__YDF_PACKAGE_SERVICE_ENVSUBST_FILE" >/dev/null || {
      err "Concat with envar substitution file '${src_file}' to '${dest_file}'"
      return "$ERR_FAILED"
    }

  done < <(find "$instruction"/ -type f)
}

#
# Execute rootcats instruction
#
#
# Arguments:
#   pkg_name  string    package name
#
# Returns:
#   0 on success, non-zero on error.
#
ydf::package_service::__instruction_homecats() {
  ydf::package_service::__recursive_mark_concat_with_envsubst \
    "$1" homecats
}

#
# Execute rootcats instruction
#
#
# Arguments:
#   pkg_name  string    package name
#
# Returns:
#   0 on success, non-zero on error.
#
ydf::package_service::__instruction_rootcats() {
  ydf::package_service::__recursive_mark_concat_with_envsubst \
    "$1" rootcats
}

#
# Execute dconf_ini instruction
#
# Arguments:
#   pkg_name  string    package name
#
# Returns:
#   0 on success, non-zero on error.
#
ydf::package_service::__instruction_dconf_ini() {
  dconf load / <dconf.ini
}

#
# Install a ydotfile package from a directory
#
# Arguments:
#   pkg_name         string    package name
#   [os_name]        string    os name
#   [packages_dir]   string     packages dir
#
# Output:
#  writes installed package name to the stdout
#
# Returns:
#   0 on success, non-zero on error.
#
ydf::package_service::install_one_from_dir() {
  local -r pkg_name="$1"
  local -r os_name="${2:-}"
  local -r packages_dir="${3:-"$(ydf::package_service::get_packages_dir)"}"

  local -r package_dir="${packages_dir}/${pkg_name}"

  # validate arguments
  if [[ ! -d "$package_dir" ]]; then
    err "Package '${pkg_name}' doesn't exist in '${packages_dir}'"
    return "$ERR_NO_DIR"
  fi

  local instr
  instr="$(ydf::package_service::get_instructions_names "$os_name")" || {
    err "Getting instructions names for os: ${os_name}"
    return "$ERR_FAILED"
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

  msg ">> INSTALLING: ${pkg_name}"

  (
    cd "$package_dir" 2>/dev/null || {
      msg ">> FAILED. NOT INSTALLED: ${pkg_name}"
      err "Changing current directory to ${package_dir}"
      return "$ERR_CHANGING_WORKDIR"
    }

    for _instr in "${instr_arr[@]}"; do

      local ifunc_partial_name="${_instr%%:*}"
      ifunc_partial_name="${ifunc_partial_name%/}"
      eval local ifile_name="${_instr##*:}"

      local ifunction="ydf::package_service::__instruction_${ifunc_partial_name}"

      # shellcheck disable=SC2154
      if [[ "$ifile_name" == */ ]]; then
        if [[ ! -d "./${ifile_name}" ]]; then
          continue
        fi
      elif [[ ! -f "./${ifile_name}" ]]; then
        continue
      fi

      "$ifunction" "$pkg_name" || {
        msg ">> FAILED. NOT INSTALLED: ${pkg_name}"
        err "Executing instruction '${_instr}' on '${package_dir}'"
        return "$ERR_YPS_INSTRUCTION_FAIL"
      }
    done

    msg ">> DONE. INSTALLED: ${pkg_name}"
  )
}

#
# Install a ydotfile package
#
# Arguments:
#   package_name   string     package name
#   [os_name]      string     operating system
#   [packages_dir] string     packages dir
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
# Install a ydotfile package
#
# Arguments:
#   os_name        string     operating system
#   package_name   string     package name
#   packages_dir   string     packages dir
#
# Output:
#  writes installed package name to the stdout
#
# Returns:
#   0 on success, non-zero on error.
#
ydf::package_service::__install_one_batch() {
  local -r os_name="$1"
  local -r packages_dir="$2"
  local -r package_name="$3"

  ydf::package_service::install_one \
    "$package_name" "$os_name" "$packages_dir"
}

#
# Install one or many ydotfile packages
#
# Arguments:
#   packages_names   string[]   packages names
#   [os_name]        string     operating system
#   [packages_dir]   string     packages dir
#
# Output:
#  writes installed packages names to the stdout
#
# Returns:
#   0 on success, non-zero on error.
#
ydf::package_service::install() {
  local -r packages_names="$1"
  local -r os_name="${2:-}"
  local -r packages_dir="${3:-}"
  # validate arguments
  if [[ -z "$packages_names" ]]; then
    err "Packages names must not be empty"
    return "$ERR_INVAL_ARG"
  fi

  local -a _elements_arr
  # shellcheck disable=SC2206,SC2317
  _elements_arr=($packages_names)
  readonly _elements_arr

  msg "> INSTALLING ${#_elements_arr[*]} packages"

  ydf::utils::for_each \
    "$packages_names" \
    "ydf::package_service::__install_one_batch '${os_name}' '${packages_dir}'" || {
    msg "> FAILED. INSTALLING packages"
    err "Installing packages"
    return "$ERR_FAILED"
  }

  msg "> DONE. INSTALLED ${#_elements_arr[*]} packages"
}
