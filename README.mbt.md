# moonbit-gltf-tools

[![CI](https://github.com/hzfhzf89/moonbit-gltf-tools/actions/workflows/test.yml/badge.svg)](https://github.com/hzfhzf89/moonbit-gltf-tools/actions/workflows/test.yml)
[![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](LICENSE)

A MoonBit toolkit for inspecting, validating, and optimizing glTF 2.0 and GLB
assets. It is designed for asset importers, build pipelines, CI checks, and
offline diagnostics—not for rendering.

## Project positioning

moonbit-gltf-tools helps catch malformed or inefficient 3D assets before they
reach a runtime or an editor. The library keeps parsing and analysis
deterministic: external URIs are reported as dependencies and are not read
implicitly during parsing.

The project currently focuses on:

- glTF 2.0 JSON documents and GLB containers;
- structural validation and actionable diagnostics;
- scene graph, transform, resource, accessor, and mesh analysis;
- binary accessor decoding, GLB writing, semantic validation, and extension audits;
- topology quality, meshlet planning, vertex-cache analysis, spatial queries,
  instancing, and progressive resource streaming;
- machine-readable reports for automation;
- a native CLI for local inspection and CI integration.

## Core capabilities

### Parsing

- Parse glTF 2.0 JSON into strongly typed MoonBit data structures.
- Unpack GLB headers, JSON chunks, and optional BIN chunks.
- Decode the core scene, mesh, material, texture, image, animation, skin,
  accessor, buffer, and buffer view structures.

### Validation and diagnostics

- Validate reference bounds across scenes, nodes, meshes, materials, buffers,
  accessors, animations, and skins.
- Detect scene graph cycles and invalid child references.
- Check accessor element sizes, byte strides, alignment, buffer view windows, and
  normalization constraints.
- Produce configurable diagnostic summaries with severity, code, path, message,
  and remediation hints.

### Analysis and optimization

- Traverse scene graphs and evaluate inherited TRS transforms.
- Estimate vertices, indices, triangles, draw calls, attribute slots, and vertex
  memory.
- Report indexed geometry ratios, missing vertex attributes, material usage,
  animation channels, and skinning information.
- Audit embedded and external resource dependencies.
- Apply configurable quality gates for general and mobile-oriented pipelines.
- Build deterministic optimization plans for geometry, materials, resources,
  animation, skinning, and runtime budgets.

### Reporting

- Build a single AssetReport from the parser, validator, scene, resource,
  geometry, and quality-analysis passes.
- Export stable debug representations for CLI and automation consumers.
- Inspect URI safety, media types, data URIs, and common asset extensions.

## Quick start

### Prerequisites

Install the current stable MoonBit toolchain and ensure moon is available on
your PATH.

### Build and test the repository

~~~~bash
moon update
moon check --target all --deny-warn
moon test --target native --deny-warn
moon test --target wasm-gc --deny-warn
moon build --target native --deny-warn
~~~~

### Run the sample asset

The repository includes a small deterministic fixture at
benchmarks/minimal.gltf.

~~~~bash
moon run --target native cmd/main benchmarks/minimal.gltf
moon run --target native cmd/main benchmarks/minimal.gltf --json
~~~~

The first command prints a human-readable inspection report. The --json
variant prints the machine-readable asset report for scripts and CI jobs.

## Library usage

Add the package to a MoonBit project with:

~~~~bash
moon add hzfhzf89/moonbit-gltf-tools
~~~~

Import the public gltf package:

~~~~mbt nocheck
///|
import {
  "hzfhzf89/moonbit-gltf-tools/gltf",
}

///|
fn inspect_asset(json : String) raise {
  let document = @gltf.parse_gltf_string(json)
  let report = @gltf.build_default_asset_report(document)
  println("triangles=\\{report.geometry.triangles}")
  println("diagnostics=\\{report.diagnostics.errors}")
}
~~~~

For GLB input, call @gltf.unpack_glb first and pass the returned JSON string
to @gltf.parse_gltf_string.

## CLI

The CLI accepts a .gltf or .glb path:

~~~~bash
moon run --target native cmd/main path/to/asset.gltf
moon run --target native cmd/main path/to/asset.glb
moon run --target native cmd/main path/to/asset.gltf --json
~~~~

The CLI reports:

1. structural validation results;
2. scene graph and resource dependency summaries;
3. mesh and animation metadata;
4. optimization suggestions;
5. quality-gate score and violations.

Use --json when another tool should consume the complete AssetReport.

## Architecture

~~~~text
.
├── lib.mbt                  # root facade exports
├── gltf/
│   ├── types.mbt            # glTF 2.0 data model
│   ├── parser.mbt           # JSON document parser
│   ├── glb.mbt              # GLB container handling
│   ├── validator.mbt        # reference and structure validation
│   ├── diagnostics.mbt      # configurable diagnostic engine
│   ├── accessor.mbt         # accessor and buffer layout analysis
│   ├── scene.mbt            # scene graph and resource analysis
│   ├── transform.mbt        # TRS/world-transform evaluation
│   ├── mesh_analysis.mbt    # geometry cost analysis
│   ├── analyzer.mbt         # optimization suggestions
│   ├── report.mbt           # unified asset reports
│   ├── quality.mbt          # quality gates
│   ├── uri.mbt              # URI classification and safety checks
│   ├── binary_reader.mbt    # bounded reads and accessor decoding
│   ├── binary_writer.mbt    # aligned GLB construction and inspection
│   ├── geometry_pipeline.mbt # geometry metrics and budget checks
│   ├── topology_analysis.mbt # manifold, boundary, and component analysis
│   ├── meshlet_pipeline.mbt # bounded meshlet and LOD planning
│   ├── cache_optimizer.mbt  # vertex-cache metrics and reordering
│   ├── spatial_query.mbt    # bounds, ray, frustum, and nearest queries
│   ├── instance_batching.mbt # transform and draw-batch planning
│   ├── streaming_scheduler.mbt # progressive resource scheduling
│   ├── semantic_validation.mbt # policy-driven semantic validation
│   ├── resource_pipeline.mbt # resource manifests and package plans
│   ├── animation_pipeline.mbt # track sampling and clip budgets
│   ├── skin_pipeline.mbt    # joint and weight analysis
│   └── report_formats.mbt   # JSON, Markdown, and CI annotations
├── cmd/main/main.mbt        # native command-line entry point
├── benchmarks/              # deterministic benchmark fixtures
└── .github/workflows/       # cross-platform CI
~~~~

The implementation is organized as independent analysis passes over the typed
document model. Applications can use individual passes or compose them through
build_asset_report. Supporting passes cover attribute validation, derived
geometry metrics and sampling, LOD quality, material sampling, resource
integrity, animation compression, scene scheduling/snapshots, runtime budgets,
asset diffs, extension audits, normalization, and release-quality matrices.

## Benchmarks

The benchmark protocol and recorded local baseline are maintained in
[benchmarks documentation](BENCHMARKS.md). Run the CLI benchmark fixture with:

~~~~bash
moon run --target native cmd/main benchmarks/minimal.gltf --json
~~~~

Recorded local baseline (2026-08-24): on Windows PowerShell with Moonc 0.10.10
and the native backend, five end-to-end samples were 2171.24, 418.56, 346.46,
263.58, and 272.16 ms; the median was 346.46 ms. The first sample included
build/cache warm-up. The fixture contains one scene and one node, and the JSON
report contains zero diagnostics. These figures are host-dependent; historical
samples and the exact protocol are documented in BENCHMARKS.md.

Benchmark comparisons should record the MoonBit version, target backend,
operating system, CPU, sample count, and whether the run includes a cold build.
Wall-clock results are host-dependent and should not be treated as universal
performance guarantees.

## Testing

The test suite covers parser behavior, GLB boundaries, reference validation,
scene cycles, accessor layouts, URI classification, transforms, mesh analysis,
quality gates, and report generation.

Recommended local checks:

~~~~bash
moon fmt
moon check --target all --deny-warn
moon test --target all --deny-warn
moon build --target native --deny-warn
moon info
~~~~

moon info regenerates the public interface snapshots in pkg.generated.mbti
files. Review those files when public APIs change.

## CI

The GitHub Actions workflow runs on Ubuntu, macOS, and Windows. It installs
Node.js and the official stable MoonBit toolchain (verified locally at Moonc
v0.10.10), then runs:

- moon check --target all --deny-warn;
- native build verification;
- formatting and public-interface drift checks;
- moon test --target all --deny-warn.

See the CI workflow at
.github/workflows/test.yml.

## License

Apache License 2.0. See LICENSE.
