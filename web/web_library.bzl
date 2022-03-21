load("@com_github_airyhq_bazel_tools//web:typescript.bzl", "get_assets_label")
load("@npm//webpack-cli:index.bzl", webpack = "webpack_cli")

def web_library(
        name,
        ts_deps,
        entry,
        output,
        aliases = {},
        externals = {},
        show_bundle_report = False,
        **kwargs):
    ts_transpiled_sources = name + "_ts_transpiled"

    ts_srcs_assets = [get_assets_label(src) for src in ts_deps]

    webpack_config = "@com_github_airyhq_bazel_tools//web:webpack.library.config.js"

    ts_config = "//:tsconfig.json"

    args = [
        "build",
        "./$(GENDIR)/" + entry,
        "--config",
        "$(execpath " + webpack_config + ")",
        "--env tsconfig=$(location " + ts_config + ")",
        "--env genDir=$(GENDIR)",
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
           webpack_config,
           ts_config,
           "@npm//:node_modules",
       ] + ts_deps + ts_srcs_assets,
       **kwargs
    )
