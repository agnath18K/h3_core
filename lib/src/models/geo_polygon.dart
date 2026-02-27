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

/// Polygon defined by an exterior ring and optional holes, for region
/// operations such as [polygonToCells].
class GeoPolygon {
  /// The exterior ring of the polygon as a list of coordinates.
  final List<LatLng> exterior;

  /// Optional interior rings (holes) to exclude from the polygon.
  final List<List<LatLng>> holes;

  /// Creates a [GeoPolygon] with an [exterior] ring and optional [holes].
  const GeoPolygon(this.exterior, [this.holes = const []]);
}
