export GYP_GENERATORS=ninja
export GYP_DEFINES='yandex_update_channel=canary'
export CC="ccache clang -Qunused-arguments"
export CXX="ccache clang++ -Qunused-arguments"
export CCACHE_CPP2=yes
export CCACHE_SLOPPINESS=time_macros
export PATH=~/bin:$PATH
export PATH=~/bin/araxis:$PATH
# export PATH=~/Desktop/browser/depot_tools:$PATH
export PATH=~/Desktop/depot_tools:$PATH
# export PATH=~/Desktop/browser_fork/src/third_party/llvm-build/Release+Asserts/bin:$PATH

# make bash autocomplete with up arrow/down arrow
bind '"\e[A":history-search-backward'
bind '"\e[B":history-search-forward'

#git bash complition
if [ -f `brew --prefix`/etc/bash_completion ]; then
    . `brew --prefix`/etc/bash_completion
fi

#git ps1
PS1='\h:\W$(__git_ps1 "(%s)") \u\$ '

shopt -s globstar

sublf() {
  subl $(find . -name $1 | head -1)
}

alias gg='git grep -n'
alias gl='git log -1'
alias ff='find . -name'
alias sv='mvim --remote-silent'
alias ag='ag --nobreak --noheading --color-line-number="1;30" --color-path="1;30" --color-match="1;31"'
