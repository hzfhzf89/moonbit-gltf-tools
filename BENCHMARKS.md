# Benchmark protocol

This protocol measures end-to-end CLI processing on deterministic glTF fixtures.
It reports the median of repeated runs on the local machine. Results are
host-dependent because CPU, MoonBit runtime, and backend affect wall-clock
values.

Run the native CLI report with:

```bash
moon run --target native cmd/main benchmarks/minimal.gltf --json
```

For a local timing sample on PowerShell, run the same command repeatedly and
record the reported wall-clock values:

```powershell
1..5 | ForEach-Object {
  (Measure-Command {
    moon run --target native cmd/main benchmarks/minimal.gltf --json | Out-Null
  }).TotalMilliseconds
}
```

Record the command, MoonBit version, OS, CPU, backend, sample count, and whether
the first sample includes a cold build when comparing releases.

## Local baseline (2026-08-19)

Fixture: benchmarks/minimal.gltf (1 scene, 1 node, 0 meshes), native target,
Windows PowerShell, Moon 0.1.20260807 / Moonc 0.10.7. Five end-to-end CLI
samples measured with Measure-Command were **1620.83, 269.31, 273.66,
270.56, 276.35 ms**; median **273.66 ms**. The first sample includes the native
build/cache warm-up, so subsequent comparisons should report cold and warm
samples separately. The JSON report confirms zero diagnostics and one traversed
node. This is a real local baseline, not a performance guarantee across hosts.

## Local baseline (2026-08-24, Moonc 0.10.9)

The same fixture and native CLI were rerun after upgrading the local stable
toolchain to Moon 0.1.20260819 / Moonc 0.10.9. Five PowerShell samples were
**6763.41, 1081.78, 620.03, 575.32, 475.71 ms**; median **620.03 ms**. The
first sample includes build and cache warm-up. These numbers supersede the
earlier local sample for comparisons made with the current toolchain.

## Local baseline (2026-08-24, current stable)

The fixture was rerun with the current stable toolchain, Moon 0.1.20260824 /
Moonc 0.10.10. Five PowerShell samples were **2171.24, 418.56, 346.46,
263.58, 272.16 ms**; median **346.46 ms**. The first sample includes build and
cache warm-up. This is the preferred baseline for comparisons with the current
release.
