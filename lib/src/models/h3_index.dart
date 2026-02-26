/// H3 cell/edge/vertex index stored as a hex string.
///
/// String-backed to avoid JS number precision loss (H3 indexes are 64-bit,
/// JS doubles only hold 53 bits exactly).
extension type const H3Index(String _hex) {
  factory H3Index.fromInt(int value) => H3Index(value.toRadixString(16));
  factory H3Index.parse(String hex) => H3Index(hex.toLowerCase());

  int toInt() => int.parse(_hex, radix: 16);
  String toHex() => _hex;
}
