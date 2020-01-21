#!/bin/sh
ls -l /tmp/wheelhouse

ls -l /var/cache/pip-alpine

if ( ! swift --version 2> /dev/null | grep -q python-swiftclient ); then
    echo Swift client not found. Installing.
    pip install python-swiftclient python-keystoneclient
fi

DNS_NAME=http://pypi.abzt.de/
CONTAINER_NAME=pypi
BASE_DIR=alpine-3.10
wheel_files=$(find /tmp/wheelhouse|grep whl$)
for filepath in $wheel_files; do
    filename=$(basename "$filepath")
    server_path="${BASE_DIR}/${filename}"
    if ! curl -s -I "${DNS_NAME}${server_path}" | grep -q "HTTP/1.1 200"; then
        swift upload --object-name "${server_path}" "${CONTAINER_NAME}" "${filepath}"
        echo "${filename}" uploaded
    else
        echo Wheel "${filepath}" already on the server
    fi
done
