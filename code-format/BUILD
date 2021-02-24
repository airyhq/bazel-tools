load("@com_github_bazelbuild_buildtools//buildifier:def.bzl", "buildifier")
load("@build_bazel_rules_nodejs//:index.bzl", "nodejs_binary")
load("//code-format:buildifier.bzl", "check_pkg")

check_pkg()

package(default_visibility = ["//visibility:public"])

exports_files([
    ".prettierignore",
    ".prettierrc.json",
    "constants.bzl",
    "checkstyle.xml",
])

nodejs_binary(
    name = "fix_prettier",
    data = [
        "chdir.js",
        "@npm//prettier",
    ],
    entry_point = "@npm//:node_modules/prettier/bin-prettier.js",
    templated_args = [
        # This is a little trick we need to do in order to run prettier in the workspace root
        # The check_prettier.sh executable can not be used in other executable rules
        "--node_options=--require=$$(rlocation $(rootpath chdir.js))",
        "'**/*.{css,scss,ts,tsx,js}'",
        "--write",
    ],
)

buildifier(
    name = "fix_buildifier",
    lint_mode = "fix",
    mode = "fix",
)
