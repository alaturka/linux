apt.fix() {
	apt-get install -y -q --fix-broken || true
}

apt.install() {
	apt.update && apt-get install -y --no-install-recommends "$@"
}

apt.install-() {
	apt-get update -qq && apt-get install -y --no-install-recommends "$@"
}
