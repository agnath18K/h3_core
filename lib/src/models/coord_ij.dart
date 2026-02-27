/// Local IJ coordinate pair for grid-local coordinate operations.
///
/// IJ coordinates are a 2D coordinate system anchored at a given origin cell,
/// useful for local grid traversal and distance calculations.
class CoordIJ {
  /// The I (column) coordinate.
  final int i;

  /// The J (row) coordinate.
  final int j;

  /// Creates a [CoordIJ] with the given [i] and [j] coordinates.
  const CoordIJ(this.i, this.j);

  @override
  bool operator ==(Object other) =>
      other is CoordIJ && i == other.i && j == other.j;

  @override
  int get hashCode => Object.hash(i, j);

  @override
  String toString() => 'CoordIJ($i, $j)';
}
