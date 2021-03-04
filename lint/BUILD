load("@com_github_bazelbuild_buildtools//buildifier:def.bzl", "buildifier")
load("//lint:buildifier.bzl", "check_pkg")
load("//lint:eslint.bzl", "eslint")

check_pkg()

eslint()

package(default_visibility = ["//visibility:public"])

exports_files([
    ".prettierignore",
    ".prettierrc.json",
    ".eslintrc",
    ".eslintignore",
    "chdir.js",
    "constants.bzl",
    "checkstyle.xml",
])

buildifier(
    name = "fix_buildifier",
    lint_mode = "fix",
    mode = "fix",
)
