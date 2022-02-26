self.source() {
	echo "$(<"${BASH_SOURCE[0]}")"

	[[ $# -eq 0 ]] || { echo; echo "$*"; }
}
