load("@build_bazel_rules_nodejs//:index.bzl", "nodejs_test")

def eslint(
        name,
        config,
        srcs = None,
        ignore = None):
    srcs = srcs if srcs else native.glob(["**/*.js", "**/*.jsx", "**/*.ts", "**/*.tsx"])
    ignore = ignore if ignore else "@com_github_airyhq_bazel_tools//lint:.eslintignore"

    nodejs_test(
        name = name,
        data = [
            config,
            ignore,
            "@npm//eslint",
            "@npm//eslint-plugin-react",
            "@npm//@typescript-eslint/eslint-plugin",
            "@npm//@typescript-eslint/parser",
        ] + srcs,
        entry_point = "@npm//:node_modules/eslint/bin/eslint.js",
        templated_args = [
            "--config $(rootpath " + config + ")",
            "--ignore-path $(rootpath " + ignore + ")",
        ] + [
            "$(rootpath " + src + ")"
            for src in srcs
        ],
        tags = ["lint"],
    )
