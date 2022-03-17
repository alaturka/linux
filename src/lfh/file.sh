lfh.put() {
	local source=${1?${FUNCNAME[0]}: missing argument}; shift
	local target=${1?${FUNCNAME[0]}: missing argument}; shift

	[[ -e $source ]] || return 0

	if [[ ! -f $target ]]; then
		cp -a "$source" "$target"

		if [[ -f .git/info/exclude ]]; then
			echo "/$target" >>.git/info/exclude
		fi
	else
		if git ls-files --error-unmatch "$target" &>/dev/null; then
			return
		fi

		if [[ $source -nt $target ]]; then
			cp -a "$source" "$target"
		fi
	fi
}
