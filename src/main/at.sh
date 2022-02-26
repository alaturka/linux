at() {
	local path=${1?${FUNCNAME[0]}: missing argument}; shift

	local paths=()

	if [[ $path = ... ]]; then
		paths+=(.local .git .github)
	else
		paths=("$path")
	fi

	if dir=$(hill "${1:-}" "${paths[@]}"); then
		cd "$dir" || exit
	else
		abort 'Top level directory not detected'
	fi

	case ${0:-} in
	*/sbin/*) [[ -n ${SUDO_USER:-} ]] || abort 'Sudo required' ;;
	esac
}

hill() {
	local cwd=${1?${FUNCNAME[0]}: missing argument}; shift

	local err=0; local hill; hill=$(
		[[ -z $cwd ]] || cd "$cwd" || exit

		while :; do
			local try

			for try; do
				if [[ -e $try ]]; then
					echo "$PWD"
					exit 0
				fi
			done

			# shellcheck disable=2128
			if [[ $PWD == "/" ]]; then
				break
			fi

			cd .. || exit
		done

		exit 1
	) || err=$?

	if [[ $err -eq 0 ]] && [[ -n ${hill:-} ]]; then
		echo "$hill"
		return 0
	fi

	return 1
}
