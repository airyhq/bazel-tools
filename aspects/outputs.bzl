def _output_group_query_aspect_impl(target, ctx):
    for og in target.output_groups:
        print("output group \"" + str(og) + "\":\n" + str(getattr(target.output_groups, og)))
    return []

# Use this aspect to discover all output groups of a rule. Example:
# bazel build --nobuild TARGET --aspects=//tools/aspects:outputs.bzl%output_group_query_aspect
output_group_query_aspect = aspect(
    implementation = _output_group_query_aspect_impl,
)
