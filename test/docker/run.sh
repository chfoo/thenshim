#/bin/bash

set -e

# Uncomment below to create the image if needed:
#docker build test/docker/ --tag thenshim-test-env

docker run --name "thenshim-test" --mount "src=`pwd`,dst=/home/ubuntu/thenshim/,type=bind" --rm \
    thenshim-test-env \
    /bin/bash test/docker/main.sh

echo "OK"
