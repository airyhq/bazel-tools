load("//lint:buildifier.bzl", "check_pkg")

check_pkg()

alias(
    name = "fix",
    actual = "//lint:fix_buildifier",
)

exports_files(
    ["repositories.bzl"],
    visibility = ["//visibility:public"],
)
