#!/usr/bin/env bash
echo "Running Bazel lint"
bazel test --test_tag_filters=lint
