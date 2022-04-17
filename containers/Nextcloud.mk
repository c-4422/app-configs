###################################################################
# NEXTCLOUD CONFIGURATION WITH MYSQL
#
# by C-4422
# 9b6b87bf3d3f44de936e7283ce4e555402feb741a005dfdc70cbbe2f08581911
# 353b5bd8ab63aa7d4f15f462ef001d7b12f1abd6d32b9f9751ef7d9df9b3462a
#
###################################################################
SHELL:=/bin/bash
NEXTCLOUD=nextcloud
DATABASE=next_db
NEXTCLOUD_PORT=8000
SERVICE_DIR=~/.config/systemd/user
IP_ADDRESS=192.168.1.232

# Password names
NEXTCLOUD_PASS=nextcloud_admin
NEXTCLOUD_DB=next_db
NEXTCLOUD_DB_ROOT=next_db_root

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
	mkdir -p -- "$(SRV_LOCATION)/$(DATABASE)"
	podman network create nextcloud_network
	podman pod create --name nextcloud-pod \
		--network nextcloud_network \
		-p $(NEXTCLOUD_PORT):80
	podman create --name $(DATABASE) \
		--label "io.containers.autoupdate=image" \
		--pod nextcloud-pod \
		-v $(SRV_LOCATION)/$(DATABASE):/var/lib/mysql:z \
		-e MYSQL_ROOT_PASSWORD="$(shell pass $(NEXTCLOUD_DB_ROOT))" \
		-e MYSQL_PASSWORD="$(shell pass $(NEXTCLOUD_DB))" \
		-e MYSQL_DATABASE=nextcloud \
		-e MYSQL_USER=nextcloud \
		-e --character-set-server=utf8mb4 \
		-e --transaction-isolation=READ-COMMITTED \
		-e --binlog-format=ROW \
		docker.io/library/mariadb:latest
	mkdir -p -- "$(SRV_LOCATION)/$(NEXTCLOUD)"
	mkdir -p -- "$(STORAGE_LOCATION)/$(NEXTCLOUD)"
	podman create --name $(NEXTCLOUD) \
		--label "io.containers.autoupdate=image" \
		--pod nextcloud-pod \
		-v $(SRV_LOCATION)/$(NEXTCLOUD):/var/www/html:z \
		-v $(STORAGE_LOCATION)/$(NEXTCLOUD):/var/www/html/data:z \
		-e NEXTCLOUD_ADMIN_USER="ncadmin" \
		-e NEXTCLOUD_ADMIN_PASSWORD="$(shell pass $(NEXTCLOUD_PASS))" \
		-e MYSQL_HOST="$(DATABASE)" \
		-e MYSQL_DATABASE=nextcloud \
		-e MYSQL_USER=nextcloud \
		-e MYSQL_PASSWORD="$(shell pass $(NEXTCLOUD_DB))" \
		-e NEXTCLOUD_TRUSTED_DOMAINS="$(IP_ADDRESS)" \
		docker.io/library/nextcloud:stable

name:
	@echo "$(NEXTCLOUD)/$(DATABASE)"

port:
	@echo "$(NEXTCLOUD_PORT)"

password:
	@echo -e "$(NEXTCLOUD):\t$(NEXTCLOUD_PASS)" | expand -t 15
	@echo -e "$(DATABASE):\t$(NEXTCLOUD_DB_ROOT), $(NEXTCLOUD_DB)" | expand -t 15

start:
	-systemctl --user start $(DATABASE)
	podman start $(DATABASE)
	-systemctl --user start $(NEXTCLOUD)
	podman start $(NEXTCLOUD)

stop:
	-systemctl --user stop $(DATABASE)
	-podman stop $(DATABASE)
	-systemctl --user stop $(NEXTCLOUD)
	-podman stop $(NEXTCLOUD)

install:
	podman generate systemd --new --name $(DATABASE) > $(SERVICE_DIR)/$(DATABASE).service
	podman generate systemd --new --name $(NEXTCLOUD) > $(SERVICE_DIR)/$(NEXTCLOUD).service
	podman generate systemd --new --name nextcloud-pod > $(SERVICE_DIR)/nextcloud-pod.service

enable:
	systemctl --user enable $(DATABASE).service
	systemctl --user enable $(NEXTCLOUD).service
	systemctl --user enable nextcloud-pod.service

disable:
	systemctl --user disable $(DATABASE).service
	systemctl --user disable $(NEXTCLOUD).service
	systemctl --user disable nextcloud-pod.service

remove:
	-podman rm $(DATABASE)
	-podman rm $(NEXTCLOUD)
	-podman pod rm nextcloud-pod
	-podman network rm nextcloud_network

clean: stop remove disable
	-rm $(SERVICE_DIR)/nextcloud-pod.service
	-rm $(SERVICE_DIR)/$(DATABASE).service
	-rm $(SERVICE_DIR)/$(NEXTCLOUD).service

.PHONY: help conatiner name port password start stop install enable disable remove clean