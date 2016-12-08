source ~/cfgs/antigen/antigen.zsh

antigen bundle zsh-users/zsh-syntax-highlighting
antigen apply

PS1='$ '

export PATH=~/bin:$PATH
export PATH=~/yandex/depot_tools:$PATH

export GYP_GENERATORS=ninja
export EDITOR=vim

bindkey -v

# make bash autocomplete with up arrow/down arrow
export HISTFILE=~/.zsh_history
export HISTSIZE=100000
setopt -o sharehistory
setopt -o inc_append_history
bindkey "^[[A" history-beginning-search-backward
bindkey "^[[B" history-beginning-search-forward

alias gg='git grep -n'
alias gl='git log -1'
alias ff='find . -name'
alias sshlin='ssh -X kirr.haze.yandex.net'
alias sshwin='ssh browser05.yandex-team.ru'
alias cfile='python ~/cfgs/tools/compile_one_file.py '

function update_title() {
  local a
  # escape '%' in $1, make nonprintables visible
  a=${(V)1//\%/\%\%}
  a=$(print -n "%20>...>$a" | tr -d "\n")
  if [[ -n "$TMUX" ]]; then
    print -n "\ek${(%)a}:${(%)2}\e\\"
  elif [[ "$TERM" =~ "screen*" ]]; then
    print -n "\ek${(%)a}:${(%)2}\e\\"
  elif [[ "$TERM" =~ "xterm*" ]]; then
    print -n "\e]0;${(%)a}:${(%)2}\a"
  fi
}

# called just before the prompt is printed
function _zsh_title__precmd() {
  update_title "zsh" "%20<...<%~"
}

# called just before a command is executed
function _zsh_title__preexec() {
  local -a cmd; cmd=(${(z)1})             # Re-parse the command line

  # Construct a command that will output the desired job number.
  case $cmd[1] in
    fg)	cmd="${(z)jobtexts[${(Q)cmd[2]:-%+}]}" ;;
    %*)	cmd="${(z)jobtexts[${(Q)cmd[1]:-%+}]}" ;;
  esac
  update_title "$cmd" "%20<...<%~"
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _zsh_title__precmd
add-zsh-hook preexec _zsh_title__preexec
