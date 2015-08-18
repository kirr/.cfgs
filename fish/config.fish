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

function tmux_window_name --description 'return tmux window name'
  set -l window_name "$_"
  set -l git_top_level (command git rev-parse --show-toplevel ^/dev/null)
  if test -n "$git_top_level"
    set -l git_dir_name (basename $git_top_level)
    set window_name "[$git_dir_name] $_"
  else
    set -l dir_name (basename $PWD)
    set window_name "[$dir_name] $_"
  end
  echo $window_name
end

# Keeping these together avoids many duplicated checks
function git_prompt_operation_branch_bare --description "__fish_git_prompt_operation_bare copy"
  # This function is passed the full repo_info array
  set -l git_dir         $argv[1]
  set -l inside_gitdir   $argv[2]
  set -l bare_repo       $argv[3]
  set -l short_sha
  if test (count $argv) = 5
    set short_sha $argv[5]
  end

  set -l branch
  set -l operation
  set -l detached no
  set -l bare
  set -l step
  set -l total
  set -l os

  if test -d $git_dir/rebase-merge
    set branch (cat $git_dir/rebase-merge/head-name ^/dev/null)
    set step (cat $git_dir/rebase-merge/msgnum ^/dev/null)
    set total (cat $git_dir/rebase-merge/end ^/dev/null)
    if test -f $git_dir/rebase-merge/interactive
      set operation "|REBASE-i"
    else
      set operation "|REBASE-m"
    end
  else
    if test -d $git_dir/rebase-apply
      set step (cat $git_dir/rebase-apply/next ^/dev/null)
      set total (cat $git_dir/rebase-apply/last ^/dev/null)
      if test -f $git_dir/rebase-apply/rebasing
        set branch (cat $git_dir/rebase-apply/head-name ^/dev/null)
        set operation "|REBASE"
      else if test -f $git_dir/rebase-apply/applying
        set operation "|AM"
      else
        set operation "|AM/REBASE"
      end
    else if test -f $git_dir/MERGE_HEAD
      set operation "|MERGING"
    else if test -f $git_dir/CHERRY_PICK_HEAD
      set operation "|CHERRY-PICKING"
    else if test -f $git_dir/REVERT_HEAD
      set operation "|REVERTING"
    else if test -f $git_dir/BISECT_LOG
      set operation "|BISECTING"
    end
  end

  if test -n "$step" -a -n "$total"
    set operation "$operation $step/$total"
  end

  if test -z "$branch"
    set branch (command git symbolic-ref HEAD ^/dev/null; set os $status)
    if test $os -ne 0
      set detached yes
      set branch (switch "$__fish_git_prompt_describe_style"
            case contains
              command git describe --contains HEAD
            case branch
              command git describe --contains --all HEAD
            case describe
              command git describe HEAD
            case default '*'
              command git describe --tags --exact-match HEAD
            end ^/dev/null; set os $status)
      if test $os -ne 0
        if test -n "$short_sha"
          set branch $short_sha...
        else
          set branch unknown
        end
      end
      set branch "($branch)"
    end
  end

  if test "true" = $inside_gitdir
    if test "true" = $bare_repo
      set bare "BARE:"
    else
      # Let user know they're inside the git dir of a non-bare repo
      set branch "GIT_DIR!"
    end
  end

  echo $operation
  echo $branch
  echo $detached
  echo $bare
end

function git_status_state --description 'return git status string'
  set -l repo_info (command git rev-parse --git-dir --is-inside-git-dir --is-bare-repository --is-inside-work-tree --short HEAD ^/dev/null)
  test -n "$repo_info"; or return

  set -l rbc (git_prompt_operation_branch_bare $repo_info)
  set -l r $rbc[1] # current operation
  set -l b (command basename $rbc[2]) # current branch
  echo "$b$r"
end

function update_tmux_state --on-variable _ --description 'Set tmux window name'
  status --is-command-substitution; and return

  test $TMUX; or return

  set -l window_name (tmux_window_name)
  set -l b_op (git_status_state)

  tmux rename-window -t$TMUX_PANE "$window_name"
  tmux set-window-option status-left "$b_op"
end
