assert.directories() {
	local missings=()

	local dir
	for dir; do
		[[ -d $dir ]] || missings+=("$dir")
	done

	[[ ${#missings[@]} -eq 0 ]] || abort "Directories required: ${missings[*]}"
}
