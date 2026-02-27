// Stub implementation — used when neither dart:ffi nor dart:js_interop
// is available (e.g., compile-time analysis on unsupported platforms).
// Every function throws UnsupportedError at runtime.

import 'models/cell_boundary.dart';
import 'models/coord_ij.dart';
import 'models/geo_polygon.dart';
import 'models/h3_index.dart';
import 'models/lat_lng.dart';

Never _unsupported() =>
    throw UnsupportedError('h3_core is not supported on this platform');

// Indexing

/// Converts a [latLng] coordinate to the H3 cell index at the given
/// [resolution] (0–15).
H3Index latLngToCell(LatLng latLng, int resolution) => _unsupported();

/// Returns the center coordinate of the given H3 [cell].
LatLng cellToLatLng(H3Index cell) => _unsupported();

/// Returns the boundary vertices of the given H3 [cell].
CellBoundary cellToBoundary(H3Index cell) => _unsupported();

// Inspection

/// Returns the resolution (0–15) of the given H3 index.
int getResolution(H3Index h) => _unsupported();

/// Returns the base cell number (0–121) of the given H3 index.
int getBaseCellNumber(H3Index h) => _unsupported();

/// Returns whether [h] is a valid H3 cell index.
bool isValidCell(H3Index h) => _unsupported();

/// Returns whether [h] is any valid H3 index (cell, edge, or vertex).
bool isValidIndex(H3Index h) => _unsupported();

/// Returns whether [h] is a pentagon cell.
bool isPentagon(H3Index h) => _unsupported();

/// Returns whether [h] has Class III resolution orientation.
bool isResClassIII(H3Index h) => _unsupported();

/// Returns the icosahedron face(s) that the given cell intersects.
List<int> getIcosahedronFaces(H3Index h) => _unsupported();

/// Returns whether [edge] is a valid H3 directed edge index.
bool isValidDirectedEdge(H3Index edge) => _unsupported();

/// Returns whether [vertex] is a valid H3 vertex index.
bool isValidVertex(H3Index vertex) => _unsupported();

/// Returns the direction digit at the given [resolution] for index [h].
int getIndexDigit(H3Index h, int resolution) => _unsupported();

/// Constructs an H3 cell index from [res], [baseCellNumber], and direction
/// [digits].
H3Index constructCell(int res, int baseCellNumber, List<int> digits) =>
    _unsupported();

// String conversion

/// Parses a [hex] string into an [H3Index], throwing [H3Exception] on
/// invalid input.
H3Index stringToH3(String hex) => _unsupported();

/// Returns the hex string representation of the given H3 index.
String h3ToString(H3Index h) => _unsupported();

// Traversal

/// Returns all cells within [k] grid steps of [origin] (filled disk).
List<H3Index> gridDisk(H3Index origin, int k) => _unsupported();

/// Returns cells within [k] steps of [origin] mapped to their grid distance.
Map<H3Index, int> gridDiskDistances(H3Index origin, int k) => _unsupported();

/// Returns cells exactly [k] grid steps from [origin] (hollow ring).
List<H3Index> gridRing(H3Index origin, int k) => _unsupported();

/// Returns the minimum grid distance between [origin] and [destination].
int gridDistance(H3Index origin, H3Index destination) => _unsupported();

/// Returns the cells along the shortest grid path from [start] to [end].
List<H3Index> gridPathCells(H3Index start, H3Index end) => _unsupported();

// Hierarchy

/// Returns the parent cell of [cell] at the coarser [parentRes].
H3Index cellToParent(H3Index cell, int parentRes) => _unsupported();

/// Returns the children of [cell] at the finer [childRes].
List<H3Index> cellToChildren(H3Index cell, int childRes) => _unsupported();

/// Returns the center child of [cell] at the finer [childRes].
H3Index cellToCenterChild(H3Index cell, int childRes) => _unsupported();

/// Returns the position of [child] within its parent at [parentRes].
int cellToChildPos(H3Index child, int parentRes) => _unsupported();

/// Returns the child cell at [childPos] within [parent] at [childRes].
H3Index childPosToCell(int childPos, H3Index parent, int childRes) =>
    _unsupported();

/// Compacts a set of [cells] by replacing complete groups with their parent.
List<H3Index> compactCells(List<H3Index> cells) => _unsupported();

/// Expands compacted [cells] to the given [resolution].
List<H3Index> uncompactCells(List<H3Index> cells, int resolution) =>
    _unsupported();

// Directed edges

/// Returns whether [origin] and [destination] share an edge.
bool areNeighborCells(H3Index origin, H3Index destination) => _unsupported();

/// Returns the directed edge from [origin] to [destination].
H3Index cellsToDirectedEdge(H3Index origin, H3Index destination) =>
    _unsupported();

/// Returns the origin cell of the directed [edge].
H3Index getDirectedEdgeOrigin(H3Index edge) => _unsupported();

/// Returns the destination cell of the directed [edge].
H3Index getDirectedEdgeDestination(H3Index edge) => _unsupported();

/// Returns the origin and destination cells of the directed [edge].
List<H3Index> directedEdgeToCells(H3Index edge) => _unsupported();

/// Returns all directed edges originating from [origin].
List<H3Index> originToDirectedEdges(H3Index origin) => _unsupported();

/// Returns the boundary vertices of the directed [edge].
CellBoundary directedEdgeToBoundary(H3Index edge) => _unsupported();

// Vertices

/// Returns the vertex at index [vertexNum] (0–5) of the [cell].
H3Index cellToVertex(H3Index cell, int vertexNum) => _unsupported();

/// Returns all vertices of the given [cell].
List<H3Index> cellToVertexes(H3Index cell) => _unsupported();

/// Returns the coordinates of the given [vertex].
LatLng vertexToLatLng(H3Index vertex) => _unsupported();

// Measurements

/// Returns the great-circle distance between [a] and [b] in kilometers.
double greatCircleDistanceKm(LatLng a, LatLng b) => _unsupported();

/// Returns the great-circle distance between [a] and [b] in meters.
double greatCircleDistanceM(LatLng a, LatLng b) => _unsupported();

/// Returns the exact area of the [cell] in km².
double cellAreaKm2(H3Index cell) => _unsupported();

/// Returns the exact area of the [cell] in m².
double cellAreaM2(H3Index cell) => _unsupported();

/// Returns the exact length of the directed [edge] in kilometers.
double edgeLengthKm(H3Index edge) => _unsupported();

/// Returns the exact length of the directed [edge] in meters.
double edgeLengthM(H3Index edge) => _unsupported();

/// Returns the average hexagon area in km² at the given [resolution].
double getHexagonAreaAvgKm2(int resolution) => _unsupported();

/// Returns the average hexagon area in m² at the given [resolution].
double getHexagonAreaAvgM2(int resolution) => _unsupported();

/// Returns the average hexagon edge length in km at the given [resolution].
double getHexagonEdgeLengthAvgKm(int resolution) => _unsupported();

/// Returns the average hexagon edge length in meters at the given
/// [resolution].
double getHexagonEdgeLengthAvgM(int resolution) => _unsupported();

/// Returns the total number of cells at the given [resolution].
int getNumCells(int resolution) => _unsupported();

// Coordinate systems

/// Converts [cell] to local IJ coordinates relative to [origin].
CoordIJ cellToLocalIj(H3Index origin, H3Index cell) => _unsupported();

/// Converts local [ij] coordinates relative to [origin] back to an H3 cell.
H3Index localIjToCell(H3Index origin, CoordIJ ij) => _unsupported();

// Regions

/// Returns all cells whose centers are within the [polygon] at [resolution].
List<H3Index> polygonToCells(GeoPolygon polygon, int resolution) =>
    _unsupported();

/// Returns cells within the [polygon] using the specified containment [mode].
List<H3Index> polygonToCellsExperimental(
  GeoPolygon polygon,
  int resolution, {
  ContainmentMode mode = ContainmentMode.center,
}) => _unsupported();

/// Returns the outlines of a set of [cells] as a GeoJSON-style
/// multi-polygon.
List<List<List<LatLng>>> cellsToMultiPolygon(List<H3Index> cells) =>
    _unsupported();

// Utilities

/// Returns the number of resolution-0 cells (always 122).
int res0CellCount() => _unsupported();

/// Returns all 122 resolution-0 cells.
List<H3Index> getRes0Cells() => _unsupported();

/// Returns the number of pentagons per resolution (always 12).
int pentagonCount() => _unsupported();

/// Returns all 12 pentagon cells at the given [resolution].
List<H3Index> getPentagons(int resolution) => _unsupported();

// Version

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

// Async wrappers

/// Async version of [polygonToCells]; runs on an isolate on native platforms.
Future<List<H3Index>> polygonToCellsAsync(GeoPolygon polygon, int resolution) =>
    _unsupported();

/// Async version of [gridDisk]; runs on an isolate on native platforms.
Future<List<H3Index>> gridDiskAsync(H3Index origin, int k) => _unsupported();

/// Async version of [compactCells]; runs on an isolate on native platforms.
Future<List<H3Index>> compactCellsAsync(List<H3Index> cells) => _unsupported();

/// Async version of [uncompactCells]; runs on an isolate on native platforms.
Future<List<H3Index>> uncompactCellsAsync(
  List<H3Index> cells,
  int resolution,
) => _unsupported();
