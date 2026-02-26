import 'dart:math';

import 'package:h3_core/h3_core.dart';
import 'package:test/test.dart';

void main() {
  final sf = H3Index.parse('89283082803ffff');

  group('greatCircleDistance', () {
    test('distance to same point is 0', () {
      const ll = LatLng(37.7749, -122.4194);
      expect(greatCircleDistanceKm(ll, ll), closeTo(0, 1e-10));
    });

    test('SF to NYC ~4130 km', () {
      const sfLL = LatLng(37.7749, -122.4194);
      const nycLL = LatLng(40.7128, -74.0060);
      final dist = greatCircleDistanceKm(sfLL, nycLL);
      expect(dist, closeTo(4130, 50));
    });

    test('meters version is 1000x km version', () {
      const a = LatLng(37.7749, -122.4194);
      const b = LatLng(40.7128, -74.0060);
      final km = greatCircleDistanceKm(a, b);
      final m = greatCircleDistanceM(a, b);
      expect(m, closeTo(km * 1000, 0.1));
    });
  });

  group('cellArea', () {
    test('area is positive', () {
      final area = cellAreaKm2(sf);
      expect(area, greaterThan(0));
    });

    test('m2 is 1e6 times km2', () {
      final km2 = cellAreaKm2(sf);
      final m2 = cellAreaM2(sf);
      expect(m2, closeTo(km2 * 1e6, km2 * 1e6 * 0.001));
    });
  });

  group('edgeLength', () {
    test('edge length is positive', () {
      final edges = originToDirectedEdges(sf);
      final length = edgeLengthKm(edges.first);
      expect(length, greaterThan(0));
    });

    test('m version is 1000x km version', () {
      final edges = originToDirectedEdges(sf);
      final km = edgeLengthKm(edges.first);
      final m = edgeLengthM(edges.first);
      expect(m, closeTo(km * 1000, 0.1));
    });
  });

  group('hexagon averages', () {
    test('area avg decreases with resolution', () {
      final area0 = getHexagonAreaAvgKm2(0);
      final area5 = getHexagonAreaAvgKm2(5);
      final area10 = getHexagonAreaAvgKm2(10);
      expect(area0, greaterThan(area5));
      expect(area5, greaterThan(area10));
    });

    test('edge length avg decreases with resolution', () {
      final len0 = getHexagonEdgeLengthAvgKm(0);
      final len5 = getHexagonEdgeLengthAvgKm(5);
      expect(len0, greaterThan(len5));
    });
  });

  group('getNumCells', () {
    test('res 0 has 122 cells', () {
      expect(getNumCells(0), equals(122));
    });

    test('formula: 2 + 120 * 7^res', () {
      for (var res = 0; res <= 5; res++) {
        final expected = 2 + 120 * pow(7, res).toInt();
        expect(getNumCells(res), equals(expected));
      }
    });
  });

  group('localIj', () {
    test('round-trip', () {
      final neighbor = gridRing(sf, 1).first;
      final ij = cellToLocalIj(sf, neighbor);
      final cell = localIjToCell(sf, ij);
      expect(cell, equals(neighbor));
    });

    test('self maps to consistent IJ', () {
      final ij = cellToLocalIj(sf, sf);
      // cellToLocalIj(origin, origin) returns a consistent IJ pair
      // (not necessarily (0,0) — IJ coords are absolute, not relative)
      final cell = localIjToCell(sf, ij);
      expect(cell, equals(sf));
    });
  });

  group('error codes', () {
    test('H3Exception.fromCode returns correct messages', () {
      final e = H3Exception.fromCode(5);
      expect(e.code, equals(5));
      expect(e.message, contains('cell'));
    });

    test('unknown code', () {
      final e = H3Exception.fromCode(99);
      expect(e.message, contains('Unknown'));
    });
  });

  group('res0 and pentagons', () {
    test('res0CellCount is 122', () {
      expect(res0CellCount(), equals(122));
    });

    test('getRes0Cells returns 122 valid cells', () {
      final cells = getRes0Cells();
      expect(cells, hasLength(122));
      for (final c in cells) {
        expect(isValidCell(c), isTrue);
        expect(getResolution(c), equals(0));
      }
    });

    test('pentagonCount is 12', () {
      expect(pentagonCount(), equals(12));
    });

    test('getPentagons returns 12 pentagons', () {
      for (var res = 0; res <= 5; res++) {
        final pents = getPentagons(res);
        expect(pents, hasLength(12));
        for (final p in pents) {
          expect(isPentagon(p), isTrue);
          expect(getResolution(p), equals(res));
        }
      }
    });
  });

  group('isValidIndex', () {
    test('valid cell is valid index', () {
      expect(isValidIndex(sf), isTrue);
    });

    test('valid edge is valid index', () {
      final edge = originToDirectedEdges(sf).first;
      expect(isValidIndex(edge), isTrue);
    });

    test('null index is not valid', () {
      expect(isValidIndex(H3Index.fromInt(0)), isFalse);
    });
  });

  group('getIndexDigit / constructCell', () {
    test('round-trip decompose and reconstruct', () {
      final res = getResolution(sf);
      final base = getBaseCellNumber(sf);
      final digits = [for (var r = 1; r <= res; r++) getIndexDigit(sf, r)];
      final rebuilt = constructCell(res, base, digits);
      expect(rebuilt, equals(sf));
    });
  });

  group('hexagon area avg m2', () {
    test('m2 is 1e6 times km2', () {
      final km2 = getHexagonAreaAvgKm2(5);
      final m2 = getHexagonAreaAvgM2(5);
      expect(m2, closeTo(km2 * 1e6, km2 * 1e6 * 0.001));
    });
  });

  group('hexagon edge length avg m', () {
    test('m is 1000x km', () {
      final km = getHexagonEdgeLengthAvgKm(5);
      final m = getHexagonEdgeLengthAvgM(5);
      expect(m, closeTo(km * 1000, 0.1));
    });
  });

  group('H3Version', () {
    test('version constants', () {
      expect(H3Version.major, equals(4));
      expect(H3Version.minor, equals(4));
      expect(H3Version.patch, equals(1));
      expect(H3Version.native, equals('4.4.1'));
      expect(H3Version.package, equals('1.0.1'));
    });
  });

  group('inspection', () {
    test('getBaseCellNumber', () {
      final base = getBaseCellNumber(sf);
      expect(base, inInclusiveRange(0, 121));
    });

    test('isResClassIII', () {
      // Res 9 is class III (odd resolutions are class III)
      expect(isResClassIII(sf), isTrue);
      final parent = cellToParent(sf, 8);
      expect(isResClassIII(parent), isFalse);
    });

    test('getIcosahedronFaces', () {
      final faces = getIcosahedronFaces(sf);
      expect(faces, isNotEmpty);
      for (final f in faces) {
        expect(f, inInclusiveRange(0, 19));
      }
    });
  });
}
