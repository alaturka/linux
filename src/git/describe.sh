# shellcheck disable=2120
git.describe() {
	local dir=${1:-.}

	local description
	description=$(git -C "$dir" describe --always --long 2>/dev/null || true)

	echo "${description:-Unknown}"
}
