// ignore_for_file: avoid_print
import 'package:h3_core/h3_core.dart';

void main() {
  // Convert a coordinate to an H3 cell index at resolution 9.
  final sf = LatLng(37.7749295, -122.4194155);
  final cell = latLngToCell(sf, 9);
  print('H3 cell: ${cell.toHex()}'); // e.g. 8928308280fffff

  // Get the center of the cell.
  final center = cellToLatLng(cell);
  print('Center: ${center.lat}, ${center.lng}');

  // Inspect the cell.
  print('Resolution: ${getResolution(cell)}');
  print('Valid: ${isValidCell(cell)}');
  print('Pentagon: ${isPentagon(cell)}');

  // Get the cell boundary vertices.
  final boundary = cellToBoundary(cell);
  print('Boundary vertices: ${boundary.vertices.length}');

  // Find neighbors within 1 grid step.
  final neighbors = gridDisk(cell, 1);
  print('Neighbors (k=1): ${neighbors.length}');

  // Grid distance between two cells.
  final other = neighbors.last;
  final distance = gridDistance(cell, other);
  print('Grid distance: $distance');

  // Hierarchy: parent and children.
  final parent = cellToParent(cell, 8);
  print('Parent (res 8): ${parent.toHex()}');

  final children = cellToChildren(cell, 10);
  print('Children (res 10): ${children.length}');

  // Compact and uncompact.
  final compacted = compactCells(children);
  print('Compacted: ${compacted.length}');

  // Measurements.
  final area = cellAreaKm2(cell);
  print('Cell area: ${area.toStringAsFixed(4)} km²');

  final dist = greatCircleDistanceKm(sf, LatLng(40.7128, -74.0060));
  print('SF to NYC: ${dist.toStringAsFixed(1)} km');

  // Directed edges.
  final neighbor = neighbors[1];
  if (areNeighborCells(cell, neighbor)) {
    final edge = cellsToDirectedEdge(cell, neighbor);
    print('Edge: ${edge.toHex()}');
    print('Edge length: ${edgeLengthKm(edge).toStringAsFixed(3)} km');
  }

  // Region: fill a polygon with cells.
  final polygon = GeoPolygon([
    LatLng(37.78, -122.42),
    LatLng(37.78, -122.41),
    LatLng(37.77, -122.41),
    LatLng(37.77, -122.42),
  ]);
  final filled = polygonToCells(polygon, 9);
  print('Cells in polygon: ${filled.length}');

  // Version info.
  print('h3_core ${H3Version.package}, H3 native ${H3Version.native}');
}
