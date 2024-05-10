.ONESHELL:

include .env .env.local

DOCKER_COMPOSE := docker-compose -f deployments/$(ENVIRONMENT)/docker-compose.yml --env-file .env.local

# ==================================================
# .TARGET: amazon-dash
# ==================================================
.PHONY: amzn/init amzn/info amzn/configure amzn/discovery amzn/run

amzn/init: # initialize
	printf "
		! Long press the dash button until LED light blinks in blue
		! Connect to Wifi with SSID 'Amazon ConfigureMe'
		! Waiting for connection "
	while ! $(MAKE) info >/dev/null 2>&1; do 
		printf '.'
	done
	printf "\n! Requesting to configure Wi-Fi settings ... "
	$(MAKE) configure >/dev/null 2>&1 && echo ✔ Success || echo ✘ Failure
amzn/info: # view about device
	curl -m 1 -fsSL --dump-header - 'http://$(DEFAULT_IP_ADDRESS)'
amzn/configure: # set up a device's Wi-Fi network
	curl -m 1 -fsSL --dump-header - 'http://$(DEFAULT_IP_ADDRESS)?amzn_ssid=$(WIFI_SSID)&amzn_pw=$(WIFI_PASSWORD)'
amzn/discovery: # discover device on network
	$(DOCKER_COMPOSE) run -it --rm $(SERVICE) amazon-dash discovery

# ==================================================
# .TARGET: docker
# ==================================================
.PHONY: build build/% run run/% up up/% exec exec/% down down/% logs log log/%

build: build/$(SERVICE)
build/%: # build or rebuild a image
	$(DOCKER_COMPOSE) build $*

run: run/$(SERVICE)
run/%: # run a one-off command on a container
	$(DOCKER_COMPOSE) run --rm $* sh -c 'bash || sh'

exec: exec/$(SERVICE)
exec/%: # run a command in a running container
	$(DOCKER_COMPOSE) exec $* sh -c 'bash || sh'

up: # create and start containers, networks, and volumes
	$(DOCKER_COMPOSE) up -d
up/%: # create and start a container
	$(DOCKER_COMPOSE) up -d $*

down: # stop and remove containers, networks, images, and volumes
	$(DOCKER_COMPOSE) down
down/%: # stop and remove a container
	$(DOCKER_COMPOSE) rm -fsv $*

logs: # view output from containers
	$(DOCKER_COMPOSE) logs -f

log: log/$(SERVICE)
log/%: # view output from a container
	$(DOCKER_COMPOSE) logs -f $*

# ==================================================
# .TARGET: other
# ==================================================
.PHONY: help clean

help: # list available targets and some
	@len=$$(awk -F':' 'BEGIN {m = 0;} /^[^\s]+:/ {gsub(/%/, "<service>", $$1); l = length($$1); if(l > m) m = l;} END {print m;}' $(MAKEFILE_LIST)) && \
	printf \
		"%s%s\n\n%s\n%s\n\n%s\n%s\n" \
		"usage:" \
		"$$(printf " make <\033[1mtarget\033[0m>")" \
		"services:" \
		"$$($(DOCKER_COMPOSE) config --services | awk '{ $$1 == "$(SERVICE)" ? x = "*" : x = " "; } { printf("  \033[1m[%s] %s\033[0m\n", x, $$1); }')" \
		"targets:" \
		"$$(awk -F':' '
			function ltrim(s) { sub(/^[ \t\r\n]+/, "", s); return s; } function rtrim(s) { sub(/[ \t\r\n]+$$/, "", s); return s; } function trim(s)  { return rtrim(ltrim(s)); }
			$$1 ~ /^#+[ \t]+\.TARGET$$/ { target = trim($$2); printf("  \033[2;37m%s:\033[m\n", target); } /^[^ \t]+:/ {gsub(/%/, target == "docker" ? "[service]" : "**", $$1); gsub(/^[^#]+/, "", $$2); gsub(/^[# \t]+/, "", $$2); if ($$2) printf "    \033[1m%-'$$len's\033[0m  %s\n", $$1, $$2;}' $(MAKEFILE_LIST)
		)"

clean: # remove cache files from the working directory

