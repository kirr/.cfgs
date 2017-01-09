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
alias sshlin='ssh -X kirr.haze.yandex.net'
alias sshwin='ssh browser05.yandex-team.ru'
alias cfile='python ~/cfgs/tools/compile_one_file.py '
