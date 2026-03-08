#!/bin/sh
set -e

cd `dirname $0`
dir=`pwd`
prefix=$dir/linux_64.minimal

cd qt-everywhere-src-6.10.2
PATH=$dir:$PATH \
CXXFLAGS="-static-libgcc -static-libstdc++ -static -Wno-unused-command-line-argument" \
CFLAGS="-static-libgcc -static-libstdc++ -static -Wno-unused-command-line-argument" \
./configure \
    --cmake-generator Ninja \
    "--prefix=$prefix" \
    --release \
    --gc-binaries \
    --static \
    --ltcg=no \
    --submodules qtbase,qtwebsockets \
    --skip qtimageformats,qtlanguageserver,qtshadertools,qtsvg,qtdeclarative \
    --no-feature-pkg-config \
    --no-feature-concurrent \
    --no-feature-sql \
    --no-feature-testlib \
    --no-feature-printsupport \
    --no-feature-xml \
    --no-feature-qmake \
    --no-feature-backtrace \
    --no-feature-dlopen \
    --no-feature-dladdr \
    --no-feature-library \
    --no-feature-itemmodel \
    --no-feature-proxymodel \
    --no-feature-sortfilterproxymodel \
    --no-feature-identityproxymodel \
    --no-feature-concatenatetablesproxymodel \
    --no-feature-stringlistmodel \
    --no-feature-gestures \
    --no-feature-animation \
    --no-feature-system-proxies \
    --no-feature-networkproxy \
    --no-feature-networkdiskcache \
    --no-feature-topleveldomain \
    --no-feature-networklistmanager \
    --no-feature-gssapi \
    --no-feature-brotli \
    --no-feature-androiddeployqt \
    --no-feature-macdeployqt \
    --no-feature-windeployqt \
    --no-feature-socks5 \
    --no-feature-publicsuffix-qt \
    --no-feature-publicsuffix-system \
    --no-feature-qtwaylandscanner \
    --no-feature-doc_snippets \
    --no-icu \
    --no-glib \
    --no-zstd \
    --nomake=tools \
    --nomake=examples \
    --nomake=tests \
    --nomake=benchmarks\
    --nomake=manual-tests\
    --nomake=minimal-static-tests \
    --stack-protector=yes \
    --gui=no \
    --widgets=no \
    --no-dbus \
    --force-bundled-libs \
    --doubleconversion=qt \
    --pcre=qt \
    --zlib=qt \
    --no-feature-openssl \
    --no-feature-opensslv30 \
    --no-feature-ocsp \
    --ssl=no \
    --sbom=no

PATH=$dir:$PATH cmake --build .
PATH=$dir:$PATH cmake --build . --target install

rm -rf "$prefix/doc"
rm -rf "$prefix/metatypes"
rm -rf "$prefix/modules"
rm -rf "$prefix/share"
rm -f "$prefix/libexec/qt-android-runner.py"
rm -f "$prefix/libexec/qt-cmake-standalone-test"
rm -f "$prefix/libexec/qt_cyclonedx_generator.py"
rm -f "$prefix/libexec/qt-internal-configure-examples"
rm -f "$prefix/libexec/qt-internal-configure-tests"
rm -f "$prefix/libexec/qt-testrunner.py"
rm -f "$prefix/libexec/sanitizer-testrunner.py"
rm -f "$prefix/bin/qt-cmake"
rm -f "$prefix/bin/qt-cmake-create"
rm -f "$prefix/bin/qt-configure-module"
rm -f "$prefix/bin/qtpaths6"
rm -f "$prefix/libexec/ensure_pro_file.cmake"
rm -f "$prefix/libexec/qt-cmake-private"
rm -f "$prefix/libexec/qt-cmake-private-install.cmake"
rm -f "$prefix/libexec/qvkgen"
rm -f "$prefix/libexec/uic"
