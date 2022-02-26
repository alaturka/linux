os.codename() {
	local codename=unknown target=/etc/os-release

	# shellcheck disable=1090
	if [[ -f $target ]]; then
		codename=$(. "$target" && echo "$VERSION_CODENAME")
	fi

	echo "$codename"
}
