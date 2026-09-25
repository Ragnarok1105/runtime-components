# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git colored-man-pages)
zstyle ':omz:update' mode reminder

if [ -d "$ZSH" ]; then
    source "$ZSH/oh-my-zsh.sh"
else
    # Fallback prompt when Oh My Zsh is not installed.
    autoload -Uz vcs_info
    precmd() { vcs_info }
    zstyle ':vcs_info:git:*' formats ' (%b)'
    setopt PROMPT_SUBST
    PROMPT='%F{green}%n@%m%f:%F{blue}%~%f%F{yellow}${vcs_info_msg_0_}%f%# '
    autoload -Uz compinit && compinit
fi

# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=20000
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY

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
alias grep='grep --color=auto'

# Environment
export EDITOR=vim
export PAGER=less
if [ -d "$HOME/bin" ]; then
    PATH="$HOME/bin:$PATH"
fi
