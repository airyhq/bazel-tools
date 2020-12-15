load("@rules_java//java:defs.bzl", "java_test")

def junit5(file, size = "small", runtime_deps = [], **kwargs):
    java_test(
        # Remove src/test/java/ prefix and .java file extension
        name = file[14:-5].replace("/", "."),
        main_class = "org.junit.platform.console.ConsoleLauncher",
        use_testrunner = False,
        size = size,
        args = [
            "--select-class %s" % file[14:-5].replace("/", "."),
            "--fail-if-no-tests",
        ],
        srcs = [
            "%s" % file,
        ],
        runtime_deps = runtime_deps + [
            "@maven//:org_junit_platform_junit_platform_console",
        ],
        **kwargs
    )
