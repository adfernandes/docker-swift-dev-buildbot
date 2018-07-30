#!/bin/bash

TIMESTAMP=`date +"%Y%m%d-%H%M%S"`
GIT_TAG='swift-4.1.3-RELEASE'

# Support using build.sh from external /src volume
if [ "$0" == "/root/build.sh" -a -x /src/build.sh ]; then
   # If a build.sh script is present in the /src area, use that instead of the script in the container
   exec /src/build.sh
fi

if [ ! -r /src/swift/utils/update-checkout ]; then
    cd /src
    git clone https://github.com/apple/swift.git
    ./swift/utils/update-checkout --clone
    ./swift/utils/update-checkout --tag "${GIT_TAG}"
fi

# Note: You can add the '--clean' argument to 'build-script' to force a clean rebuild
#
/src/swift/utils/build-script --assertions --no-swift-stdlib-assertions --llbuild --swiftpm --xctest \
    --build-subdir=buildbot_linux --lldb --release --foundation --libdispatch --lit-args=-v -- \
    --swift-enable-ast-verifier=0 --build-ninja --install-swift --install-lldb --install-llbuild --install-swiftpm --install-xctest \
    --install-prefix=/usr \
    '--swift-install-components=autolink-driver;compiler;clang-builtin-headers;stdlib;swift-remote-mirror;sdk-overlay;license' \
    --build-swift-static-stdlib --build-swift-static-sdk-overlay --build-swift-stdlib-unittest-extra \
    --install-destdir=/install --installable-package="/output/${GIT_TAG}-ubuntu-$(lsb_release -sr).tar.gz" \
    --install-foundation --install-libdispatch --reconfigure \
    2>&1 | tee /output/build-${TIMESTAMP}.log
