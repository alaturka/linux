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
