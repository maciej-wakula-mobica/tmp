#!/bin/bash
WORK_DIR="${PWD}"
SRC_DIR="${1}"
GITURL="${2}"
GITBRANCH='master'
set -u
set -e

mkdir -p "${SRC_DIR}"
cd "${SRC_DIR}"
git clone --depth=50 "${GITURL}"
git checkout "${GITBRANCH}"
git submodule update --init --recursive
