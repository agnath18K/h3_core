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

LatLng cellToLatLng(H3Index cell) {
  return using((Arena arena) {
    final ll = arena<c.LatLng>();
    checkH3Error(c.cellToLatLng(cell.toInt(), ll));
    return LatLng(ll.ref.lat * radsToDeg, ll.ref.lng * radsToDeg);
  });
}

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

int getResolution(H3Index h) => c.getResolution(h.toInt());

int getBaseCellNumber(H3Index h) => c.getBaseCellNumber(h.toInt());

bool isValidCell(H3Index h) => c.isValidCell(h.toInt()) == 1;

bool isValidIndex(H3Index h) => c.isValidIndex(h.toInt()) == 1;

bool isPentagon(H3Index h) => c.isPentagon(h.toInt()) == 1;

bool isResClassIII(H3Index h) => c.isResClassIII(h.toInt()) == 1;

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

bool isValidDirectedEdge(H3Index edge) =>
    c.isValidDirectedEdge(edge.toInt()) == 1;

bool isValidVertex(H3Index vertex) => c.isValidVertex(vertex.toInt()) == 1;

int getIndexDigit(H3Index h, int resolution) {
  return using((Arena arena) {
    final out = arena<Int>();
    checkH3Error(c.getIndexDigit(h.toInt(), resolution, out));
    return out.value;
  });
}

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

H3Index stringToH3(String hex) {
  return using((Arena arena) {
    final str = hex.toNativeUtf8(allocator: arena);
    final out = arena<Uint64>();
    checkH3Error(c.stringToH3(str.cast<Char>(), out));
    return H3Index.fromInt(out.value);
  });
}

String h3ToString(H3Index h) {
  return using((Arena arena) {
    final buf = arena<Char>(17);
    checkH3Error(c.h3ToString(h.toInt(), buf, 17));
    return buf.cast<Utf8>().toDartString();
  });
}

// Traversal

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

int gridDistance(H3Index origin, H3Index destination) {
  return using((Arena arena) {
    final out = arena<Int64>();
    checkH3Error(c.gridDistance(origin.toInt(), destination.toInt(), out));
    return out.value;
  });
}

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

H3Index cellToParent(H3Index cell, int parentRes) {
  return using((Arena arena) {
    final out = arena<Uint64>();
    checkH3Error(c.cellToParent(cell.toInt(), parentRes, out));
    return H3Index.fromInt(out.value);
  });
}

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

H3Index cellToCenterChild(H3Index cell, int childRes) {
  return using((Arena arena) {
    final out = arena<Uint64>();
    checkH3Error(c.cellToCenterChild(cell.toInt(), childRes, out));
    return H3Index.fromInt(out.value);
  });
}

int cellToChildPos(H3Index child, int parentRes) {
  return using((Arena arena) {
    final out = arena<Int64>();
    checkH3Error(c.cellToChildPos(child.toInt(), parentRes, out));
    return out.value;
  });
}

H3Index childPosToCell(int childPos, H3Index parent, int childRes) {
  return using((Arena arena) {
    final out = arena<Uint64>();
    checkH3Error(c.childPosToCell(childPos, parent.toInt(), childRes, out));
    return H3Index.fromInt(out.value);
  });
}

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

bool areNeighborCells(H3Index origin, H3Index destination) {
  return using((Arena arena) {
    final out = arena<Int>();
    checkH3Error(c.areNeighborCells(origin.toInt(), destination.toInt(), out));
    return out.value == 1;
  });
}

H3Index cellsToDirectedEdge(H3Index origin, H3Index destination) {
  return using((Arena arena) {
    final out = arena<Uint64>();
    checkH3Error(
      c.cellsToDirectedEdge(origin.toInt(), destination.toInt(), out),
    );
    return H3Index.fromInt(out.value);
  });
}

H3Index getDirectedEdgeOrigin(H3Index edge) {
  return using((Arena arena) {
    final out = arena<Uint64>();
    checkH3Error(c.getDirectedEdgeOrigin(edge.toInt(), out));
    return H3Index.fromInt(out.value);
  });
}

H3Index getDirectedEdgeDestination(H3Index edge) {
  return using((Arena arena) {
    final out = arena<Uint64>();
    checkH3Error(c.getDirectedEdgeDestination(edge.toInt(), out));
    return H3Index.fromInt(out.value);
  });
}

List<H3Index> directedEdgeToCells(H3Index edge) {
  return using((Arena arena) {
    final out = arena<Uint64>(2);
    checkH3Error(c.directedEdgeToCells(edge.toInt(), out));
    return [H3Index.fromInt(out[0]), H3Index.fromInt(out[1])];
  });
}

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

H3Index cellToVertex(H3Index cell, int vertexNum) {
  return using((Arena arena) {
    final out = arena<Uint64>();
    checkH3Error(c.cellToVertex(cell.toInt(), vertexNum, out));
    return H3Index.fromInt(out.value);
  });
}

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

LatLng vertexToLatLng(H3Index vertex) {
  return using((Arena arena) {
    final ll = arena<c.LatLng>();
    checkH3Error(c.vertexToLatLng(vertex.toInt(), ll));
    return LatLng(ll.ref.lat * radsToDeg, ll.ref.lng * radsToDeg);
  });
}

// Measurements

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

double cellAreaKm2(H3Index cell) {
  return using((Arena arena) {
    final out = arena<Double>();
    checkH3Error(c.cellAreaKm2(cell.toInt(), out));
    return out.value;
  });
}

double cellAreaM2(H3Index cell) {
  return using((Arena arena) {
    final out = arena<Double>();
    checkH3Error(c.cellAreaM2(cell.toInt(), out));
    return out.value;
  });
}

double edgeLengthKm(H3Index edge) {
  return using((Arena arena) {
    final out = arena<Double>();
    checkH3Error(c.edgeLengthKm(edge.toInt(), out));
    return out.value;
  });
}

double edgeLengthM(H3Index edge) {
  return using((Arena arena) {
    final out = arena<Double>();
    checkH3Error(c.edgeLengthM(edge.toInt(), out));
    return out.value;
  });
}

double getHexagonAreaAvgKm2(int resolution) {
  return using((Arena arena) {
    final out = arena<Double>();
    checkH3Error(c.getHexagonAreaAvgKm2(resolution, out));
    return out.value;
  });
}

double getHexagonAreaAvgM2(int resolution) {
  return using((Arena arena) {
    final out = arena<Double>();
    checkH3Error(c.getHexagonAreaAvgM2(resolution, out));
    return out.value;
  });
}

double getHexagonEdgeLengthAvgKm(int resolution) {
  return using((Arena arena) {
    final out = arena<Double>();
    checkH3Error(c.getHexagonEdgeLengthAvgKm(resolution, out));
    return out.value;
  });
}

double getHexagonEdgeLengthAvgM(int resolution) {
  return using((Arena arena) {
    final out = arena<Double>();
    checkH3Error(c.getHexagonEdgeLengthAvgM(resolution, out));
    return out.value;
  });
}

int getNumCells(int resolution) {
  return using((Arena arena) {
    final out = arena<Int64>();
    checkH3Error(c.getNumCells(resolution, out));
    return out.value;
  });
}

// Coordinate systems

CoordIJ cellToLocalIj(H3Index origin, H3Index cell) {
  return using((Arena arena) {
    final ij = arena<c.CoordIJ>();
    checkH3Error(c.cellToLocalIj(origin.toInt(), cell.toInt(), 0, ij));
    return CoordIJ(ij.ref.i, ij.ref.j);
  });
}

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

int res0CellCount() => c.res0CellCount();

List<H3Index> getRes0Cells() {
  return using((Arena arena) {
    final out = arena<Uint64>(122);
    checkH3Error(c.getRes0Cells(out));
    return [for (var i = 0; i < 122; i++) H3Index.fromInt(out[i])];
  });
}

int pentagonCount() => c.pentagonCount();

List<H3Index> getPentagons(int resolution) {
  return using((Arena arena) {
    final out = arena<Uint64>(12);
    checkH3Error(c.getPentagons(resolution, out));
    return [for (var i = 0; i < 12; i++) H3Index.fromInt(out[i])];
  });
}

abstract final class H3Version {
  static const String package = '1.0.1';
  static const String native = '4.4.1';
  static const int major = 4;
  static const int minor = 4;
  static const int patch = 1;
}

// Async — runs on isolate to keep the UI thread free.

Future<List<H3Index>> polygonToCellsAsync(
  GeoPolygon polygon,
  int resolution,
) async {
  return Isolate.run(() => polygonToCells(polygon, resolution));
}

Future<List<H3Index>> gridDiskAsync(H3Index origin, int k) async {
  return Isolate.run(() => gridDisk(origin, k));
}

Future<List<H3Index>> compactCellsAsync(List<H3Index> cells) async {
  return Isolate.run(() => compactCells(cells));
}

Future<List<H3Index>> uncompactCellsAsync(
  List<H3Index> cells,
  int resolution,
) async {
  return Isolate.run(() => uncompactCells(cells, resolution));
}
