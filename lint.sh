#!/usr/bin/env bash
echo "Running Bazel lint"
bazel run //code-format:check_buildifier
