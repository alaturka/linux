self.renew() {
	builtin pushd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null || exit

	# shellcheck disable=2119
	if git.sane; then
		git.sync || warn 'Self renew failed'
	else
		warn 'No Git repository found to self renew'
	fi

	builtin popd >/dev/null || exit
}

self.renew-() {
	builtin pushd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null || exit

	# shellcheck disable=2119
	if git.sane; then
		git.sync || abort 'Self renew failed'
	else
		abort 'No Git repository found to self renew'
	fi

	builtin popd >/dev/null || exit
}
