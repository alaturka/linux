is.wsl() {
	local osrelease
	read -r osrelease </proc/sys/kernel/osrelease

	[[ ${osrelease,,} == *microsoft ]]
}
