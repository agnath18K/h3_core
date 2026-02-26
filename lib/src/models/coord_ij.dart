/// IJ coordinates for local coordinate operations.
class CoordIJ {
  final int i;
  final int j;

  const CoordIJ(this.i, this.j);

  @override
  bool operator ==(Object other) =>
      other is CoordIJ && i == other.i && j == other.j;

  @override
  int get hashCode => Object.hash(i, j);

  @override
  String toString() => 'CoordIJ($i, $j)';
}
