# Some parts are adapted from https://github.com/mrzool/bash-sensible
[[ -n ${PS1:-} ]] || return

HISTSIZE=500000
HISTFILESIZE=100000
HISTCONTROL='erasedups:ignoreboth'
HISTTIMEFORMAT='%F %T '
HISTIGNORE='&:[ ]*:exit:ls:bg:fg:history:clear'; export HISTIGNORE

shopt -s autocd
shopt -s cdspell
shopt -s checkwinsize
shopt -s cmdhist
shopt -s dirspell
shopt -s globstar
shopt -s histappend
shopt -s nocaseglob
shopt -s no_empty_cmd_completion

bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
bind '"\e[C": forward-char'
bind '"\e[D": backward-char'
bind 'set completion-ignore-case on'
bind 'set completion-map-case on'
bind 'set mark-symlinked-directories on'
bind 'set show-all-if-ambiguous on'

if [[ -x /usr/bin/dircolors ]]; then
	eval -- "$(dircolors -b)"

    	alias ls='ls --color=auto'
	alias grep='grep --color=auto'
	alias fgrep='fgrep --color=auto'
	alias egrep='egrep --color=auto'
fi

# shellcheck disable=1091
if [[ -f /usr/share/bash-completion/bash_completion ]]; then
	. /usr/share/bash-completion/bash_completion
elif [[ -f /etc/bash_completion ]]; then
	. /etc/bash_completion
fi

if [[ -x /usr/lib/command-not-found ]] || [[ -x /usr/share/command-not-found/command-not-found ]]; then
	command_not_found_handle() {
                if [[ -x /usr/lib/command-not-found ]]; then
			/usr/lib/command-not-found -- "$1"
                	return $?
                elif [[ -x /usr/share/command-not-found/command-not-found ]]; then
			/usr/share/command-not-found/command-not-found -- "$1"
                	return $?
		else
			printf "%s: command not found\n" "$1" >&2
			return 127
		fi
	}
fi

# shellcheck disable=2034
declare -Ag ansi_colors_256=(
	[black]='\e[1m\e[38;5;8m'
	[blue]='\e[1m\e[38;5;12m'
	[cyan]='\e[1m\e[38;5;14m'
	[green]='\e[1m\e[38;5;10m'
	[grey]='\e[1m\e[38;5;8m'
	[magenta]='\e[1m\e[38;5;13m'
	[red]='\e[1m\e[38;5;9m'
	[white]='\e[1m\e[38;5;15m'
	[yellow]='\e[1m\e[38;5;11m'

	[null]='\e[0m'
)

prompt_command() {
	local last_exit_code=$?

	if ! [[ $PWD == "$HOME" ]]; then
		local pwd=${PWD/#$HOME/\~}; local slug=${pwd##*/} dir=${pwd%/*}/
	else
		local slug='~' dir=''
	fi

	local char='>'; [[ ${EUID:-} -ne 0 ]] || char='#'

	local -n c=ansi_colors_256
	c[char]=${c[yellow]}; [[ $last_exit_code -eq 0 ]] || c[char]=${c[red]}

	PS1="\[${c[grey]}\]${dir}\[${c[null]}\]\[${c[cyan]}\]${slug}\[${c[null]}\] \[${c[char]}\]${char}\[${c[null]}\] "
}
export PROMPT_COMMAND=prompt_command

[[ ! -d ~/.local/src/github.com ]] || CDPATH=.:~/.local/src/github.com

alias e='editor'
alias E='sudo editor'

play() {
	local prog

	if prog=$(command -v play 2>/dev/null) && [[ -x $prog ]]; then
		"$prog" "$@"
	elif command -v classwork &>/dev/null; then
		classwork play "$@"
	fi
}
