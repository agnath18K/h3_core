/// Latitude/longitude in degrees.
class LatLng {
  final double lat;
  final double lng;

  const LatLng(this.lat, this.lng);

  @override
  bool operator ==(Object other) =>
      other is LatLng && lat == other.lat && lng == other.lng;

  @override
  int get hashCode => Object.hash(lat, lng);

  @override
  String toString() => 'LatLng($lat, $lng)';
}
