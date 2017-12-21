#!/bin/bash

set -u
set -e
typeset version=""
typeset targets="linux,darwin,windows,amd64,386,arm,arm64"

while [[ $# -gt 0 ]] ; do
	case "${1}" in
		-v|--version)
			shift 1
			version="${1}"
			;;
		-v*)
			version="${1#-v}"
			;;
		--rebuild)
			shift 1
			targets="${1}"
			;;
		--help)
			echo "Usage: ${0} -v versionName [--rebuild linux,darwin,windows,amd64,386,arm,arm64]"
			exit 127
			;;
		*)
			echo "Invalid option ${1}" >&2
			exit 1
			;;
	esac
	shift 1
done

if [[ -z "${version}" ]] ; then
  echo "-v (build version) is required"
  exit
fi

echo Cleanup build directory
rm -rf build/
mkdir -p build/

typeset BUILD_DATE=`date -u +%d-%m-%Y@%H:%M:%S`
typeset LDFLAGS="-s -w -X main.applicationVersion=${version} -X main.applicationBuildDate=${BUILD_DATE} "

echo "version = \"${version}\", date = \"${BUILD_DATE}\""

function bld {
	typeset targets=${1}
	typeset LDFLAGS=${2}
	typeset platform=${3}
	typeset exe=${4}
	typeset os=${5}
	typeset arch=${6}
	typeset arm=${7}
	[[ ",${targets}," == *,"${os}",* ]] && [[ ",${targets}," == *,"${arch}",* ]] && [[ ",${targets},," == *,"${arm}",* ]] && {
		echo "Target OS=${os}, arch=${arch}, arm=${arm:-n/n}"
		env GOOS=${os} GOARCH=${arch} GOARM=${arm} go build -ldflags "${LDFLAGS} -X main.applicationPlatform=${platform}" -o "${exe}" main.go
	}
}

bld "${targets}" "{$LDFLAGS}" LINUX_386    build/rpc-agent-linux-386         linux   386   ""
bld "${targets}" "{$LDFLAGS}" LINUX_AMD64  build/rpc-agent-linux-amd64       linux   amd64 ""
bld "${targets}" "{$LDFLAGS}" LINUX_ARM    build/rpc-agent-linux-arm32       linux   arm   5
bld "${targets}" "{$LDFLAGS}" LINUX_ARM64  build/rpc-agent-linux-arm64       linux   arm64 5
bld "${targets}" "{$LDFLAGS}" DARWIN_386   build/rpc-agent-darwin-386        darwin  386   ""
bld "${targets}" "{$LDFLAGS}" DARWIN_AMD64 build/rpc-agent-darwin-amd64      darwin  amd64 ""
bld "${targets}" "{$LDFLAGS}" WINDOWS_386  build/rpc-agent-windows-386.exe   windows 386   ""
bld "${targets}" "{$LDFLAGS}" DARWIN_AMD64 build/rpc-agent-windows-amd64.exe windows amd64 ""

exit 0
