# Only apply these settings in interactive shells.
[[ $- != *i* ]] && return

# History
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoreboth
shopt -s histappend

# Show the current Git branch in the prompt.
git_branch() {
    local b
    b=$(git symbolic-ref --short HEAD 2>/dev/null) && printf ' (%s)' "$b"
}
PS1='\[\e[32m\]\u@\h\[\e[0m\]:\[\e[34m\]\w\[\e[33m\]$(git_branch)\[\e[0m\]\$ '

# Aliases
if ls --color=auto / >/dev/null 2>&1; then
    alias ls='ls --color=auto'
else
    alias ls='ls -G'
fi
alias ll='ls -alF'
alias la='ls -A'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias gccw='gcc -Wall -Wextra -g'
alias gdb='gdb -q'
alias ..='cd ..'
alias grep='grep --color=auto'

# Environment
export EDITOR=vim
export PAGER=less
if [ -d "$HOME/bin" ]; then
    PATH="$HOME/bin:$PATH"
fi

# boilersay
export PATH="$HOME/.local/bin:$PATH"
alias boilersay='cowsay -f train'
alias hail='printf "Hammer Up\nBoiler Down\nHail Purdue\n" | boilersay -n'
