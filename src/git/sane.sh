# shellcheck disable=2120
git.sane() {
	local dir=${1:-.}

	git -C "$dir" rev-parse --is-inside-work-tree &>/dev/null || return 1
	git -C "$dir" rev-parse --verify HEAD &>/dev/null         || return 1
}
