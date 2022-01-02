###################################################################
# NEXTCLOUD CONFIGURATION WITH MYSQL
#
# by C-4422
# 9b6b87bf3d3f44de936e7283ce4e555402feb741a005dfdc70cbbe2f08581911
# 353b5bd8ab63aa7d4f15f462ef001d7b12f1abd6d32b9f9751ef7d9df9b3462a
#
###################################################################
NEXTCLOUD=nextcloud
DATABASE=next_db
NEXTCLOUD_PORT=8000
DATABASE_PORT=3306

# Pass names
NEXTCLOUD_PASS=nextcloud_admin
NEXTCLOUD_DB=next_db
NEXTCLOUD_DB_ROOT=next_db_root

container:
	mkdir -p -- "$(SRV_LOCATION)/$(DATABASE)"
	podman create --name $(DATABASE) \
		--label "io.containers.autoupdate=image" \
		-p $(DATABASE_PORT):3306 \
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
		-p $(NEXTCLOUD_PORT):80 \
		-v $(SRV_LOCATION)/$(NEXTCLOUD):/var/www/html:z \
		-v $(STORAGE_LOCATION)/$(NEXTCLOUD):/var/www/html/data:z \
		-e NEXTCLOUD_ADMIN_USER="ncadmin" \
		-e NEXTCLOUD_ADMIN_PASSWORD="$(shell pass $(NEXTCLOUD_PASS))" \
		-e MYSQL_HOST=$(IP_ADDRESS) \
		-e MYSQL_DATABASE=nextcloud \
		-e MYSQL_USER=nextcloud \
		-e MYSQL_PASSWORD="$(shell pass $(NEXTCLOUD_DB))" \
		-e NEXTCLOUD_TRUSTED_DOMAINS="$(IP_ADDRESS)" \
		docker.io/library/nextcloud:stable

name:
	@echo "$(NEXTCLOUD)/$(DATABASE)"

port:
	@echo "$(NEXTCLOUD_PORT)/$(DATABASE_PORT)"

password:
	@printf '%s:\t%s\n' "$(NEXTCLOUD)" "$(NEXTCLOUD_PASS)" | expand -t 15
	@printf '%s:\t%s, %s\n' "$(DATABASE)" "$(NEXTCLOUD_DB_ROOT)" "$(NEXTCLOUD_DB)" | expand -t 15

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

enable:
	systemctl --user enable $(DATABASE).service
	systemctl --user enable $(NEXTCLOUD).service

disable:
	-systemctl --user disable $(DATABASE).service
	-systemctl --user disable $(NEXTCLOUD).service

clean: stop remove disable
	-rm $(SERVICE_DIR)/$(DATABASE).service
	-rm $(SERVICE_DIR)/$(NEXTCLOUD).service