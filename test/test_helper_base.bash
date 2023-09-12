# LOAD BAT LIBS
# shellcheck source=/usr/lib/bash-bats-support-git/load.bash
. "${BATS_LIBS_DIR}/bash-bats-support-git/load.bash"
# shellcheck source=/usr/lib/bash-bats-assert-git/load.bash
. "${BATS_LIBS_DIR}/bash-bats-assert-git/load.bash"
# shellcheck source=/usr/lib/bats-file/load.bash
. "${BATS_LIBS_DIR}/bats-file/load.bash"

# VARIABLES

# HELPER FUNCTIONS

dotf() {
  "${SRC_DIR}/usr/bin/dotf" "$@"
}
