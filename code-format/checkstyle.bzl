load("@rules_java//java:defs.bzl", "java_test")

def checkstyle(srcs, config = None):
    config = config if config else "@com_github_airyhq_bazel_tools//code-format:checkstyle.xml"

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

# Add code style checking to all java files in package if not already defined
def check_pkg():
    existing_rules = native.existing_rules().keys()
    if "checkstyle" not in existing_rules:
        checkstyle(native.glob(["**/*.java"]))
