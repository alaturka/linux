apt.add() {
	local name=${1?${FUNCNAME[0]}: missing argument};  shift
	local key=${1?${FUNCNAME[0]}: missing argument};   shift
	local src=${1?${FUNCNAME[0]}: missing argument};   shift
	local suite=${1?${FUNCNAME[0]}: missing argument}; shift

	local components=${*:-main}

	local list=/etc/apt/sources.list.d/$name.list
	local keyring=/usr/share/keyrings/$name.gpg

	! [[ -f $list ]] || return 0

	local -i err=0; local temp="$keyring".tmp; (
		curl -fsSL "$key" >"$temp"

		if grep -qFI '' "$temp"; then # text?
			gpg --dearmor <"$temp" >"$keyring"
		else # binary?
			mv -f "$temp" "$keyring"
		fi
	) || err=$?; rm -f "$temp"

	[[ $err -eq 0 ]] || return $err

	cat >"$list" <<-EOF
		deb [signed-by=$keyring] $src $suite $components
	EOF

	apt-get update --quiet --yes
}
