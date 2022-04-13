#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

if [ -z "{version}" ]; then
    chart_version=$(head -n 1 {version_file})
else
    chart_version="{version}"
fi

case {auth} in
"none")
    {helm_binary} repo add {repository_name} {repository_url} --force-update
    ;;
"basic")
    {helm_binary} repo add {repository_name} {repository_url} --force-update --username ${HELM_REPO_USERNAME} --password ${HELM_REPO_PASSWORD}
    ;;
*)
    echo "Authentication not supported"
    exit 1
    ;;
esac

{helm_binary} cm-push --version ${chart_version} {package} {repository_name} --force
{helm_binary} repo remove {repository_name}
