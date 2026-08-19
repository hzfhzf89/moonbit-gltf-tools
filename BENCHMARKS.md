# Benchmark protocol

The benchmark suite measures useful pipeline operations rather than synthetic
line counts. It uses deterministic in-memory glTF documents and reports the
median of repeated runs on the local machine. Results are intentionally not
hard-coded because CPU, MoonBit runtime and backend affect wall-clock values.

Run the native benchmark harness with:

```bash
moon run --target native cmd/main -- --benchmark
```

The report contains document construction time, validation time, scene traversal
time, resource audit time, and the number of processed nodes/primitives. Record
the command, MoonBit version, OS, CPU and sample count when comparing releases.

## Local baseline (2026-08-18)

Fixture: benchmarks/minimal.gltf (1 scene, 1 node, 0 meshes), native target,
Windows PowerShell, Moon 0.1.20260807 / Moonc 0.10.7. Five end-to-end CLI
samples measured with Measure-Command were **1739.72, 316.77, 309.28,
386.85, 312.15 ms**; median **316.77 ms**. The first sample includes the native
build/cache warm-up, so subsequent comparisons should report cold and warm
samples separately. The JSON report confirms zero diagnostics and one traversed
node. This is a real local baseline, not a performance guarantee across hosts.
