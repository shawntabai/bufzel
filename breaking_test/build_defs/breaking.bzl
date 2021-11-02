def _buf_breaking_test_impl(ctx):
    path_args = ""
    for src in ctx.files.srcs:
        path_args += " --path \"$WORKSPACE_RELATIVE/%s\"" % src.path
    path_args = path_args.lstrip()

    # Note: This will fail if git isn't provided by the current shell environment.
    # It would probably be better if git were a toolchain dependency?
    script = """
        WORKSPACE_ROOT="$(external/buf_workspace_root/workspace_root.sh)"
        WORKSPACE_RELATIVE="$(external/buf_workspace_root/workspace_relative.sh)"
        cd "$WORKSPACE_ROOT"
        cd "$(git rev-parse --show-toplevel)"
        buf breaking {path_args} --against ".git#branch={git_branch},format=git"
    """.format(path_args = path_args, git_branch = ctx.attr.git_branch)

    # Write the test script out to a file when building. Actually running the test will execute that script.
    ctx.actions.write(
        output = ctx.outputs.executable,
        content = script,
        is_executable = True,
    )

    runfiles = ctx.runfiles(files = ctx.files.srcs + ctx.files.deps + ctx.files.buf_binary)
    return [DefaultInfo(runfiles = runfiles)]

_buf_breaking_test = rule(
    implementation = _buf_breaking_test_impl,
    attrs = {
        "srcs": attr.label_list(mandatory = True, allow_files = True),
        "deps": attr.label_list(
            default = [
                Label("@buf_workspace_root//:workspace_relative"),
                Label("@buf_workspace_root//:workspace_root"),
            ],
        ),
        "git_branch": attr.string(default = "main"),
        "buf_binary": attr.label(
            allow_single_file = True,
            cfg = "exec",
            executable = True,
        ),
    },
    test = True,
)

def buf_breaking_test(**kwargs):
    _buf_breaking_test(
        buf_binary = select({
            "@bazel_tools//src/conditions:darwin_x86_64": "@buf_darwin_x86_64//file",
            "@bazel_tools//src/conditions:linux_x86_64": "@buf_linux_x86_64//file",
            "@bazel_tools//src/conditions:windows": "@buf_windows_x86_64//file",
        }),
        **kwargs
    )
