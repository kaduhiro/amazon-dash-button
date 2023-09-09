#!/bin/sh

SLACK_API_URL=https://slack.com/api/chat.postMessage
	
main() {
	[ -z "$1" -o -z "$2" ] && help

	if [ -z "$SLACK_TOKEN" ]; then
		echo "error: SLACK_TOKEN is undefined"
		return 1
	fi
	
	CHANNEL_OR_USER=$1
	MESSAGE=$2
	
	curl \
		-X POST \
		-H "Authorization: Bearer $SLACK_TOKEN" \
		-H "Content-Type: application/json" \
		--data "{
			'channel': '$CHANNEL_OR_USER',
			'text': '$MESSAGE'
		}" \
		$SLACK_API_URL
}

help() {
	cat <<- EOF
	Usage: $0 [CHANNEL or USER] [MESSAGE]
	EOF

	exit 1
}

main "$@"
exit $?
