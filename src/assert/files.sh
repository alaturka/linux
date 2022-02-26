assert.files() {
	local missings=()

	local file
	for file; do
		[[ -f $file ]] || missings+=("$file")
	done

	[[ ${#missings[@]} -eq 0 ]] || abort "File(s) required: ${missings[*]}"
}
