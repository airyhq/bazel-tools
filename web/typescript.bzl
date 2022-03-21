load("@com_github_airyhq_bazel_tools//web:files.bzl", "copy_filegroups")
load("@npm//@bazel/typescript:index.bzl", "ts_project")
load("@build_bazel_rules_nodejs//:index.bzl", "js_library")
load("@bazel_skylib//rules:write_file.bzl", "write_file")


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

def ts_web_library(name, srcs = None, deps = None, data = None, tsconfig = None, **kwargs):
    tsconfig = "//:tsconfig.json" if not tsconfig else tsconfig
    deps = [] if not deps else deps
    srcs = native.glob(["**/*.json", "**/*.ts", "**/*.tsx"]) if not srcs else srcs

    add_assets(name, data)

    ts_project(
        name = name + "_ts_project",
        srcs = srcs,
        tsconfig = tsconfig,
        deps = deps,
        source_map = True,
        validate = False,
        resolve_json_module = True,
        declaration = True,
        **kwargs,
    )

    # Create placeholder package.json to import by module name
    write_file(
        name = name + "_package.json",
        out = "package.json",
        content = ['{"name": "' + name + '","version":"0.0.0"}'],
    )

    js_library(
        name = name,
        package_name = name,
        srcs = [name + "_package.json"],
        deps = [name + "_ts_project"],
    )

def add_assets(name, data):
    default_data_glob = native.glob([
        "**/*.scss",
        "**/*.css",
        "**/*.png",
        "**/*.svg",
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


def ts_declaration_import(name, srcs = None, **kwargs):
    srcs = native.glob(["**/*.d.ts"]) if not srcs else srcs

    add_assets(name, data = [])
    js_library(
        name = name,
        srcs = srcs,
        **kwargs,
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
