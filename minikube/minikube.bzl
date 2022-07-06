def _minikube_tool_impl(ctx):
    os_build_name = "linux"
    if ctx.os.name.startswith("mac"):
        os_build_name = "darwin"
    ctx.download(
        "https://storage.googleapis.com/minikube/releases/latest/minikube-%s-amd64" % (os_build_name),
        output='minikube',
        executable=True,
    )
    ctx.file("BUILD", 'exports_files(["minikube"])')

minikube_tool = repository_rule(
    implementation = _minikube_tool_impl,
)

def _minikube_start_impl(ctx):
    script = "{} -p {} start --driver={} --cpus={} --memory={} --container-runtime=containerd --ports={}:{} --extra-config=apiserver.service-nodeport-range=1-65535".format(ctx.executable._minikube_binary.path, ctx.attr.profile, ctx.attr.driver, ctx.attr.cpus, ctx.attr.memory, ctx.attr.ingress_port, ctx.attr.ingress_port)

    ctx.actions.write(
        output = ctx.outputs.executable,
        content = script,
        is_executable = True,
    )

    runfiles = ctx.runfiles(files = [ctx.executable._minikube_binary])
    return [DefaultInfo(runfiles = runfiles)]

minikube_start = rule(
    implementation = _minikube_start_impl,
    executable = True,
    attrs = {
        "_minikube_binary": attr.label(
            executable = True,
            cfg = "exec",
            allow_files = True,
            default = Label("@minikube_binary//:minikube"),
            doc = "The Minikube binary downloaded with a repository rule.",
        ),
        "profile": attr.string(
            doc = "The Minikube profile.",
            default = "airy-core",
        ),
        "driver": attr.string(
            doc = "The Minikube driver.",
            default = "docker",
        ),
        "cpus": attr.string(
            doc = "CPU cores for the Kubernetes node.",
            default = "4",
        ),
        "memory": attr.string(
            doc = "Memory for the Kubernetes node.",
            default = "7168",
        ),
        "ingress_port": attr.string(
            doc = "Port for the ingress controller NodePort.",
            default = "80",
        ),
    },
)

def _minikube_stop_impl(ctx):
    script = "{} -p {} delete".format(ctx.executable._minikube_binary.path, ctx.attr.profile)

    ctx.actions.write(
        output = ctx.outputs.executable,
        content = script,
        is_executable = True,
    )

    runfiles = ctx.runfiles(files = [ctx.executable._minikube_binary])
    return [DefaultInfo(runfiles = runfiles)]

minikube_stop = rule(
    implementation = _minikube_stop_impl,
    executable = True,
    attrs = {
        "_minikube_binary": attr.label(
            executable = True,
            cfg = "exec",
            allow_files = True,
            default = Label("@minikube_binary//:minikube"),
            doc = "The Minikube binary downloaded with a repository rule.",
        ),
        "profile": attr.string(
            doc = "The Minikube profile.",
            default = "airy-core",
        ),
    },
)
