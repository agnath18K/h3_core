import 'package:h3_core/h3_core.dart';
import 'package:test/test.dart';

void main() {
  // SF polygon (degrees) — derived from upstream test vectors
  const sfPolygon = GeoPolygon([
    LatLng(37.813318999983238, -122.4089866999972145),
    LatLng(37.7866302000007224, -122.3805436999997056),
    LatLng(37.7198061999978478, -122.3544736999993603),
    LatLng(37.7076131999975672, -122.5123436999983966),
    LatLng(37.7835871999971715, -122.5247187000021967),
    LatLng(37.8151571999998453, -122.4798767000009008),
  ]);

  group('polygonToCells', () {
    test('SF polygon at res 9 returns cells', () {
      final cells = polygonToCells(sfPolygon, 9);
      // The exact count depends on the polygon — upstream says ~1253
      expect(cells.length, greaterThan(1000));
      expect(cells.length, lessThan(1500));
      for (final c in cells) {
        expect(isValidCell(c), isTrue);
        expect(getResolution(c), equals(9));
      }
    });

    test('small polygon at low res', () {
      // A small triangle
      const poly = GeoPolygon([
        LatLng(37.78, -122.42),
        LatLng(37.77, -122.41),
        LatLng(37.77, -122.42),
      ]);
      final cells = polygonToCells(poly, 7);
      expect(cells, isNotEmpty);
    });
  });

  group('polygon with hole', () {
    test('hole reduces cell count', () {
      // Create a polygon with a hole
      final hole = [
        const LatLng(37.77, -122.45),
        const LatLng(37.77, -122.43),
        const LatLng(37.75, -122.43),
        const LatLng(37.75, -122.45),
      ];
      final withHole = GeoPolygon(sfPolygon.exterior, [hole]);

      final cellsNoHole = polygonToCells(sfPolygon, 9);
      final cellsWithHole = polygonToCells(withHole, 9);

      expect(cellsWithHole.length, lessThan(cellsNoHole.length));
    });
  });

  group('polygonToCellsExperimental', () {
    test('center mode matches non-experimental', () {
      final cells = polygonToCells(sfPolygon, 9);
      final cellsExp = polygonToCellsExperimental(sfPolygon, 9);
      expect(cellsExp.length, closeTo(cells.length, 10));
    });

    // h3-js v4.x only supports center containment mode; skip on web.
    test('full containment returns fewer cells', () {
      final center = polygonToCellsExperimental(sfPolygon, 9);
      final full = polygonToCellsExperimental(
        sfPolygon,
        9,
        mode: ContainmentMode.full,
      );
      expect(full.length, lessThan(center.length));
    }, testOn: 'vm');

    test('overlapping returns more cells', () {
      final center = polygonToCellsExperimental(sfPolygon, 9);
      final overlap = polygonToCellsExperimental(
        sfPolygon,
        9,
        mode: ContainmentMode.overlapping,
      );
      expect(overlap.length, greaterThan(center.length));
    }, testOn: 'vm');
  });

  group('cellsToMultiPolygon', () {
    test('single cell returns one polygon', () {
      final cell = H3Index.parse('89283082803ffff');
      final multi = cellsToMultiPolygon([cell]);
      expect(multi, hasLength(1));
      expect(multi.first, hasLength(1)); // one ring (exterior)
      expect(multi.first.first.length, greaterThanOrEqualTo(5)); // vertices
    });

    test('contiguous cells return one polygon', () {
      final cell = H3Index.parse('89283082803ffff');
      final disk = gridDisk(cell, 1); // 7 contiguous cells
      final multi = cellsToMultiPolygon(disk);
      expect(multi, hasLength(1)); // one polygon
    });

    test('round-trip: polygon -> cells -> multipolygon', () {
      const poly = GeoPolygon([
        LatLng(37.78, -122.42),
        LatLng(37.77, -122.41),
        LatLng(37.77, -122.42),
      ]);
      final cells = polygonToCells(poly, 8);
      if (cells.isNotEmpty) {
        final multi = cellsToMultiPolygon(cells);
        expect(multi, isNotEmpty);
        // Each polygon should have at least one ring with vertices
        for (final polygon in multi) {
          expect(polygon, isNotEmpty);
          for (final ring in polygon) {
            expect(ring.length, greaterThanOrEqualTo(3));
          }
        }
      }
    });
  });
}
