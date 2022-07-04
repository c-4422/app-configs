###################################################################
# ONLYOFFICE CONFIGURATION
#
# by C-4422
# 9b6b87bf3d3f44de936e7283ce4e555402feb741a005dfdc70cbbe2f08581911
# 353b5bd8ab63aa7d4f15f462ef001d7b12f1abd6d32b9f9751ef7d9df9b3462a
#
###################################################################
SHELL:=/bin/bash
SERVICE_DIR=~/.config/systemd/user
CONTAINER_NAME=onlyoffice
PORT=8001

# Pass names
OFFICE_SECRET=office_secret

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

container:
	podman create --name $(CONTAINER_NAME) \
		--label "io.containers.autoupdate=image" \
		-i -t -p $(PORT):80 \
		-e JWT_ENABLED=true \
		-e JWT_SECRET=$(shell pass $(OFFICE_SECRET)) \
		docker.io/onlyoffice/documentserver:latest

name:
	@echo "$(CONTAINER_NAME)"

port:
	@echo "$(PORT)"

password:
	@printf '%s:\t%s\n' "$(CONTAINER_NAME)" "$(OFFICE_SECRET)" | expand -t 15

set-password:
	@cpass set $(OFFICE_SECRET)

show-password:
	@echo "$(OFFICE_SECRET)=$(shell cpass get $(OFFICE_SECRET))"

start:
	-systemctl --user start $(CONTAINER_NAME)
	podman start $(CONTAINER_NAME)

stop:
	-systemctl --user stop $(CONTAINER_NAME)
	-podman stop $(CONTAINER_NAME)

install:
	podman generate systemd --new --name $(CONTAINER_NAME) > $(SERVICE_DIR)/$(CONTAINER_NAME).service

enable:
	systemctl --user enable $(CONTAINER_NAME).service

disable:
	-systemctl --user disable $(CONTAINER_NAME).service

remove:
	-podman rm $(CONTAINER_NAME)

clean: stop remove disable
	-rm $(SERVICE_DIR)/$(CONTAINER_NAME).service

.PHONY: help conatiner name port password start stop install enable disable remove clean