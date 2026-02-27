# h3_core

[![pub package](https://img.shields.io/pub/v/h3_core.svg)](https://pub.dev/packages/h3_core)
[![CI](https://github.com/agnath18K/h3_core/actions/workflows/ci.yml/badge.svg)](https://github.com/agnath18K/h3_core/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![H3 Version](https://img.shields.io/badge/H3-v4.4.1-green.svg)](https://github.com/uber/h3/releases/tag/v4.4.1)

Dart/Flutter bindings for the [H3](https://h3geo.org) geospatial indexing library, originally developed at [Uber](https://github.com/uber/h3).

Wraps **H3 v4.4.1** via `dart:ffi` on native platforms and **h3-js** via `dart:js_interop` on web. Same API on all platforms.

## Features

- Full H3 v4.4.1 API (~80 functions)
- Native: zero-overhead FFI calls via Build Hooks (compiles C natively — no pre-built binaries)
- Web: h3-js interop via `dart:js_interop`
- Single package, identical API on all platforms
- Type-safe Dart API with extension types (`H3Index`, `LatLng`, `CellBoundary`)
- Async wrappers for heavy operations

## Platform Support

| Platform | Backend | CI Tested |
|----------|---------|-----------|
| Android  | dart:ffi (C) | via macOS build |
| iOS      | dart:ffi (C) | via macOS build |
| macOS    | dart:ffi (C) | macOS stable |
| Linux    | dart:ffi (C) | Ubuntu stable + beta |
| Windows  | dart:ffi (C) | Windows stable |
| Web      | h3-js (JS)   | Chrome stable |

## Installation

```yaml
dependencies:
  h3_core: ^1.0.3
```

## Quick Start

```dart
import 'package:h3_core/h3_core.dart';

// Convert coordinates to H3 cell
final cell = latLngToCell(LatLng(37.7749, -122.4194), 9);
print(cell.toHex()); // 89283082803ffff

// Get cell center
final center = cellToLatLng(cell);
print('${center.lat}, ${center.lng}');

// Get neighbors
final neighbors = gridDisk(cell, 1); // 7 cells (origin + 6 neighbors)

// Check cell properties
print(getResolution(cell)); // 9
print(isValidCell(cell));   // true
print(isPentagon(cell));    // false
```

## API Overview

### Indexing
- `latLngToCell` — Convert coordinates to H3 cell
- `cellToLatLng` — Get cell center point
- `cellToBoundary` — Get cell boundary vertices

### Inspection
- `getResolution`, `getBaseCellNumber`, `isValidCell`, `isPentagon`, `isResClassIII`
- `getIcosahedronFaces`, `isValidIndex`, `isValidDirectedEdge`, `isValidVertex`

### Traversal
- `gridDisk`, `gridDiskDistances` — Get cells within k distance
- `gridRing` — Get hollow ring at distance k
- `gridDistance` — Distance between two cells
- `gridPathCells` — Line of cells between two cells

### Hierarchy
- `cellToParent`, `cellToChildren`, `cellToCenterChild`
- `cellToChildPos`, `childPosToCell`
- `compactCells`, `uncompactCells`

### Directed Edges
- `areNeighborCells`, `cellsToDirectedEdge`
- `getDirectedEdgeOrigin`, `getDirectedEdgeDestination`
- `originToDirectedEdges`, `directedEdgeToBoundary`

### Vertices
- `cellToVertex`, `cellToVertexes`, `vertexToLatLng`

### Measurements
- `greatCircleDistanceKm`, `greatCircleDistanceM`
- `cellAreaKm2`, `cellAreaM2`
- `edgeLengthKm`, `edgeLengthM`
- `getHexagonAreaAvgKm2`, `getHexagonEdgeLengthAvgKm`
- `getNumCells`

### Regions
- `polygonToCells` — Fill polygon with cells
- `cellsToMultiPolygon` — Convert cells to polygon boundaries

### Coordinates
- `cellToLocalIj`, `localIjToCell`

### Async
- `polygonToCellsAsync`, `gridDiskAsync`, `compactCellsAsync`, `uncompactCellsAsync`

## Web Setup

Add the h3-js script tag to your `web/index.html` before the Flutter bootstrap:

```html
<script src="https://cdn.jsdelivr.net/npm/h3-js@4/dist/h3-js.umd.js"></script>
<script src="flutter_bootstrap.js" async></script>
```

## Versioning

Package version uses its own semver. Wraps H3 C library v4.4.1.

## License

Apache 2.0 (matching H3)
