git.islocalandpresent() {
	local url=${1?${FUNCNAME[0]}: missing argument}; shift
	local dir=${1?${FUNCNAME[0]}: missing argument}; shift

	# Fast code path
	if [[ $url == . ]] && [[ $dir == . ]]; then
		return 0
	fi

	case $url in
	file://*) url=${url#file://} ;;
	esac

	case $url in
	*://*)
		return 1
		;;
	*)
		local this that

		this=$(readlink -m "$url") || return
		that=$(readlink -m "$dir") || return

		if [[ $this == "$that" ]]; then
			return 0
		fi
		;;
	esac

	return 1
}

git.clone() {
	local url=${1?${FUNCNAME[0]}: missing argument}; shift
	local dir=${1?${FUNCNAME[0]}: missing argument}; shift
	local ref=${1:-}

	if git.islocalandpresent "$url" "$dir"; then
		info "Skip cloning as the repository seems local: $url"

		return 0
	fi

	if [[ -e $dir ]]; then
		fail "Destination already exists: $dir"
		return 1
	fi

	local flags=(
		'--single-branch'
		'--quiet'
	)

	[[ -z ${ref:-} ]] || [[ $ref == . ]] || flags+=(
		'--branch'
		"$ref"
	)

	getting "Cloning $url"

	local -i err=0
	git clone "${flags[@]}" "$url" "$dir" || err=$?

	if [[ $err -ne 0 ]]; then
		fail "Cloning repository failed: $url"
		rm -rf -- "$dir"
	fi

	return $err
}
