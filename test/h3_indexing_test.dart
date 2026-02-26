import 'package:h3_core/h3_core.dart';
import 'package:test/test.dart';

void main() {
  group('latLngToCell', () {
    test('San Francisco at res 9', () {
      final cell = latLngToCell(const LatLng(37.7749295, -122.4194155), 9);
      expect(cell.toHex(), equals('89283082803ffff'));
    });

    test('Statue of Liberty at res 10', () {
      final cell = latLngToCell(const LatLng(40.689167, -74.044444), 10);
      expect(cell.toHex(), equals('8a2a1072b59ffff'));
    });

    test('invalid resolution throws', () {
      expect(
        () => latLngToCell(const LatLng(0, 0), 16),
        throwsA(isA<H3Exception>()),
      );
    });

    test('multiple resolutions', () {
      const ll = LatLng(37.7749295, -122.4194155);
      for (var res = 0; res <= 15; res++) {
        final cell = latLngToCell(ll, res);
        expect(getResolution(cell), equals(res));
      }
    });
  });

  group('cellToLatLng', () {
    test('round-trip', () {
      const original = LatLng(37.7749295, -122.4194155);
      final cell = latLngToCell(original, 9);
      final center = cellToLatLng(cell);
      expect(center.lat, closeTo(original.lat, 0.01));
      expect(center.lng, closeTo(original.lng, 0.01));
    });
  });

  group('cellToBoundary', () {
    test('hexagon has 6 vertices', () {
      final cell = H3Index.parse('89283082803ffff');
      final boundary = cellToBoundary(cell);
      expect(boundary.vertices.length, equals(6));
    });

    test('pentagon has 5 vertices', () {
      // Res 0 pentagon (base cell 4)
      final pentagons = getPentagons(0);
      final boundary = cellToBoundary(pentagons.first);
      expect(boundary.vertices.length, equals(5));
    });
  });

  group('isValidCell', () {
    test('valid cell', () {
      expect(isValidCell(H3Index.parse('89283082803ffff')), isTrue);
    });

    test('H3_NULL is invalid', () {
      expect(isValidCell(H3Index.fromInt(0)), isFalse);
    });
  });

  group('isPentagon', () {
    test('regular hexagon', () {
      expect(isPentagon(H3Index.parse('89283082803ffff')), isFalse);
    });

    test('pentagon cell', () {
      final pentagons = getPentagons(0);
      expect(isPentagon(pentagons.first), isTrue);
    });
  });

  group('string conversion', () {
    test('stringToH3 and h3ToString round-trip', () {
      const hex = '89283082803ffff';
      final cell = stringToH3(hex);
      expect(h3ToString(cell), equals(hex));
    });

    test('H3Index.parse matches stringToH3', () {
      const hex = '89283082803ffff';
      expect(H3Index.parse(hex), equals(stringToH3(hex)));
    });
  });
}
