###################################################################
# MASTER MAKEFILE
#
# by C-4422
# 9b6b87bf3d3f44de936e7283ce4e555402feb741a005dfdc70cbbe2f08581911
# 353b5bd8ab63aa7d4f15f462ef001d7b12f1abd6d32b9f9751ef7d9df9b3462a
#
# This makefile calls all makefiles within the conatiners
# folder. Store all of your application configurations
# in the containers folder and this make file will set it
# all up for you
###################################################################
IP_ADDRESS=192.168.1.232
SERVICE_DIR = ~/.config/systemd/user

SUBDIRS := $(wildcard *containers/*.mk)

all:
	@export IP_ADDRESS=$(IP_ADDRESS) && export SERVICE_DIR=$(SERVICE_DIR) \
	$(foreach file, $(SUBDIRS), make -f $(file);)

start:
	@$(foreach file, $(SUBDIRS), make -f $(file) start;)

stop:
	@$(foreach file, $(SUBDIRS), make -f $(file) stop;)

install:
	@$(foreach file, $(SUBDIRS), make -f $(file) install;)

enable:
	@$(foreach file, $(SUBDIRS), make -f $(file) enable;)

disable:
	@$(foreach file, $(SUBDIRS), make -f $(file) disable;)

clean:
	@$(foreach file, $(SUBDIRS), make -f $(file) clean;)

list:
	@printf '+-------------------+---------------------------------------+----------\n'
	@printf '|NAME               |CONTAINER MAKE COMMAND                 |PORT\n'
	@printf '+-------------------+---------------------------------------+----------\n'
	@$(foreach file, $(SUBDIRS), printf '|%s\t|make -f %s\t|%s\n' "$(shell make -f $(file) name)" \
	"$(file)" "$(shell make -f $(file) port)" | expand -t 20;)

help:
	@echo "USAGE: make TARGET [TARGET...]"
	@echo "Targets:"
	@echo -e "   help\t\t\tDisplay this help message"
	@echo -e "   all (default)\tCreate and start containers"
	@echo -e "   list\t\t\tList containers"
	@echo -e "   start\t\tStart containers"
	@echo -e "   stop\t\t\tStop containers"
	@echo -e "   install\t\tInstall systemd service files for containers"
	@echo -e "   enable\t\tEnable systemd service files for containers"
	@echo -e "   remove\t\tRemove all containers"
	@echo -e "   disable\t\tDisable systemd service files for containers"
	@echo -e "   clean\t\tClean up everything"
	@echo -e "   update\t\tTo update use the command: podman auto-update"

.PHONY: all start stop install enable disable clean list help