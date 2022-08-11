#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

if [ -z "{version}" ]; then
    chart_version=$(head -n 1 {version_file})
else
    chart_version="{version}"
fi

dir=$(dirname {package})
chart_dir="${dir}/chart"
chart_tar="${dir}/package.tar"

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

gunzip --force -c {package} > ${chart_tar}
mkdir -p ${chart_dir}
tar -xf ${chart_tar}  -C ${chart_dir}

{helm_binary} cm-push --version ${chart_version} ${chart_dir} {repository_name} --force
{helm_binary} repo remove {repository_name}
