self.root() {
	local subject=${1?${FUNCNAME[0]}: missing argument}; shift

	# shellcheck disable=2155
	[[ -n ${self_dir_:-} ]] || declare -g self_dir_=$(readlink -m "${BASH_SOURCE[0]%/*}"/..)

	echo "${self_dir_}/opt/$subject${*+/$*}"
}
