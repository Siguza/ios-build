# libimobiledevice

One-for-all build script for [libimobiledevice](https://github.com/libimobiledevice) projects, including dependencies (targeting macOS).

Builds are static, which makes for big binaries, but ones that can be shared without any fuss.

### Env vars

|Var|Meaning|Default|
|:-|:-|:-|
|`PREFIX`|Where to install|`$HOME/local/dist`|
|`SDK`|Where system headers are|`/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk`|
|`LIBTOOLIZE`|Name or path of GNU libtoolize|`glibtoolize`|

### Building dependencies

Before building libimobiledevice projects themselves, you need the following dependencies. Sorry, my script currently can't fetch the latest version by itself, maybe one day. What it **can** do though is build them.

For each dependency, download the latest tarball from the linked website, extract it, `cd` into the directory, then invoke the build script with the argument from the first column:

|Build arg|Download page|
|:-:|:-|
|`gmp`|https://gmplib.org/download/gmp/|
|`nettle`|https://ftp.gnu.org/gnu/nettle/|
|`libtasn1`|https://ftp.gnu.org/gnu/libtasn1/|
|`gnutls`|https://gnutls.org/download.html|
|`libgpg-error`|https://www.gnupg.org/ftp/gcrypt/libgpg-error/|
|`libgcrypt`|https://www.gnupg.org/ftp/gcrypt/libgcrypt/|
|`libzip`|https://libzip.org/download/|

### Building the actual projects

Once you've installed the dependencies in `PREFIX`, you can run the build script either with no args (which builds all projects), or pass as many of the following as you like:

- `libplist`
- `libusbmuxd`
- `libimobiledevice`
- `libirecovery`
- `libcrippy-1`
- `libpartialzip-1`
- `libfragmentzip`
- `idevicerestore`
- `ideviceinstaller`
- `libideviceactivation`

Updates are automatically pulled on build, so to update any particular project, just re-run the build script with that arg.
