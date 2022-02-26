assert.programs() {
	local missings=()

	local prog
	for prog; do
		command -v "$prog" &>/dev/null || missings+=("$prog")
	done

	[[ ${#missings[@]} -eq 0 ]] || abort "Program(s) required: ${missings[*]}"
}
