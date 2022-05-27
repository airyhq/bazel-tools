workspace(
    name = "com_github_airyhq_bazel_tools",
    managed_directories = {"@npm": ["node_modules"]},
)

load("//:repositories.bzl", "airy_bazel_tools_dependencies", "airy_jvm_deps")

airy_bazel_tools_dependencies()

# Golang
load("@io_bazel_rules_go//go:deps.bzl", "go_register_toolchains", "go_rules_dependencies")

go_rules_dependencies()

go_register_toolchains(version = "1.18")

load("@com_google_protobuf//:protobuf_deps.bzl", "protobuf_deps")

protobuf_deps()

# Java
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

# Javascript
load("@build_bazel_rules_nodejs//:repositories.bzl", "build_bazel_rules_nodejs_dependencies")

build_bazel_rules_nodejs_dependencies()

load("@build_bazel_rules_nodejs//:index.bzl", "node_repositories", "yarn_install")

node_repositories()

yarn_install(
    name = "npm",
    package_json = "//:package.json",
    yarn_lock = "//:yarn.lock",
)
