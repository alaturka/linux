os.id() {
	local id=unknown target=/etc/os-release

	# shellcheck disable=1090
	if [[ -f $target ]]; then
		id=$(. "$target" && echo "$ID")
	fi

	echo "$id"
}
