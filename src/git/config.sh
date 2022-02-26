git.config() {
	local dir=${1?${FUNCNAME[0]}: missing argument}; shift
	local key=${1?${FUNCNAME[0]}: missing argument}; shift

	if [[ $# -eq 0 ]]; then
		git config -C "$dir" --local --get "$key"
	elif [[ -n $1 ]]; then
		git config -C "$dir" --local "$key" "$1"
	else
		git config -C "$dir" --local --unset "$key"
	fi || true
}
