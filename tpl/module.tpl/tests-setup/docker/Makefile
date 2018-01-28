name                 ?= %module_name%
tag                  ?= latest
mode                 ?= install
base_directory       ?= ../..
role_directory       ?= roles/%module_name%
playbook_directory   ?= playbooks
test_setup_directory ?= tests-setup/docker
test_archive         ?= deployment.tar.gz
test_config          ?= test-config

build_args += $(shell [ -z "${http_proxy}" ] || echo " --build-arg http_proxy=${http_proxy} ")
build_args += $(shell [ -z "${https_proxy}" ] || echo " --build-arg https_proxy=${http_proxy} ")

ansible_log="ansible-$(name).log"

build: SHELL:=/bin/bash
build: package 
	cp Dockerfile.$(mode) Dockerfile
	( set -o pipefail; docker build $(build_args)  --force-rm -t $(name):$(tag) . |& tee -a $(ansible_log) )
package: clean
	cd $(base_directory) && tar cvfz $(test_setup_directory)/$(test_archive) $(role_directory) $(playbook_directory)
	mkdir $(test_config)
	cp $(base_directory)/tests/inventory ./$(test_config)/
	cp $(base_directory)/tests/%module_name% ./$(test_config)/
	pi-build-tools init-ansible-config .
clean:
	if [ -f $(test_archive) ]; then rm $(test_archive) ;fi
	if [ -d $(test_config) ]; then rm -rf $(test_config) ;fi
	if [ -f Dockerfile ]; then rm Dockerfile ;fi
	if [ -f ansible.cfg ]; then rm ansible.cfg ;fi
	if [ -f  $(ansible_log) ]; then rm $(ansible_log)  ;fi
up: 
	docker-compose up -d
stop:
	docker-compose stop
rm: stop
	docker-compose rm -f
save:
	docker commit $(id) $(tag):$(name)
clean-images:
	docker rmi $(name) || true
