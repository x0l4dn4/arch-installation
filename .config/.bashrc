[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '
[ -z "$DISPLAY" ] && niri-session

PATH=$PATH:$HOME/.local/bin
