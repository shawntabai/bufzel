# `breaking_test`

This strategy has two main components:
* [`buf_deps.bzl`](buf_deps.bzl): Creates the external repository for the Buf binary and workspace rules
* [`build_defs/breaking.bzl`](build_defs/breaking.bzl): Contains the rule for creating a `buf_breaking_test`

## `buf_deps.bzl`

In this workspace configuration file, we select the right Buf binary based on platform. We also have a repository
rule that allows us to capture the workspace root, since the tests will need to run from there. You can see the
way this is used at the end of the [`WORKSPACE`](WORKSPACE) file:

```bazel
buf_workspace(
    # Needed if git repo root and workspace root are not the same
    relative_to_git_root = "./breaking_test",
    # Needed because the WORKSPACE file is the only place we have access to this variable
    workspace_root = __workspace_dir__,
)
```

This will create a special external repository named `buf_workspace_root` that contains two shell scripts:
* `workspace_root.sh`: Print the absolute path for the workspace root
* `workspace_relative.sh`: Print the path for the workspace root relative to the git repo root

These scripts will be needed for the test to be able to figure out the right run directory and arguments.

## `build_defs/breaking.bzl`

This creates the `buf_breaking_test` rule, which uses those workspace folders to run the breaking change test.
The script that gets generated for the test follows the following flow:

1. `cd` into the workspace root directory
2. `cd` into the root directory of the current git repo
3. Execute the `buf breaking` command with the specified proto files, diffing against the specified git branch

## Example

See [`example/BUILD.bazel`](example/BUILD.bazel) for an example of the usage.
