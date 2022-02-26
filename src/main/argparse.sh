argparse() {
	[[ $(declare -p argv 2>/dev/null) =~ 'declare -a' ]] || panic 'argv must be defined'
	[[ $(declare -p argh 2>/dev/null) =~ 'declare -A' ]] || panic 'argh must be defined'

	while [[ $# -gt 0 ]]; do
		case $1 in
		--)
			shift
			;;
		*=*)
			local key=${1%%=*} value=${1#*=}

			argh[$key]=$value
			shift
			;;
		*)
			break
			;;
		esac
	done

	argv=("$@")
}
