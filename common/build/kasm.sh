#!/bin/bash

mkdir /src
git clone https://github.com/kasmtech/KasmVNC.git /src
cd /src
git checkout -f ${KASMVNC_COMMIT}
sed -i -e '/find_package(FLTK/s@^@#@' -e '/add_subdirectory(tests/s@^@#@' CMakeLists.txt
cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DBUILD_VIEWER:BOOL=OFF -DENABLE_GNUTLS:BOOL=OFF .
make -j4
