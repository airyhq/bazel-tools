load("@com_github_airyhq_bazel_tools//web:files.bzl", "copy_filegroups")
load("@npm//@bazel/typescript:index.bzl", "ts_library")

"""
Usage

ts_web_library(
    name = "mylib",
    srcs = ["index.ts"],
    deps = [
        "@npm//react",
        "@npm//@types/react",
    ],
    data = ["assets/logo.svg"]
)

parameters:

name     -  Unique name of the rule. Will also be used as the js module name so that you can import it like so
            `import {someFunction} from 'mylib'`
srcs     -  (optional) Your components source files. By default we glob all .ts and .tsx files, so for most use cases you can avoid this
deps     -  (optional) Node module dependencies required to build the library
data     -  (optional) Files needed as imports to your typescript files. By default we glob a typical web file extensions.
tsconfig -  (optional) It's possible to extend tsconfigs! Give it a try, if
            it fits your use case (https://www.npmjs.com/package/@bazel/typescript#ts_config)
"""

ASSETS_SUFFIX = "_assets"

def ts_web_library(name, srcs = None, deps = None, data = None, tsconfig = None):
    tsconfig = "//:tsconfig.json" if not tsconfig else tsconfig
    deps = [] if not deps else deps
    srcs = native.glob(["**/*.tsx", "**/*.ts"]) if not srcs else srcs

    default_data_glob = native.glob([
        "**/*.scss",
        "**/*.css",
        "**/*.json",
        "**/*.png",
        "**/*.svg",
        "**/*.json",
    ])

    data = default_data_glob if not data else data

    native.filegroup(
        name = name + "_asset_files",
        srcs = data,
    )

    copy_filegroups(
        name = name + ASSETS_SUFFIX,
        input_groups = [
            name + "_asset_files",
        ],
    )

    ts_library(
        name = name,
        module_name = name,
        srcs = srcs,
        devmode_module = "esnext",
        devmode_target = "esnext",
        prodmode_module = "esnext",
        prodmode_target = "esnext",
        tsconfig = tsconfig,
        deps = deps,
    )

# Helper function to get asset target from a ts_web_library target
def get_assets_label(lib):
    # Fully qualified name e.g. //package/lib:lib
    if ":" in lib:
        return lib + ASSETS_SUFFIX

    # Shorthand e.g. //package/lib
    folders = lib.split("/")
    last_folder = folders[-1]

    return lib + ":" + last_folder + ASSETS_SUFFIX
