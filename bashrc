#
# ~/.bashrc
#

### Presets

[[ "$(whoami)" = "root" ]] && return

[[ -z "$FUNCNEST" ]] && export FUNCNEST=100          # limits recursive functions, see 'man bash'

## Use the up and down arrow keys for finding a command in history
## (you can write some initial letters of the command first).
bind '"\e[A":history-search-backward'
bind '"\e[B":history-search-forward'

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# PS1='[\u@\h \W]\$ '
PS1='\u@\h$ '

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Use z for moving quicker through directories
[[ -r "/usr/share/z/z.sh" ]] && source /usr/share/z/z.sh

# fzf stuff
source /usr/share/fzf/key-bindings.bash
source /usr/share/fzf/completion.bash
export FZF_DEFAULT_COMMAND="rg --files --hidden --follow --glob '!.git'"

# Execute the environment variables for GUI programs (firefox wayland support)
# export MOZ_ENABLE_WAYLAND=1
# export $(/usr/lib/systemd/user-environment-generators/30-systemd-environment-d-generator)

# set standard web browser
if [ -n "$DISPLAY" ]; then
    export BROWSER=firefox
else 
    export BROWSER=links
fi

# set standard editor
alias vim=nvim
export EDITOR=/usr/bin/nvim
export VISUAL=$EDITOR

# Julia variables
export JULIA_NUM_THREADS=14
export JULIA_EDITOR=$EDITOR
export CMDSTAN='/home/carl/Dokumente/01_programs/git-repositories/cmdstan/'
export JULIA_CMDSTAN_HOME=$CMDSTAN

# Expand Bash History
HISTSIZE=2000
HISTFILESIZE=4000

# Themes for `bat`
export BAT_THEME='gruvbox-light'

# alias for clearing screen properly
alias cls='printf "\033c"'

function knit { Rscript -e "rmarkdown::render('$1')"; }
export -f knit
complete -f -X '!*.Rmd' knit

# for gpg-agent
export GPG_TTY="$(tty)"
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent

# CD on quit when using nnn (-> use alias 'n')
if [ -f /usr/share/nnn/quitcd/quitcd.bash_zsh ]; then
    source /usr/share/nnn/quitcd/quitcd.bash_zsh
fi

#
# ALIASES ----

alias ..='cd ..'
alias ls='ls --color=auto'
alias ll='eza -hlr --icons'
# alias cat='bat -pp --wrap character --terminal-width 80'
alias r='conda activate radian && radian --no-save'
alias tree="tree -C"
alias mamba='micromamba'
alias conda='micromamba'
alias sudo='sudo -E'
alias disable_edp1='swaymsg output eDP-1 disable'

# Set an alias for connecting to RStudio
alias sshfs-hpc='sshfs s-sc-frontend1.charite.de:/ ~/SC-HPC/'
alias ssh-hpc='ssh s-sc-frontend1.charite.de'

# UTILITY FUNCTIONS ----

# When within the Charite network, mount the cluster project directory
function mount_smb() {
    gio mount smb://sc-data.sc-store.charite.de/sc-project-computational-medicine
    ln -sf /run/user/1000/gvfs/smb-share\:server\=sc-data.sc-store.charite.de\,share\=sc-project-computational-medicine/ SC-HPC-SMB
}

# configure proxy settings for the shell 
function enable_proxy() {
    export http_proxy="http://proxy.charite.de:8080"
    export https_proxy=$http_proxy
    export HTTPS_PROXY=$http_proxy
    export HTTP_PROXY=$http_proxy
    export ftp_proxy=$http_proxy
    export FTP_PROXY=$http_proxy
    export sync_proxy=$http_proxy
    export no_proxy="localhost,127.0.0.1,localaddress,.localdomain.com,.charite.de"
    export NO_PROXY=$no_proxy
    echo "Proxy settings enabled."
}
function disable_proxy() {
    unset http_proxy
    unset https_proxy
    unset HTTP_PROXY
    unset HTTPS_PROXY
    unset ftp_proxy
    unset FTP_PROXY
    unset rsync_proxy
    unset no_proxy
    unset NO_PROXY
    echo "Proxy settings disabled."
}

mount_onedrive() {
    rclone mount \
        --vfs-cache-mode full \
        ChariteOneDrive: OneDrive/ \
        --header 'Prefer: Include-Feature=AddToOneDrive' \
        --daemon
}

unmount_onedrive() {
    fusermount -u /home/carl/OneDrive/
}

launch_rstudio() {
    conda activate charite-hpc
    container_dir="/sc-projects/sc-proj-computational-medicine/programs/all-inclusive-rstudio-apptainer/sif"
    sc-launch-rstudio \
        -t 12:00:00 \
        -u cabe12 \
        -N 1 \
        -n 1 \
        --mem 64G \
        -c 16 \
        -i ${container_dir}/all_inclusive_rstudio_4.4.0.sif \
        -B /sc-projects/sc-proj-computational-medicine/ \
        -B /sc-scratch/sc-scratch-computational-medicine/ \
        -B /sc-resources/ukb/data/ \
        -B /opt/conda
}

# MAMBA ----

# >>> mamba initialize >>>
# !! Contents within this block are managed by 'micromamba shell init' !!
export MAMBA_EXE='/usr/bin/micromamba';
export MAMBA_ROOT_PREFIX='/home/carl/micromamba';
__mamba_setup="$("$MAMBA_EXE" shell hook --shell bash --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__mamba_setup"
else
    alias micromamba="$MAMBA_EXE"  # Fallback on help from micromamba activate
fi
unset __mamba_setup
# <<< mamba initialize <<<

# =============================================================================
#
# Utility functions for zoxide.
#

# pwd based on the value of _ZO_RESOLVE_SYMLINKS.
function __zoxide_pwd() {
    \builtin pwd -L
}

# cd + custom logic based on the value of _ZO_ECHO.
function __zoxide_cd() {
    # shellcheck disable=SC2164
    \builtin cd -- "$@"
}

# =============================================================================
#
# Hook configuration for zoxide.
#

# Hook to add new entries to the database.
__zoxide_oldpwd="$(__zoxide_pwd)"

function __zoxide_hook() {
    \builtin local -r retval="$?"
    \builtin local pwd_tmp
    pwd_tmp="$(__zoxide_pwd)"
    if [[ ${__zoxide_oldpwd} != "${pwd_tmp}" ]]; then
        __zoxide_oldpwd="${pwd_tmp}"
        \command zoxide add -- "${__zoxide_oldpwd}"
    fi
    return "${retval}"
}

# Initialize hook.
if [[ ${PROMPT_COMMAND:=} != *'__zoxide_hook'* ]]; then
    PROMPT_COMMAND="__zoxide_hook;${PROMPT_COMMAND#;}"
fi

# =============================================================================
#
# When using zoxide with --no-cmd, alias these internal functions as desired.
#

__zoxide_z_prefix='z#'

# Jump to a directory using only keywords.
function __zoxide_z() {
    # shellcheck disable=SC2199
    if [[ $# -eq 0 ]]; then
        __zoxide_cd ~
    elif [[ $# -eq 1 && $1 == '-' ]]; then
        __zoxide_cd "${OLDPWD}"
    elif [[ $# -eq 1 && -d $1 ]]; then
        __zoxide_cd "$1"
    elif [[ $# -eq 2 && $1 == '--' ]]; then
        __zoxide_cd "$2"
    elif [[ ${@: -1} == "${__zoxide_z_prefix}"?* ]]; then
        # shellcheck disable=SC2124
        \builtin local result="${@: -1}"
        __zoxide_cd "${result:${#__zoxide_z_prefix}}"
    else
        \builtin local result
        # shellcheck disable=SC2312
        result="$(\command zoxide query --exclude "$(__zoxide_pwd)" -- "$@")" &&
            __zoxide_cd "${result}"
    fi
}

# Jump to a directory using interactive search.
function __zoxide_zi() {
    \builtin local result
    result="$(\command zoxide query --interactive -- "$@")" && __zoxide_cd "${result}"
}

# =============================================================================
#
# Commands for zoxide. Disable these using --no-cmd.
#

\builtin unalias z &>/dev/null || \builtin true
function z() {
    __zoxide_z "$@"
}

\builtin unalias zi &>/dev/null || \builtin true
function zi() {
    __zoxide_zi "$@"
}

# Load completions.
# - Bash 4.4+ is required to use `@Q`.
# - Completions require line editing. Since Bash supports only two modes of
#   line editing (`vim` and `emacs`), we check if either them is enabled.
# - Completions don't work on `dumb` terminals.
if [[ ${BASH_VERSINFO[0]:-0} -eq 4 && ${BASH_VERSINFO[1]:-0} -ge 4 || ${BASH_VERSINFO[0]:-0} -ge 5 ]] &&
    [[ :"${SHELLOPTS}": =~ :(vi|emacs): && ${TERM} != 'dumb' ]]; then
    # Use `printf '\e[5n'` to redraw line after fzf closes.
    \builtin bind '"\e[0n": redraw-current-line' &>/dev/null

    function __zoxide_z_complete() {
        # Only show completions when the cursor is at the end of the line.
        [[ ${#COMP_WORDS[@]} -eq $((COMP_CWORD + 1)) ]] || return

        # If there is only one argument, use `cd` completions.
        if [[ ${#COMP_WORDS[@]} -eq 2 ]]; then
            \builtin mapfile -t COMPREPLY < <(
                \builtin compgen -A directory -- "${COMP_WORDS[-1]}" || \builtin true
            )
        # If there is a space after the last word, use interactive selection.
        elif [[ -z ${COMP_WORDS[-1]} ]] && [[ ${COMP_WORDS[-2]} != "${__zoxide_z_prefix}"?* ]]; then
            \builtin local result
            # shellcheck disable=SC2312
            result="$(\command zoxide query --exclude "$(__zoxide_pwd)" --interactive -- "${COMP_WORDS[@]:1:${#COMP_WORDS[@]}-2}")" &&
                COMPREPLY=("${__zoxide_z_prefix}${result}/")
            \builtin printf '\e[5n'
        fi
    }

    \builtin complete -F __zoxide_z_complete -o filenames -- z
    \builtin complete -r zi &>/dev/null || \builtin true
fi

# =============================================================================

# YAZI Config =================================================================

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# =============================================================================
