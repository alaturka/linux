# --- UI minimal

abort() { printf '\e[1m\e[38;5;9m✗\e[0m   \e[1m%s\e[0m\n' "$*" >&2; exit 1;   }
fail()  { printf '\e[1m\e[38;5;9m✗\e[0m   \e[1m%s\e[0m\n' "$*" >&2;           }
fail-() { printf '\e[1m\e[38;5;9m✗\e[0m   \e[1m%s\e[0m\n' "$*" >&2; return 1; }
panic() { printf '\e[1m\e[38;5;9m✗\e[0m   \e[0m%s\e[0m\n' "$*" >&2; exit 128; }
quit()  { printf '\e[1m✓\e[0m   \e[1m%s\e[0m\n'           "$*" >&2; exit 0;   }
