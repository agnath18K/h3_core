/// H3 geospatial indexing for Dart/Flutter.
///
/// Uses dart:ffi on native, h3-js on web.
library;

export 'src/errors.dart';
export 'src/h3_stub.dart'
    if (dart.library.ffi) 'src/h3_ffi.dart'
    if (dart.library.js_interop) 'src/h3_web.dart';
export 'src/models/cell_boundary.dart';
export 'src/models/coord_ij.dart';
export 'src/models/geo_polygon.dart';
export 'src/models/h3_index.dart';
export 'src/models/lat_lng.dart';
