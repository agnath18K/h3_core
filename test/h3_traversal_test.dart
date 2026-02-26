import 'package:h3_core/h3_core.dart';
import 'package:test/test.dart';

void main() {
  final sf = H3Index.parse('89283082803ffff');

  group('gridDisk', () {
    test('k=0 returns origin only', () {
      final disk = gridDisk(sf, 0);
      expect(disk, hasLength(1));
      expect(disk.first, equals(sf));
    });

    test('k=1 returns 7 cells', () {
      final disk = gridDisk(sf, 1);
      expect(disk, hasLength(7));
      expect(disk, contains(sf));
    });

    test('k=2 returns 19 cells', () {
      final disk = gridDisk(sf, 2);
      expect(disk, hasLength(19));
    });

    test('pentagon k=1 returns 6 cells', () {
      final pent = getPentagons(1).first;
      final disk = gridDisk(pent, 1);
      expect(disk, hasLength(6)); // pentagon + 5 neighbors
    });
  });

  group('gridDiskDistances', () {
    test('k=1 maps cells to distances', () {
      final result = gridDiskDistances(sf, 1);
      expect(result, hasLength(7));
      expect(result[sf], equals(0));
      // All other cells should be distance 1
      final dist1 = result.values.where((d) => d == 1);
      expect(dist1, hasLength(6));
    });
  });

  group('gridRing', () {
    test('k=0 returns origin only', () {
      final ring = gridRing(sf, 0);
      expect(ring, hasLength(1));
      expect(ring.first, equals(sf));
    });

    test('k=1 returns 6 cells', () {
      final ring = gridRing(sf, 1);
      expect(ring, hasLength(6));
      expect(ring, isNot(contains(sf)));
    });

    test('k=2 returns 12 cells', () {
      final ring = gridRing(sf, 2);
      expect(ring, hasLength(12));
    });
  });

  group('gridDistance', () {
    test('distance to self is 0', () {
      expect(gridDistance(sf, sf), equals(0));
    });

    test('distance to neighbor is 1', () {
      final neighbors = gridRing(sf, 1);
      expect(gridDistance(sf, neighbors.first), equals(1));
    });

    test('resolution mismatch throws', () {
      final res3 = H3Index.parse('832830fffffffff');
      final res2 = H3Index.parse('822837fffffffff');
      expect(() => gridDistance(res3, res2), throwsA(isA<H3Exception>()));
    });
  });

  group('gridPathCells', () {
    test('path to self has 1 cell', () {
      final path = gridPathCells(sf, sf);
      expect(path, hasLength(1));
      expect(path.first, equals(sf));
    });

    test('path to neighbor has 2 cells', () {
      final neighbor = gridRing(sf, 1).first;
      final path = gridPathCells(sf, neighbor);
      expect(path, hasLength(2));
      expect(path.first, equals(sf));
      expect(path.last, equals(neighbor));
    });

    test('path length matches distance + 1', () {
      final target = gridRing(sf, 3).first;
      final path = gridPathCells(sf, target);
      final dist = gridDistance(sf, target);
      expect(path, hasLength(dist + 1));
    });
  });
}
