# pd-zig-external

A "hello world" example Pd external written in Zig.

## Building the external

To build, run:
```bash
zig build
```
Additional build args include:
- `--release=[fast,safe,small]` for performing a release build
- `-Dpatches=[copy,symbolic,skip]`
  - `copy` - Install copies of patches.
  - `symbolic` - Install symbolic links to patches. This makes it easier to track changes made to the patches.
  - `skip` - Don't install any patches.
- `-Dfloat_size=64` for specifying the size of floating-point numbers.
  - 64 and 32 are probably the only sizes that should be used, though in theory, other sizes should also work.
