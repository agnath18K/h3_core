import 'package:h3_core/h3_core.dart';
import 'package:test/test.dart';

void main() {
  final sf9 = H3Index.parse('89283082803ffff');

  group('cellToParent', () {
    test('res 9 to res 8', () {
      final parent = cellToParent(sf9, 8);
      expect(getResolution(parent), equals(8));
      expect(isValidCell(parent), isTrue);
    });

    test('res 9 to res 0', () {
      final parent = cellToParent(sf9, 0);
      expect(getResolution(parent), equals(0));
    });

    test('parent at same resolution is self', () {
      final parent = cellToParent(sf9, 9);
      expect(parent, equals(sf9));
    });
  });

  group('cellToChildren', () {
    test('hexagon has 7 children', () {
      final parent = cellToParent(sf9, 8);
      final children = cellToChildren(parent, 9);
      expect(children, hasLength(7));
      expect(children, contains(sf9));
    });

    test('pentagon has 6 children', () {
      final pent = getPentagons(0).first;
      final children = cellToChildren(pent, 1);
      expect(children, hasLength(6));
    });

    test('children at same resolution returns self', () {
      final children = cellToChildren(sf9, 9);
      expect(children, hasLength(1));
      expect(children.first, equals(sf9));
    });
  });

  group('cellToCenterChild', () {
    test('center child at next resolution', () {
      final parent = cellToParent(sf9, 8);
      final center = cellToCenterChild(parent, 9);
      expect(getResolution(center), equals(9));
      expect(isValidCell(center), isTrue);
    });
  });

  group('cellToChildPos / childPosToCell', () {
    test('round-trip', () {
      final parent = cellToParent(sf9, 8);
      final pos = cellToChildPos(sf9, 8);
      final reconstructed = childPosToCell(pos, parent, 9);
      expect(reconstructed, equals(sf9));
    });
  });

  group('compactCells', () {
    test('compact 7 children to parent', () {
      final parent = cellToParent(sf9, 8);
      final children = cellToChildren(parent, 9);
      final compacted = compactCells(children);
      expect(compacted, hasLength(1));
      expect(compacted.first, equals(parent));
    });

    test('compact non-compactable cells returns same', () {
      // 3 random neighbors shouldn't compact
      final disk = gridDisk(sf9, 1);
      final subset = disk.take(3).toList();
      final compacted = compactCells(subset);
      expect(compacted, hasLength(3));
    });
  });

  group('uncompactCells', () {
    test('uncompact parent to 7 children', () {
      final parent = cellToParent(sf9, 8);
      final uncompacted = uncompactCells([parent], 9);
      expect(uncompacted, hasLength(7));
    });

    test('compact then uncompact is identity', () {
      final parent = cellToParent(sf9, 8);
      final children = cellToChildren(parent, 9);
      final compacted = compactCells(children);
      final uncompacted = uncompactCells(compacted, 9);
      expect(uncompacted.toSet(), equals(children.toSet()));
    });
  });
}
