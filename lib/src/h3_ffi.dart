import 'dart:ffi';
import 'dart:isolate';

import 'package:ffi/ffi.dart';

import '_ffi_utils.dart';
import 'generated/h3_bindings.g.dart' as c;
import 'models/cell_boundary.dart';
import 'models/coord_ij.dart';
import 'models/geo_polygon.dart';
import 'models/h3_index.dart';
import 'models/lat_lng.dart';

// Indexing

/// Converts a [latLng] coordinate to the H3 cell index at the given
/// [resolution] (0–15).
H3Index latLngToCell(LatLng latLng, int resolution) {
  return using((Arena arena) {
    final ll = arena<c.LatLng>();
    ll.ref.lat = latLng.lat * degsToRads;
    ll.ref.lng = latLng.lng * degsToRads;
    final out = arena<Uint64>();

    checkH3Error(c.latLngToCell(ll, resolution, out));
    return H3Index.fromInt(out.value);
  });
}

/// Returns the center coordinate of the given H3 [cell].
LatLng cellToLatLng(H3Index cell) {
  return using((Arena arena) {
    final ll = arena<c.LatLng>();
    checkH3Error(c.cellToLatLng(cell.toInt(), ll));
    return LatLng(ll.ref.lat * radsToDeg, ll.ref.lng * radsToDeg);
  });
}

/// Returns the boundary vertices of the given H3 [cell].
CellBoundary cellToBoundary(H3Index cell) {
  return using((Arena arena) {
    final cb = arena<c.CellBoundary>();
    checkH3Error(c.cellToBoundary(cell.toInt(), cb));

    final numVerts = cb.ref.numVerts;
    final verts = <LatLng>[];
    for (var i = 0; i < numVerts; i++) {
      verts.add(
        LatLng(
          cb.ref.verts[i].lat * radsToDeg,
          cb.ref.verts[i].lng * radsToDeg,
        ),
      );
    }
    return CellBoundary(verts);
  });
}

// Inspection

/// Returns the resolution (0–15) of the given H3 index.
int getResolution(H3Index h) => c.getResolution(h.toInt());

/// Returns the base cell number (0–121) of the given H3 index.
int getBaseCellNumber(H3Index h) => c.getBaseCellNumber(h.toInt());

/// Returns whether [h] is a valid H3 cell index.
bool isValidCell(H3Index h) => c.isValidCell(h.toInt()) == 1;

/// Returns whether [h] is any valid H3 index (cell, edge, or vertex).
bool isValidIndex(H3Index h) => c.isValidIndex(h.toInt()) == 1;

/// Returns whether [h] is a pentagon cell.
bool isPentagon(H3Index h) => c.isPentagon(h.toInt()) == 1;

/// Returns whether [h] has Class III resolution orientation.
bool isResClassIII(H3Index h) => c.isResClassIII(h.toInt()) == 1;

/// Returns the icosahedron face(s) that the given cell intersects.
List<int> getIcosahedronFaces(H3Index h) {
  return using((Arena arena) {
    final maxOut = arena<Int>();
    checkH3Error(c.maxFaceCount(h.toInt(), maxOut));
    final maxFaces = maxOut.value;

    final faces = arena<Int>(maxFaces);
    for (var i = 0; i < maxFaces; i++) {
      faces[i] = -1;
    }
    checkH3Error(c.getIcosahedronFaces(h.toInt(), faces));
    return [
      for (var i = 0; i < maxFaces; i++)
        if (faces[i] >= 0) faces[i],
    ];
  });
}

/// Returns whether [edge] is a valid H3 directed edge index.
bool isValidDirectedEdge(H3Index edge) =>
    c.isValidDirectedEdge(edge.toInt()) == 1;

/// Returns whether [vertex] is a valid H3 vertex index.
bool isValidVertex(H3Index vertex) => c.isValidVertex(vertex.toInt()) == 1;

/// Returns the direction digit at the given [resolution] for index [h].
int getIndexDigit(H3Index h, int resolution) {
  return using((Arena arena) {
    final out = arena<Int>();
    checkH3Error(c.getIndexDigit(h.toInt(), resolution, out));
    return out.value;
  });
}

/// Constructs an H3 cell index from [res], [baseCellNumber], and direction
/// [digits].
H3Index constructCell(int res, int baseCellNumber, List<int> digits) {
  return using((Arena arena) {
    final digitsPtr = arena<Int>(digits.length);
    for (var i = 0; i < digits.length; i++) {
      digitsPtr[i] = digits[i];
    }
    final out = arena<Uint64>();
    checkH3Error(c.constructCell(res, baseCellNumber, digitsPtr, out));
    return H3Index.fromInt(out.value);
  });
}

// String conversion

/// Parses a [hex] string into an [H3Index], throwing [H3Exception] on
/// invalid input.
H3Index stringToH3(String hex) {
  return using((Arena arena) {
    final str = hex.toNativeUtf8(allocator: arena);
    final out = arena<Uint64>();
    checkH3Error(c.stringToH3(str.cast<Char>(), out));
    return H3Index.fromInt(out.value);
  });
}

/// Returns the hex string representation of the given H3 index.
String h3ToString(H3Index h) {
  return using((Arena arena) {
    final buf = arena<Char>(17);
    checkH3Error(c.h3ToString(h.toInt(), buf, 17));
    return buf.cast<Utf8>().toDartString();
  });
}

// Traversal

/// Returns all cells within [k] grid steps of [origin] (filled disk).
List<H3Index> gridDisk(H3Index origin, int k) {
  return using((Arena arena) {
    final sizeOut = arena<Int64>();
    checkH3Error(c.maxGridDiskSize(k, sizeOut));
    final maxSize = sizeOut.value;

    final out = arena<Uint64>(maxSize);
    checkH3Error(c.gridDisk(origin.toInt(), k, out));

    return [
      for (var i = 0; i < maxSize; i++)
        if (out[i] != 0) H3Index.fromInt(out[i]),
    ];
  });
}

/// Returns cells within [k] steps of [origin] mapped to their grid distance.
Map<H3Index, int> gridDiskDistances(H3Index origin, int k) {
  return using((Arena arena) {
    final sizeOut = arena<Int64>();
    checkH3Error(c.maxGridDiskSize(k, sizeOut));
    final maxSize = sizeOut.value;

    final cells = arena<Uint64>(maxSize);
    final distances = arena<Int>(maxSize);
    checkH3Error(c.gridDiskDistances(origin.toInt(), k, cells, distances));

    final result = <H3Index, int>{};
    for (var i = 0; i < maxSize; i++) {
      if (cells[i] != 0) {
        result[H3Index.fromInt(cells[i])] = distances[i];
      }
    }
    return result;
  });
}

/// Returns cells exactly [k] grid steps from [origin] (hollow ring).
List<H3Index> gridRing(H3Index origin, int k) {
  return using((Arena arena) {
    final sizeOut = arena<Int64>();
    checkH3Error(c.maxGridRingSize(k, sizeOut));
    final maxSize = sizeOut.value;

    final out = arena<Uint64>(maxSize);
    checkH3Error(c.gridRing(origin.toInt(), k, out));

    return [
      for (var i = 0; i < maxSize; i++)
        if (out[i] != 0) H3Index.fromInt(out[i]),
    ];
  });
}

/// Returns the minimum grid distance between [origin] and [destination].
int gridDistance(H3Index origin, H3Index destination) {
  return using((Arena arena) {
    final out = arena<Int64>();
    checkH3Error(c.gridDistance(origin.toInt(), destination.toInt(), out));
    return out.value;
  });
}

/// Returns the cells along the shortest grid path from [start] to [end].
List<H3Index> gridPathCells(H3Index start, H3Index end) {
  return using((Arena arena) {
    final sizeOut = arena<Int64>();
    checkH3Error(c.gridPathCellsSize(start.toInt(), end.toInt(), sizeOut));
    final size = sizeOut.value;

    final out = arena<Uint64>(size);
    checkH3Error(c.gridPathCells(start.toInt(), end.toInt(), out));

    return [for (var i = 0; i < size; i++) H3Index.fromInt(out[i])];
  });
}

// Hierarchy

/// Returns the parent cell of [cell] at the coarser [parentRes].
H3Index cellToParent(H3Index cell, int parentRes) {
  return using((Arena arena) {
    final out = arena<Uint64>();
    checkH3Error(c.cellToParent(cell.toInt(), parentRes, out));
    return H3Index.fromInt(out.value);
  });
}

/// Returns the children of [cell] at the finer [childRes].
List<H3Index> cellToChildren(H3Index cell, int childRes) {
  return using((Arena arena) {
    final sizeOut = arena<Int64>();
    checkH3Error(c.cellToChildrenSize(cell.toInt(), childRes, sizeOut));
    final size = sizeOut.value;

    final out = arena<Uint64>(size);
    checkH3Error(c.cellToChildren(cell.toInt(), childRes, out));

    return [for (var i = 0; i < size; i++) H3Index.fromInt(out[i])];
  });
}

/// Returns the center child of [cell] at the finer [childRes].
H3Index cellToCenterChild(H3Index cell, int childRes) {
  return using((Arena arena) {
    final out = arena<Uint64>();
    checkH3Error(c.cellToCenterChild(cell.toInt(), childRes, out));
    return H3Index.fromInt(out.value);
  });
}

/// Returns the position of [child] within its parent at [parentRes].
int cellToChildPos(H3Index child, int parentRes) {
  return using((Arena arena) {
    final out = arena<Int64>();
    checkH3Error(c.cellToChildPos(child.toInt(), parentRes, out));
    return out.value;
  });
}

/// Returns the child cell at [childPos] within [parent] at [childRes].
H3Index childPosToCell(int childPos, H3Index parent, int childRes) {
  return using((Arena arena) {
    final out = arena<Uint64>();
    checkH3Error(c.childPosToCell(childPos, parent.toInt(), childRes, out));
    return H3Index.fromInt(out.value);
  });
}

/// Compacts a set of [cells] by replacing complete groups with their parent.
List<H3Index> compactCells(List<H3Index> cells) {
  return using((Arena arena) {
    final h3Set = arena<Uint64>(cells.length);
    for (var i = 0; i < cells.length; i++) {
      h3Set[i] = cells[i].toInt();
    }

    final out = arena<Uint64>(cells.length);
    checkH3Error(c.compactCells(h3Set, out, cells.length));

    return [
      for (var i = 0; i < cells.length; i++)
        if (out[i] != 0) H3Index.fromInt(out[i]),
    ];
  });
}

/// Expands compacted [cells] to the given [resolution].
List<H3Index> uncompactCells(List<H3Index> cells, int resolution) {
  return using((Arena arena) {
    final h3Set = arena<Uint64>(cells.length);
    for (var i = 0; i < cells.length; i++) {
      h3Set[i] = cells[i].toInt();
    }

    final sizeOut = arena<Int64>();
    checkH3Error(
      c.uncompactCellsSize(h3Set, cells.length, resolution, sizeOut),
    );
    final size = sizeOut.value;

    final out = arena<Uint64>(size);
    checkH3Error(c.uncompactCells(h3Set, cells.length, out, size, resolution));

    return [
      for (var i = 0; i < size; i++)
        if (out[i] != 0) H3Index.fromInt(out[i]),
    ];
  });
}

// Directed edges

/// Returns whether [origin] and [destination] share an edge.
bool areNeighborCells(H3Index origin, H3Index destination) {
  return using((Arena arena) {
    final out = arena<Int>();
    checkH3Error(c.areNeighborCells(origin.toInt(), destination.toInt(), out));
    return out.value == 1;
  });
}

/// Returns the directed edge from [origin] to [destination].
H3Index cellsToDirectedEdge(H3Index origin, H3Index destination) {
  return using((Arena arena) {
    final out = arena<Uint64>();
    checkH3Error(
      c.cellsToDirectedEdge(origin.toInt(), destination.toInt(), out),
    );
    return H3Index.fromInt(out.value);
  });
}

/// Returns the origin cell of the directed [edge].
H3Index getDirectedEdgeOrigin(H3Index edge) {
  return using((Arena arena) {
    final out = arena<Uint64>();
    checkH3Error(c.getDirectedEdgeOrigin(edge.toInt(), out));
    return H3Index.fromInt(out.value);
  });
}

/// Returns the destination cell of the directed [edge].
H3Index getDirectedEdgeDestination(H3Index edge) {
  return using((Arena arena) {
    final out = arena<Uint64>();
    checkH3Error(c.getDirectedEdgeDestination(edge.toInt(), out));
    return H3Index.fromInt(out.value);
  });
}

/// Returns the origin and destination cells of the directed [edge].
List<H3Index> directedEdgeToCells(H3Index edge) {
  return using((Arena arena) {
    final out = arena<Uint64>(2);
    checkH3Error(c.directedEdgeToCells(edge.toInt(), out));
    return [H3Index.fromInt(out[0]), H3Index.fromInt(out[1])];
  });
}

/// Returns all directed edges originating from [origin].
List<H3Index> originToDirectedEdges(H3Index origin) {
  return using((Arena arena) {
    final out = arena<Uint64>(6);
    checkH3Error(c.originToDirectedEdges(origin.toInt(), out));
    return [
      for (var i = 0; i < 6; i++)
        if (out[i] != 0) H3Index.fromInt(out[i]),
    ];
  });
}

/// Returns the boundary vertices of the directed [edge].
CellBoundary directedEdgeToBoundary(H3Index edge) {
  return using((Arena arena) {
    final cb = arena<c.CellBoundary>();
    checkH3Error(c.directedEdgeToBoundary(edge.toInt(), cb));

    final numVerts = cb.ref.numVerts;
    final verts = <LatLng>[];
    for (var i = 0; i < numVerts; i++) {
      verts.add(
        LatLng(
          cb.ref.verts[i].lat * radsToDeg,
          cb.ref.verts[i].lng * radsToDeg,
        ),
      );
    }
    return CellBoundary(verts);
  });
}

// Vertices

/// Returns the vertex at index [vertexNum] (0–5) of the [cell].
H3Index cellToVertex(H3Index cell, int vertexNum) {
  return using((Arena arena) {
    final out = arena<Uint64>();
    checkH3Error(c.cellToVertex(cell.toInt(), vertexNum, out));
    return H3Index.fromInt(out.value);
  });
}

/// Returns all vertices of the given [cell].
List<H3Index> cellToVertexes(H3Index cell) {
  return using((Arena arena) {
    final out = arena<Uint64>(6);
    checkH3Error(c.cellToVertexes(cell.toInt(), out));
    return [
      for (var i = 0; i < 6; i++)
        if (out[i] != 0) H3Index.fromInt(out[i]),
    ];
  });
}

/// Returns the coordinates of the given [vertex].
LatLng vertexToLatLng(H3Index vertex) {
  return using((Arena arena) {
    final ll = arena<c.LatLng>();
    checkH3Error(c.vertexToLatLng(vertex.toInt(), ll));
    return LatLng(ll.ref.lat * radsToDeg, ll.ref.lng * radsToDeg);
  });
}

// Measurements

/// Returns the great-circle distance between [a] and [b] in kilometers.
double greatCircleDistanceKm(LatLng a, LatLng b) {
  return using((Arena arena) {
    final aPtr = arena<c.LatLng>();
    aPtr.ref.lat = a.lat * degsToRads;
    aPtr.ref.lng = a.lng * degsToRads;
    final bPtr = arena<c.LatLng>();
    bPtr.ref.lat = b.lat * degsToRads;
    bPtr.ref.lng = b.lng * degsToRads;
    return c.greatCircleDistanceKm(aPtr, bPtr);
  });
}

/// Returns the great-circle distance between [a] and [b] in meters.
double greatCircleDistanceM(LatLng a, LatLng b) {
  return using((Arena arena) {
    final aPtr = arena<c.LatLng>();
    aPtr.ref.lat = a.lat * degsToRads;
    aPtr.ref.lng = a.lng * degsToRads;
    final bPtr = arena<c.LatLng>();
    bPtr.ref.lat = b.lat * degsToRads;
    bPtr.ref.lng = b.lng * degsToRads;
    return c.greatCircleDistanceM(aPtr, bPtr);
  });
}

/// Returns the exact area of the [cell] in km².
double cellAreaKm2(H3Index cell) {
  return using((Arena arena) {
    final out = arena<Double>();
    checkH3Error(c.cellAreaKm2(cell.toInt(), out));
    return out.value;
  });
}

/// Returns the exact area of the [cell] in m².
double cellAreaM2(H3Index cell) {
  return using((Arena arena) {
    final out = arena<Double>();
    checkH3Error(c.cellAreaM2(cell.toInt(), out));
    return out.value;
  });
}

/// Returns the exact length of the directed [edge] in kilometers.
double edgeLengthKm(H3Index edge) {
  return using((Arena arena) {
    final out = arena<Double>();
    checkH3Error(c.edgeLengthKm(edge.toInt(), out));
    return out.value;
  });
}

/// Returns the exact length of the directed [edge] in meters.
double edgeLengthM(H3Index edge) {
  return using((Arena arena) {
    final out = arena<Double>();
    checkH3Error(c.edgeLengthM(edge.toInt(), out));
    return out.value;
  });
}

/// Returns the average hexagon area in km² at the given [resolution].
double getHexagonAreaAvgKm2(int resolution) {
  return using((Arena arena) {
    final out = arena<Double>();
    checkH3Error(c.getHexagonAreaAvgKm2(resolution, out));
    return out.value;
  });
}

/// Returns the average hexagon area in m² at the given [resolution].
double getHexagonAreaAvgM2(int resolution) {
  return using((Arena arena) {
    final out = arena<Double>();
    checkH3Error(c.getHexagonAreaAvgM2(resolution, out));
    return out.value;
  });
}

/// Returns the average hexagon edge length in km at the given [resolution].
double getHexagonEdgeLengthAvgKm(int resolution) {
  return using((Arena arena) {
    final out = arena<Double>();
    checkH3Error(c.getHexagonEdgeLengthAvgKm(resolution, out));
    return out.value;
  });
}

/// Returns the average hexagon edge length in meters at the given
/// [resolution].
double getHexagonEdgeLengthAvgM(int resolution) {
  return using((Arena arena) {
    final out = arena<Double>();
    checkH3Error(c.getHexagonEdgeLengthAvgM(resolution, out));
    return out.value;
  });
}

/// Returns the total number of cells at the given [resolution].
int getNumCells(int resolution) {
  return using((Arena arena) {
    final out = arena<Int64>();
    checkH3Error(c.getNumCells(resolution, out));
    return out.value;
  });
}

// Coordinate systems

/// Converts [cell] to local IJ coordinates relative to [origin].
CoordIJ cellToLocalIj(H3Index origin, H3Index cell) {
  return using((Arena arena) {
    final ij = arena<c.CoordIJ>();
    checkH3Error(c.cellToLocalIj(origin.toInt(), cell.toInt(), 0, ij));
    return CoordIJ(ij.ref.i, ij.ref.j);
  });
}

/// Converts local [ij] coordinates relative to [origin] back to an H3 cell.
H3Index localIjToCell(H3Index origin, CoordIJ ij) {
  return using((Arena arena) {
    final ijPtr = arena<c.CoordIJ>();
    ijPtr.ref.i = ij.i;
    ijPtr.ref.j = ij.j;
    final out = arena<Uint64>();
    checkH3Error(c.localIjToCell(origin.toInt(), ijPtr, 0, out));
    return H3Index.fromInt(out.value);
  });
}

// Regions

/// Returns all cells whose centers are within the [polygon] at [resolution].
List<H3Index> polygonToCells(GeoPolygon polygon, int resolution) {
  return using((Arena arena) {
    final gp = arena<c.GeoPolygon>();

    final extVerts = arena<c.LatLng>(polygon.exterior.length);
    for (var i = 0; i < polygon.exterior.length; i++) {
      extVerts[i].lat = polygon.exterior[i].lat * degsToRads;
      extVerts[i].lng = polygon.exterior[i].lng * degsToRads;
    }
    gp.ref.geoloop.numVerts = polygon.exterior.length;
    gp.ref.geoloop.verts = extVerts;

    gp.ref.numHoles = polygon.holes.length;
    if (polygon.holes.isNotEmpty) {
      final holesPtr = arena<c.GeoLoop>(polygon.holes.length);
      for (var h = 0; h < polygon.holes.length; h++) {
        final hole = polygon.holes[h];
        final holeVerts = arena<c.LatLng>(hole.length);
        for (var i = 0; i < hole.length; i++) {
          holeVerts[i].lat = hole[i].lat * degsToRads;
          holeVerts[i].lng = hole[i].lng * degsToRads;
        }
        holesPtr[h].numVerts = hole.length;
        holesPtr[h].verts = holeVerts;
      }
      gp.ref.holes = holesPtr;
    } else {
      gp.ref.holes = nullptr;
    }

    final sizeOut = arena<Int64>();
    checkH3Error(c.maxPolygonToCellsSize(gp, resolution, 0, sizeOut));
    final maxSize = sizeOut.value;

    final out = arena<Uint64>(maxSize);
    checkH3Error(c.polygonToCells(gp, resolution, 0, out));

    return [
      for (var i = 0; i < maxSize; i++)
        if (out[i] != 0) H3Index.fromInt(out[i]),
    ];
  });
}

/// Returns cells within the [polygon] using the specified containment [mode].
List<H3Index> polygonToCellsExperimental(
  GeoPolygon polygon,
  int resolution, {
  ContainmentMode mode = ContainmentMode.center,
}) {
  return using((Arena arena) {
    final gp = arena<c.GeoPolygon>();

    final extVerts = arena<c.LatLng>(polygon.exterior.length);
    for (var i = 0; i < polygon.exterior.length; i++) {
      extVerts[i].lat = polygon.exterior[i].lat * degsToRads;
      extVerts[i].lng = polygon.exterior[i].lng * degsToRads;
    }
    gp.ref.geoloop.numVerts = polygon.exterior.length;
    gp.ref.geoloop.verts = extVerts;

    gp.ref.numHoles = polygon.holes.length;
    if (polygon.holes.isNotEmpty) {
      final holesPtr = arena<c.GeoLoop>(polygon.holes.length);
      for (var h = 0; h < polygon.holes.length; h++) {
        final hole = polygon.holes[h];
        final holeVerts = arena<c.LatLng>(hole.length);
        for (var i = 0; i < hole.length; i++) {
          holeVerts[i].lat = hole[i].lat * degsToRads;
          holeVerts[i].lng = hole[i].lng * degsToRads;
        }
        holesPtr[h].numVerts = hole.length;
        holesPtr[h].verts = holeVerts;
      }
      gp.ref.holes = holesPtr;
    } else {
      gp.ref.holes = nullptr;
    }

    final flags = mode.index;
    final sizeOut = arena<Int64>();
    checkH3Error(
      c.maxPolygonToCellsSizeExperimental(gp, resolution, flags, sizeOut),
    );
    final maxSize = sizeOut.value;

    final out = arena<Uint64>(maxSize);
    checkH3Error(
      c.polygonToCellsExperimental(gp, resolution, flags, maxSize, out),
    );

    return [
      for (var i = 0; i < maxSize; i++)
        if (out[i] != 0) H3Index.fromInt(out[i]),
    ];
  });
}

/// Returns the outlines of a set of [cells] as a GeoJSON-style
/// multi-polygon.
List<List<List<LatLng>>> cellsToMultiPolygon(List<H3Index> cells) {
  return using((Arena arena) {
    final h3Set = arena<Uint64>(cells.length);
    for (var i = 0; i < cells.length; i++) {
      h3Set[i] = cells[i].toInt();
    }

    final linkedPoly = arena<c.LinkedGeoPolygon>();
    checkH3Error(c.cellsToLinkedMultiPolygon(h3Set, cells.length, linkedPoly));

    try {
      return _extractMultiPolygon(linkedPoly);
    } finally {
      c.destroyLinkedMultiPolygon(linkedPoly);
    }
  });
}

List<List<List<LatLng>>> _extractMultiPolygon(
  Pointer<c.LinkedGeoPolygon> linkedPoly,
) {
  final result = <List<List<LatLng>>>[];
  var polyPtr = linkedPoly;

  while (polyPtr != nullptr) {
    final polygon = <List<LatLng>>[];
    var loopPtr = polyPtr.ref.first;

    while (loopPtr != nullptr) {
      final ring = <LatLng>[];
      var llPtr = loopPtr.ref.first;

      while (llPtr != nullptr) {
        ring.add(
          LatLng(
            llPtr.ref.vertex.lat * radsToDeg,
            llPtr.ref.vertex.lng * radsToDeg,
          ),
        );
        llPtr = llPtr.ref.next;
      }
      polygon.add(ring);
      loopPtr = loopPtr.ref.next;
    }
    result.add(polygon);
    polyPtr = polyPtr.ref.next;
  }

  return result;
}

// Utilities

/// Returns the number of resolution-0 cells (always 122).
int res0CellCount() => c.res0CellCount();

/// Returns all 122 resolution-0 cells.
List<H3Index> getRes0Cells() {
  return using((Arena arena) {
    final out = arena<Uint64>(122);
    checkH3Error(c.getRes0Cells(out));
    return [for (var i = 0; i < 122; i++) H3Index.fromInt(out[i])];
  });
}

/// Returns the number of pentagons per resolution (always 12).
int pentagonCount() => c.pentagonCount();

/// Returns all 12 pentagon cells at the given [resolution].
List<H3Index> getPentagons(int resolution) {
  return using((Arena arena) {
    final out = arena<Uint64>(12);
    checkH3Error(c.getPentagons(resolution, out));
    return [for (var i = 0; i < 12; i++) H3Index.fromInt(out[i])];
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

// Async — runs on isolate to keep the UI thread free.

/// Async version of [polygonToCells]; runs on an isolate to avoid blocking
/// the UI thread.
Future<List<H3Index>> polygonToCellsAsync(
  GeoPolygon polygon,
  int resolution,
) async {
  return Isolate.run(() => polygonToCells(polygon, resolution));
}

/// Async version of [gridDisk]; runs on an isolate to avoid blocking the
/// UI thread.
Future<List<H3Index>> gridDiskAsync(H3Index origin, int k) async {
  return Isolate.run(() => gridDisk(origin, k));
}

/// Async version of [compactCells]; runs on an isolate to avoid blocking
/// the UI thread.
Future<List<H3Index>> compactCellsAsync(List<H3Index> cells) async {
  return Isolate.run(() => compactCells(cells));
}

/// Async version of [uncompactCells]; runs on an isolate to avoid blocking
/// the UI thread.
Future<List<H3Index>> uncompactCellsAsync(
  List<H3Index> cells,
  int resolution,
) async {
  return Isolate.run(() => uncompactCells(cells, resolution));
}
