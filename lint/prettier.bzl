load("@build_bazel_rules_nodejs//:index.bzl", "nodejs_binary", "nodejs_test")

def fix_prettier(
        name = "fix_prettier",
        config = None,
        **kwargs):
    _prettier_impl(
        name = name,
        rule = nodejs_binary,
        args = [
            "--node_options=--require=$$(rlocation $(rootpath @com_github_airyhq_bazel_tools//util:chdir.js))",
            "'./**/*.{css,scss,ts,tsx,js,jsx,md}'",
            "--write",
        ],
        srcs = [],
        config = config,
        **kwargs
    )

def prettier(
        name = "prettier",
        config = None,
        srcs = None,
        **kwargs):
    srcs = srcs if srcs else native.glob(["**/*.js", "**/*.jsx", "**/*.ts", "**/*.tsx", "**/*.scss", "**/*.css", "**/*.md"])
    _prettier_impl(
        name = name,
        rule = nodejs_test,
        args = [
            "--check",
        ],
        srcs = srcs,
        config = config,
        **kwargs
    )

def _prettier_impl(
        name,
        rule,
        args,
        srcs,
        config = None,
        **kwargs):
    ignore = kwargs.pop("ignore", "@com_github_airyhq_bazel_tools//lint:.prettierignore")

    cmd_args = [
        "--ignore-path $$(rlocation $(rootpath " + ignore + "))",
    ] + args + [
        "$(rootpath " + src + ")"
        for src in srcs
    ]

    data = [
        "@com_github_airyhq_bazel_tools//util:chdir.js",
        ignore,
        "@npm//prettier",
    ]

    if config != None:
        cmd_args += ["--config $$(rlocation $(rootpath " + config + "))"] + cmd_args
        data = [config] + data

    rule(
        name = name,
        data = data + srcs,
        entry_point = {"@npm//:node_modules/prettier": "bin-prettier.js"},
        templated_args = cmd_args,
        tags = ["lint"],
    )

#
# Add code style checking to all web files in package if not already defined
def check_pkg(name = "prettier"):
    existing_rules = native.existing_rules().keys()
    if name not in existing_rules:
        prettier()
