import 'dart:js_interop';

@JS('h3')
external H3Js get h3;

/// Bindings to the global `h3` object from h3-js.
extension type H3Js._(JSObject _) implements JSObject {
  // --- Indexing ---
  external JSString latLngToCell(JSNumber lat, JSNumber lng, JSNumber res);
  external JSArray<JSNumber> cellToLatLng(JSString cell);
  external JSArray<JSArray<JSNumber>> cellToBoundary(JSString cell);

  // --- Inspection ---
  external JSNumber getResolution(JSString h);
  external JSNumber getBaseCellNumber(JSString h);
  external JSBoolean isValidCell(JSString h);
  external JSBoolean isPentagon(JSString h);
  external JSBoolean isResClassIII(JSString h);
  external JSArray<JSNumber> getIcosahedronFaces(JSString h);
  external JSBoolean isValidDirectedEdge(JSString edge);
  external JSBoolean isValidVertex(JSString vertex);

  // --- Traversal ---
  external JSArray<JSString> gridDisk(JSString origin, JSNumber k);
  external JSArray<JSArray<JSString>> gridDiskDistances(
    JSString origin,
    JSNumber k,
  );
  external JSArray<JSString> gridRingUnsafe(JSString origin, JSNumber k);
  external JSNumber gridDistance(JSString origin, JSString destination);
  external JSArray<JSString> gridPathCells(JSString start, JSString end);

  // --- Hierarchy ---
  external JSString cellToParent(JSString cell, JSNumber parentRes);
  external JSArray<JSString> cellToChildren(JSString cell, JSNumber childRes);
  external JSString cellToCenterChild(JSString cell, JSNumber childRes);
  external JSNumber cellToChildPos(JSString child, JSNumber parentRes);
  external JSString childPosToCell(
    JSNumber childPos,
    JSString parent,
    JSNumber childRes,
  );
  external JSArray<JSString> compactCells(JSArray<JSString> cells);
  external JSArray<JSString> uncompactCells(
    JSArray<JSString> cells,
    JSNumber res,
  );

  // --- Directed Edges ---
  external JSBoolean areNeighborCells(JSString origin, JSString destination);
  external JSString cellsToDirectedEdge(JSString origin, JSString destination);
  external JSString getDirectedEdgeOrigin(JSString edge);
  external JSString getDirectedEdgeDestination(JSString edge);
  external JSArray<JSString> directedEdgeToCells(JSString edge);
  external JSArray<JSString> originToDirectedEdges(JSString origin);
  external JSArray<JSArray<JSNumber>> directedEdgeToBoundary(JSString edge);

  // --- Vertices ---
  external JSString cellToVertex(JSString cell, JSNumber vertexNum);
  external JSArray<JSString> cellToVertexes(JSString cell);
  external JSArray<JSNumber> vertexToLatLng(JSString vertex);

  // --- Measurements ---
  external JSNumber greatCircleDistance(
    JSArray<JSNumber> a,
    JSArray<JSNumber> b,
    JSString unit,
  );
  external JSNumber cellArea(JSString cell, JSString unit);
  external JSNumber edgeLength(JSString edge, JSString unit);
  external JSNumber getHexagonAreaAvg(JSNumber res, JSString unit);
  external JSNumber getHexagonEdgeLengthAvg(JSNumber res, JSString unit);
  external JSNumber getNumCells(JSNumber res);

  // --- Coordinate Systems ---
  external CoordIJJs cellToLocalIj(JSString origin, JSString cell);
  external JSString localIjToCell(JSString origin, CoordIJJsLiteral ij);

  // --- Regions ---
  external JSArray<JSString> polygonToCells(
    JSAny polygon, // number[][] (simple) or number[][][] (with holes)
    JSNumber res, [
    JSBoolean? isGeoJson,
  ]);
  external JSArray<JSArray<JSArray<JSArray<JSNumber>>>> cellsToMultiPolygon(
    JSArray<JSString> cells, [
    JSBoolean? formatAsGeoJson,
  ]);

  // --- Utilities ---
  external JSArray<JSString> getRes0Cells();
  external JSArray<JSString> getPentagons(JSNumber res);
}

// CoordIJ interop

extension type CoordIJJs._(JSObject _) implements JSObject {
  external JSNumber get i;
  external JSNumber get j;
}

extension type CoordIJJsLiteral._(JSObject _) implements JSObject {
  external factory CoordIJJsLiteral({int i, int j});
}
