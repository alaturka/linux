url.ok() {
	local url=${1?${FUNCNAME[0]}: missing argument}; shift
	local timeout=${1:-10}

	curl -fsLI -m "$timeout" "$url" -o /dev/null
}
