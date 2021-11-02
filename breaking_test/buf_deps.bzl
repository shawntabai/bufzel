load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")

_BUF_VERSION = "v0.56.0"
_BUF_BINARIES = {
    "buf_darwin_x86_64": {
        "asset": "buf-Darwin-x86_64",
        "sha256": "e156da18eff6d2868f338b2e00fcd97d6dbdf1c6938331056098eab42df0a321",
    },
    "buf_linux_x86_64": {
        "asset": "buf-Linux-x86_64",
        "sha256": "48ab010b1328c55d1172b3aa5e1ef6975c12100090b355a026df0e7926947d0b",
    },
    "buf_windows_x86_64": {
        "asset": "buf-Windows-x86_64.exe",
        "sha256": "4674c6ae89af38701903fa50388a5cc7beff2c5bbf594aa4d63578e973fc748a",
    },
}

_BUF_URL_PREFIX = "https://github.com/bufbuild/buf/releases/download/%s/" % _BUF_VERSION

_BUF_MAIN_REPO_KEY = "bufbuild_buf"
_HTTP_FILE_TARGET_PATTERN = "@%s//file"

BUF_MAIN_BINARY_TARGET = _HTTP_FILE_TARGET_PATTERN % _BUF_MAIN_REPO_KEY

def _buf_binary(key):
    binary = _BUF_BINARIES[key]
    http_file(
        name = key,
        urls = [_BUF_URL_PREFIX + binary["asset"]],
        sha256 = binary["sha256"],
        executable = True,
    )

def buf_binaries():
    _buf_binary("buf_darwin_x86_64")
    _buf_binary("buf_linux_x86_64")
    _buf_binary("buf_windows_x86_64")

def _buf_workspace_impl(repository_ctx):
    repository_ctx.file("workspace_root.sh", "echo \"%s\"" % repository_ctx.attr.workspace_root)
    repository_ctx.file("workspace_relative.sh", "echo \"%s\"" % repository_ctx.attr.relative_to_git_root)
    repository_ctx.file(
        "BUILD.bazel",
        (
            """sh_library(name = "workspace_root", srcs = ["workspace_root.sh"], visibility = ["//visibility:public"])\n""" +
            """sh_library(name = "workspace_relative", srcs = ["workspace_relative.sh"], visibility = ["//visibility:public"])\n"""
        ),
    )

_buf_workspace = repository_rule(
    implementation = _buf_workspace_impl,
    local = True,
    attrs = {
        "workspace_root": attr.string(mandatory = True),
        "relative_to_git_root": attr.string(default = "."),
    },
)

def buf_workspace(**kwargs):
    _buf_workspace(
        name = "buf_workspace_root",
        relative_to_git_root = kwargs.pop("relative_to_git_root"),
        workspace_root = kwargs.pop("workspace_root"),
    )
