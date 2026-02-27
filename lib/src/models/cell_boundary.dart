import 'lat_lng.dart';

/// Cell boundary as an ordered list of vertices in degrees.
class CellBoundary {
  /// The boundary vertices in order. Typically 6 for hexagons, 5 for pentagons.
  final List<LatLng> vertices;

  /// Creates a [CellBoundary] from an ordered list of [vertices].
  const CellBoundary(this.vertices);

  @override
  String toString() => 'CellBoundary(${vertices.length} vertices)';
}
