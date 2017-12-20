#!/bin/bash
WORK_DIR="${PWD}"
SRC_DIR="${WORK_DIR}"
BUILD_DIR="${SRC_DIR}/wpw-sdk-thrift/rpc-thrift-src"
THRIFT_GO_PKG_PREFIX='github.com/WPTechInnovation/wpw-sdk-go/wpwithin/rpc/wpthrift/gen-go'
set -u
set -e

cd "${BUILD_DIR}"
thrift -r --gen go:package_prefix="${THRIFT_GO_PKG_PREFIX}" wpwithin.thrift
thrift -r --gen js:node wpwithin.thrift
thrift -r --gen py wpwithin.thrift
thrift -r --gen csharp:nullable wpwithin.thrift
thrift -r --gen java wpwithin.thrift

cp -r "${BUILD_DIR}/gen-go" "${SRC_GO_DIR}/"
cp -r "${BUILD_DIR}/gen-nodejs" "${SRC_NODEJS_DIR}/"
cp -r "${BUILD_DIR}/gen-py" "${SRC_PY_DIR}/"
cp -r "${BUILD_DIR}/gen-csharp" "${SRC_DOTNET_DIR}/"
cp -r "${BUILD_DIR}/gen-java" "${SRC_JAVA_DIR}/"

cd "${SRC_GO_DIR}/"
git add ./gen-go
git commit -m "Auto-generated sources for Apache thrift"

cd "${SRC_NODEJS_DIR}/"
git add ./gen-nodejs
git commit -m "Auto-generated sources for Apache thrift"

cd "${SRC_PY_DIR}/"
git add ./gen-py
git commit -m "Auto-generated sources for Apache thrift"

cd "${SRC_NODEJS_DIR}/"
git add ./gen-csharp
git commit -m "Auto-generated sources for Apache thrift"

cd "${SRC_JAVA_DIR}/"
git add ./gen-java
git commit -m "Auto-generated sources for Apache thrift"
