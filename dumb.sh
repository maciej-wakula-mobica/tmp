#!/bin/bash

set -x
set -v
set -u
set -e

root="${PWD}/build"
if [[ $# -gt 0 ]] && [[ -d "${1}" ]] ; then
  root="${1}"
fi
cd "${root}"

ver="test"

export GOPATH="${root}/go"
if [[ -d "${root}/go/src" ]] ; then
  cd "${root}/go/src/github.com/WPTechInnovation/wpw-sdk-go"
  git checkout develop
  git pull
  cd "${root}/go/src/git.apache.org/thrift.git"
  git checkout 0.10.0
  git pull
else
  cd "${root}"
  mkdir -p "${root}/go/src/github.com/WPTechInnovation"
  cd "${root}/go/src/github.com/WPTechInnovation"
  git clone git@github.com:WPTechInnovation/wpw-sdk-go.git
  cd "${root}/go/src/github.com/WPTechInnovation/wpw-sdk-go"
  git checkout develop
  git submodule update --init --recursive --remote

  mkdir -p "${root}/go/src/git.apache.org/"
  cd "${root}/go/src/git.apache.org/"
  go get git.apache.org/thrift.git/lib/go/...
  cd "${root}/go/src/git.apache.org/thrift.git"
  git checkout 0.10.0
fi

if [[ -d "${root}/thrift/wpw-sdk-thrift" ]] ; then
  cd "${root}/thrift/wpw-sdk-thrift"
  git pull
else
  mkdir -p "${root}/thrift"
  cd "${root}/thrift"
  git clone git@github.com:WPTechInnovation/wpw-sdk-thrift.git
fi
cd "${root}/thrift/wpw-sdk-thrift/rpc-thrift-src"
thrift -r --gen go:package_prefix="github.com/WPTechInnovation/wpw-sdk-go/wpwithin/rpc/wpthrift/gen-go"
thrift -r --gen js:node wpwithin.thrift
thrift -r --gen py wpwithin.thrift
thrift -r --gen csharp:nullable wpwithin.thrift
thrift -r --gen java wpwithin.thrift
mkdir -p "${root}/go/src/github.com/WPTechInnovation/wpw-sdk-go/wpwithin/rpc/wpthrift"
mv "${root}/thrift/wpw-sdk-thrift/rpc-thrift-src/gen-go" "${root}/go/src/github.com/WPTechInnovation/wpw-sdk-go/wpwithin/rpc-agent/wpthrift/"

cd "${root}/go/src/github.com/WPTechInnovation/wpw-sdk-go/wpwithin/applications/rpc-agent/"
./build-all.sh -v${ver}

if [[ -d "${root}/iot-core/wpw-sdk-iot-core" ]] ; then
  cd "${root}/iot-core/wpw-sdk-iot-core"
  git pull
else
  mkdir -p "${root}/iot-core"
  cd "${root}/iot-core"
  git clone git@github.com:WPTechInnovation/wpw-sdk-iot-core.git
fi
cp "${root}/go/src/github.com/WPTechInnovation/wpw-sdk-go/wpwithin/applications/rpc-agent/build/rpc-agent-*" "${root}/iot-core/bin/"
export WPW_HOME="${root}/iot-core"
