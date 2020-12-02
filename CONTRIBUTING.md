# Contributing

We ❤️ every form of contribution. The following document aims to provide enough
context to work with our codebase and to open pull requests that follow our
convention.  If this document does not provide enough help, open a [new
issue](https://github.com/airyhq/bazel-tools/issues/new) and we'll gladly help you get
started.

## Pull Requests

When opening a Pull Request, check that:

- Tests are passing
- Code is linted
- Description references the issue
- The branch name follows our convention
- Commits are squashed and follow our conventions

## Work with the code

The Airy Bazel tools use [Bazel](https://bazel.build/) to build and test
itself. We suggest you to install
[bazelisk](https://github.com/bazelbuild/bazelisk), a small utility that will
install the right version of Bazel for you given the `.bazelversion`

### Build

You can build the whole project using the following command:

```sh
bazel build //...
```

and build a specific project like so:

```sh
bazel build //code-format:all
```

### Lint

We use [buildifier](https://github.com/bazelbuild/buildtools/tree/master/buildifier) to lint our Bazel files.
To execute the buildifier linter run:

```shell script
bazel run //:check
```

You can also run:

```shell script
bazel run //:fix
```

to try fixing issues automatically.


### Managing dependencies

If you add, remove, or change a dependency from the `maven_install`, you must
re-pin dependencies using the following command:

```sh
bazel run @unpinned_maven//:pin
```

### Exploring the code base

Bazel has an extensive [query
language](https://docs.bazel.build/versions/master/query.html) you can use to
dig deeper into projects. Here are a few examples:

```sh
# show all deps of a given project
bazel query "deps(//code-format:all)" --output label

# show the available tests of a given project
bazel query "tests(//code-format:all)" --output label

# show all the packages under a specific path
bazel query "code-format/..." --output package
```

If you are not familiar with a specific project, you can also run the following
query:

```sh
bazel query "code-format/..."
```

The query shows all the targets produced under that specified package. It can
help with getting started.

Bazel also offers a friendly and powerful autocompletion, please refer to [this
document](https://github.com/bazelbuild/bazel/blob/master/site/docs/completion.md)
to install it locally.

## Naming conventions

Please refer to our [open source naming convention](https://docs.airy.co/guidelines/contributing#naming-conventions)
