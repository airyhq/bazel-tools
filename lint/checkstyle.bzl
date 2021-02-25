load("@rules_java//java:defs.bzl", "java_test")

def checkstyle(name = "checkstyle", srcs = None, config = None):
    srcs = srcs if srcs else native.glob(["**/*.java"])
    config = config if config else "@com_github_airyhq_bazel_tools//lint:checkstyle.xml"

    java_test(
        name = "checkstyle",
        args = [
            "-c $(location " + config + ")",
            "./",
        ],
        size = "small",
        use_testrunner = False,
        main_class = "com.puppycrawl.tools.checkstyle.Main",
        data = [
            config,
        ] + srcs,
        runtime_deps = [
            "@maven//:com_puppycrawl_tools_checkstyle",
        ],
        tags = ["lint"],
    )
