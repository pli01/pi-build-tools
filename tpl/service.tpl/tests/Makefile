ansible-log="ansible-%service_name%.log"

default: test syntax-check
test: check-idempotence syntax-check clean 
	./test-%service_name%.sh
syntax-check:
	pi-build-tools init-ansible-config ..
	cd .. && ansible-playbook playbooks/configure-%service_name%.yml -i tests/inventory --syntax-check
	rm ../ansible.cfg
check-idempotence:
	./test-idempotence.sh %service_name%
check-ansible-warnings:
	./test-ansible-warnings.sh ../tests-setup/docker $(ansible-log)
check-lint:
	ansible-lint ../playbooks/configure-%service_name%.yml;\
	for role in ../roles/*;\
	do \
	    ansible-lint $$role;\
	done
clean:
	if [ -d test-out ]; then rm -rf test-out ; fi
	if [ -f ../ansible.cfg ]; then rm ../ansible.cfg ; fi
