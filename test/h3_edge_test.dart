import 'package:h3_core/h3_core.dart';
import 'package:test/test.dart';

void main() {
  final sf = H3Index.parse('89283082803ffff');

  group('areNeighborCells', () {
    test('adjacent cells are neighbors', () {
      final neighbors = gridRing(sf, 1);
      expect(areNeighborCells(sf, neighbors.first), isTrue);
    });

    test('non-adjacent cells are not neighbors', () {
      final distant = gridRing(sf, 3).first;
      expect(areNeighborCells(sf, distant), isFalse);
    });

    test('cell is not its own neighbor', () {
      expect(areNeighborCells(sf, sf), isFalse);
    });
  });

  group('directed edges', () {
    late H3Index neighbor;
    late H3Index edge;

    setUp(() {
      neighbor = gridRing(sf, 1).first;
      edge = cellsToDirectedEdge(sf, neighbor);
    });

    test('edge is valid', () {
      expect(isValidDirectedEdge(edge), isTrue);
    });

    test('cell is not a valid edge', () {
      expect(isValidDirectedEdge(sf), isFalse);
    });

    test('getDirectedEdgeOrigin', () {
      expect(getDirectedEdgeOrigin(edge), equals(sf));
    });

    test('getDirectedEdgeDestination', () {
      expect(getDirectedEdgeDestination(edge), equals(neighbor));
    });

    test('directedEdgeToCells', () {
      final cells = directedEdgeToCells(edge);
      expect(cells, hasLength(2));
      expect(cells[0], equals(sf));
      expect(cells[1], equals(neighbor));
    });

    test('directedEdgeToBoundary has 2 vertices', () {
      final boundary = directedEdgeToBoundary(edge);
      expect(boundary.vertices, hasLength(2));
    });
  });

  group('originToDirectedEdges', () {
    test('hexagon has 6 edges', () {
      final edges = originToDirectedEdges(sf);
      expect(edges, hasLength(6));
      for (final edge in edges) {
        expect(isValidDirectedEdge(edge), isTrue);
        expect(getDirectedEdgeOrigin(edge), equals(sf));
      }
    });

    test('pentagon has 5 edges', () {
      final pent = getPentagons(1).first;
      final edges = originToDirectedEdges(pent);
      expect(edges, hasLength(5));
    });
  });
}
