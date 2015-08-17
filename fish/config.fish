alias gg='git grep -n'
alias gl='git log -1'
alias ff='find . -name'
alias sshlin='ssh -X kirr.haze.yandex.net'
alias sshwin='ssh browser05.yandex-team.ru'
alias cfile='python ~/cfgs/tools/compile_one_file.py '

bind \cb beginning-of-line

set -gx PATH /usr/local/bin ~/yandex/depot_tools $PATH
set -gx GYP_GENERATORS ninja
set -gx EDITOR vim

function git_branch_tmux --on-variable _ --description 'Set tmux window name'
  status --is-command-substitution; and return

  test $TMUX; or return

  set -l tmux_window_name "$_"
  set -l git_top_level (command git rev-parse --show-toplevel ^/dev/null)
  if test -n "$git_top_level"
    set -l git_dir_name (basename $git_top_level)
    set tmux_window_name "[$git_dir_name] $_"
  else
    set -l dir_name (basename $PWD)
    set tmux_window_name "[$dir_name] $_"
  end
  tmux rename-window "$tmux_window_name"
end
