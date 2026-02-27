/// Latitude/longitude coordinate pair in degrees.
class LatLng {
  /// Latitude in degrees, from -90 to 90.
  final double lat;

  /// Longitude in degrees, from -180 to 180.
  final double lng;

  /// Creates a coordinate from [lat] and [lng] in degrees.
  const LatLng(this.lat, this.lng);

  @override
  bool operator ==(Object other) =>
      other is LatLng && lat == other.lat && lng == other.lng;

  @override
  int get hashCode => Object.hash(lat, lng);

  @override
  String toString() => 'LatLng($lat, $lng)';
}
