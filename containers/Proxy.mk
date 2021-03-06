##################################################################
# PROXY Container Configuration File
#
# by C-4422
# 9b6b87bf3d3f44de936e7283ce4e555402feb741a005dfdc70cbbe2f08581911
# 353b5bd8ab63aa7d4f15f462ef001d7b12f1abd6d32b9f9751ef7d9df9b3462a
#
##################################################################
SHELL:=/bin/bash
PROXY=proxy
WEB_PORT=8181
HTTP_PORT=80
HTTPS_PORT=443
SERVICE_DIR=~/.config/systemd/user

container:
	mkdir -p -- "$(SRV_LOCATION)/$(PROXY)"
	podman create --name $(PROXY) \
		--label "io.containers.autoupdate=image" \
		-p $(WEB_PORT):8181 \
		-p $(HTTP_PORT):8080 \
		-p $(HTTPS_PORT):4443 \
		-v $(SRV_LOCATION)/$(PROXY):/config:z \
		docker.io/jlesage/nginx-proxy-manager

name:
	@echo "$(PROXY)"

port:
	@echo "$(WEB_PORT)/$(HTTP_PORT)/$(HTTPS_PORT)"

password:
	@echo -e "$(PROXY):\tN/A" | expand -t 15

set-password:
	@echo "N/A"

show-password:
	@echo "N/A"

start:
	-systemctl --user start $(PROXY)
	podman start $(PROXY)

stop:
	-systemctl --user stop $(PROXY)
	-podman stop $(PROXY)

install:
	podman generate systemd --new --name $(PROXY) > $(SERVICE_DIR)/$(PROXY).service

enable:
	systemctl --user enable $(PROXY).service

disable:
	-systemctl --user disable $(PROXY).service

remove:
	-podman rm $(PROXY)

clean: stop remove disable
	-rm $(SERVICE_DIR)/$(PROXY).service

help:
	@echo "USAGE: make TARGET [TARGET...]"
	@echo "Targets:"
	@echo -e "   help\tDisplay this help message" | expand -t 20
	@echo -e "   container\tCreate container" | expand -t 20
	@echo -e "   name\tPrint container name" | expand -t 20
	@echo -e "   port\tList ports used by container" | expand -t 20
	@echo -e "   password\tList names of passwords used by container" | expand -t 20
	@echo -e "   set-password\tSet passwords for container" | expand -t 20
	@echo -e "   show-password\tShow passwords for container" | expand -t 20
	@echo -e "   start\tStart container" | expand -t 20
	@echo -e "   stop\tStop container" | expand -t 20
	@echo -e "   install\tInstall systemd service files for container" | expand -t 20
	@echo -e "   enable\tEnable systemd service files for container" | expand -t 20
	@echo -e "   remove\tRemove container" | expand -t 20
	@echo -e "   disable\tDisable systemd service files for container" | expand -t 20
	@echo -e "   clean\tClean up everything" | expand -t 20

.PHONY: help container name port password set-password show-password password start stop install enable disable clean