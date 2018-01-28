#!/bin/bash
#Sample test for service

#1 for fail, 0 for success
test_result=1;

echo "TESTING %SERVICE_NAME% "

echo "SETUP"
if [ ! -d test-out ]; then mkdir test-out; fi

echo "TEST"
echo "TODO tests"
test_result=0

echo "TEARDOWN"

exit $test_result;

