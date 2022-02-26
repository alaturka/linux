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
