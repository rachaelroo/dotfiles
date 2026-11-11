# ============================================================================
#  bashrc - minimal, portable, dependency-free (Bash 3.2+)
#  Copy/symlink to ~/.bashrc. For login shells (including macOS Terminal), add
#  this to ~/.bash_profile: [[ -f ~/.bashrc ]] && . ~/.bashrc
# ============================================================================

# Leave scripts and non-interactive SSH commands alone.
case $- in
    *i*) ;;
    *) return ;;
esac

# --- PATH -------------------------------------------------------------------
# Only add existing directories, without duplicates or empty PATH entries.
_path_prepend() {
    [[ -d $1 ]] || return 0
    case ":${PATH-}:" in
        *":$1:"*) ;;
        *) PATH="$1${PATH:+:$PATH}" ;;
    esac
}

# Standard local installs, Homebrew (Intel/Apple Silicon), and Linuxbrew.
# Later additions take priority; personal tools win over package-manager tools.
for _bin in \
    /usr/local/sbin /usr/local/bin \
    /home/linuxbrew/.linuxbrew/sbin /home/linuxbrew/.linuxbrew/bin \
    "$HOME/.linuxbrew/sbin" "$HOME/.linuxbrew/bin" \
    /opt/homebrew/sbin /opt/homebrew/bin \
    "$HOME/bin" "$HOME/.local/bin"
do
    _path_prepend "$_bin"
done
export PATH
unset _bin
unset -f _path_prepend

# --- History / navigation ---------------------------------------------------
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoreboth         # Skip consecutive duplicates and leading spaces.
shopt -s histappend            # Don't overwrite history from other terminals.
shopt -s cmdhist               # Store multiline commands as a single entry.
shopt -s checkwinsize          # Update terminal dimensions after each command.

# Type a prefix, then use Up/Down to search matching history entries.
# Handle both normal and application-mode arrow keys.
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
bind '"\eOA": history-search-backward'
bind '"\eOB": history-search-forward'

# --- Optional tab completion ------------------------------------------------
# Modern bash-completion needs Bash 4.2+; macOS's stock Bash uses the legacy
# Homebrew bash-completion package instead of bash-completion@2.
_load_bash_completion() {
    local file
    if (( BASH_VERSINFO[0] > 4 ||
          (BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] >= 2) )); then
        for file in \
            /opt/homebrew/etc/profile.d/bash_completion.sh \
            /usr/local/etc/profile.d/bash_completion.sh \
            /home/linuxbrew/.linuxbrew/etc/profile.d/bash_completion.sh \
            "$HOME/.linuxbrew/etc/profile.d/bash_completion.sh" \
            /usr/share/bash-completion/bash_completion
        do
            if [[ -r $file ]]; then
                . "$file"
                return
            fi
        done
    fi
    for file in \
        /opt/homebrew/etc/bash_completion \
        /usr/local/etc/bash_completion \
        /home/linuxbrew/.linuxbrew/etc/bash_completion \
        "$HOME/.linuxbrew/etc/bash_completion" \
        /etc/bash_completion
    do
        if [[ -r $file ]]; then
            . "$file"
            return
        fi
    done
}
# Avoid loading it twice if the system startup files already enabled it.
if ! declare -F _filedir >/dev/null 2>&1; then
    _load_bash_completion
fi
unset -f _load_bash_completion

# --- Defaults ---------------------------------------------------------------
if [[ -z ${EDITOR-} ]]; then
    if command -v vim >/dev/null 2>&1; then
        export EDITOR=vim
    else
        export EDITOR=vi
    fi
fi
export VISUAL="${VISUAL:-$EDITOR}"
export PAGER="${PAGER:-less}"
export LESS="${LESS:--FRX}"    # Color support; quit if output fits one screen.

# --- Aliases ----------------------------------------------------------------
case ${OSTYPE-} in
    darwin*|freebsd*)
        alias ls='ls -G'
        ;;
    linux*)
        alias ls='ls --color=auto'
        ;;
esac
alias ll='ls -alF'
alias la='ls -A'
alias lla='ls -lah'
alias ..='cd ..'
alias ...='cd ../..'
alias md='mkdir -p'
alias cp='cp -i'
alias mv='mv -i'
alias df='df -h'
alias du='du -h'
alias h='history'
alias g='git'
alias gs='git status --short --branch'
alias gd='git diff'
alias gl='git log --oneline --decorate -20'

# --- Prompt -----------------------------------------------------------------
# user@host directory (branch*) $ — * marks tracked or untracked changes.
# Detached HEAD shows the short commit ID; outside a repo, omit the Git segment.
_git_prompt() {
    command -v git >/dev/null 2>&1 || return 0
    local branch dirty
    branch=$(git symbolic-ref --quiet --short HEAD 2>/dev/null) ||
        branch=$(git rev-parse --short HEAD 2>/dev/null) || return 0
    if [[ -n $(GIT_OPTIONAL_LOCKS=0 git status --porcelain 2>/dev/null) ]]; then
        dirty='*'
    fi
    printf ' (%s%s)' "$branch" "$dirty"
}

# Bracket non-printing color escapes so wrapping and line editing work properly.
case ${TERM-} in
    xterm*|screen*|tmux*|rxvt*|linux|ansi|alacritty*|foot*|wezterm*)
        PS1='\[\e[32m\]\u@\h\[\e[0m\] \[\e[36m\]\W\[\e[33m\]$(_git_prompt)\[\e[0m\] \$ '
        ;;
    *)
        PS1='\u@\h \W$(_git_prompt) \$ '
        ;;
esac

# --- Machine-specific additions (not tracked) -------------------------------
if [[ -f "$HOME/.bashrc.local" ]]; then
    . "$HOME/.bashrc.local"
fi
