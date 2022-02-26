available() {
	local prog=${1?${FUNCNAME[0]}: missing argument}; shift

	command -v "$prog" &>/dev/null
}
