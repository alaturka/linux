try() {
	"$@" || warn "'$*' exit code $? is suppressed"
}
