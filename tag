#!/bin/bash
# Update sources
# Update .thrift
# Gen thrift sources
# Create a "RC-" branch
# Gen RPC-agents
# Add RPC-agents
# Commit

# Fetch * sources
# Add repo mirrors to iot-core
# Update
# Gen "RC-" branches
# Copy gen-*
# Commit
# Build samples
# Run tests
# Add build log somewhere

# git push all

# Checks, paths and variables {{{
set -u
set -v
set -x
set -e

typeset root=~/src/tag/
typeset do='go,js,py,java,dotnet,linux,windows,arm,i386,amd64'
typeset version='MAWK-dev-test'
typeset BCAST_INTERVAL_MS=1000
typeset SRC_BRANCH='develop'
typeset IOT_BRANCH='master'
typeset SRC_BRANCH_GO=''
typeset SRC_BRANCH_PY=''
typeset SRC_BRANCH_JS=''
typeset SRC_BRANCH_JAVA=''
typeset SRC_BRANCH_CS=''
typeset SRC_BRANCH_IOTCORE=''

if [[ $# -gt 1 ]] ; then
	do="${2}"
fi

if [[ -d "${root}/cs" ]] \
&& [[ -d "${root}/go" ]] \
&& [[ -d "${root}/java" ]] \
&& [[ -d "${root}/js" ]] \
&& [[ -d "${root}/py" ]] \
&& [[ -d "${root}/wpw-sdk-iot-core" ]]
then
	echo "Paths ok..."
else
	echo "${root} is missing one of the sub-projects"
fi
export CSPATH="${root}/cs/wpw-sdk-dotnet"
export GOPATH="${root}/go"
export JAVAPATH="${root}/java/wpw-sdk-java"
export JSPATH="${root}/js/wpw-sdk-nodejs"
export PYPATH="${root}/py/wpw-sdk-python"
export THRIFTPATH="${GOPATH}/src/github.com/WPTechInnovation/wpw-sdk-go/wpw-sdk-thrift/rpc-thrift-src"
export IOTCOREPATH="${root}/wpw-sdk-iot-core"

WPW_HOME="${IOTCOREPATH}"
echo "WPW_HOME=${WPW_HOME}"
ls -l "${WPW_HOME}/bin"
# }}}

# Update repos, checkout branch {{{
cd "${CSPATH}"
git reset --hard
git checkout "${SRC_BRANCH_CS:-${SRC_BRANCH}}"
cd "${GOPATH}"
git reset --hard
git checkout "${SRC_BRANCH_GO:-${SRC_BRANCH}}"
cd "${JSPATH}"
git reset --hard
git checkout "${SRC_BRANCH_JS:-${SRC_BRANCH}}"
cd "${JAVAPATH}"
git reset --hard
git checkout "${SRC_BRANCH_JAVA:-${SRC_BRANCH}}"
cd "${PYPATH}"
git reset --hard
git checkout "${SRC_BRANCH_PY:-${SRC_BRANCH}}"
cd "${IOTCOREPATH}"
git reset --hard
git checkout "${SRC_BRANCH_IOTCORE:-${IOT_BRANCH:-${SRC_BRANCH} } }"
# }}}

# THRIFT {{{

cd "${THRIFTPATH}"
[[ true                    ]] && {
	rm -rf                         "${GOPATH}/src/github.com/WPTechInnovation/wpw-sdk-go/wpwithin/rpc/wpthrift/gen-go"
	thrift -r --gen go:package_prefix="github.com/WPTechInnovation/wpw-sdk-go/wpwithin/rpc/wpthrift/gen-go/" \
		-o "${GOPATH}/src/github.com/WPTechInnovation/wpw-sdk-go/wpwithin/rpc/wpthrift/" \
		wpwithin.thrift 
}
[[ ",${do}," == *,js,*     ]] && {
	thrift -r --gen js:node \
		wpwithin.thrift
}
[[ ",${do}," == *,py,*     ]] && {
	thrift -r --gen py \
		wpwithin.thrift
}
[[ ",${do}," == *,dotnet,* ]] && {
	thrift -r --gen csharp:nullable \
		wpwithin.thrift
}
[[ ",${do}," == *,java,*   ]] && {
	thrift -r --gen java \
		wpwithin.thrift
}
# }}}

# RPC {{{
typeset BUILD_COMMON_LDD_OPTS="-X main.applicationVersion=$version -X main.applicationBuildDate=`date -u +%d-%m-%Y@%H:%M:%S` -X github.com/WPTechInnovation/wpw-sdk-go/wpwithin/core/factory.BroadcastStepSleep=${BCAST_INTERVAL_MS}"
cd "${GOPATH}/src/github.com/WPTechInnovation/wpw-sdk-go/applications/rpc-agent"

typeset RPC_BIN_PREFIX="${WPW_HOME}/bin/"
rm -f "${RPC_BIN_PREFIX}rpc-agent-"*
#./build-all.sh -v test
if [[ ",${do}," == *,linux,* ]] && [[ ",${do}," == *,amd64,* ]] ; then #{{{
	env GOOS=linux GOARCH=amd64 \
		go build \
		-ldflags "${BUILD_COMMON_LDD_OPTS} -X main.applicationPlatform=LINUX_AMD64" \
		-o "${RPC_BIN_PREFIX}rpc-agent-linux-386" \
		main.go
fi # }}}
if [[ ",${do}," == *,linux,* ]] && [[ ",${do}," == *,i386,* ]] ; then # {{{
	env GOOS=linux GOARCH=386 \
		go build \
		-ldflags "${BUILD_COMMON_LDD_OPTS} -X main.applicationPlatform=LINUX_386" \
		-o "${RPC_BIN_PREFIX}rpc-agent-linux-amd64" \
		main.go
fi # }}}
if [[ ",${do}," == *,linux,* ]] && [[ ",${do}," == *,arm,* ]] ; then # {{{
	env GOOS=linux GOARCH=arm GOARM=5 \
		go build \
		-ldflags "${BUILD_COMMON_LDD_OPTS} -X main.applicationPlatform=LINUX_ARM" \
		-o "${RPC_BIN_PREFIX}rpc-agent-linux-arm32" \
		main.go
	env GOOS=linux GOARCH=arm64 GOARM=5 \
		go build \
		-ldflags "${BUILD_COMMON_LDD_OPTS} -X main.applicationPlatform=LINUX_ARM64" \
		-o "${RPC_BIN_PREFIX}rpc-agent-linux-arm64" \
		main.go
fi # }}}
if [[ ",${do}," == *,windows,* ]] && [[ ",${do}," == *,i386,* ]] ; then # {{{
	env GOOS=windows GOARCH=386 \
		go build \
		-ldflags "${BUILD_COMMON_LDD_OPTS} -X main.applicationPlatform=WIN_386" \
		-o "${RPC_BIN_PREFIX}rpc-agent-windows-386" \
		main.go
fi # }}}
if [[ ",${do}," == *,windows,* ]] && [[ ",${do}," == *,amd64,* ]] ; then # {{{
	env GOOS=windows GOARCH=amd64 \
		go build \
		-ldflags "${BUILD_COMMON_LDD_OPTS} -X main.applicationPlatform=WIN_AMD64" \
		-o "${RPC_BIN_PREFIX}rpc-agent-windows-amd64" \
		main.go
fi # }}}
if [[ ",${do}," == *,darwin,* ]] && [[ ",${do}," == *,i386,* ]] ; then # {{{
	env GOOS=darwin GOARCH=386 \
		go build \
		-ldflags "${BUILD_COMMON_LDD_OPTS} -X main.applicationPlatform=DARWIN_386" \
		-o "${RPC_BIN_PREFIX}rpc-agent-darwin-386" \
		main.go
fi # }}}
if [[ ",${do}," == *,darwin,* ]] && [[ ",${do}," == *,amd64,* ]] ; then # {{{
	env GOOS=darwin GOARCH=amd64 \
		go build \
		-ldflags "${BUILD_COMMON_LDD_OPTS} -X main.applicationPlatform=DARWIN_AMD64" \
		-o "${RPC_BIN_PREFIX}rpc-agent-darwin-amd64" \
		main.go
fi # }}}
#cp build/rpc-agent-* "${WPW_HOME}/bin/"

# {{{
#env GOOS=linux GOARCH=amd64 go build -ldflags "-X main.applicationVersion=$version -X main.applicationBuildDate=`date -u +%d-%m-%Y@%H:%M:%S` -X main.applicationPlatform=LINUX_AMD64 -X github.com/WPTechInnovation/wpw-sdk-go/wpwithin/core/factory.BroadcastStepSleep=1000" -o build/rpc-agent-linux-amd64 main.go
#sed -i 's/BroadcastStepSleep = 5000/BroadcastStepSleep = 500/' "${GOPATH}/src/github.com/WPTechInnovation/wpw-sdk-go/wpwithin/core/factory.go" 
#env GOOS=linux GOARCH=amd64 go build -ldflags "-X main.applicationVersion=test -X main.applicationBuildDate=`date -u +%d-%m-%Y@%H:%M:%S` -X main.applicationPlatform=LINUX_AMD64" -o build/rpc-agent-linux-amd64 main.go
#sed -i 's/BroadcastStepSleep = 500/BroadcastStepSleep = 5000/' "${GOPATH}/src/github.com/WPTechInnovation/wpw-sdk-go/wpwithin/core/factory.go" 
#cp build/rpc-agent-linux-amd64 "${WPW_HOME}/bin/"
# }}}
# }}}
# Copy RPC to projects {{{
rm -f "${JSPATH}/library/iot-core-component/bin/rpc-agent-"*
if [[ ",${do}," == *,js,* ]] ; then
	cp build/rpc-agent-* "${JSPATH}/library/iot-core-component/bin/"
fi
#}}}
# TODO rest of langs

# gen-* {{{
# gen-CS {{{
#rm -f "${CSPATH}/"
#cp -r "${THRIFT_GENS}/gen-cs" "${CSPATH}/library/wpwithin-thrift/"
# }}}
# gen-JAVA {{{
rm -rf "${JAVAPATH}/"
if [[ ",${do}," == *,java,* ]] ; then
	mkdir -p "${JAVAPATH}/sdk/src/main/java/"
	cp -r "${THRIFT_GENS}/gen-java/com" "${JAVAPATH}/sdk/src/main/java/"
fi
# }}}
# gen-JS {{{
rm -f "${JSPATH}/library/wpwithin-thrift/*.js"
if [[ ",${do}," == *,js,* ]] ; then
	cp -r "${THRIFT_GENS}/gen-nodejs/"*.js "${JSPATH}/library/wpwithin-thrift/"
fi
# }}}
# gen-py {{{
###### Requires setuptools
## sudo apt install python-pip
## sudo apt install python-setuptools
## sudo python setup.py install
rm -rf "${PYPATH}/wpwithinpy/wpwithin/"
if [[ ",${do}," == *,py,* ]] ; then
	mkdir -p "${PYPATH}/wpwithinpy/wpwithin/"
	cp -r "${THRIFT_GENS}/gen-py/wpthrift_types/" "${PYPATH}/wpwithinpy/wpwithin/"
	cp -r "${THRIFT_GENS}/gen-py/wpthrift/"* "${PYPATH}/wpwithinpy/wpwithin/"
	#cp -r "${THRIFT_GENS}/gen-py/__init__.py" "${PYPATH}/wpwithinpy/wpwithin/"
fi
# }}}
# }}}

# Tests {{{
# }}}

# vim: fdm=marker foldmarker={{{,}}}
