load("@com_github_airyhq_bazel_tools//web:typescript.bzl", "get_assets_label")
load("@npm//webpack-cli:index.bzl", webpack = "webpack_cli")

def web_library(
        name,
        app_lib,
        entry,
        output,
        aliases = {},
        externals = {},
        show_bundle_report = False,
        module_deps = [],
        **kwargs):
    ts_transpiled_sources = name + "_ts_transpiled"

    ts_srcs = [app_lib] + module_deps
    ts_srcs_assets = [get_assets_label(src) for src in ts_srcs]

    native.filegroup(
        name = ts_transpiled_sources,
        srcs = ts_srcs,
        output_group = "es5_sources",
    )

    webpack_config = "@com_github_airyhq_bazel_tools//web:webpack.library.config.js"

    ts_config = app_lib + "_tsconfig.json"

    args = [
        "build",
        "./$(GENDIR)/" + entry,
        "--config",
        "$(execpath " + webpack_config + ")",
        "--env tsconfig=$(location " + ts_config + ")",
        "--env outputDict=" + json.encode(output),
        "--env externalDict=" + json.encode(externals),
        "--env path=$(@D)",
        "--env aliases=" + json.encode(aliases),
    ]

    if show_bundle_report == True:
        args.append("--env show_bundle_report")

    webpack(
        name = name,
        output_dir = True,
        args = args,
        data = [
           ":" + ts_transpiled_sources,
           webpack_config,
           ts_config,
           "@npm//:node_modules",
       ] +
       ts_srcs_assets,
       **kwargs
    )
