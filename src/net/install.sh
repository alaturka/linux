url.install() {
	local url=${1?${FUNCNAME[0]}: missing argument}; shift
	local dst=${1?${FUNCNAME[0]}: missing argument}; shift
	local timeout=${1:-10}

	curl -fsSL -m "$timeout" "$url" |
	case $url in
	*.tar.gz) tar -xz -C "$dst" ;;
	*.tar.xz) tar -xJ -C "$dst" ;;
	esac
}
