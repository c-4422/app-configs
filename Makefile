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
SHELL:=/bin/bash
IP_ADDRESS=192.168.1.232
SERVICE_DIR = ~/.config/systemd/user

SUBDIRS := $(wildcard *containers/*.mk)

help:
	@echo "USAGE: make TARGET [TARGET...]"
	@echo "Targets:"
	@echo -e "   help\tDisplay this help message" | expand -t 15
	@echo -e "   all\tCreate and start containers" | expand -t 15
	@echo -e "   list\tList all containers" | expand -t 15
	@echo -e "   start\tStart all containers" | expand -t 15
	@echo -e "   stop\tStop all containers" | expand -t 15
	@echo -e "   install\tInstall systemd service files for all containers" | expand -t 15
	@echo -e "   enable\tEnable systemd service files for all containers" | expand -t 15
	@echo -e "   remove\tRemove all containers" | expand -t 15
	@echo -e "   disable\tDisable systemd service files for all containers" | expand -t 15
	@echo -e "   clean\tClean up and remove all containers" | expand -t 15
	@echo -e "   update\tUpdate all containers using the update script" | expand -t 15

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

remove:
	@$(foreach file, $(SUBDIRS), make -f $(file) remove;)

clean:
	@$(foreach file, $(SUBDIRS), make -f $(file) clean;)

list:
	@printf '+-------------------+---------------------------------------+----------\n'
	@printf '|NAME               |CONTAINER MAKE COMMAND                 |PORT\n'
	@printf '+-------------------+---------------------------------------+----------\n'
	@$(foreach file, $(SUBDIRS), printf '|%s\t|make -f %s\t|%s\n' "$(shell make -f $(file) name)" \
	"$(file)" "$(shell make -f $(file) port)" | expand -t 20;)

.PHONY: all start stop install enable disable clean list help