def shellcheck(
        name = "shellcheck",
        scrs = None):
    scrs = scrs if scrs else native.glob(["**/*.sh"])

    native.sh_test(
        name = name,
        srcs = ["@com_github_airyhq_bazel_tools//lint:shellcheck.sh"],
        data = [
            "@npm//:node_modules/shellcheck/shellcheck-stable/shellcheck",
        ] + scrs,
        args = [
            "$(location @npm//:node_modules/shellcheck/shellcheck-stable/shellcheck)",
        ] + [
            script
            for script in scrs
        ],
        tags = ["lint"],
    )
