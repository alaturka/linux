apt.update() {
	local target=/var/cache/apt/pkgcache.bin expiry=3

	if ! [[ -f $target ]] || [[ -n $(find "$target" -maxdepth 0 -type f -mmin +"$expiry" 2>/dev/null) ]]; then
		apt-get update -qq
	fi
}
