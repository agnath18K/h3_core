import 'package:h3_core/h3_core.dart';
import 'package:test/test.dart';

void main() {
  final sf = H3Index.parse('89283082803ffff');

  group('cellToVertex', () {
    test('returns valid vertex', () {
      final vertex = cellToVertex(sf, 0);
      expect(isValidVertex(vertex), isTrue);
    });

    test('vertex is not a valid cell', () {
      final vertex = cellToVertex(sf, 0);
      expect(isValidCell(vertex), isFalse);
    });
  });

  group('cellToVertexes', () {
    test('hexagon has 6 vertices', () {
      final vertexes = cellToVertexes(sf);
      expect(vertexes, hasLength(6));
      for (final v in vertexes) {
        expect(isValidVertex(v), isTrue);
      }
    });

    test('pentagon has 5 vertices', () {
      final pent = getPentagons(1).first;
      final vertexes = cellToVertexes(pent);
      expect(vertexes, hasLength(5));
    });
  });

  group('vertexToLatLng', () {
    test('returns valid coordinates', () {
      final vertex = cellToVertex(sf, 0);
      final ll = vertexToLatLng(vertex);
      expect(ll.lat, inInclusiveRange(-90, 90));
      expect(ll.lng, inInclusiveRange(-180, 180));
    });
  });

  group('isValidVertex', () {
    test('valid vertex returns true', () {
      final vertex = cellToVertex(sf, 0);
      expect(isValidVertex(vertex), isTrue);
    });

    test('cell index returns false', () {
      expect(isValidVertex(sf), isFalse);
    });

    test('H3_NULL returns false', () {
      expect(isValidVertex(H3Index.fromInt(0)), isFalse);
    });
  });
}
