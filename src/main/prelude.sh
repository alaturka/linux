set -Eeuo pipefail; shopt -s nullglob; unset CDPATH; IFS=$' \t\n'; [[ -z ${TRACE:-} ]] || set -x
export LC_ALL=C.UTF-8 LANG=C.UTF-8 DEBIAN_FRONTEND=noninteractive
