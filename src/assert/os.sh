assert.os() {
	local os=${1?${FUNCNAME[0]}: missing argument}; shift

	local id target=/etc/os-release

	# shellcheck disable=1090
	if [[ -f $target ]]; then
		id=$(. "$target" && echo "$ID")
	fi
	
	[[ -n ${id:-} ]] || panic 'Cannot determine OS type'

	case $os in
	debuntu) [[ $id == debian ]] || [[ $id == ubuntu ]] || [[ $id == pop ]] ;;
	debian)  [[ $id == debian ]]                                            ;;
	ubuntu)  [[ $id == ubuntu ]]                                            ;;
	pop)     [[ $id == pop    ]]                                            ;;
	*)       panic "Unknown OS type: $os"                                   ;;
	esac || abort "Unsupported OS: $id"
}
