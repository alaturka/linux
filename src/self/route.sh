self.route() {
	local subject=${1?${FUNCNAME[0]}: missing argument}; shift
	local route=${1?${FUNCNAME[0]}: missing argument};   shift

	# shellcheck disable=2155
	[[ -n ${self_dir_:-} ]] || declare -g self_dir_=$(readlink -m "${BASH_SOURCE[0]%/*}"/..)

	local exec=$self_dir_/libexec/$subject/$route

	[[ -x $exec ]] || panic "Executable not found for route $route: $exec"

	running "$route"

	"$exec" "$@"
}

self.route-() {
	local subject=${1?${FUNCNAME[0]}: missing argument}; shift
	local route=${1?${FUNCNAME[0]}: missing argument};   shift

	# shellcheck disable=2155
	[[ -n ${self_dir_:-} ]] || declare -g self_dir_=$(readlink -m "${BASH_SOURCE[0]%/*}"/..)

	local exec=$self_dir_/libexec/$subject/$route

	[[ -x $exec ]] || panic "Executable not found for route $route: $exec"

	! [[ -t 1 ]] || info "$route"

	builtin exec "$exec" "$@"
}

procedure()  { self.route  procedure "${1?${FUNCNAME[0]}: missing argument}" "${@:2}"; }
procedure-() { self.route- procedure "${1?${FUNCNAME[0]}: missing argument}" "${@:2}"; }

provision()  { self.route  provision "${1?${FUNCNAME[0]}: missing argument}" "${@:2}"; }
provision-() { self.route- provision "${1?${FUNCNAME[0]}: missing argument}" "${@:2}"; }

scriptlet()  { self.route  scriptlet "${1?${FUNCNAME[0]}: missing argument}" "${@:2}"; }
scriptlet-() { self.route- scriptlet "${1?${FUNCNAME[0]}: missing argument}" "${@:2}"; }
