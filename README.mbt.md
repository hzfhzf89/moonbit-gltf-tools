# moonbit-gltf-tools

MoonBit glTF/GLB 资产解析、校验、诊断与优化工具箱。

本项目面向游戏、Web3D、数字孪生和资源构建流水线，提供纯 MoonBit 的
glTF 2.0 数据模型、JSON/GLB 解析、场景图分析、引用完整性校验、资源依赖
审计、网格统计、访问器布局检查和可复现基准入口。项目不负责渲染，重点是
在资产进入运行时之前发现错误并给出可操作的优化建议。

## 快速开始

```bash
moon check --target all
moon test --target all
moon run --target native cmd/main
```

库的入口在 `lib.mbt`，CLI 示例在 `cmd/main/main.mbt`。公开 API 的完整说明
和设计边界见源码文档；GLB 输入必须是 glTF 2.0，外部 URI 只做依赖审计，
不会在解析阶段隐式读取本地文件。

## 工程质量与基准

仓库提供三平台 GitHub Actions，覆盖 `moon check`、`moon build`、`moon test`、
格式化和接口快照。`benchmarks/` 中的基准使用固定的合成场景，报告解析吞吐、
校验吞吐、节点遍历和资源审计的 wall-clock 样本；运行方式和结果记录在
`BENCHMARKS.md`。

## 许可证

Apache License 2.0，见 [LICENSE](LICENSE)。

A high-performance, lightweight glTF 2.0 and GLB asset parsing, validation, and optimization tool library written in pure MoonBit.

## Features

- **Robust Parser**: Parses standard glTF JSON and unpacks binary GLB containers (with embedded JSON & BIN chunks) securely.
- **Node Tree Hierarchy Analyzer**: Traverses the node tree, extracts structural hierarchy details, node depths, and skinned/mesh node distributions.
- **Metadata Extractor**: Inspects meshes, vertex counts, indices, primitive topologies, materials, animations, and samplers.
- **Resource Dependency Tracker**: Detects external asset references (URIs), embedded images (base64 data URIs), and internal buffers to generate asset manifests.
- **Asset Validator**: Validates reference integrity, index bounds, cycle detection in scene graphs, and Khronos specification compliance.
- **Optimization Reporter**: Evaluates asset configurations, identifies unindexed primitives, warns on excessive draw calls, and identifies unused materials/textures to produce actionable optimization suggestions.

## Installation

Add this dependency to your `moon.mod`:

```json
import {
  "username/moonbit-gltf-tools": "0.1.0"
}
```

## Quick Start

### 1. Parsing and Analyzing a Model

```mbt nocheck
///|
fn main {
  let json_str =
    #|{
    #|  "asset": { "version": "2.0" },
    #|  "scenes": [{ "nodes": [0] }],
    #|  "nodes": [{ "mesh": 0, "name": "RootNode" }],
    #|  "meshes": [{
    #|    "primitives": [{ "attributes": { "POSITION": 0 } }]
    #|  }],
    #|  "accessors": [{ "componentType": 5126, "count": 24, "type": "VEC3" }]
    #|}

  // Parse glTF JSON
  let doc = @gltf.parse_gltf_string(json_str)

  // Validate model structure
  let validation = @gltf.validate_document(doc)
  println("Is valid: \{validation.is_valid}")

  // Generate optimization report
  let opt_report = @gltf.analyze_optimization(doc)
  println("Total Vertices: \{opt_report.total_vertices}")
  println("Draw Calls: \{opt_report.draw_calls}")
  println("Suggestions: \{to_repr(opt_report.suggestions)}")
}
```

### 2. Unpacking a GLB File

```mbt nocheck
///|
fn process_glb(glb_bytes : Bytes) {
  let unpacked = @gltf.unpack_glb(glb_bytes)
  let doc = @gltf.parse_gltf_string(unpacked.json_str)
  println("glTF Version: \{doc.version}")
}
```

## CLI Usage

To run the command-line interface tool locally:

```bash
# Build the project
moon build --target native

# Analyze a glTF or GLB file
moon run cmd/main -- path/to/model.glb
```

## License

This project is licensed under the Apache License 2.0. See the [LICENSE](LICENSE) file for details.
