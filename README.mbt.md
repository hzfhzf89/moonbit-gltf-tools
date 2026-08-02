# moonbit-gltf-tools

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
