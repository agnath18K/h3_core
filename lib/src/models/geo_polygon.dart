import 'lat_lng.dart';

/// Containment mode for polygon fill operations.
enum ContainmentMode {
  /// Cell center is contained in the shape.
  center,

  /// Cell is fully contained in the shape.
  full,

  /// Cell overlaps the shape at any point.
  overlapping,

  /// Cell bounding box overlaps shape.
  overlappingBbox,
}

/// Polygon for region operations.
class GeoPolygon {
  final List<LatLng> exterior;
  final List<List<LatLng>> holes;

  const GeoPolygon(this.exterior, [this.holes = const []]);
}
