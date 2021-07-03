# zprint

Build zprint for iOS.  
Invoke `build.sh` with path to the `zprint.tproj` folder inside a [`system_cmds`](https://opensource.apple.com/tarballs/system_cmds/) source tree.

Requires a kernel patch to work though. If using checkra1n/PongoOS, this will do it:

```c
*(uint32_t*)dt_prop(dt_find(gDeviceTree, "/device-tree/chosen"), "debug-enabled", NULL) = 1;
```

Might have unintended side effects though, highly untested. Maybe we'll ship a proper patch some day.
