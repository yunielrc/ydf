# Setup fzf
# ---------

# Auto-completion
# ---------------
[[ $- == *i* ]] && source '/usr/share/fzf/completion.zsh' 2>/dev/null

# Key bindings
# ------------
source '/usr/share/fzf/key-bindings.zsh'

# Environment
# FIND_CMD="find -not -path '*/.git/*'"
# export FZF_DEFAULT_COMMAND="command ${FIND_CMD}"
# export FZF_DEFAULT_COMMAND="command ${FD_COMMAND}"
# export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
# export FZF_COMPLETION_TRIGGER=',,'
# export FZF_DEFAULT_OPTS='--multi --height 50% --layout=reverse --border'

# Use fd (https://github.com/sharkdp/fd) instead of the default find
# command for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
# _fzf_compgen_path() {
#   $FZF_DEFAULT_COMMAND . "$1"
# }

# Use fd to generate the list for directory completion
# _fzf_compgen_dir() {
#   $FZF_DEFAULT_COMMAND --type d . "$1"
# }

# Supported commands
# usage: _fzf_setup_completion path|dir|var|alias|host COMMANDS...
# _fzf_setup_completion path bat
