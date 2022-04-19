def _helm_tool_impl(ctx):
    os_build_name = "linux-amd64"
    if ctx.os.name.startswith("mac"):
        os_build_name = "darwin-amd64"
    ctx.download_and_extract(
        "https://get.helm.sh/helm-%s-%s.tar.gz" % (ctx.attr.version, os_build_name),
        stripPrefix = os_build_name,
    )
    ctx.execute(["./helm", "plugin", "install", "https://github.com/chartmuseum/helm-push"])
    ctx.file("BUILD", 'exports_files(["helm"])')

helm_tool = repository_rule(
    implementation = _helm_tool_impl,
    attrs = {
        "version": attr.string(default = "v3.8.1"),
    },
)

def _helm_template_test_impl(ctx):
    script = "{} template {}".format(ctx.executable._helm_binary.path, ctx.file.chart.short_path)

    ctx.actions.write(
        output = ctx.outputs.executable,
        content = script,
        is_executable = True,
    )

    runfiles = ctx.runfiles(files = [ctx.file.chart, ctx.executable._helm_binary])
    return [DefaultInfo(runfiles = runfiles)]

helm_template_test = rule(
    implementation = _helm_template_test_impl,
    test = True,
    attrs = {
        "chart": attr.label(allow_single_file = True),
        "_helm_binary": attr.label(
            executable = True,
            cfg = "exec",
            allow_files = True,
            default = Label("@helm_binary//:helm"),
            doc = "The Helm binary downloaded with a repository rule.",
        ),
    },
)

def _helm_push_impl(ctx):
    repository_url = ctx.expand_make_variables("repository_url", ctx.attr.repository_url, {})
    repository_name = ctx.expand_make_variables("repository_name", ctx.attr.repository_name, {})
    auth = ctx.expand_make_variables("auth", ctx.attr.auth, {})
    version = ctx.expand_make_variables("version", ctx.attr.version, {})

    if auth == "none" or auth == "basic":
        ctx.actions.expand_template(
            template = ctx.file._push_script_template,
            output = ctx.outputs.executable,
            substitutions = {
                "{helm_binary}": ctx.executable._helm_binary.path,
                "{package}": ctx.file.chart.short_path,
                "{repository_url}": repository_url,
                "{repository_name}": repository_name,
                "{auth}": auth,
                "{version}": version,
                "{version_file}": ctx.file.version_file.path,
            },
            is_executable = True,
        )
    else:
        fail("Authentication for the Helm repository not supported.")

    runfiles = ctx.runfiles(files = [ctx.file.chart, ctx.executable._helm_binary, ctx.file.version_file])
    return [DefaultInfo(runfiles = runfiles)]

helm_push = rule(
    implementation = _helm_push_impl,
    executable = True,
    attrs = {
        "chart": attr.label(
            allow_single_file = True,
            doc = "A tgz package with the Helm chart directory.",
        ),
        "version": attr.string(
            doc = "Version of the Helm chart.",
        ),
        "repository_url": attr.string(
            mandatory = True,
            doc = "The repository to which the Helm chart is pushed.",
        ),
        "repository_name": attr.string(
            default = "bazel",
            doc = "The name of the temporary repository added by Bazel.",
        ),
        "auth": attr.string(
            default = "none",
            doc = "The type of auth for the Helm repository (currently none and basic)."
        ),
        "version_file": attr.label(
            allow_single_file = True,
            doc = "An alternative file containing the version.",
        ),
        "_helm_binary": attr.label(
            executable = True,
            cfg = "exec",
            allow_files = True,
            default = Label("@helm_binary//:helm"),
            doc = "The Helm binary downloaded with a repository rule.",
        ),
        "_push_script_template": attr.label(
            allow_single_file = True,
            default = "@com_github_airyhq_bazel_tools//helm:push.sh",
            doc = "A bash script for pushing the Helm packages to a repo."
        ),
    },
)
