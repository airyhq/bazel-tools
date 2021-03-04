load("@build_bazel_rules_nodejs//:index.bzl", "nodejs_binary", "nodejs_test")

def fix_prettier(
        name = "fix_prettier",
        **kwargs):
    _prettier_impl(
        name = name,
        rule = nodejs_binary,
        args = [
            "--node_options=--require=$$(rlocation $(rootpath chdir.js))",
            "'**/*.{css,scss,ts,tsx,js}'",
            "--write",
        ],
        **kwargs
    )

def prettier(
        name = "prettier",
        srcs = None,
        **kwargs):
    srcs = srcs if srcs else native.glob(["**/*.js", "**/*.jsx", "**/*.ts", "**/*.tsx", "**/*.scss", "**/*.css"])
    _prettier_impl(
        name = name,
        rule = nodejs_test,
        args = [
            "--check",
        ],
        srcs = srcs,
        **kwargs
    )


    nodejs_test(
        name = name,
        data = [
            config,
            ignore,
            "@npm//prettier",
        ] + srcs,
        entry_point = "@npm//:node_modules/prettier/bin-prettier.js",
        templated_args = [
            "--check",
            "--config $(rootpath " + config + ")",
            "--ignore-path $(rootpath " + ignore + ")",
        ] + [
            "$(rootpath " + src + ")"
            for src in srcs
        ],
        tags = ["lint"],
    )

def _prettier_impl(
        name,
        rule,
        args,
        srcs,
        **kwargs):
    config = kwargs.pop("config", "@com_github_airyhq_bazel_tools//lint:.prettierrc.json")
    ignore = kwargs.pop("ignore", "@com_github_airyhq_bazel_tools//lint:.prettierignore")

    rule(
        name = name,
        data = [
            "chdir.js",
            config,
            ignore,
            "@npm//prettier",
        ] + srcs,
        entry_point = "@npm//:node_modules/prettier/bin-prettier.js",
        templated_args = [
            "--config $(rootpath " + config + ")",
            "--ignore-path $(rootpath " + ignore + ")",
        ] + args + [
            "$(rootpath " + src + ")"
            for src in srcs
        ],
        tags = ["lint"],
    )

# Add code style checking to all web files in package if not already defined
def check_pkg(name = "prettier"):
    existing_rules = native.existing_rules().keys()
    if name not in existing_rules:
        prettier()
