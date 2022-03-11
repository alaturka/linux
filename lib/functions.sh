set -Eeuo pipefail; shopt -s nullglob; unset CDPATH; IFS=$' \t\n'; [[ -z ${TRACE:-} ]] || set -x
export LC_ALL=C.UTF-8 LANG=C.UTF-8 DEBIAN_FRONTEND=noninteractive

available() {
	local prog=${1?${FUNCNAME[0]}: missing argument}; shift

	command -v "$prog" &>/dev/null
}

pp() {
	local pp_name_=${1?${FUNCNAME[0]}: missing argument}; shift
	local -n pp_ref_=$pp_name_
	local pp_label_=${*:-"${!pp_ref_}"}

	if [[ "$(declare -p "$pp_name_")" =~ declare\ -[aA] ]]; then
		echo "$pp_label_"
	
		local key
		for key in "${!pp_ref_[@]}"; do
			printf '    %-32s%s\n' "${key}" "${pp_ref_[$key]}"
		done | sort
	else
		printf '    %-32s%s\n' "${pp_label_}" "${pp_ref_}"
	fi

	echo
}

pp-() {
	local pp_name_=${1?${FUNCNAME[0]}: missing argument}; shift
	local -n pp_ref_=$pp_name_

	if [[ "$(declare -p "$pp_name_")" =~ declare\ -[aA] ]]; then
		local key
		for key in "${!pp_ref_[@]}"; do
			printf '    %-32s%s\n' "${key}" "${pp_ref_[$key]}"
		done | sort
	else
		printf '    %-32s%s\n' '' "${pp_ref_}"
	fi

	echo
}

# --- UI

abort()   { printf '\e[1m\e[38;5;9m✗\e[0m   \e[1m%s\e[0m\n'  "$*" >&2; exit 1;     }
fail()    { printf '\e[1m\e[38;5;9m✗\e[0m   \e[1m%s\e[0m\n'  "$*" >&2;             }
fail-()   { printf '\e[1m\e[38;5;9m✗\e[0m   \e[1m%s\e[0m\n'  "$*" >&2; return 1;   }
getting() { printf '\e[1m\e[38;5;14m…\e[0m   \e[1m%s\e[0m\n' "$*" >&2;             }
panic()   { printf '\e[1m\e[38;5;9m✗\e[0m   \e[0m%s\e[0m\n'  "$*" >&2; exit 128;   }
quit()    { printf '\e[1m✓\e[0m   \e[1m%s\e[0m\n'            "$*" >&2; exit 0;     }
running() { printf '\e[1m\e[38;5;14m>\e[0m   \e[1m%s\e[0m\n' "$*" >&2;             }
succeed() { printf '\e[1m\e[38;5;10m✓\e[0m   \e[1m%s\e[0m\n' "$*" >&2;             }
waiting() { printf '\e[1m\e[38;5;11m…\e[0m   \e[1m%s\e[0m\n' "$*" >&2;             }
warn()    { printf '\e[1m\e[38;5;11m!\e[0m   \e[1m%s\e[0m\n' "$*" >&2;             }
verbose() { [[ -n ${VERBOSE:-} ]] || [[ -n ${LC_VERBOSE:-} ]];                     } # LC_VERBOSE is a hack for sudo
info()    { ! verbose || printf '\e[1m\e[38;5;3mℹ\e[0m   \e[0m%s\e[0m\n' "$*" >&2; }

assert.directories() {
	local missings=()

	local dir
	for dir; do
		[[ -d $dir ]] || missings+=("$dir")
	done

	[[ ${#missings[@]} -eq 0 ]] || abort "Directories required: ${missings[*]}"
}

assert.files() {
	local missings=()

	local file
	for file; do
		[[ -f $file ]] || missings+=("$file")
	done

	[[ ${#missings[@]} -eq 0 ]] || abort "File(s) required: ${missings[*]}"
}

assert.os() {
	local os=${1?${FUNCNAME[0]}: missing argument}; shift

	local id target=/etc/os-release

	# shellcheck disable=1090
	if [[ -f $target ]]; then
		id=$(. "$target" && echo "$ID")
	fi
	
	[[ -n ${id:-} ]] || panic 'Cannot determine OS type'

	case $os in
	debuntu) [[ $id == debian ]] || [[ $id == ubuntu ]] || [[ $id == pop ]] ;;
	debian)  [[ $id == debian ]]                                            ;;
	ubuntu)  [[ $id == ubuntu ]]                                            ;;
	pop)     [[ $id == pop    ]]                                            ;;
	*)       panic "Unknown OS type: $os"                                   ;;
	esac || abort "Unsupported OS: $id"
}

assert.privilege() {
	[[ ${EUID:-} -eq 0 ]] || abort "Sudo required"
}

assert.programs() {
	local missings=()

	local prog
	for prog; do
		command -v "$prog" &>/dev/null || missings+=("$prog")
	done

	[[ ${#missings[@]} -eq 0 ]] || abort "Program(s) required: ${missings[*]}"
}

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

apt.clean() {
	apt-get -y autoremove --purge || true
	apt-get -y autoclean          || true
}

apt.install() {
	apt.update && apt-get install -y --no-install-recommends "$@"
}

apt.install-() {
	apt-get update -qq && apt-get install -y --no-install-recommends "$@"
}

apt.update() {
	local target=/var/cache/apt/pkgcache.bin expiry=3

	if ! [[ -f $target ]] || [[ -n $(find "$target" -maxdepth 0 -type f -mmin +"$expiry" 2>/dev/null) ]]; then
		apt-get update -qq
	fi
}

apt.upgrade() {
	apt.update && apt-get -qq upgrade
}


git.islocalandpresent() {
	local url=${1?${FUNCNAME[0]}: missing argument}; shift
	local dir=${1?${FUNCNAME[0]}: missing argument}; shift

	# Fast code path
	if [[ $url == . ]] && [[ $dir == . ]]; then
		return 0
	fi

	case $url in
	file://*) url=${url#file://} ;;
	esac

	case $url in
	*://*)
		return 1
		;;
	*)
		local this that

		this=$(readlink -m "$url") || return
		that=$(readlink -m "$dir") || return

		if [[ $this == "$that" ]]; then
			return 0
		fi
		;;
	esac

	return 1
}

git.clone() {
	local url=${1?${FUNCNAME[0]}: missing argument}; shift
	local dir=${1?${FUNCNAME[0]}: missing argument}; shift
	local ref=${1:-}

	if git.islocalandpresent "$url" "$dir"; then
		info "Skip cloning as the repository seems local: $url"

		return 0
	fi

	if [[ -e $dir ]]; then
		fail "Destination already exists: $dir"
		return 1
	fi

	local flags=(
		'--single-branch'
		'--quiet'
	)

	[[ -z ${ref:-} ]] || [[ $ref == . ]] || flags+=(
		'--branch'
		"$ref"
	)

	getting "Cloning $url"

	local -i err=0
	git clone "${flags[@]}" "$url" "$dir" || err=$?

	if [[ $err -ne 0 ]]; then
		fail "Cloning repository failed: $url"
		rm -rf -- "$dir"
	fi

	return $err
}

# shellcheck disable=2120
git.describe() {
	local dir=${1:-.}

	local description
	description=$(git -C "$dir" describe --always --long 2>/dev/null || true)

	echo "${description:-Unknown}"
}

# shellcheck disable=2120
git.resolve() {
	local path=${1:-}

	if [[ -n $path ]]; then
		[[ -e $path ]] || fail "No such path found: $path"

		local dir=$path
		[[ -d $path ]] || dir=${path%/*}

		pushd "$dir" >/dev/null || exit
	fi

	local -i err=0
	git rev-parse --show-toplevel || err=$?

	if [[ -n $path ]]; then
		popd >/dev/null || exit
	fi

	return $err
}

# shellcheck disable=2120
git.sane() {
	local dir=${1:-.}

	git -C "$dir" rev-parse --is-inside-work-tree &>/dev/null || return 1
	git -C "$dir" rev-parse --verify HEAD &>/dev/null         || return 1
}

# git.sync syncs the working copy of a Git repository with the remote
#
# $1: working copy, default: current directory
# $2: remote url,   default: current remote origin
# $3: branch,       default: current branch
#
# Use "." or empty string in place of the argument to accept the default value
# shellcheck disable=2120
git.sync() {
	local dir=.
	if [[ $# -gt 0 ]]; then
		[[ -z $1 ]] || [[ $1 == . ]] || dir=$1
		shift
	fi

	if ! git -C "$dir" rev-parse --verify HEAD &>/dev/null; then
		fail "Not a (valid) Git repository: $dir"
		return 1
	fi

	local type
	type=$(git -C "$dir" config --local --default=exact --get sync.type)

	if [[ $type == never ]]; then
		info "Skip syncing due to the sync type: $type"
		return 0
	fi

	local epoch
	epoch=$(git -C "$dir" config --local --default=0 --get sync.epoch)

	if [[ $((EPOCHSECONDS - epoch)) -le ${GIT_SYNC_EXPIRE:-60} ]]; then
		info "Skip syncing due to the sync epoch"
		return 0
	fi

	local cururl
	cururl=$(git -C "$dir" config remote.origin.url)

	local url=$cururl
	if [[ $# -gt 0 ]]; then
		[[ -z $1 ]] || [[ $1 == . ]] || url=$1
		shift
	fi

	local curref
	curref=$(git -C "$dir" rev-parse --abbrev-ref HEAD)

	local ref=$curref
	if [[ $# -gt 0 ]]; then
		[[ -z $1 ]] || [[ $1 == . ]] || ref=$1
		shift
	fi

	local before after

	getting "Syncing with $url"

	before=$(git -C "$dir" rev-parse HEAD)

	if [[ $url != "$cururl" ]] || [[ $ref != "$curref" ]]; then
		[[ $url == "$cururl" ]] || git -C "$dir" config remote.origin.url "$url"

		# Reset git fetch refs, so that it can fetch all branches (GH-3368)
		git -C "$dir" config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'
		# Fetch remote branch
		git -C "$dir" fetch --quiet --force origin "refs/heads/\"$ref\":refs/remotes/origin/$ref"
		# Checkout and track the branch
		git -C "$dir" checkout --quiet -B "$ref" -t origin/"$ref"
		# Reset branch HEAD
		git -C "$dir" reset --quiet --hard origin/"$ref"
	else
		git -C "$dir" fetch --quiet --force origin
		# Reset branch HEAD
		git -C "$dir" reset --quiet --hard origin/"$ref"
	fi

	after=$(git -C "$dir" rev-parse HEAD)

	[[ $type == exact ]] || git -C "$dir" clean -xdfq

	git -C "$dir" config --local sync.epoch "$EPOCHSECONDS"

	if [[ $before == "$after" ]]; then
		info 'No changes found'
	else
		info 'Changes found'

		if verbose; then
			git -C "$dir" \
				--no-pager \
				log \
				--no-decorate \
				--format='tformat: * %C(yellow)%h%Creset %<|(72,trunc)%s %C(cyan)%cr%Creset' \
				"$before..HEAD"
		fi
	fi
}

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

at() {
	local path=${1?${FUNCNAME[0]}: missing argument}; shift

	local paths=()

	if [[ $path = ... ]]; then
		paths+=(.local .git .github)
	else
		paths=("$path")
	fi

	if dir=$(hill "${1:-}" "${paths[@]}"); then
		cd "$dir" || exit
	else
		abort 'Top level directory not detected'
	fi

	case ${0:-} in
	*/sbin/*) [[ -n ${SUDO_USER:-} ]] || abort 'Sudo required' ;;
	esac
}

hill() {
	local cwd=${1?${FUNCNAME[0]}: missing argument}; shift

	local err=0; local hill; hill=$(
		[[ -z $cwd ]] || cd "$cwd" || exit

		while :; do
			local try

			for try; do
				if [[ -e $try ]]; then
					echo "$PWD"
					exit 0
				fi
			done

			# shellcheck disable=2128
			if [[ $PWD == "/" ]]; then
				break
			fi

			cd .. || exit
		done

		exit 1
	) || err=$?

	if [[ $err -eq 0 ]] && [[ -n ${hill:-} ]]; then
		echo "$hill"
		return 0
	fi

	return 1
}

# shellcheck disable=2120
net.ok() {
	local tries=${1:-10}

	while ! ip route get 1.1.1.1 &>/dev/null; do
		sleep 0.1

		((tries--)); [[ $tries -gt 0 ]] || return 1
	done

	return 0
}

url.ok() {
	local url=${1?${FUNCNAME[0]}: missing argument}; shift
	local timeout=${1:-10}

	curl -fsLI -m "$timeout" "$url" -o /dev/null
}

os.codename() {
	local codename=unknown target=/etc/os-release

	# shellcheck disable=1090
	if [[ -f $target ]]; then
		codename=$(. "$target" && echo "$VERSION_CODENAME")
	fi

	echo "$codename"
}

os.id() {
	local id=unknown target=/etc/os-release

	# shellcheck disable=1090
	if [[ -f $target ]]; then
		id=$(. "$target" && echo "$ID")
	fi

	echo "$id"
}

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

self.root() {
	local subject=${1?${FUNCNAME[0]}: missing argument}; shift

	# shellcheck disable=2155
	[[ -n ${self_dir_:-} ]] || declare -g self_dir_=$(readlink -m "${BASH_SOURCE[0]%/*}"/..)

	echo "${self_dir_}/opt/$subject${*+/$*}"
}

self.source() {
	echo "$(<"${BASH_SOURCE[0]}")"

	[[ $# -eq 0 ]] || { echo; echo "$*"; }
}

is.wsl() {
	local osrelease
	read -r osrelease </proc/sys/kernel/osrelease

	[[ ${osrelease,,} == *microsoft ]]
}
