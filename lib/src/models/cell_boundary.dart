import 'lat_lng.dart';

/// Cell boundary as a list of vertices in degrees.
class CellBoundary {
  final List<LatLng> vertices;

  const CellBoundary(this.vertices);

  @override
  String toString() => 'CellBoundary(${vertices.length} vertices)';
}
