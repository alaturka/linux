# shellcheck disable=2120
net.ok() {
	local tries=${1:-10}

	while ! ip route get 1.1.1.1 &>/dev/null; do
		sleep 0.1

		((tries--)); [[ $tries -gt 0 ]] || return 1
	done

	return 0
}
