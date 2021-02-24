load("@build_bazel_rules_nodejs//:index.bzl", "nodejs_test")

def prettier(name, srcs, config = None, ignore = None):
    config = config if config else "@com_github_airyhq_bazel_tools//code-format:.prettierrc.json"
    ignore = ignore if ignore else "@com_github_airyhq_bazel_tools//code-format:.prettierignore"

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

# Add code style checking to all web files in package if not already defined
def check_pkg(name = "prettier"):
    existing_rules = native.existing_rules().keys()
    if name not in existing_rules:
        prettier(name = name, srcs = native.glob(["**/*.js", "**/*.jsx", "**/*.ts", "**/*.tsx", "**/*.scss", "**/*.css"]))
