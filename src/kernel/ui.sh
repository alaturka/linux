# --- UI

abort()   { printf '\e[1m\e[38;5;9m✗\e[0m   \e[1m%s\e[0m\n'  "$*" >&2; exit 1;     }
fail()    { printf '\e[1m\e[38;5;9m✗\e[0m   \e[1m%s\e[0m\n'  "$*" >&2;             }
fail-()   { printf '\e[1m\e[38;5;9m✗\e[0m   \e[1m%s\e[0m\n'  "$*" >&2; return 1;   }
getting() { printf '\e[1m\e[38;5;14m…\e[0m   \e[1m%s\e[0m\n' "$*" >&2;             }
info()    { ! verbose || printf '\e[1m\e[38;5;3mℹ\e[0m   \e[0m%s\e[0m\n' "$*" >&2; }
notice()  {
	if [[ $# -gt 0 ]]; then
		printf '\e[1m\e[38;5;11m%s\e[0m\n' "$*"
	else
		printf '\e[1m\e[38;5;11m'; cat -; printf '\e[0m'
	fi >&2
}
panic()   { printf '\e[1m\e[38;5;9m✗\e[0m   \e[0m%s\e[0m\n'  "$*" >&2; exit 128;   }
quit()    { printf '\e[1m✓\e[0m   \e[1m%s\e[0m\n'            "$*" >&2; exit 0;     }
running() { printf '\e[1m\e[38;5;14m>\e[0m   \e[1m%s\e[0m\n' "$*" >&2;             }
succeed() { printf '\e[1m\e[38;5;10m✓\e[0m   \e[1m%s\e[0m\n' "$*" >&2;             }
waiting() { printf '\e[1m\e[38;5;11m…\e[0m   \e[1m%s\e[0m\n' "$*" >&2;             }
warn()    { printf '\e[1m\e[38;5;11m!\e[0m   \e[1m%s\e[0m\n' "$*" >&2;             }
verbose() { [[ -n ${VERBOSE:-} ]] || [[ -n ${LC_VERBOSE:-} ]];                     } # LC_VERBOSE is a hack for sudo
