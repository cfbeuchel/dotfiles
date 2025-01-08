#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc
#
# Source fzf file?
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Modify $PATH
#
# Include ~/bin
export PATH=$PATH:~/bin/
