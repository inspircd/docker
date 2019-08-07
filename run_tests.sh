#!/bin/bash

export INSP_VERSION

clean_up() {
    local ret_val="$?"

    # Clean up any remaining containers (e.g., due to fast-failing test)
    local inspircd_containers="$(docker ps -q -a -f "ancestor=inspircd:testing")"
    if [[ -n "${inspircd_containers}" ]]; then
        docker rm -fv ${inspircd_containers}
    fi

    # Exit with ultimate exit code
    exit "${ret_val}"
}
trap clean_up EXIT

# Make sure test-tracking file exists
touch ok_tests.txt
pad=$(printf '.%.0s' {1..100})

for test_file in tests/*.sh; do
    printf "%.35s " "${test_file} ${pad}"

    # Check if test already passed.
    grep -w -q "$(sha1sum "${test_file}")" ok_tests.txt \
        && { printf "0 ( OK )\n"; continue; } \
        || true

    # Run test, capturing all output to log variable
    test_log=$(sh "${test_file}" 2>&1)
    [[ $? -eq 0 ]] \
        && {
            echo "0 ( OK )"
            sha1sum "${test_file}" >> ok_tests.txt
        } \
        || {
            ret=$?
            echo "${ret} (FAIL)"
            # Print full output of test script
            echo "${test_log}"
            exit ${ret}
        }
done
# Remove test-tracking cache on successful tests.
rm ok_tests.txt
