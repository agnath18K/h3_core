/// Base exception for all H3 errors.
class H3Exception implements Exception {
  final int code;
  final String message;

  const H3Exception(this.code, this.message);

  factory H3Exception.fromCode(int code) {
    return switch (code) {
      1 => const H3Exception(1, 'Operation failed'),
      2 => const H3Exception(2, 'Argument outside acceptable range'),
      3 => const H3Exception(3, 'Invalid latitude or longitude'),
      4 => const H3Exception(4, 'Resolution must be between 0 and 15'),
      5 => const H3Exception(5, 'Invalid H3 cell index'),
      6 => const H3Exception(6, 'Invalid directed edge index'),
      7 => const H3Exception(7, 'Invalid undirected edge index'),
      8 => const H3Exception(8, 'Invalid vertex index'),
      9 => const H3Exception(9, 'Pentagon distortion encountered'),
      10 => const H3Exception(10, 'Duplicate input'),
      11 => const H3Exception(11, 'Cells are not neighbors'),
      12 => const H3Exception(12, 'Incompatible resolutions'),
      13 => const H3Exception(13, 'Memory allocation failed'),
      14 => const H3Exception(14, 'Buffer size insufficient'),
      15 => const H3Exception(15, 'Invalid option or flags'),
      16 => const H3Exception(16, 'Invalid H3 index'),
      17 => const H3Exception(17, 'Invalid base cell number'),
      18 => const H3Exception(18, 'Invalid index digit'),
      19 => const H3Exception(19, 'Deleted digit (K-subsequence) encountered'),
      _ => H3Exception(code, 'Unknown H3 error (code: $code)'),
    };
  }

  @override
  String toString() => 'H3Exception($code): $message';
}
