ansible-log="ansible-%module_name%.log"

default: test
test: check-lint syntax-check check-idempotence check-ansible-warnings clean 
	./test-%module_name%.sh
syntax-check:
	pi-build-tools init-ansible-config ..
	cd .. && ansible-playbook playbooks/test.yml -i tests/inventory --syntax-check
	rm ../ansible.cfg
check-ansible-warnings:
	./test-ansible-warnings.sh ../tests-setup/docker $(ansible-log)
check-idempotence:
	./test-idempotence.sh %module_name%
check-lint:
	ansible-lint ../roles/%module_name%
clean:
	if [ -d test-out ]; then rm -rf test-out ; fi
	if [ -f ../ansible.cfg ]; then rm ../ansible.cfg ; fi
