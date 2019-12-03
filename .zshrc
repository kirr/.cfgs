source ~/antigen.zsh

antigen bundle zsh-users/zsh-syntax-highlighting
antigen apply

PS1='$ '

export PATH=~/bin:$PATH
#export PATH=~/yandex/depot_tools:$PATH

export GYP_GENERATORS=ninja
export EDITOR=vim

bindkey -v

bindkey "^?" backward-delete-char
bindkey "^W" backward-kill-word
bindkey "^U" backward-kill-line

# make bash autocomplete with up arrow/down arrow
export HISTFILE=~/.zsh_history
export HISTSIZE=10000
export SAVEHIST=10000
export TERM=xterm-256color
setopt sharehistory
setopt inc_append_history
bindkey "^P" history-beginning-search-backward
bindkey "^N" history-beginning-search-forward

set -o vi
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export FZF_DEFAULT_COMMAND='
  (git ls-tree -r --name-only HEAD ||
   rg --files ||
   find . -path "*/\.*" -prune -o -type f -print -o -type l -print |
      sed s/^..//) 2> /dev/null'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"


# The next line updates PATH for Yandex Cloud CLI.
if [ -f '/Users/kirr/yandex-cloud/path.bash.inc' ]; then source '/Users/kirr/yandex-cloud/path.bash.inc'; fi

source ~/.git-prompt.sh
