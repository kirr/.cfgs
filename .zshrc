source ~/cfgs/antigen/antigen.zsh

antigen bundle zsh-users/zsh-syntax-highlighting
antigen apply

PS1='$ '

export PATH=~/bin:$PATH
export PATH=~/yandex/depot_tools:$PATH

export GYP_GENERATORS=ninja
export EDITOR=vim

bindkey -v

bindkey "^?" backward-delete-char
bindkey "^W" backward-kill-word
bindkey "^U" backward-kill-line

# make bash autocomplete with up arrow/down arrow
export HISTFILE=~/.zsh_history
export HISTSIZE=100000
export SAVEHIST=2000
setopt sharehistory
setopt inc_append_history
bindkey "^P" history-beginning-search-backward
bindkey "^N" history-beginning-search-forward

alias gg='git grep -n'
alias gl='git log -1'
alias ff='find . -name'
alias sshlin='ssh root@browser-dev-kirr.man.yp-c.yandex.net'
alias sshwin='ssh browser05.yandex-team.ru'
alias cfile='python ~/cfgs/tools/compile_one_file.py '
export PATH="/usr/local/opt/go@1.8/bin:$PATH"

export FZF_DEFAULT_COMMAND='
  (git ls-tree -r --name-only HEAD ||
   find . -path "*/\.*" -prune -o -type f -print -o -type l -print |
      sed s/^..//) 2> /dev/null'
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
