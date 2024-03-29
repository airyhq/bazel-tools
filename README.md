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
load("@com_github_airyhq_bazel_tools//lint:prettier.bzl", "prettier")

prettier(
    name = "prettier",
    config = "//:.prettierrc.json",
    srcs = ["index.js"], # Defaults to all js,jsx,ts,tsx,scss,css files
    ignore = "//:.prettierignore", # Defaults to lint/.prettierignore
)
```

Both rules will add a `:prettier` test target to your package, which can be run like so:

```shell script
bazel test //my/package:prettier
```

To try fixing prettier issues you instantiate the `prettier_fix` rule in your root `BUILD` file:

```python
load("@com_github_airyhq_bazel_tools//lint:prettier.bzl", "fix_prettier")

fix_prettier(
    name = "fix_prettier",
    config = "//:.prettierrc.json", # Defaults to lint/.prettierrc.json
    ignore = "//:.prettierignore", # Defaults to lint/.prettierignore
)
```

Run it like so:

```shell script
bazel run //:fix_prettier
```

### Eslint

Checking a set of Type- or Javascript source files:

```python
load("@com_github_airyhq_bazel_tools//lint:eslint.bzl", "eslint")

eslint(
    name = "eslint",
    config = "//:.eslint.json",
    srcs = ["index.ts"], # Defaults to all js,jsx,ts,tsx,scss,css files in package
    ignore = "//:.eslintignore", # Defaults to lint/.eslintignore
)
```

This rule will add an `:eslint` test target to your package, which can be run like so:

```shell script
bazel test //my/package:eslint
```

### Checkstyle

Checking a set of Java source files:

```python
load("@com_github_airyhq_bazel_tools//lint:checkstyle.bzl", "checkstyle")

checkstyle(
    name = "checkstyle",
    srcs = ["src/main/java/airy/core/Main.java"], #  Defaults to all .java files in package
    config = "//:checkstyle.xml" # Defaults to lint/checkstyle.xml
)
```

Both rules will add a `:checkstyle` test target to your package, which can be run like so:

```shell script
bazel test //my/package:checkstyle
```

### Buildifier

[Buildifier](https://github.com/bazelbuild/buildtools/tree/master/buildifier) is used for linting Bazel `BUILD` and `.bzl` files.

Macro to check all starlark source files in a package:

```python
load("@com_github_airyhq_bazel_tools//lint:buildifier.bzl", "check_pkg")

check_pkg()
```

To try fixing buildifier lint issues you can run:

```shell script
bazel run @com_github_airyhq_bazel_tools//lint:fix_buildifier
```

These two rules are a very shallow wrapper of buildifier, but we package them for convenience. If you are looking
to use its extensive API you can replace this implementation with your own.

### Shellcheck

[Shellcheck](https://www.shellcheck.net/) gives warnings and suggestions for
bash/sh shell scripts.

Macro to check all scripts including subdirectories ending with `.sh`:

```python
load("@com_github_airyhq_bazel_tools//lint:shellcheck.bzl", "shellcheck")

shellcheck()
```

Alternatively you can pass a glob of shellscript files with the `scripts` parameter.

## Web builds

For web builds we use the [rules_nodejs](https://github.com/bazelbuild/rules_nodejs) repository. You have to install the 
development dependencies listed in the [`package.json`](./package.json) to use the web rules. 

### `ts_web_library`

This is a thin wrapper around the `ts_project` provided by `rules_nodejs`. It also aggregates asset dependencies so
that they are available to downstream bundling. 

```python
load("@com_github_airyhq_bazel_tools//web:typescript.bzl", "ts_web_library")

ts_web_library(
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

- `name`    Unique name of the rule. This will also be used as the js module name so that you can import it like so
            `import {someFunction} from 'mylib'`.
- `srcs`    (optional) Your components source files. By default we glob all `.ts` and `.tsx` files.
- `deps`    (optional) Node module dependencies required to compile the library.
- `data`    (optional) Files needed as imports to your typescript files. By default we glob typical web file extensions.
- `tsconfig`    (optional) It's possible to extend tsconfigs (https://www.npmjs.com/package/@bazel/typescript#ts_config)
- `lint_rule`    (optional) by default this is set to [check_pkg()](#prettier). Setting this flag to None, will
disable linting for this package.

### `web_app`

Bundles your web resources using `webpack` and adds a target `*_server` that you can use for 
running a webpack server with hot code reloading.

```shell script
bazel run //my/web/package:bundle_server
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
    dev_tsconfig = "//:tsconfig.json",
    output = {
        "publicPath": "/blog/"
    },
    module_deps = module_deps,
    webpack_prod_config = ":webpack.prod.config.js",
    webpack_dev_config = ":webpack.dev.config.js",
)
```

**Parameters:**

- `name`    Unique name of the build rule. The dev server rule will be called `name_server`
- `static_assets`   (optional) Filegroup (list of files) that should be copied "as is" to the webroot.
                  Files need to be in a folder called 'public'.
- `entry`   Relative path to your compiled index.js
- `index`   index.html file used for the build
- `dev_tsconfig`  (optional) Defaults to `tsconfig.json`, which has to include a mapping of modules to paths using `compilerOptions.paths`.
- `output`  (optional) Dictionary that gets applied to the webpack output https://webpack.js.org/configuration/output/
- `aliases` (optional) applied to webpack [alias](https://webpack.js.org/configuration/resolve/#resolvealias)
- `show_bundle_report`  If set to true generates a static bundle size report
- `dev_index`   (optional) index.html file used for the devserver (defaults to `index`)
- `module_deps` (optional) app_lib dependencies on `ts_web_library` targets


### `web_library`

```python
load("@com_github_airyhq_bazel_tools//web:web_library.bzl", "web_library")

web_library(
    name = "bundle",
    app_lib = ":app",
entry = "my/web/package/src/index.js",
    module_deps = ["//package/lib:ts_web_lib_target"],
    output = {
        "publicPath": "/blog/"
    }
)
```

**Parameters:**

- `name`    Unique name of the build rule.
- `app_lib` Label of the app `ts_web_library`
- `entry`   Relative path to your compiled index.js
- `output`  Dictionary that gets applied to the webpack output https://webpack.js.org/configuration/output/
- `aliases` (optional) applied to webpack [alias](https://webpack.js.org/configuration/resolve/#resolvealias)
- `show_bundle_report`  If set to true generates a static bundle size report
- `externals`   (optional) Dependencies that should not be bundled, see https://webpack.js.org/guides/author-libraries/#externalize-lodash
- `module_deps` (optional) app_lib dependencies on `ts_web_library` targets

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

## Helm

Currently the helm rule set supports: downloading the helm binary as a repository rule, `helm template` in a form of test rule and `helm push` to a Chartmuseum helm repository.

For downloading the helm binary, add this to your WORKSPACES file:

```python
load("@com_github_airyhq_bazel_tools//helm:helm.bzl", "helm_tool")

helm_tool(
    name = "helm_binary",
)
```

The chart needs to be packaged before it can be processed by Bazel. To do that, add this to your BUILD file in the directory where the `Chart.yaml` file resides:

```python
load("@rules_pkg//:pkg.bzl", "pkg_tar")

filegroup(
    name = "files",
    srcs = glob([
        "**/*.yaml",
        "**/*.tpl",
    ]),
)

pkg_tar(
    name = "package",
    srcs = [":files"],
    extension = "tgz",
    strip_prefix = "./",
)
```

For running a test with `helm template`, add this to your BUILD file, in the same directory:


```python
load("@com_github_airyhq_bazel_tools//helm:helm.bzl", "helm_template_test")

helm_template_test(
    name = "template",
    chart = ":package",
)
```

Then run:

```shell
bazel test //.../helm-chart:template
```

**Parameters:**

- `name`    Unique name of the rule.
- `_helm_binary`    Location of the Helm binary to be used (Defaults to the binary downloaded with the repository rule).
- `chart`   A tgz archive containing the Helm chart.

For pushing to a Chartmuseum helm repository, add this to your BUILD file, in the same directory:

```python
load("@com_github_airyhq_bazel_tools//helm:helm.bzl", "helm_push")
helm_push(
    name = "push_testing",
    repository_url = "https://testing.helm.airy.co",
    repository_name = "airy",
    auth = "none",
    chart = chart,
)
helm_push(
    name = "push",
    repository_url = "https://helm.airy.co",
    repository_name = "airy",
    auth = "basic",
    chart = chart,
)
```

Then run:

```shell
bazel run //.../helm-chart:push
```

**Parameters:**

- `name`    Unique name of the rule.
- `_helm_binary`    Location of the Helm binary to be used (Defaults to the binary downloaded with the repository rule).
- `chart`   A tgz archive containing the Helm chart.
- `repository_url`  The URL of the repository where the Helm chart is pushed.
- `repository_name` The name of the temporary repoository added by Bazel.
- `auth`    Authentication type for the Helm repository (currently only `none` and `basic` are supported).
- `_push_script_template`   A script that is used and templated for running `helm push`.
- `version` A string containing the version of the Helm chart.
- `version_file`    An alternative to providing the version, a file can be used containing the version as a first line.

Note that only `basic` auth is supported at the moment. If you are using it, you must export `HELM_REPO_USERNAME` and `HELM_REPO_PASSWORD` with the username and the password of your Chartmuseum helm repository.

## Minikube

Currently the Minikube rule set supports starting (creating) and stopping (destroying) a Minikube Kubernetes cluster.

For downloading the Minikube binary, add this to your WORKSPACE file:

```python
load("@com_github_airyhq_bazel_tools//minikube:minikube.bzl", "minikube_tool")

minikube_tool(
    name = "minikube_binary",
)
```

For creating a Kubernetes cluster add this to your BUILD file:

```python
load("@com_github_airyhq_bazel_tools//minikube:minikube.bzl", "minikube_start")

minikube_start(
    name = "minikube-start",
)
```

Then run:

```shell
bazel run //.../infrastructure:minikube-start
```

**Parameters:**

- `name`    Unique name of the rule.
- `_minikube_binary`    (optional) Location of the Minikube binary to be used (Defaults to the binary downloaded with the repository rule).
- `profile`   (optional) The Minikube profile [default: airy-core].
- `driver`   (optional) The Minikube driver [default: docker].
- `cpus`  (optional) The number of CPU cores for the Kubernetes node [default: 4].
- `memory` (optional) The amount of memory of the Kubernetes node [default: 7168].
- `ingress_port`    (optional) The NodePort to be opened for the Ingress Controller [default: 80].

For destroying a Kubernetes cluster add this to your BUILD file:

```python
load("@com_github_airyhq_bazel_tools//minikube:minikube.bzl", "minikube_stop")

minikube_stop(
    name = "minikube-stop",
)
```

Then run:

```shell
bazel run //.../infrastructure:minikube-stop
```

**Parameters:**

- `name`    Unique name of the rule.
- `_minikube_binary`    (optional) Location of the Minikube binary to be used (Defaults to the binary downloaded with the repository rule).
- `profile`   (optional) The Minikube profile [default: airy-core].

## Aspects

We provide a simple [aspect](https://docs.bazel.build/versions/main/skylark/aspects.html) that helps discover the output groups of a target. 
It can be used like so:

```shell
bazel build --nobuild //path/to:target  --aspects=@com_github_airyhq_bazel_tools//aspects:outputs.bzl%output_group_query_aspect
```

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
