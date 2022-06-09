###################################################################
# NEXTCLOUD CONFIGURATION WITH MYSQL
#
# by C-4422
# 9b6b87bf3d3f44de936e7283ce4e555402feb741a005dfdc70cbbe2f08581911
# 353b5bd8ab63aa7d4f15f462ef001d7b12f1abd6d32b9f9751ef7d9df9b3462a
#
###################################################################
SHELL:=/bin/bash
SERVICE_DIR=~/.config/systemd/user
NEXTCLOUD_NAME=nextcloud
DATABASE_NAME=next_db
NEXTCLOUD_PORT=8000
NEXTCLOUD_TRUSTED_DOMAINS=192.168.1.232

# Storage Locations
DATABASE_APP_LOCATION=$(SRV_LOCATION)/$(DATABASE_NAME)
NEXTCLOUD_APP_LOCATION=$(SRV_LOCATION)/$(NEXTCLOUD_NAME)
NEXTCLOUD_STORAGE_LOCATION=$(STORAGE_LOCATION)/$(NEXTCLOUD_NAME)

# Password names
NEXTCLOUD_PASS=ncadmin
NEXTCLOUD_DB=next_db
NEXTCLOUD_DB_ROOT=next_db_root

container:
	mkdir -p -- "$(DATABASE_APP_LOCATION)"
	podman network create nextcloud_network
	podman pod create --name nextcloud-pod \
		--network nextcloud_network \
		-p $(NEXTCLOUD_PORT):80
	podman create --name $(DATABASE_NAME) \
		--label "io.containers.autoupdate=image" \
		--pod nextcloud-pod \
		-v $(DATABASE_APP_LOCATION):/var/lib/mysql:z \
		-e MYSQL_ROOT_PASSWORD="$(shell cpass get $(NEXTCLOUD_DB_ROOT))" \
		-e MYSQL_PASSWORD="$(shell cpass get $(NEXTCLOUD_DB))" \
		-e MYSQL_DATABASE=nextcloud \
		-e MYSQL_USER=nextcloud \
		-e --character-set-server=utf8mb4 \
		-e --transaction-isolation=READ-COMMITTED \
		-e --binlog-format=ROW \
		docker.io/library/mariadb:latest
	mkdir -p -- "$(NEXTCLOUD_APP_LOCATION)"
	mkdir -p -- "$(NEXTCLOUD_STORAGE_LOCATION)"
	podman create --name $(NEXTCLOUD_NAME) \
		--label "io.containers.autoupdate=image" \
		--pod nextcloud-pod \
		-v $(NEXTCLOUD_APP_LOCATION):/var/www/html:z \
		-v $(NEXTCLOUD_STORAGE_LOCATION):/var/www/html/data:z \
		-e NEXTCLOUD_ADMIN_USER="ncadmin" \
		-e NEXTCLOUD_ADMIN_PASSWORD="$(shell cpass get $(NEXTCLOUD_PASS))" \
		-e MYSQL_HOST="$(DATABASE_NAME)" \
		-e MYSQL_DATABASE=nextcloud \
		-e MYSQL_USER=nextcloud \
		-e MYSQL_PASSWORD="$(shell cpass get $(NEXTCLOUD_DB))" \
		-e NEXTCLOUD_TRUSTED_DOMAINS="$(NEXTCLOUD_TRUSTED_DOMAINS)" \
		docker.io/library/nextcloud:stable

name:
	@echo "$(NEXTCLOUD_NAME)/$(DATABASE_NAME)"

port:
	@echo "$(NEXTCLOUD_PORT)"

password:
	@echo -e "$(NEXTCLOUD_NAME):\t$(NEXTCLOUD_PASS)" | expand -t 15
	@echo -e "$(DATABASE_NAME):\t$(NEXTCLOUD_DB_ROOT), $(NEXTCLOUD_DB)" | expand -t 15

set-password:
	@cpass set $(NEXTCLOUD_PASS)
	@cpass set $(NEXTCLOUD_DB)
	@cpass set $(NEXTCLOUD_DB_ROOT)

show-password:
	@echo "$(NEXTCLOUD_PASS)=$(shell cpass get $(NEXTCLOUD_PASS))"
	@echo "$(NEXTCLOUD_DB)=$(shell cpass get $(NEXTCLOUD_DB))"
	@echo "$(NEXTCLOUD_DB_ROOT)=$(shell cpass get $(NEXTCLOUD_DB_ROOT))"

start:
	-systemctl --user start $(DATABASE_NAME)
	podman start $(DATABASE_NAME)
	-systemctl --user start $(NEXTCLOUD_NAME)
	podman start $(NEXTCLOUD_NAME)

stop:
	-systemctl --user stop $(DATABASE_NAME)
	-podman stop $(DATABASE_NAME)
	-systemctl --user stop $(NEXTCLOUD_NAME)
	-podman stop $(NEXTCLOUD_NAME)

install:
	podman generate systemd --files --new --name nextcloud-pod
	mv container-$(NEXTCLOUD_NAME).service $(SERVICE_DIR)/.
	mv container-$(DATABASE_NAME).service $(SERVICE_DIR)/.
	mv pod-nextcloud-pod.service $(SERVICE_DIR)/.

enable:
	systemctl --user enable pod-nextcloud-pod.service
	systemctl --user enable container-$(DATABASE_NAME).service
	systemctl --user enable container-$(NEXTCLOUD_NAME).service

disable:
	systemctl --user disable pod-nextcloud-pod.service
	systemctl --user disable container-$(DATABASE_NAME).service
	systemctl --user disable container-$(NEXTCLOUD_NAME).service

remove:
	-podman rm $(DATABASE_NAME)
	-podman rm $(NEXTCLOUD_NAME)
	-podman pod rm nextcloud-pod
	-podman network rm nextcloud_network

clean: stop remove disable
	-rm $(SERVICE_DIR)/pod-nextcloud-pod.service
	-rm $(SERVICE_DIR)/container-$(DATABASE_NAME).service
	-rm $(SERVICE_DIR)/container-$(NEXTCLOUD_NAME).service

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
