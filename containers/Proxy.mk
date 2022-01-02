###############################################################
# PROXY Container Configuration File
###############################################################
PROXY=proxy
WEB_PORT=8181
HTTP_PORT=80
HTTPS_PORT=443

container:
	mkdir -p -- "$(SRV_LOCATION)/$(PROXY)"
	podman create --name $(PROXY) \
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
	@printf '%s:\t%s\n' "$(NEXTCLOUD)" "N/A" | expand -t 15

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