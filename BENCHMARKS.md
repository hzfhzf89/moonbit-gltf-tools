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

## Local baseline (2026-08-18)

Fixture: benchmarks/minimal.gltf (1 scene, 1 node, 0 meshes), native target,
Windows PowerShell, Moon 0.1.20260807 / Moonc 0.10.7. Five end-to-end CLI
samples measured with Measure-Command were **1739.72, 316.77, 309.28,
386.85, 312.15 ms**; median **316.77 ms**. The first sample includes the native
build/cache warm-up, so subsequent comparisons should report cold and warm
samples separately. The JSON report confirms zero diagnostics and one traversed
node. This is a real local baseline, not a performance guarantee across hosts.
