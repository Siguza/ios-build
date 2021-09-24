# libimobiledevice

One-for-all build script for [libimobiledevice](https://github.com/libimobiledevice) projects, including dependencies (targeting macOS).

Builds are static, which makes for big binaries, but ones that can be shared without any fuss.

### Env vars

|Var|Meaning|Default|
|:-|:-|:-|
|`PREFIX`|Where to install|`$HOME/Developer/local/dist` for arm64<br>`$HOME/local/dist` for x86_64|
|`SDK`|Where system headers are|`/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk`|
|`USE_LIBRESSL`|Whether or not to use the system-provided libressl|`true` for arm64<br>`false` for x86_64|
|`BUILD_SHARED`|Link shared instead of statically|`false`|

### Building dependencies

Before building the LIMD stack itself, you'll need some dependencies.  
Until I figure out a way to always pull the latest version of those, you'll have to download the tarballs yourself, sorry.

Once you have those though, you can use my script to build them. Just `cd` into the source folder and call `build.sh` with the project name. For example:

    cd libzip
    ../build.sh libzip

The actual list of dependencies depends on `USE_LIBRESSL`.  
On x86_64, binaries are built with macOS 10.9 compatibility, so for compatibility, a static GnuTLS stack is used.  
On arm64, GnuTLS cannot be used since libnettle does not support that architecture. But since compatibility only goes back to macOS 11.0, using the system-provided libraries is preferred here.

**arm64 dependencies (or `USE_LIBRESSL=true`)**

|`build.sh` arg|Download page|
|:-:|:-|
|`libzip`|https://libzip.org/download/|

**x86_64 dependencies (or `USE_LIBRESSL=false`)**

|`build.sh` arg|Download page|
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
- `idevicerestore`
- `ideviceinstaller`
- `libideviceactivation`

Updates are automatically pulled on build, so to update any particular project, just re-run the build script with that arg.
