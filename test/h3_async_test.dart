import 'package:h3_core/h3_core.dart';
import 'package:test/test.dart';

void main() {
  final sf = H3Index.parse('89283082803ffff');
  const sfPolygon = GeoPolygon([
    LatLng(37.813318999983238, -122.4089866999972145),
    LatLng(37.7866302000007224, -122.3805436999997056),
    LatLng(37.7198061999978478, -122.3544736999993603),
    LatLng(37.7076131999975672, -122.5123436999983966),
    LatLng(37.7835871999971715, -122.5247187000021967),
    LatLng(37.8151571999998453, -122.4798767000009008),
  ]);

  group('polygonToCellsAsync', () {
    test('matches sync version', () async {
      final sync = polygonToCells(sfPolygon, 9);
      final async = await polygonToCellsAsync(sfPolygon, 9);
      expect(async.length, equals(sync.length));
      expect(async.toSet(), equals(sync.toSet()));
    });
  });

  group('gridDiskAsync', () {
    test('matches sync version', () async {
      final sync = gridDisk(sf, 3);
      final async = await gridDiskAsync(sf, 3);
      expect(async.length, equals(sync.length));
      expect(async.toSet(), equals(sync.toSet()));
    });
  });

  group('compactCellsAsync', () {
    test('matches sync version', () async {
      final disk = gridDisk(sf, 2);
      final sync = compactCells(disk);
      final async = await compactCellsAsync(disk);
      expect(async.length, equals(sync.length));
      expect(async.toSet(), equals(sync.toSet()));
    });
  });

  group('uncompactCellsAsync', () {
    test('matches sync version', () async {
      final disk = gridDisk(sf, 2);
      final compacted = compactCells(disk);
      final sync = uncompactCells(compacted, 9);
      final async = await uncompactCellsAsync(compacted, 9);
      expect(async.length, equals(sync.length));
      expect(async.toSet(), equals(sync.toSet()));
    });
  });
}
