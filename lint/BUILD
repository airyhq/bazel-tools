load("@com_github_bazelbuild_buildtools//buildifier:def.bzl", "buildifier")
load("//lint:buildifier.bzl", "check_pkg")

package(default_visibility = ["//visibility:public"])

check_pkg()

exports_files([
    ".prettierignore",
    ".prettierrc.json",
    ".eslintrc",
    ".eslintignore",
    "constants.bzl",
    "checkstyle.xml",
    "shellcheck.sh",
])

buildifier(
    name = "fix_buildifier",
    lint_mode = "fix",
    mode = "fix",
)
