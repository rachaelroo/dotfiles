# ============================================================================
#  bash_profile - login shell entry point (macOS Terminal and Linux consoles)
#  Login shells read this file, not .bashrc. Sourcing .bashrc from here makes
#  the tracked bashrc apply to both login and non-login interactive shells.
# ============================================================================

if [[ -f ~/.bashrc ]]; then
    . ~/.bashrc
fi
