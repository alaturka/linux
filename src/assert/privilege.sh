assert.privilege() {
	[[ ${EUID:-} -eq 0 ]] || abort "Sudo required"
}
