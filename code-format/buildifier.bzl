load("@com_github_bazelbuild_buildtools//buildifier:def.bzl", "buildifier_test")
load("//code-format:constants.bzl", "STARLARK_FILE_GLOB")

# buildifier_test implementation reference https://github.com/bazelbuild/buildtools/pull/929
def check_pkg():
    existing_rules = native.existing_rules().keys()

    if "starlark_files" not in existing_rules:
        native.filegroup(
            name = "starlark_files",
            srcs = native.glob(STARLARK_FILE_GLOB),
        )

    if "buildifier" not in existing_rules:
        buildifier_test(
            name = "buildifier",
            size = "small",
            timeout = "short",
            srcs = [":starlark_files"],
            mode = "check",
        )
