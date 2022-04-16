###############################################################
# PROXY Container Configuration File
###############################################################
PROXY=proxy
WEB_PORT=8181
HTTP_PORT=80
HTTPS_PORT=443
SERVICE_DIR=~/.config/systemd/user

help:
	@echo "USAGE: make TARGET [TARGET...]"
	@echo "Targets:"
	@echo -e "   help\tDisplay this help message" | expand -t 15
	@echo -e "   container\tCreate container" | expand -t 15
	@echo -e "   name\tPrint container name" | expand -t 15
	@echo -e "   port\tList ports used by container" | expand -t 15
	@echo -e "   start\tStart container" | expand -t 15
	@echo -e "   stop\tStop container" | expand -t 15
	@echo -e "   install\tInstall systemd service files for container" | expand -t 15
	@echo -e "   enable\tEnable systemd service files for container" | expand -t 15
	@echo -e "   remove\tRemove container" | expand -t 15
	@echo -e "   disable\tDisable systemd service files for container" | expand -t 15
	@echo -e "   clean\tClean up everything" | expand -t 15

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
	@printf '%s:\t%s\n' "$(PROXY)" "N/A" | expand -t 15

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

clean: stop remove disable
	-rm $(SERVICE_DIR)/$(PROXY).service

.PHONY: help conatiner name port password start stop install enable disable clean