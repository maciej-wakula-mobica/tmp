#!/bin/bash

# colors
typeset RED='\033[0;31m'
typeset GREEN='\033[0;32m'
typeset NC='\033[0m'  # No Color

typeset -r REPO_GOLANG="https://github.com/WPTechInnovation/wpw-sdk-go.git"
typeset -r REPO_DOTNET="https://github.com/WPTechInnovation/wpw-sdk-dotnet.git"
typeset -r REPO_NODEJS="https://github.com/WPTechInnovation/wpw-sdk-nodejs.git"
typeset -r REPO_PYTHON="https://github.com/WPTechInnovation/wpw-sdk-python.git"
typeset -r REPO_JAVA="https://github.com/WPTechInnovation/wpw-sdk-java.git"
typeset -r REPO_IOT="https://github.com/WPTechInnovation/wpw-sdk-iot-core.git"
typeset -r REPO_THRIFT="https://github.com/WPTechInnovation/wpw-sdk-thrift.git"
typeset ALL_REPOS="${REPO_GOLANG} ${REPO_DOTNET} ${REPO_NODEJS} ${REPO_PYTHON} ${REPO_JAVA} ${REPO_IOT} ${REPO_THRIFT}"

typeset -r REPO_GOLANG_NAME="wpw-sdk-go"
typeset -r REPO_DOTNET_NAME="wpw-sdk-dotnet"
typeset -r REPO_NODEJS_NAME="wpw-sdk-nodejs"
typeset -r REPO_PYTHON_NAME="wpw-sdk-python"
typeset -r REPO_JAVA_NAME="wpw-sdk-java"
typeset -r REPO_IOT_NAME="wpw-sdk-iot-core"
typeset -r REPO_THRIFT_NAME="wpw-sdk-thrift"
typeset ALL_REPOS_NAMES="${REPO_GOLANG_NAME} ${REPO_DOTNET_NAME} ${REPO_NODEJS_NAME} ${REPO_PYTHON_NAME} ${REPO_JAVA_NAME} ${REPO_IOT_NAME} ${REPO_THRIFT_NAME}"

typeset RC_BRANCH_NAME=""
typeset VERBOSE=false

function cleanup {
    for repo_name in ${ALL_REPOS_NAMES};
    do        
        if [ -d "${repo_name}" ]; then
            echo -e "${RED} Removing directory ${repo_name}${NC}"
            # Control will enter here if $DIRECTORY exists.
            rm -fr "${repo_name}"
        fi
    done
}

while true; do
  case "$1" in
    -v | --verbose ) VERBOSE=true; shift ;;
    -b | --branch ) RC_BRANCH_NAME="$2"; shift ;;
    -n | --nocolor )
        RED="";
        GREEN="";
        NC="";
        shift ;;
    #-r | --repos )
    * ) break ;;
  esac
done

if [[ -z ${RC_BRANCH_NAME} ]]; then
    echo -e "${RED}error, branch name not defined${NC}"
    exit 1
fi

echo -e "${GREEN}Cloning all repos.${NC}"

# clone repos
for repo in ${ALL_REPOS};
do
    echo -e "${GREEN}git clone ${repo}${NC}"
    git clone ${repo}
    RC=$?
    if [[ ${RC} != 0 ]]
    then
        echo -e "${RED}error, failed to clone ${repo}${NC}"
        cleanup
        exit 2
    fi
done

echo -e "${GREEN}Changing the branch to ${RED}${RC_BRANCH_NAME}.${NC}"
# change branch
for repo_name in ${ALL_REPOS_NAMES};
do
    cd ${repo_name}
    echo -e "${GREEN}${repo_name}:${NC} git checkout ${RC_BRANCH_NAME}"
    git checkout "${RC_BRANCH_NAME}"
    RC=$?
    if [[ ${RC} != 0 ]]
    then
        echo -e "${RED}error, failed to checkout ${repo_name} to ${RC_BRANCH_NAME}${NC}"
        cd ..
        cleanup
        exit 2
    fi
    cd ..
done

exit 0
