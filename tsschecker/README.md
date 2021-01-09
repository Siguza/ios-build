# tsschecker

One-for-all build script for [tsschecker](https://github.com/tihmstar/tsschecker) projects, including dependencies (targeting macOS).

Builds are static, which makes for big binaries, but ones that can be shared without any fuss.

### Env vars

|Var|Meaning|Default|
|:-|:-|:-|
|`PREFIX`|Where to install|`$HOME/Developer/local/dist` for arm64<br>`$HOME/local/dist` for x86_64|
|`SDK`|Where system headers are|`/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk`|
|`LIBTOOLIZE`|Name or path of GNU libtoolize|`glibtoolize`|

### Building

Simply invoke the build script either with no args (which builds all projects), or pass as many of the following as you like:

- `libgeneral`
- `libfragmentzip`
- `tsschecker`

Updates are automatically pulled on build, so to update any particular project, just re-run the build script with that arg.
