# export STATUS # for custom exit status
eval "$(starship init zsh)"
# export STARSHIP_CONFIG=~/.starship.toml

# 'cmd_duration' module slow down bash execution time in a big way.
#
# disabling 'cmd_duration' module in .toml don't fix the problem
# because this only disable printing command execution time in console and
# doesn't reset DEBUG signal to its original value.
#
# $ trap -p DEBUG
# $ trap -- 'starship_preexec "$_"' DEBUG
# ------------------------------------------------
# the solution:
# trap - DEBUG
# $ trap -p DEBUG
# $ # no DEBUG signal handlers now
