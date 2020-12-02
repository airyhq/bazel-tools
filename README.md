# Airy Bazel-tools

Bazel tooling used by all Airy Bazel workspaces.

## Installation

To install, add this snippet to your `WORKSPACE`:

```
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
    ...
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

These two rules are a very shallow wrapper of buildifier, but we package it for convenvience. If you are looking
to use its extensive API you can replace this implementation with your own.

## How to contribute

We welcome (and love) every form of contribution! Good entry points to the
project are:

- Our [contributing guidelines](TODO)
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

We at Airy ❤️ Open Source. Check out our other projects over at [docs.airy.co](https://docs.airy.co).
