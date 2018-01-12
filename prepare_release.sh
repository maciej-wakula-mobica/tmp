#!/bin/bash

# colors
typeset RED='\033[0;31m'
typeset GREEN='\033[0;32m'
typeset NC='\033[0m'  # No Color

typeset -r REPO_GO="https://github.com/WPTechInnovation/wpw-sdk-go.git"
typeset -r REPO_DOTNET="https://github.com/WPTechInnovation/wpw-sdk-dotnet.git"
typeset -r REPO_NODEJS="https://github.com/WPTechInnovation/wpw-sdk-nodejs.git"
typeset -r REPO_PYTHON="https://github.com/WPTechInnovation/wpw-sdk-python.git"
typeset -r REPO_JAVA="https://github.com/WPTechInnovation/wpw-sdk-java.git"
typeset -r REPO_IOT="https://github.com/WPTechInnovation/wpw-sdk-iot-core.git"
typeset -r REPO_THRIFT="https://github.com/WPTechInnovation/wpw-sdk-thrift.git"

typeset -r REPO_GO_NAME="wpw-sdk-go"
typeset -r REPO_DOTNET_NAME="wpw-sdk-dotnet"
typeset -r REPO_NODEJS_NAME="wpw-sdk-nodejs"
typeset -r REPO_PYTHON_NAME="wpw-sdk-python"
typeset -r REPO_JAVA_NAME="wpw-sdk-java"
typeset -r REPO_IOT_NAME="wpw-sdk-iot-core"
typeset -r REPO_THRIFT_NAME="wpw-sdk-thrift"
#typeset ALL_REPOS_NAMES="${REPO_DOTNET_NAME} ${REPO_NODEJS_NAME} ${REPO_PYTHON_NAME} ${REPO_JAVA_NAME} ${REPO_IOT_NAME} ${REPO_THRIFT_NAME} ${REPO_GO_NAME}"

typeset RC_BRANCH_NAME="develop"
typeset MASTER_BRANCH_NAME="master"
typeset VERSION=""
typeset IN_REPOS_NAMES=()
typeset IN_REPOS=()
typeset PUSH=false
typeset PUSH_ONLY=false
typeset CLEAN=false

function cleanup {
    echo -e "${RED}cleanup${NC}"
    # for repo_name in ${ALL_REPOS_NAMES};
    # do
    #     if [ -d "${repo_name}" ]; then
    #         echo -e "${RED} Removing directory ${repo_name}${NC}"
    #         # Control will enter here if $DIRECTORY exists.
    #         #rm -fr "${repo_name}"
    #     fi
    # done
}

function join_by {
    local IFS="$1"; shift; echo "$*";
}


while true; do
  case "$1" in
    -v | --version ) VERSION="$2"; shift; shift ;;
    -b | --branch ) RC_BRANCH_NAME="$2"; shift; shift ;;
    -m | --master_branch ) MASTER_BRANCH_NAME="$2"; shift; shift ;;
    -p | --push ) PUSH=true; shift ;;
    -o | --push_only ) PUSH_ONLY=true; shift ;;
    -c | --clean ) CLEAN=true; shift ;;
    -r | --repos_names )
        IN_REPOS_NAMES=(${2//,/ })
        # IFS=','
        # read -ra IN_REPOS_NAMES <<< "$2"
        # #IN_REPOS_NAMES=($2)
        # unset IFS
        shift
        shift
        ;;
    -e | --repos )
        IFS=','
        IN_REPOS=($2)
        unset IFS
        shift
        shift
        ;;
    -n | --no-color )
        RED="";
        GREEN="";
        NC="";
        shift ;;
    * ) break ;;
  esac
done

if [[ -z ${VERSION} ]]; then
    echo -e "${RED}error, version name not defined${NC}"
    exit 1
fi

if [[ ${PUSH} == true && ${PUSH_ONLY} == true ]]; then
    echo -e "${RED}error, both parameters: push (-p) and push_only (-o) cannot be set${NC}"
    exit 1
fi

if [[ ${#IN_REPOS_NAMES[@]} -ne 0 ]]; then
    ALL_REPOS_NAMES=("${IN_REPOS_NAMES[@]}")
else
    ALL_REPOS_NAMES=( ${REPO_GO_NAME} ${REPO_DOTNET_NAME} ${REPO_NODEJS_NAME} ${REPO_PYTHON_NAME} ${REPO_JAVA_NAME} ${REPO_IOT_NAME} ${REPO_THRIFT_NAME} )
fi

typeset ALL_REPOS_NAMES_STRING=`join_by , "${ALL_REPOS_NAMES[@]}"`

if [[ ${#IN_REPOS[@]} -ne 0 ]]; then
    ALL_REPOS=("${IN_REPOS[@]}")
else
    ALL_REPOS=( ${REPO_GO} ${REPO_DOTNET} ${REPO_NODEJS} ${REPO_PYTHON} ${REPO_JAVA} ${REPO_IOT} ${REPO_THRIFT} )
fi

typeset ALL_REPOS_STRING=`join_by , "${ALL_REPOS[@]}"`

if [[ ${PUSH_ONLY} == false ]]; then
    # prepare_clones
    echo -e "${GREEN}*** prepare_env.sh ${NC}"
    ./prepare_env.sh -b ${RC_BRANCH_NAME} -r ${ALL_REPOS_NAMES_STRING} -e ${ALL_REPOS_STRING}
    RC=$?
    if [[ ${RC} != 0 ]]
    then
        echo -e "${RED}error, failed to prepares clones${NC}"
        cleanup
        exit 2
    fi

    # build rpc agents
    #build-all.sh
    # RC=$?
    # if [[ ${RC} != 0 ]]
    # then
    #     echo -e "${RED}error, failed to build RPC agents${NC}"
    #     cleanup
    #     exit 2
    # fi

    # update submodules
    echo -e "${GREEN}*** update_submodules.sh ${NC}"
    ./update_submodules.sh -b "${RC_BRANCH_NAME}" -r "${ALL_REPOS_NAMES_STRING}"
    RC=$?
    if [[ ${RC} != 0 ]]
    then
        echo -e "${RED}error, failed to update submodules${NC}"
        cleanup
        exit 2
    fi

    # merge release candidate to develop/master
    echo -e "${GREEN}*** merge_rc.sh ${NC}"
    ./merge_rc.sh -b "${RC_BRANCH_NAME}" -m "${MASTER_BRANCH_NAME}" -r "${ALL_REPOS_NAMES_STRING}"
    RC=$?
    if [[ ${RC} != 0 ]]
    then
        echo -e "${RED}error, failed to merge branches${NC}"
        cleanup
        exit 2
    fi

    # tag changes
    echo -e "${GREEN}*** tag_repos.sh ${NC}"
    ./tag_repos.sh -v "${VERSION}" -r "${ALL_REPOS_NAMES_STRING}"
    RC=$?
    if [[ ${RC} != 0 ]]
    then
        echo -e "${RED}error, failed to tag version${NC}"
        cleanup
        exit 2
    fi
fi

if [[ ${PUSH} == true ]]; then
    # push
    echo -e "${GREEN}*** push_repos.sh${NC}"
    ./push_repos.sh -m "${MASTER_BRANCH_NAME}" -r "${ALL_REPOS_NAMES_STRING}"
    RC=$?
    if [[ ${RC} != 0 ]]
    then
        echo -e "${RED}error, failed to push changes${NC}"
        cleanup
        exit 2
    fi
fi

exit 0
