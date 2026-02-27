import 'dart:js_interop';

import '_h3_js_bindings.dart' as js;
import 'errors.dart';
import 'models/cell_boundary.dart';
import 'models/coord_ij.dart';
import 'models/geo_polygon.dart';
import 'models/h3_index.dart';
import 'models/lat_lng.dart';

JSString _toJs(H3Index h) => h.toHex().toJS;
H3Index _fromJs(JSString s) => H3Index.parse(s.toDart);

JSArray<JSNumber> _latLngToJsArray(LatLng ll) =>
    <JSNumber>[ll.lat.toJS, ll.lng.toJS].toJS;

LatLng _jsArrayToLatLng(JSArray<JSNumber> arr) {
  final list = arr.toDart;
  return LatLng(list[0].toDartDouble, list[1].toDartDouble);
}

/// Maps h3-js exceptions to [H3Exception].
T _catchJsError<T>(T Function() fn) {
  try {
    return fn();
  } on Object catch (e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('invalid cell') || msg.contains('invalid h3index')) {
      throw const H3Exception(5, 'Invalid H3 cell index');
    }
    if (msg.contains('invalid directed edge')) {
      throw const H3Exception(6, 'Invalid directed edge index');
    }
    if (msg.contains('invalid vertex')) {
      throw const H3Exception(8, 'Invalid vertex index');
    }
    if (msg.contains('not neighbor') || msg.contains('not neighbors')) {
      throw const H3Exception(11, 'Cells are not neighbors');
    }
    if (msg.contains('pentagon')) {
      throw const H3Exception(9, 'Pentagon distortion encountered');
    }
    if (msg.contains('resolution')) {
      throw const H3Exception(4, 'Resolution must be between 0 and 15');
    }
    if (msg.contains('latlng') ||
        msg.contains('latitude') ||
        msg.contains('longitude')) {
      throw const H3Exception(3, 'Invalid latitude or longitude');
    }
    throw H3Exception(1, 'H3 operation failed: $e');
  }
}

// Indexing

/// Converts a [latLng] coordinate to the H3 cell index at the given
/// [resolution] (0–15).
H3Index latLngToCell(LatLng latLng, int resolution) {
  return _catchJsError(() {
    final hex = js.h3.latLngToCell(
      latLng.lat.toJS,
      latLng.lng.toJS,
      resolution.toJS,
    );
    return _fromJs(hex);
  });
}

/// Returns the center coordinate of the given H3 [cell].
LatLng cellToLatLng(H3Index cell) {
  return _catchJsError(() {
    final arr = js.h3.cellToLatLng(_toJs(cell));
    return _jsArrayToLatLng(arr);
  });
}

/// Returns the boundary vertices of the given H3 [cell].
CellBoundary cellToBoundary(H3Index cell) {
  return _catchJsError(() {
    final arr = js.h3.cellToBoundary(_toJs(cell));
    final verts = <LatLng>[];
    for (final pair in arr.toDart) {
      verts.add(_jsArrayToLatLng(pair));
    }
    return CellBoundary(verts);
  });
}

// Inspection

/// Returns the resolution (0–15) of the given H3 index.
int getResolution(H3Index h) {
  return _catchJsError(() => js.h3.getResolution(_toJs(h)).toDartInt);
}

/// Returns the base cell number (0–121) of the given H3 index.
int getBaseCellNumber(H3Index h) {
  return _catchJsError(() => js.h3.getBaseCellNumber(_toJs(h)).toDartInt);
}

/// Returns whether [h] is a valid H3 cell index.
bool isValidCell(H3Index h) {
  return _catchJsError(() => js.h3.isValidCell(_toJs(h)).toDart);
}

/// Returns whether [h] is any valid H3 index (cell, edge, or vertex).
///
/// Checks cell, edge, and vertex validity (h3-js has no single isValidIndex).
bool isValidIndex(H3Index h) {
  final hex = _toJs(h);
  return js.h3.isValidCell(hex).toDart ||
      js.h3.isValidDirectedEdge(hex).toDart ||
      js.h3.isValidVertex(hex).toDart;
}

/// Returns whether [h] is a pentagon cell.
bool isPentagon(H3Index h) {
  return _catchJsError(() => js.h3.isPentagon(_toJs(h)).toDart);
}

/// Returns whether [h] has Class III resolution orientation.
bool isResClassIII(H3Index h) {
  return _catchJsError(() => js.h3.isResClassIII(_toJs(h)).toDart);
}

/// Returns the icosahedron face(s) that the given cell intersects.
List<int> getIcosahedronFaces(H3Index h) {
  return _catchJsError(() {
    final faces = js.h3.getIcosahedronFaces(_toJs(h));
    return [for (final f in faces.toDart) f.toDartInt];
  });
}

/// Returns whether [edge] is a valid H3 directed edge index.
bool isValidDirectedEdge(H3Index edge) {
  return _catchJsError(() => js.h3.isValidDirectedEdge(_toJs(edge)).toDart);
}

/// Returns whether [vertex] is a valid H3 vertex index.
bool isValidVertex(H3Index vertex) {
  return _catchJsError(() => js.h3.isValidVertex(_toJs(vertex)).toDart);
}

/// Returns the direction digit at the given [resolution] for index [h].
///
/// Uses BigInt since h3-js doesn't expose this and JS can't do 64-bit bit ops.
int getIndexDigit(H3Index h, int resolution) {
  final bigInt = BigInt.parse(h.toHex(), radix: 16);
  final shift = (15 - resolution) * 3;
  return ((bigInt >> shift) & BigInt.from(0x7)).toInt();
}

/// Constructs an H3 cell index from [res], [baseCellNumber], and direction
/// [digits].
///
/// Uses BigInt for the same reason as [getIndexDigit].
H3Index constructCell(int res, int baseCellNumber, List<int> digits) {
  var value = BigInt.zero;
  value |= BigInt.one << 59; // mode = cell
  value |= BigInt.from(res & 0xF) << 52;
  value |= BigInt.from(baseCellNumber & 0x7F) << 45;
  // Fill unused digit slots with 7 (invalid marker)
  for (var r = 1; r <= 15; r++) {
    value |= BigInt.from(0x7) << ((15 - r) * 3);
  }
  for (var i = 0; i < digits.length && i < res; i++) {
    final shift = (15 - (i + 1)) * 3;
    value &= ~(BigInt.from(0x7) << shift);
    value |= BigInt.from(digits[i] & 0x7) << shift;
  }
  return H3Index(value.toRadixString(16));
}

// String conversion

/// Parses a [hex] string into an [H3Index], throwing [H3Exception] on
/// invalid input.
H3Index stringToH3(String hex) {
  final h = H3Index.parse(hex);
  if (!isValidIndex(h)) {
    throw const H3Exception(16, 'Invalid H3 index');
  }
  return h;
}

/// Returns the hex string representation of the given H3 index.
String h3ToString(H3Index h) => h.toHex();

// Traversal

/// Returns all cells within [k] grid steps of [origin] (filled disk).
List<H3Index> gridDisk(H3Index origin, int k) {
  return _catchJsError(() {
    final cells = js.h3.gridDisk(_toJs(origin), k.toJS);
    return [for (final c in cells.toDart) _fromJs(c)];
  });
}

/// Returns cells within [k] steps of [origin] mapped to their grid distance.
Map<H3Index, int> gridDiskDistances(H3Index origin, int k) {
  return _catchJsError(() {
    final rings = js.h3.gridDiskDistances(_toJs(origin), k.toJS);
    final result = <H3Index, int>{};
    final ringList = rings.toDart;
    for (var dist = 0; dist < ringList.length; dist++) {
      for (final cell in ringList[dist].toDart) {
        result[_fromJs(cell)] = dist;
      }
    }
    return result;
  });
}

/// Returns cells exactly [k] grid steps from [origin] (hollow ring).
List<H3Index> gridRing(H3Index origin, int k) {
  return _catchJsError(() {
    final cells = js.h3.gridRingUnsafe(_toJs(origin), k.toJS);
    return [for (final c in cells.toDart) _fromJs(c)];
  });
}

/// Returns the minimum grid distance between [origin] and [destination].
int gridDistance(H3Index origin, H3Index destination) {
  return _catchJsError(() {
    return js.h3.gridDistance(_toJs(origin), _toJs(destination)).toDartInt;
  });
}

/// Returns the cells along the shortest grid path from [start] to [end].
List<H3Index> gridPathCells(H3Index start, H3Index end) {
  return _catchJsError(() {
    final cells = js.h3.gridPathCells(_toJs(start), _toJs(end));
    return [for (final c in cells.toDart) _fromJs(c)];
  });
}

// Hierarchy

/// Returns the parent cell of [cell] at the coarser [parentRes].
H3Index cellToParent(H3Index cell, int parentRes) {
  return _catchJsError(() {
    return _fromJs(js.h3.cellToParent(_toJs(cell), parentRes.toJS));
  });
}

/// Returns the children of [cell] at the finer [childRes].
List<H3Index> cellToChildren(H3Index cell, int childRes) {
  return _catchJsError(() {
    final children = js.h3.cellToChildren(_toJs(cell), childRes.toJS);
    return [for (final c in children.toDart) _fromJs(c)];
  });
}

/// Returns the center child of [cell] at the finer [childRes].
H3Index cellToCenterChild(H3Index cell, int childRes) {
  return _catchJsError(() {
    return _fromJs(js.h3.cellToCenterChild(_toJs(cell), childRes.toJS));
  });
}

/// Returns the position of [child] within its parent at [parentRes].
int cellToChildPos(H3Index child, int parentRes) {
  return _catchJsError(() {
    return js.h3.cellToChildPos(_toJs(child), parentRes.toJS).toDartInt;
  });
}

/// Returns the child cell at [childPos] within [parent] at [childRes].
H3Index childPosToCell(int childPos, H3Index parent, int childRes) {
  return _catchJsError(() {
    return _fromJs(
      js.h3.childPosToCell(childPos.toJS, _toJs(parent), childRes.toJS),
    );
  });
}

/// Compacts a set of [cells] by replacing complete groups with their parent.
List<H3Index> compactCells(List<H3Index> cells) {
  return _catchJsError(() {
    final jsArr = <JSString>[for (final c in cells) _toJs(c)].toJS;
    final compacted = js.h3.compactCells(jsArr);
    return [for (final c in compacted.toDart) _fromJs(c)];
  });
}

/// Expands compacted [cells] to the given [resolution].
List<H3Index> uncompactCells(List<H3Index> cells, int resolution) {
  return _catchJsError(() {
    final jsArr = <JSString>[for (final c in cells) _toJs(c)].toJS;
    final uncompacted = js.h3.uncompactCells(jsArr, resolution.toJS);
    return [for (final c in uncompacted.toDart) _fromJs(c)];
  });
}

// Directed edges

/// Returns whether [origin] and [destination] share an edge.
bool areNeighborCells(H3Index origin, H3Index destination) {
  return _catchJsError(() {
    return js.h3.areNeighborCells(_toJs(origin), _toJs(destination)).toDart;
  });
}

/// Returns the directed edge from [origin] to [destination].
H3Index cellsToDirectedEdge(H3Index origin, H3Index destination) {
  return _catchJsError(() {
    return _fromJs(
      js.h3.cellsToDirectedEdge(_toJs(origin), _toJs(destination)),
    );
  });
}

/// Returns the origin cell of the directed [edge].
H3Index getDirectedEdgeOrigin(H3Index edge) {
  return _catchJsError(() {
    return _fromJs(js.h3.getDirectedEdgeOrigin(_toJs(edge)));
  });
}

/// Returns the destination cell of the directed [edge].
H3Index getDirectedEdgeDestination(H3Index edge) {
  return _catchJsError(() {
    return _fromJs(js.h3.getDirectedEdgeDestination(_toJs(edge)));
  });
}

/// Returns the origin and destination cells of the directed [edge].
List<H3Index> directedEdgeToCells(H3Index edge) {
  return _catchJsError(() {
    final cells = js.h3.directedEdgeToCells(_toJs(edge));
    return [for (final c in cells.toDart) _fromJs(c)];
  });
}

/// Returns all directed edges originating from [origin].
List<H3Index> originToDirectedEdges(H3Index origin) {
  return _catchJsError(() {
    final edges = js.h3.originToDirectedEdges(_toJs(origin));
    return [for (final e in edges.toDart) _fromJs(e)];
  });
}

/// Returns the boundary vertices of the directed [edge].
CellBoundary directedEdgeToBoundary(H3Index edge) {
  return _catchJsError(() {
    final arr = js.h3.directedEdgeToBoundary(_toJs(edge));
    final verts = <LatLng>[];
    for (final pair in arr.toDart) {
      verts.add(_jsArrayToLatLng(pair));
    }
    return CellBoundary(verts);
  });
}

// Vertices

/// Returns the vertex at index [vertexNum] (0–5) of the [cell].
H3Index cellToVertex(H3Index cell, int vertexNum) {
  return _catchJsError(() {
    return _fromJs(js.h3.cellToVertex(_toJs(cell), vertexNum.toJS));
  });
}

/// Returns all vertices of the given [cell].
List<H3Index> cellToVertexes(H3Index cell) {
  return _catchJsError(() {
    final verts = js.h3.cellToVertexes(_toJs(cell));
    return [for (final v in verts.toDart) _fromJs(v)];
  });
}

/// Returns the coordinates of the given [vertex].
LatLng vertexToLatLng(H3Index vertex) {
  return _catchJsError(() {
    final arr = js.h3.vertexToLatLng(_toJs(vertex));
    return _jsArrayToLatLng(arr);
  });
}

// Measurements

/// Returns the great-circle distance between [a] and [b] in kilometers.
double greatCircleDistanceKm(LatLng a, LatLng b) {
  return _catchJsError(() {
    return js.h3
        .greatCircleDistance(
          _latLngToJsArray(a),
          _latLngToJsArray(b),
          'km'.toJS,
        )
        .toDartDouble;
  });
}

/// Returns the great-circle distance between [a] and [b] in meters.
double greatCircleDistanceM(LatLng a, LatLng b) {
  return _catchJsError(() {
    return js.h3
        .greatCircleDistance(_latLngToJsArray(a), _latLngToJsArray(b), 'm'.toJS)
        .toDartDouble;
  });
}

/// Returns the exact area of the [cell] in km².
double cellAreaKm2(H3Index cell) {
  return _catchJsError(() {
    return js.h3.cellArea(_toJs(cell), 'km2'.toJS).toDartDouble;
  });
}

/// Returns the exact area of the [cell] in m².
double cellAreaM2(H3Index cell) {
  return _catchJsError(() {
    return js.h3.cellArea(_toJs(cell), 'm2'.toJS).toDartDouble;
  });
}

/// Returns the exact length of the directed [edge] in kilometers.
double edgeLengthKm(H3Index edge) {
  return _catchJsError(() {
    return js.h3.edgeLength(_toJs(edge), 'km'.toJS).toDartDouble;
  });
}

/// Returns the exact length of the directed [edge] in meters.
double edgeLengthM(H3Index edge) {
  return _catchJsError(() {
    return js.h3.edgeLength(_toJs(edge), 'm'.toJS).toDartDouble;
  });
}

/// Returns the average hexagon area in km² at the given [resolution].
double getHexagonAreaAvgKm2(int resolution) {
  return _catchJsError(() {
    return js.h3.getHexagonAreaAvg(resolution.toJS, 'km2'.toJS).toDartDouble;
  });
}

/// Returns the average hexagon area in m² at the given [resolution].
double getHexagonAreaAvgM2(int resolution) {
  return _catchJsError(() {
    return js.h3.getHexagonAreaAvg(resolution.toJS, 'm2'.toJS).toDartDouble;
  });
}

/// Returns the average hexagon edge length in km at the given [resolution].
double getHexagonEdgeLengthAvgKm(int resolution) {
  return _catchJsError(() {
    return js.h3
        .getHexagonEdgeLengthAvg(resolution.toJS, 'km'.toJS)
        .toDartDouble;
  });
}

/// Returns the average hexagon edge length in meters at the given
/// [resolution].
double getHexagonEdgeLengthAvgM(int resolution) {
  return _catchJsError(() {
    return js.h3
        .getHexagonEdgeLengthAvg(resolution.toJS, 'm'.toJS)
        .toDartDouble;
  });
}

/// Returns the total number of cells at the given [resolution].
int getNumCells(int resolution) {
  return _catchJsError(() {
    return js.h3.getNumCells(resolution.toJS).toDartInt;
  });
}

// Coordinate systems

/// Converts [cell] to local IJ coordinates relative to [origin].
CoordIJ cellToLocalIj(H3Index origin, H3Index cell) {
  return _catchJsError(() {
    final ij = js.h3.cellToLocalIj(_toJs(origin), _toJs(cell));
    return CoordIJ(ij.i.toDartInt, ij.j.toDartInt);
  });
}

/// Converts local [ij] coordinates relative to [origin] back to an H3 cell.
H3Index localIjToCell(H3Index origin, CoordIJ ij) {
  return _catchJsError(() {
    final jsIj = js.CoordIJJsLiteral(i: ij.i, j: ij.j);
    return _fromJs(js.h3.localIjToCell(_toJs(origin), jsIj));
  });
}

// Regions

/// Returns all cells whose centers are within the [polygon] at [resolution].
List<H3Index> polygonToCells(GeoPolygon polygon, int resolution) {
  return _catchJsError(() {
    final coords = _geoPolygonToJsCoords(polygon);
    final cells = js.h3.polygonToCells(coords, resolution.toJS);
    return [for (final c in cells.toDart) _fromJs(c)];
  });
}

/// Returns cells within the [polygon] using the specified containment [mode].
///
/// Only [ContainmentMode.center] is supported on web (h3-js v4 limitation).
List<H3Index> polygonToCellsExperimental(
  GeoPolygon polygon,
  int resolution, {
  ContainmentMode mode = ContainmentMode.center,
}) {
  if (mode == ContainmentMode.center) {
    return polygonToCells(polygon, resolution);
  }
  throw UnsupportedError(
    'polygonToCellsExperimental with mode $mode is not supported on web. '
    'h3-js v4.x only supports center containment mode.',
  );
}

/// Returns the outlines of a set of [cells] as a GeoJSON-style
/// multi-polygon.
List<List<List<LatLng>>> cellsToMultiPolygon(List<H3Index> cells) {
  return _catchJsError(() {
    final jsArr = <JSString>[for (final c in cells) _toJs(c)].toJS;
    final multi = js.h3.cellsToMultiPolygon(jsArr);

    final result = <List<List<LatLng>>>[];
    for (final polygon in multi.toDart) {
      final rings = <List<LatLng>>[];
      for (final ring in polygon.toDart) {
        final verts = <LatLng>[];
        for (final pair in ring.toDart) {
          verts.add(_jsArrayToLatLng(pair));
        }
        rings.add(verts);
      }
      result.add(rings);
    }
    return result;
  });
}

/// h3-js accepts number[][] for simple polygons, number[][][] with holes.
JSAny _geoPolygonToJsCoords(GeoPolygon polygon) {
  JSArray<JSArray<JSNumber>> ringToJs(List<LatLng> ring) =>
      <JSArray<JSNumber>>[for (final ll in ring) _latLngToJsArray(ll)].toJS;

  if (polygon.holes.isEmpty) {
    return ringToJs(polygon.exterior);
  }

  final rings = <JSArray<JSArray<JSNumber>>>[
    ringToJs(polygon.exterior),
    for (final hole in polygon.holes) ringToJs(hole),
  ];
  return rings.toJS;
}

// Utilities

/// Returns the number of resolution-0 cells (always 122).
int res0CellCount() => 122;

/// Returns all 122 resolution-0 cells.
List<H3Index> getRes0Cells() {
  return _catchJsError(() {
    final cells = js.h3.getRes0Cells();
    return [for (final c in cells.toDart) _fromJs(c)];
  });
}

/// Returns the number of pentagons per resolution (always 12).
int pentagonCount() => 12;

/// Returns all 12 pentagon cells at the given [resolution].
List<H3Index> getPentagons(int resolution) {
  return _catchJsError(() {
    final cells = js.h3.getPentagons(resolution.toJS);
    return [for (final c in cells.toDart) _fromJs(c)];
  });
}

/// Version constants for the h3_core package and the underlying H3 C library.
abstract final class H3Version {
  /// The h3_core Dart package version.
  static const String package = '1.0.1';

  /// The H3 C library version string.
  static const String native = '4.4.1';

  /// The H3 C library major version.
  static const int major = 4;

  /// The H3 C library minor version.
  static const int minor = 4;

  /// The H3 C library patch version.
  static const int patch = 1;
}

// Async — on web h3-js is sync, so these just wrap in a future.

/// Async version of [polygonToCells]; wraps in a future on web.
Future<List<H3Index>> polygonToCellsAsync(
  GeoPolygon polygon,
  int resolution,
) async {
  return polygonToCells(polygon, resolution);
}

/// Async version of [gridDisk]; wraps in a future on web.
Future<List<H3Index>> gridDiskAsync(H3Index origin, int k) async {
  return gridDisk(origin, k);
}

/// Async version of [compactCells]; wraps in a future on web.
Future<List<H3Index>> compactCellsAsync(List<H3Index> cells) async {
  return compactCells(cells);
}

/// Async version of [uncompactCells]; wraps in a future on web.
Future<List<H3Index>> uncompactCellsAsync(
  List<H3Index> cells,
  int resolution,
) async {
  return uncompactCells(cells, resolution);
}
