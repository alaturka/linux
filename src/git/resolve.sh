# shellcheck disable=2120
git.resolve() {
	local path=${1:-}

	if [[ -n $path ]]; then
		[[ -e $path ]] || fail "No such path found: $path"

		local dir=$path
		[[ -d $path ]] || dir=${path%/*}

		pushd "$dir" >/dev/null || exit
	fi

	local -i err=0
	git rev-parse --show-toplevel || err=$?

	if [[ -n $path ]]; then
		popd >/dev/null || exit
	fi

	return $err
}
