# Airy Bazel-tools

Bazel tooling used by all Airy Bazel workspaces.

## Installation

To install, add this snippet to your `WORKSPACE`:

```python
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")
git_repository(
    name = "com_github_airyhq_bazel_tools",
    branch = "main",
    remote = "https://github.com/airyhq/bazel-tools.git"
)

load("@com_github_airyhq_bazel_tools//:repositories.bzl", "airy_bazel_tools_dependencies", "airy_jvm_deps")
airy_bazel_tools_dependencies()

# Required for Java Checkstyle
load("@rules_jvm_external//:defs.bzl", "maven_install")

maven_install(
    artifacts = YOUR_JVM_ARTIFACTS_LIST + airy_jvm_deps,
    # ...
)
```

## Code formatting

We use language specific linters:

- [Buildifier](https://github.com/bazelbuild/buildtools/tree/master/buildifier)
  to lint Bazel files
- [Prettier](https://prettier.io/) for TypeScript, JavaScript and SCSS
- [CheckStyle](https://checkstyle.sourceforge.io/) for Java

### Prettier

**Prerequisite:** `prettier` is installed using [`rules_nodejs`](https://bazelbuild.github.io/rules_nodejs/)

Checking a set of Type- or Javascript source files:

```python
load("@com_github_airyhq_bazel_tools//code-format:prettier.bzl", "prettier")

prettier(
    srcs = ["index.js"],
    config = "//:.prettierrc.json" # Defaults to code-format/.prettierrc.json
)
```

As a convenience Macro to check all `.{js,jsx,ts,tsx,scss,css}` source files:

```python
load("@com_github_airyhq_bazel_tools//code-format:prettier.bzl", "check_pkg")

check_pkg()
```

Both rules will add a `:prettier` test target to your package, which can be run like so:

```shell script
bazel test //my/package:prettier
```

To try fixing prettier issues you can run:

```shell script
bazel run @com_github_airyhq_bazel_tools//code-format:fix_prettier
```

### Checkstyle

Checking a set of Java source files:

```python
load("@com_github_airyhq_bazel_tools//code-format:checkstyle.bzl", "checkstyle")

checkstyle(
    srcs = ["src/main/java/airy/core/Main.java"],
    config = "//:checkstyle.xml" # Defaults to code-format/checkstyle.xml
)
```

As a convenience Macro to check all Java source files in a package:

```python
load("@com_github_airyhq_bazel_tools//code-format:checkstyle.bzl", "check_pkg")

check_pkg()
```

Both rules will add a `:checkstyle` test target to your package, which can be run like so:

```shell script
bazel test //my/package:checkstyle
```

### Buildifier

[Buildifier](https://github.com/bazelbuild/buildtools/tree/master/buildifier) is used for linting Bazel `BUILD` and `.bzl` files.

Because Bazel files cannot be used as source files we cannot configure them as a package level test.
So instead to lint your files, you can run:

```shell script
bazel run @com_github_airyhq_bazel_tools//code-format:check_buildifier
```

To try fixing buildifier lint issues you can run:

```shell script
bazel run @com_github_airyhq_bazel_tools//code-format:fix_buildifier
```

These two rules are a very shallow wrapper of buildifier, but we package them for convenience. If you are looking
to use its extensive API you can replace this implementation with your own.

## Web builds

For web builds we use the [rules_nodejs](https://github.com/bazelbuild/rules_nodejs) repository. You have to install the 
following npm packages with `rules_nodejs` to use the web rules:

```
yarn add -D path minimist webpack@4.43.0 webpack-dev-middleware express connect-history-api-fallback html-webpack-plugin \
copy-webpack-plugin@6.3.2 terser-webpack-plugin@5.0.3 @babel/core @babel/preset-env @bazel/ibazel @bazel/typescript@1.6.0 \
@svgr/webpack ejs-compiled-loader node-sass react-hot-loader style-loader
``` 

### `ts_library`

This is a thin wrapper around the `ts_library` provided by `rules_nodejs`. It also aggregates asset dependencies so
that they are available to downstream bundling. 

```python
load("@com_github_airyhq_bazel_tools//web:typescript.bzl", "ts_library")

ts_library(
    name = "mylib",
    srcs = ["index.ts"],
    deps = [
        "//my/web/library:ts_lib",
        "@npm//react",
        "@npm//@types/react",
    ],
    data = ["assets/logo.svg"]
)
```

**Parameters:**

- `name`    Unique name of the rule. Will also be used as the js module name so that you can import it like so
            `import {someFunction} from 'mylib'`.
- `srcs`    (optional) Your components source files. By default we glob all `.ts` and `.tsx` files.
- `deps`    (optional) Node module dependencies required to compile the library.
- `data`    (optional) Files needed as imports to your typescript files. By default we glob typical web file extensions.
- `tsconfig`    (optional) It's possible to extend tsconfigs. Give it a try, if
            it fits your use case (https://www.npmjs.com/package/@bazel/typescript#ts_config)

### `web_app`

Bundles your web resources using `webpack`. Adds an additional target `bundle_server` that you can use for 
running a webpack server with hot code reloading. For this to work you need to install [ibazel](https://github.com/bazelbuild/bazel-watcher):

```shell script
ibazel run //my/web/package:bundle_server
```

```python
load("@com_github_airyhq_bazel_tools//web:web_app.bzl", "web_app")

web_app(
    name = "bundle",
    app_lib = ":app",
    static_assets = "//my/web/package/public",
    entry = "my/web/package/src/index.js",
    index = ":index.html",
    dev_index = ":dev_index.html",
    module_deps = module_deps,
    webpack_prod_config = ":webpack.prod.config.js",
    webpack_dev_config = ":webpack.dev.config.js",
)
```

**Parameters:**

- `name`    Unique name of the build rule. The dev server rule will be called `name_server`
- `app_lib` Label of the app `ts_library`
- `static_assets`   (optional) Filegroup (list of files) that should be copied "as is" to the webroot.
                  Files need to be in a folder called 'public'.
- `entry`   Relative path to your compiled index.js
- `index`   index.html file used for the build
- `dev_index`   (optional) index.html file used for the devserver (defaults to `index`)
- `module_deps` (optional) app_lib dependencies on `ts_library` targets


### `web_library`

```python
load("@com_github_airyhq_bazel_tools//web:web_library.bzl", "web_library")

web_library(
    name = "bundle",
    app_lib = ":app",
    entry = "my/web/package/src/index.js",
    module_deps = module_deps,
    output = {
        "publicPath": "/blog/"
    }
)
```

**Parameters:**

- `name`    Unique name of the build rule.
- `app_lib` Label of the app `ts_library`
- `entry`   Relative path to your compiled index.js
- `output`  Dictionary that gets applied to the webpack output https://webpack.js.org/configuration/output/
- `externals`   (optional) Dependencies that should not be bundled, see https://webpack.js.org/guides/author-libraries/#externalize-lodash
- `module_deps` (optional) app_lib dependencies on `ts_library` targets

## Java

### `avro_java_library`

This rule takes Avro schema definition files `.avsc` and compiles them to a Jar using the [Avro tools](https://avro.apache.org/docs/current/gettingstartedjava.html) 

```python
load("@com_github_airyhq_bazel_tools//java:avro.bzl", "avro_java_library")

avro_java_library(
    name = "user", 
    srcs = ["user.avsc"]
)

# Example Usage
java_library(
    name = "mylib",
    deps = [":user"],
)
```

**Parameters:**

- `name`    Unique name of the generated java library.  
- `srcs`    Avro definition files to compile. If you leave this empty it will default to `["{name}.avsc"]`.


### `junit5`

This is an opinionated wrapper around the Bazel built-in [`java_test`](https://docs.bazel.build/versions/master/be/java.html#java_test).
It requires that the test path starts with `src/java/test` and that the test package name is the same as the file path.
I.e. a test file in package `com.package` needs to be located in `src/test/java/com/package/`.

```python
load("@com_github_airyhq_bazel_tools//java:junit5.bzl", "junit5")

junit5(
    file = "src/java/test/com/package/Test.java", 
    size = "small",
)
```

**Parameters:**

- `file`    Relative file path of the test file 

For more options see the Bazel `java_test` [rule](https://docs.bazel.build/versions/master/be/java.html#java_test) 


## How to contribute

We welcome (and love) every form of contribution! Good entry points to the
project are:

- Our [contributing guidelines](CONTRIBUTING.md)
- Issues with the tag
  [gardening](https://github.com/airyhq/bazel-tools/issues?q=is%3Aissue+is%3Aopen+label%3Agardening)
- Issues with the tag [good first
  patch](https://github.com/airyhq/bazel-tools/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+patch%22)

If you're still not sure where to start, open a [new
issue](https://github.com/airyhq/bazel-tools/issues/new) and we'll gladly help you get
started.

## Code of Conduct

To ensure a safe experience and a welcoming community, the project adheres to the [contributor
convenant](https://www.contributor-covenant.org/) [code of
conduct](/code_of_conduct.md).


## Airy Open Source

At Airy we ❤️ Open Source. Check out our other projects over at [docs.airy.co](https://docs.airy.co).
