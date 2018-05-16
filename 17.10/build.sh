#!/bin/bash

TIMESTAMP=`date +"%Y%m%d-%H%M%S"`
GIT_TAG='swift-4.1.1-RELEASE'

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
    ./swift/utils/update-checkout --tag "${GIT_TAG}"
fi

# The following is ONLY needed on Artful (17.10) because the version of
# swig (3.0.10) in that distro is incompatible with Swift's LLDB build
#
# BEGIN ARTFUL HACK
pushd /tmp
    apt update
    apt purge -y swig swig3.0
    apt install -y curl build-essential libpcre3-dev python-dev python3-dev
    curl -L 'http://prdownloads.sourceforge.net/swig/swig-3.0.12.tar.gz' > "swig.tgz"
    tar xf "swig.tgz"
    pushd "swig-"*
        ./configure
        make
        make install
    popd
    rm -r "swig.tgz" "swig-"*
popd
# END ARTFUL HACK

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
