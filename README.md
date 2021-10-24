# bufzel

Prototypes for Bazel plugin for Buf

## Strategies

There are a few strategies for prototyping explored in the different subfolders here:

### `new_rules`

The [`new_rules`](./new_rules) subfolder defines new `buf_proto_library` and `go_buf_proto_library` rules for Buf. This
means that these targets can easily specify Buf options, but they may not play nicely with preexisting rules.

### `existing_rules`

The [`existing_rules`](./existing_rules) subfolder implements the existing `go_proto_compiler` rule for Buf. This means
that you can use the preexisting `proto_library` and `go_proto_library` as normal, but you just change the `compilers`
attribute of the latter to make it use Buf instead of protoc.

The problem with this approach is that `go_proto_library` doesn't appear to have any mechanism to configure all the
options that Buf provides. This means that a user who wants any of that functionality would have to declare their own
`go_buf_proto_compiler` target that specifies configuration options.

Also, the existing approach is to have multiple `compilers` specified (rather than 1 compiler with multiple plugins). So
we would either have to break that paradigm, or the user would have to create their own compiler target for each plugin
(e.g. go, go-grpc, go-validate) with the custom config options.
