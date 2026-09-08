[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias rm='rm -i'
alias p=wl-paste
alias c='wl-copy -n'

PS1='[\[\e[32m\]\u\[\e[0m\]@\[\e[31m\]\h\[\e[0m\] \W]\$ '
# Nice response for ANSI colors https://stackoverflow.com/questions/4842424/list-of-ansi-color-escape-sequences


[ -z "$DISPLAY" ] && niri-session

PATH=$PATH:$HOME/.local/bin

# [ $(uptime -r | cut -d ' ' -f 2) -lt 2 ] && cat c | c

cat todo
