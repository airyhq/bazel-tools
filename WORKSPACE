workspace(
    name = "com_github_airyhq_bazel_tools",
    managed_directories = {"@npm": ["node_modules"]},
)

load("//:repositories.bzl", "airy_bazel_tools_dependencies", "airy_jvm_deps")

airy_bazel_tools_dependencies()


load("@rules_jvm_external//:defs.bzl", "maven_install")

maven_install(
    artifacts = airy_jvm_deps,
    maven_install_json = "//:maven_install.json",
    repositories = [
        "https://repo1.maven.org/maven2",
    ],
)

load("@maven//:defs.bzl", "pinned_maven_install")

pinned_maven_install()

load("@build_bazel_rules_nodejs//:index.bzl", "node_repositories", "yarn_install")

node_repositories()

yarn_install(
    name = "npm",
    package_json = "//:package.json",
    yarn_lock = "//:yarn.lock",
)
