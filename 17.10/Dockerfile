# Test an Apple Swift build with the Linux buildbot preset using a
# using a codebase provided in a Volume.

FROM ubuntu:17.10

LABEL maintainer="https://github.com/adfernandes/docker-swift-dev-buildbot"

# Set the locale
RUN apt-get update && \
    apt-get --no-install-recommends -y install locales && \
    locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Volume mounted from host to access source code. [Required]
VOLUME ["/src"]
# Volume to store compiled package and build log. [Optional]
VOLUME ["/output"]

# Where build-script will store the build files
ENV SWIFT_BUILD_ROOT /build

COPY build.sh /root/build.sh

# Note: git config required for swiftpm/Tests/dep/FunctionalBuildTests.swift
RUN buildDeps='git cmake ninja-build uuid-dev icu-devtools libbsd-dev \
      libedit-dev libxml2-dev libsqlite3-dev swig \
      python libpython-dev python3 libpython3-dev \
      libblocksruntime-dev libcurl4-openssl-dev automake autoconf \
      libtool systemtap-sdt-dev libkqueue-dev \
      libncurses5-dev pkg-config ca-certificates rsync file'; \
      runDeps='libicu-dev clang'; \
       apt-get --no-install-recommends -y install $buildDeps $runDeps \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && git config --global user.email "nobody@example.com" \
    && git config --global user.name "Nobody" \
    && chmod +x /root/build.sh

CMD ["/root/build.sh"]
