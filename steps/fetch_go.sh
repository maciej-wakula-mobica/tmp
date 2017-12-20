#!/bin/bash
WORK_DIR="${PWD}"
SRC_DIR="${1}"
GITURL="${2}"
GOPATH="${SRC_DIR}"
GOCD="${SRC_DIR}/src/github.com/WPTechInnovation/wpw-sdk-go"
GITBRANCH='develop'

mkdir -p "${GOCD}"
cd "${GOCD}"
git clone --depth=50 "${GITURL}"
git checkout "${GITBRANCH}"
git submodule update --init --recursive

cd ../../../git.apache.org/thrift.git/
git checkout 0.10.0
cd -

go get ./...
