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

H3Index latLngToCell(LatLng latLng, int resolution) => _unsupported();
LatLng cellToLatLng(H3Index cell) => _unsupported();
CellBoundary cellToBoundary(H3Index cell) => _unsupported();

// Inspection

int getResolution(H3Index h) => _unsupported();
int getBaseCellNumber(H3Index h) => _unsupported();
bool isValidCell(H3Index h) => _unsupported();
bool isValidIndex(H3Index h) => _unsupported();
bool isPentagon(H3Index h) => _unsupported();
bool isResClassIII(H3Index h) => _unsupported();
List<int> getIcosahedronFaces(H3Index h) => _unsupported();
bool isValidDirectedEdge(H3Index edge) => _unsupported();
bool isValidVertex(H3Index vertex) => _unsupported();
int getIndexDigit(H3Index h, int resolution) => _unsupported();
H3Index constructCell(int res, int baseCellNumber, List<int> digits) =>
    _unsupported();

// String conversion

H3Index stringToH3(String hex) => _unsupported();
String h3ToString(H3Index h) => _unsupported();

// Traversal

List<H3Index> gridDisk(H3Index origin, int k) => _unsupported();
Map<H3Index, int> gridDiskDistances(H3Index origin, int k) => _unsupported();
List<H3Index> gridRing(H3Index origin, int k) => _unsupported();
int gridDistance(H3Index origin, H3Index destination) => _unsupported();
List<H3Index> gridPathCells(H3Index start, H3Index end) => _unsupported();

// Hierarchy

H3Index cellToParent(H3Index cell, int parentRes) => _unsupported();
List<H3Index> cellToChildren(H3Index cell, int childRes) => _unsupported();
H3Index cellToCenterChild(H3Index cell, int childRes) => _unsupported();
int cellToChildPos(H3Index child, int parentRes) => _unsupported();
H3Index childPosToCell(int childPos, H3Index parent, int childRes) =>
    _unsupported();
List<H3Index> compactCells(List<H3Index> cells) => _unsupported();
List<H3Index> uncompactCells(List<H3Index> cells, int resolution) =>
    _unsupported();

// Directed edges

bool areNeighborCells(H3Index origin, H3Index destination) => _unsupported();
H3Index cellsToDirectedEdge(H3Index origin, H3Index destination) =>
    _unsupported();
H3Index getDirectedEdgeOrigin(H3Index edge) => _unsupported();
H3Index getDirectedEdgeDestination(H3Index edge) => _unsupported();
List<H3Index> directedEdgeToCells(H3Index edge) => _unsupported();
List<H3Index> originToDirectedEdges(H3Index origin) => _unsupported();
CellBoundary directedEdgeToBoundary(H3Index edge) => _unsupported();

// Vertices

H3Index cellToVertex(H3Index cell, int vertexNum) => _unsupported();
List<H3Index> cellToVertexes(H3Index cell) => _unsupported();
LatLng vertexToLatLng(H3Index vertex) => _unsupported();

// Measurements

double greatCircleDistanceKm(LatLng a, LatLng b) => _unsupported();
double greatCircleDistanceM(LatLng a, LatLng b) => _unsupported();
double cellAreaKm2(H3Index cell) => _unsupported();
double cellAreaM2(H3Index cell) => _unsupported();
double edgeLengthKm(H3Index edge) => _unsupported();
double edgeLengthM(H3Index edge) => _unsupported();
double getHexagonAreaAvgKm2(int resolution) => _unsupported();
double getHexagonAreaAvgM2(int resolution) => _unsupported();
double getHexagonEdgeLengthAvgKm(int resolution) => _unsupported();
double getHexagonEdgeLengthAvgM(int resolution) => _unsupported();
int getNumCells(int resolution) => _unsupported();

// Coordinate systems

CoordIJ cellToLocalIj(H3Index origin, H3Index cell) => _unsupported();
H3Index localIjToCell(H3Index origin, CoordIJ ij) => _unsupported();

// Regions

List<H3Index> polygonToCells(GeoPolygon polygon, int resolution) =>
    _unsupported();
List<H3Index> polygonToCellsExperimental(
  GeoPolygon polygon,
  int resolution, {
  ContainmentMode mode = ContainmentMode.center,
}) => _unsupported();
List<List<List<LatLng>>> cellsToMultiPolygon(List<H3Index> cells) =>
    _unsupported();

// Utilities

int res0CellCount() => _unsupported();
List<H3Index> getRes0Cells() => _unsupported();
int pentagonCount() => _unsupported();
List<H3Index> getPentagons(int resolution) => _unsupported();

// Version

abstract final class H3Version {
  static const String package = '1.0.1';
  static const String native = '4.4.1';
  static const int major = 4;
  static const int minor = 4;
  static const int patch = 1;
}

// Async wrappers

Future<List<H3Index>> polygonToCellsAsync(GeoPolygon polygon, int resolution) =>
    _unsupported();

Future<List<H3Index>> gridDiskAsync(H3Index origin, int k) => _unsupported();
Future<List<H3Index>> compactCellsAsync(List<H3Index> cells) => _unsupported();
Future<List<H3Index>> uncompactCellsAsync(
  List<H3Index> cells,
  int resolution,
) => _unsupported();
