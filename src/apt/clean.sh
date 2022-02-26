apt.clean() {
	apt-get -y autoremove --purge || true
	apt-get -y autoclean          || true
}
