def shellcheck(
        name = "shellcheck",
        scripts = None):
    scripts = scripts if scripts else native.glob(["**/*.sh"])

    native.sh_test(
        name = name,
        srcs = ["@com_github_airyhq_bazel_tools//lint:shellcheck.sh"],
        data = [
            "@npm//:node_modules/shellcheck/shellcheck-stable/shellcheck",
        ] + scripts,
        args = [
            "$(location @npm//:node_modules/shellcheck/shellcheck-stable/shellcheck)",
        ] + [
            script
            for script in scripts
        ],
        tags = ["lint"],
    )
