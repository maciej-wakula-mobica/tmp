#!/bin/bash
SCRIPT_ROOT=$PWD

REPO_DIR="${SCRIPT_ROOT}/repos"
GITHUB_PREFIX='https://github.com/WPTechInnovation'

rm -rf "${REPO_DIR}/*"

${SCRIPT_ROOT}/steps/fetch_go.sh "${REPO_DIR}/go" "${GITHUB_PREFIX}/wpw-sdk-go.git"
# WARNING: hard-coded strings depend on the repo path

${SCRIPT_ROOT}/steps/fetch_thrift.sh "${REPO_DIR}/thrift" "${GITHUB_PREFIX}/wpw-sdk-thrift.git"
# TODO: fetch_java
# TODO: fetch_node
# TODO: fetch_python
# TODO: fetch_dotnet
${SCRIPT_ROOT}/steps/gen_thrift.sh
${SCRIPT_ROOT}/steps/gen_rpc.sh
# TODO: make tag in every repo
# TODO: push iot-core
# TODO: push gen
# TODO: make release
# TODO: Run all the tests
