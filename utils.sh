isSudo() {

	if [ `id -u` -eq 0 ]; then
		return 0
	else
		return 1
	fi

}

getParam() {
	p=$(cat conf.txt | grep "$1=" | cut -d '=' -f2-)
	echo "$p"
}
