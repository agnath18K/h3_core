/// H3 cell, directed edge, or vertex index stored as a hex string.
///
/// Backed by a [String] rather than [int] to avoid precision loss on the
/// web platform — H3 indexes are 64-bit integers, but JavaScript doubles
/// only hold 53 bits of integer precision.
extension type const H3Index(String _hex) {
  /// Creates an [H3Index] from a 64-bit integer value.
  factory H3Index.fromInt(int value) => H3Index(value.toRadixString(16));

  /// Parses a hex string into an [H3Index], normalising to lower case.
  factory H3Index.parse(String hex) => H3Index(hex.toLowerCase());

  /// Returns the 64-bit integer value of this index.
  int toInt() => int.parse(_hex, radix: 16);

  /// Returns the lowercase hex string representation of this index.
  String toHex() => _hex;
}
