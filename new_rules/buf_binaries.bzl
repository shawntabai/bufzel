load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")

_BUF_VERSION = "v0.56.0"
_BUF_BINARIES = {
    "buf_darwin_x86_64": {
        "asset": "buf-Darwin-x86_64",
        "sha256": "982629af4a7acdef13edff90f41349b03b44f43dd480d8e5e38fb86241492ee7",
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
