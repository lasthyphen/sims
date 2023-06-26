#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

MAIN_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )"; cd .. && pwd )

source "$MAIN_PATH"/scripts/constants.sh

# Download coreth
echo "Building Dijets Utility Chain Binaries with version ${coreth_version} ..."
go get "github.com/lasthyphen/coreth@$coreth_version";
coreth_path="$GOPATH/pkg/mod/github.com/lasthyphen/coreth@$coreth_version"
cd "$coreth_path"
go build -ldflags "-X github.com/lasthyphen/coreth/plugin/evm.Version=$coreth_version" -o "$evm_path" "plugin/"*.go
cd "$MAIN_PATH"

# Build subnet-evm
echo "Building EVM comptabile Binaries with version ${subnetevm_version} ..."
go get "github.com/lasthyphen/subnet-evm@$subnetevm_version";
svm_path="$GOPATH/pkg/mod/github.com/lasthyphen/subnet-evm@$subnetevm_version"
cd "$svm_path"
go build -ldflags "-X github.com/lasthyphen/subnet-evm/plugin/evm.Version=$subnetevm_version" -o "$subnetevm_path" "plugin/"*.go
cd "$MAIN_PATH"

# Build timestampvm
echo "Building sample Net Engine Binaries with version ${timestampvm_version} ..."
go get "github.com/lasthyphen/timestampvm@$timestampvm_version";
tvm_path="$GOPATH/pkg/mod/github.com/lasthyphen/timestampvm@$timestampvm_version"
cd "$tvm_path"
go build -o "$timestampvm_path" "main/"*.go
cd "$MAIN_PATH"

# Building coreth + using go get can mess with the go.mod file.
go mod tidy

# Exit build successfully if the binaries are created
if [[ -f "$evm_path" && -f "$subnetevm_path" && -f "$timestampvm_path" ]]; then
        echo "Build Successful"
        exit 0
else
        echo "Build failure" >&2
        exit 1
fi
