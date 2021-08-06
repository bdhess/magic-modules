#!/bin/bash
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
pushd $SCRIPT_DIR
TPG_ROOT=$(mktemp -d -t tpg-XXXXXX)
git clone --depth 1 https://github.com/terraform-providers/terraform-provider-google $TPG_ROOT/oldtpg
git clone --depth 1 https://github.com/terraform-providers/terraform-provider-google $TPG_ROOT/newtpg
pushd ../../
make tpgtools OUTPUT_PATH=$TPG_ROOT/newtpg VERSION=ga PRODUCT=$1 RESOURCE=$2
popd
go mod edit -replace=newtpg=$TPG_ROOT/newtpg
go mod edit -replace=oldtpg=$TPG_ROOT/oldtpg
go mod tidy

go run ./ --resource=google_$1_$2

go mod edit -droprequire=oldtpg
go mod edit -droprequire=newtpg
go mod edit -dropreplace=newtpg
go mod edit -dropreplace=oldtpg
go mod tidy
popd
