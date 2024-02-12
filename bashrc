#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ..='cd ..'
alias ls='ls --color=auto'
alias ll='eza -hlr --icons'
alias cat='bat -pp --wrap character --terminal-width 80'
alias r='conda activate radian && radian --no-save'
alias tree="tree -C"
alias mamba='micromamba'
alias conda='micromamba'
alias sudo='sudo -E'
alias disable_edp1='swaymsg output eDP-1 disable'

# Set an alias for connecting to RStudio
alias launch-rstudio="conda activate charite-hpc && sc-launch-rstudio \
    -t 12:00:00 \
    -u cabe12 \
    -N 1 \
    -n 1 \
    --mem 64G \
    -c 32 \
    -i /sc-projects/sc-proj-computational-medicine/programs/all-inclusive-rstudio-apptainer/sif/all_inclusive_rstudio_4.3.1.sif \
    -B /sc-projects/sc-proj-computational-medicine/ \
    -B /sc-scratch/sc-scratch-computational-medicine/ \
    -B /sc-resources/ukb/data/ \
    -B /opt/conda"
alias sshfs-hpc='sshfs s-sc-frontend1.charite.de:/ ~/SC-HPC/'
alias ssh-hpc='ssh s-sc-frontend1.charite.de'
alias mount-onedrive="rclone mount \
    --vfs-cache-mode full \
    ChariteOneDrive: OneDrive/ \
    --header 'Prefer: Include-Feature=AddToOneDrive'"

# PS1='[\u@\h \W]\$ '
PS1='\u@\h$ '

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

# alias for clearing screen properly
alias cls='printf "\033c"'

function knit { Rscript -e "rmarkdown::render('$1')"; }
export -f knit
complete -f -X '!*.Rmd' knit

# for gpg-agent
export GPG_TTY="$(tty)"
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent

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

### Presets

[[ "$(whoami)" = "root" ]] && return

[[ -z "$FUNCNEST" ]] && export FUNCNEST=100          # limits recursive functions, see 'man bash'

## Use the up and down arrow keys for finding a command in history
## (you can write some initial letters of the command first).
bind '"\e[A":history-search-backward'
bind '"\e[B":history-search-forward'

# >>> mamba initialize >>>
# !! Contents within this block are managed by 'mamba init' !!
export MAMBA_EXE="/usr/bin/micromamba";
export MAMBA_ROOT_PREFIX="/home/carl/micromamba";
__mamba_setup="$("$MAMBA_EXE" shell hook --shell bash --prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__mamba_setup"
else
    if [ -f "/home/carl/micromamba/etc/profile.d/micromamba.sh" ]; then
        . "/home/carl/micromamba/etc/profile.d/micromamba.sh"
    else
        export  PATH="/home/carl/micromamba/bin:$PATH"  # extra space after export prevents interference from conda init
    fi
fi
unset __mamba_setup
# <<< mamba initialize <<<

# CD on quit when using nnn (-> use alias 'n')
if [ -f /usr/share/nnn/quitcd/quitcd.bash_zsh ]; then
    source /usr/share/nnn/quitcd/quitcd.bash_zsh
fi
