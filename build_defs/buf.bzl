BufLibrary = provider(fields=["files"])

def _buf_proto_library_impl(ctx):
  srcpaths = [f.path for f in ctx.files.srcs]
  args = ["build", "--path"] + srcpaths + ["--output", ctx.outputs.out.path]
  msg = "Building proto to %s" % ctx.outputs.out.path
  ctx.actions.run(
    inputs = ctx.files.srcs,
    mnemonic = "BufBuild",
    progress_message = msg,
    executable = ctx.executable._compiler,
    arguments = args,
    outputs = [ctx.outputs.out],
  )
  return [BufLibrary(files=depset([ctx.outputs.out]))]

_buf_proto_library = rule(
  implementation = _buf_proto_library_impl,
  attrs = {
    "srcs": attr.label_list(mandatory = True, allow_files = True),
    "out": attr.output(),
    "_compiler": attr.label(
      default = Label("@com_github_bufbuild_buf//cmd/buf"),
      allow_single_file = True,
      cfg = "exec",
      executable = True,
    ),
  },
)

def buf_proto_library(**kwargs):
    name = kwargs["name"]
    _buf_proto_library(
        out = "%s.compiledproto" % name,
        **kwargs
    )
