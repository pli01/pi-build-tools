####################################################
#           This file is generated don't edit      #
####################################################
default: import-requirements

RELEASE_VERSION=$(shell cat version)
ifeq ($(SNAPSHOT),1)
  $(info **************************** Building with SNAPSHOT MODE *********************************)
  RELEASE_VERSION=`cat version`"-SNAPSHOT"
endif

RELEASE_FILE_NAME=%service_name%
RELEASE_PLAYBOOK_NAME=%service_name%

RELEASE_FILENAME=$(RELEASE_FILE_NAME)-$(RELEASE_VERSION).tar.gz

package: clean import-requirements
	pi-build-tools package service $(RELEASE_FILENAME) $(RELEASE_VERSION)

publish: unit-test package
	if [ -f version ]; then pi-build-tools publish $(RELEASE_PLAYBOOK_NAME) $(RELEASE_VERSION) $(RELEASE_FILENAME) dist; else echo "version file is required"; exit 1; fi

unit-test: clean import-requirements build-docker-image run-docker-image execute-tests stop-docker-image

build-docker-image:
	cd tests-setup/docker && $(MAKE)
run-docker-image:
	cd tests-setup/docker && $(MAKE) up
clean-docker-image:
	cd tests-setup/docker && $(MAKE) clean-images
execute-tests: SHELL:=/bin/bash
execute-tests:
	cd tests && $(MAKE) ;\
	case "$$?" in \
		"0") exit 0;; \
		*) cd .. && $(MAKE) stop-docker-image ;\
		   exit 1;; \
	esac;
stop-docker-image:
	cd tests-setup/docker && $(MAKE) rm

init-ansible-config :
	if [ ! -f ansible.cfg ]; then pi-build-tools init-ansible-config `pwd`;fi
generate-requirements : clean-requirements
	pi-build-tools requirements-generator
import-requirements : init-ansible-config generate-requirements
	ansible-galaxy install -c -r requirements.yml
clean: clean-config clean-requirements clean-roles clean-test clean-dist
clean-dist:
	if [ -d dist ]; then rm -rf dist; fi
clean-config:
	if [ -f ansible.cfg ]; then rm ansible.cfg ;fi
clean-requirements:
	if [ -f requirements.yml ]; then rm requirements.yml ;fi
clean-roles:
	pi-build-tools requirements-cleaner
clean-test:
	cd tests && $(MAKE) clean
	cd tests-setup/docker && $(MAKE) clean
