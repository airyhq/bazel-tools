load("@com_github_bazelbuild_buildtools//buildifier:def.bzl", "buildifier_test")
load("//lint:constants.bzl", "STARLARK_FILE_GLOB")

# buildifier_test implementation reference https://github.com/bazelbuild/buildtools/pull/929
def check_pkg(name = "buildifier", exclude_patterns = ["**/node_modules/**"]):
    existing_rules = native.existing_rules().keys()

    if "starlark_files" not in existing_rules:
        native.filegroup(
            name = "starlark_files",
            srcs = native.glob(STARLARK_FILE_GLOB, exclude = exclude_patterns),
        )

    if name not in existing_rules:
        buildifier_test(
            name = name,
            size = "small",
            timeout = "short",
            srcs = [":starlark_files"],
            mode = "check",
            tags = ["lint"],
        )
