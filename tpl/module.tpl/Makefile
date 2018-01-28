####################################################################
#           This file has been generated don't edit                #
####################################################################

RELEASE_VERSION=$(shell cat version)
ifeq ($(SNAPSHOT),1)
  $(info **************************** Building with SNAPSHOT MODE *********************************)
  RELEASE_VERSION=`cat version`"-SNAPSHOT"
endif

RELEASE_FILE_NAME=%module_name%
RELEASE_MODULE_NAME=%module_name%

RELEASE_FILENAME=$(RELEASE_FILE_NAME)-$(RELEASE_VERSION).tar.gz
package: clean
	@echo "**** packaging $(RELEASE_FILE_NAME) version : [$(RELEASE_VERSION)] ****"
	mkdir dist
	cp -R roles dist/
	( cd dist/roles/$(RELEASE_MODULE_NAME) && find . -type f | xargs tar cvfz ../../$(RELEASE_FILENAME) --exclude tests )

publish: unit-test package
	if [ -f version ]; then pi-build-tools publish $(RELEASE_MODULE_NAME) $(RELEASE_VERSION) $(RELEASE_FILENAME) dist; else echo "version file is required"; exit 1; fi

unit-test: clean build-docker-image run-docker-image execute-tests stop-docker-image
build-docker-image:
	cd tests-setup/docker && $(MAKE)
run-docker-image:
	cd tests-setup/docker && $(MAKE) up
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
clean-docker-image:
	cd tests-setup/docker && $(MAKE) clean-images
clean:
	cd tests && $(MAKE) clean
	cd tests-setup/docker && $(MAKE) clean
	if [ -d dist ]; then rm -rf dist ; fi

