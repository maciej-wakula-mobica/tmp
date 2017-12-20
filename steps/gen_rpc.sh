#!/bin/bash
WORK_DIR="${PWD}"
SRC_DIR="${WORK_DIR}/src"
IOTCORE_DIR="${WORK_DIR}/wpw-sdk-iot-core/bin"
GOPATH="${SRC_DIR}"
BUILD_DIR="${SRC_DIR}/github.com/WPTechInnovation/wpw-sdk-go/applications/rpc-agent"
THRIFT_GO_PKG_PREFIX='github.com/WPTechInnovation/wpw-sdk-go/wpwithin/rpc/wpthrift/gen-go'
VER="0.9"
set -u
set -e

git tag -a

cd "${BUILD_DIR}"
./build-all -v${VER}
cd build
mv rpc-agent-* "${IOTCORE_DIR}/"
cd "${IOTCORE_DIR}/"
git add ./rpc-agent-*
git commit -m "Auto-generated rpc-agent v${VER}"
