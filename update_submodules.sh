#!/bin/bash

# colors
typeset RED='\033[0;31m'
typeset GREEN='\033[0;32m'
typeset NC='\033[0m'  # No Color

# typeset -r REPO_GOLANG_NAME="wpw-sdk-go"
typeset -r REPO_DOTNET_NAME="wpw-sdk-dotnet"
typeset -r REPO_NODEJS_NAME="wpw-sdk-nodejs"
typeset -r REPO_PYTHON_NAME="wpw-sdk-python"
typeset -r REPO_JAVA_NAME="wpw-sdk-java"
# typeset -r REPO_IOT_NAME="wpw-sdk-iot-core"
# typeset -r REPO_THRIFT_NAME="wpw-sdk-thrift"
typeset ALL_REPOS_NAMES="${REPO_DOTNET_NAME} ${REPO_NODEJS_NAME} ${REPO_PYTHON_NAME} ${REPO_JAVA_NAME}"

typeset RC_BRANCH_NAME=""
typeset VERBOSE=false

function cleanup {
    echo -e "${RED}cleanup${NC}"
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
    -n | --no-color )
        RED="";
        GREEN="";
        NC="";
        shift ;;
    #-r | --repos )
    * ) break ;;
  esac
done

# update submodules in wrapper repos
for repo_name in ${ALL_REPOS_NAMES};
do
    cd ${repo_name}
    echo -e "${GREEN}${repo_name}:${NC} git submodule update --init --recursive"
    git submodule update --init --recursive
    RC=$?
    if [[ ${RC} != 0 ]]
    then
        echo -e "${RED}error, failed to init/update submodule for ${repo_name}${NC}"
        cd ..
        cleanup
        exit 1
    fi
    
    echo -e "${GREEN}${repo_name}:${NC} git submodule update --remote"
    git submodule update --remote
    RC=$?
    if [[ ${RC} != 0 ]]
    then
        echo -e "${RED}error, failed to update submodule for ${repo_name}${NC}"
        cd ..
        cleanup
        exit 2
    fi
    cd ..
done

echo -e "${GREEN}Add files and commit.${NC}"
# commit repos
for repo_name in ${ALL_REPOS_NAMES};
do
    cd ${repo_name}
    file_to_add=""
    case "${repo_name}" in
        ${REPO_PYTHON_NAME} )
            file_to_add="wpwithinpy/iot-core-component"
            ;;
        ${REPO_NODEJS_NAME} )
            file_to_add="library/iot-core-component"
            ;;
        *)
            file_to_add="iot-core-component"
            ;;
    esac
    
    echo -e "${GREEN}${repo_name}:${NC} git add ${file_to_add}"
    git add ${file_to_add}
    RC=$?
    if [[ ${RC} != 0 ]]
    then
        echo -e "${RED}error, failed to: git add ${repo_name}${NC}"
        cd ..
        cleanup
        exit 3
    fi

    echo -e "${GREEN}${repo_name}:${NC} git commit -m update ${file_to_add} in ${repo_name}"
    git commit -m "update ${file_to_add}"
    RC=$?
    if [[ ${RC} != 0 ]]
    then
        echo -e "${RED}error, failed to: git commit in ${repo_name}${NC}"
        cd ..
        cleanup
        exit 4
    fi

    cd ..
done

exit 0
