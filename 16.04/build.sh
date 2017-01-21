#!/bin/bash

TIMESTAMP=`date +"%Y%m%d-%H%M%S"`

# Support using build.sh from external /src volume
if [ -x /src/build.sh ]; then
    CMD="/src/build.sh"
else
    # original behavior
    CMD="/src/swift/utils/build-script"
fi

exec "$CMD" \
  --preset=buildbot_linux \
  install_destdir=/install \
  installable_package=/output/swift-${TIMESTAMP}-ubuntu16.04.tar.gz \
  --libdispatch -- --install-libdispatch
  2>&1 | tee /output/build-${TIMESTAMP}.log
