load("@build_bazel_rules_nodejs//:index.bzl", "nodejs_test")

def prettier(srcs, config = None, ignore = None):
    config = config if config else "@com_github_airyhq_bazel_tools//code-format:.prettierrc.json"
    ignore = ignore if ignore else "@com_github_airyhq_bazel_tools//code-format:.prettierignore"

    nodejs_test(
        name = "prettier",
        data = [
            config,
            ignore,
            "@npm//prettier",
        ] + srcs,
        entry_point = "@npm//:node_modules/prettier/bin-prettier.js",
        install_source_map_support = False,
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
def check_pkg():
    existing_rules = native.existing_rules().keys()
    if "prettier" not in existing_rules:
        prettier(native.glob(["**/*.js", "**/*.jsx", "**/*.ts", "**/*.tsx", "**/*.scss", "**/*.css"]))
