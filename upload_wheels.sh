#!/bin/bash

if ( ! swift --version 2> /dev/null | grep -q python-swiftclient ); then
    echo Swift client not found. Installing.
    pip install python-swiftclient python-keystoneclient
fi

DNS_NAME=http://pypi.abzt.de/
CONTAINER_NAME=pypi
BASE_DIR=alpine-3.10
wheel_files=$(find /var/cache/pip-alpine|grep whl$)
for filepath in $wheel_files; do
    filename=$(basename "$filepath")
    # shellcheck disable=SC2001
    package_name=$(echo "$filename"|sed s/-.*//)
    server_path="$BASE_DIR/$package_name/$filename"
    if ! curl -s -I "${DNS_NAME}${server_path}" | grep -q "HTTP/1.1 200"; then
        swift upload --object-name "${server_path}" "${CONTAINER_NAME}" "${filepath}"
        echo "${filename}" uploaded
    else
        echo Wheel "${filepath}" already on the server
    fi
done
