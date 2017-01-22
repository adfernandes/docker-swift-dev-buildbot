#!/bin/bash

TIMESTAMP=`date +"%Y%m%d-%H%M%S"`

# Support using build.sh from external /src volume
if [ "$0" == "/root/build.sh" -a -x /src/build.sh ]; then                
   # If a build.sh script is present in the /src area, use that instead of the script in the
   # container         
   exec /src/build.sh  
fi

if [ ! -r /src/swift/utils/update-checkout ]; then
    cd /src
    git clone https://github.com/apple/swift.git
    ./swift/utils/update-checkout --clone
fi

exec /src/swift/utils/build-script \
  --preset=buildbot_linux_1604 \
  install_destdir=/install \
  installable_package=/output/swift-${TIMESTAMP}-ubuntu16.04.tar.gz \
  2>&1 | tee /output/build-${TIMESTAMP}.log
