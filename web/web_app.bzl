load("@com_github_airyhq_bazel_tools//web:typescript.bzl", "get_assets_label")
load("@build_bazel_rules_nodejs//:index.bzl", "nodejs_binary")
load("@npm//webpack-cli:index.bzl", webpack = "webpack_cli")

def web_app(
        name,
        app_lib,
        entry,
        index,
        dev_tsconfig = None,
        output = {},
        static_assets = None,
        module_deps = [],
        aliases = {},
        dev_index = None,
        webpack_prod_config = None,
        webpack_dev_config = None,
        show_bundle_report = False,
        **kwargs
        ):
    static_assets = [static_assets] if static_assets else []
    ts_transpiled_sources = name + "_ts_transpiled"

    ts_srcs = [app_lib] + module_deps
    ts_srcs_assets = [get_assets_label(src) for src in ts_srcs]

    native.filegroup(
        name = ts_transpiled_sources,
        srcs = ts_srcs,
        output_group = "es5_sources",
    )

    webpack_prod_config = "@com_github_airyhq_bazel_tools//web:webpack.prod.config.js" if not webpack_prod_config else webpack_prod_config
    webpack_dev_config = "@com_github_airyhq_bazel_tools//web:webpack.dev.config.js" if not webpack_dev_config else webpack_dev_config

    ts_config = app_lib + "_tsconfig.json"

    build_args = [
        "build",
        "./$(GENDIR)/" + entry,
        "--config",
        "$(execpath " + webpack_prod_config + ")",
        "--env tsconfig=$(location " + ts_config + ")",
        "--env outputDict=" + json.encode(output),
        "--env index=$(location " + index + ")",
        "--env path=$(@D)",
        "--env aliases=" + json.encode(aliases),
    ]

    if show_bundle_report == True:
        build_args.append("--env show_bundle_report")

    webpack(
        name = name,
        output_dir = True,
        args = build_args,
        data = [
            ts_transpiled_sources,
            webpack_prod_config,
            index,
            ts_config,
            "@npm//:node_modules",
        ] + ts_srcs_assets + static_assets,
        **kwargs
    )

    dev_index = index if not dev_index else dev_index
    dev_tsconfig = dev_tsconfig if dev_tsconfig else "//:tsconfig.json"

    nodejs_binary(
        name = name + "_server",
        entry_point = "@com_github_airyhq_bazel_tools//web:runWebpackDevServer.js",
        templated_args = [
            "--node_options=--require=$$(rlocation $(rootpath @com_github_airyhq_bazel_tools//util:chdir.js))",
            "--entry=" + entry,
            "--config=$$(rlocation $(rootpath " + webpack_dev_config + "))",
            "--tsconfig=$$(rlocation $(rootpath " + dev_tsconfig + "))",
            "--outputDict='" + json.encode(output) + "'",
            "--aliases='" + json.encode(aliases) + "'",
            "--index=$$(rlocation $(rootpath " + dev_index + "))",
        ],
        data = [
            webpack_dev_config,
            dev_index,
            dev_tsconfig,
            "@com_github_airyhq_bazel_tools//util:chdir.js",
            "@npm//:node_modules",
        ] + static_assets,
    )
