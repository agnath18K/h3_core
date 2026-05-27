## 1.0.6

- Move repository to the `wayqteam` GitHub organization; refresh `pubspec.yaml` URLs (`repository`, `homepage`, `issue_tracker`) and README CI badge
- Bump dependencies to latest majors: `hooks ^2.0.0`, `code_assets ^1.1.0`, `native_toolchain_c ^0.19.0`, `lints ^6.1.0`
- Upgrade vendored H3 C library from 4.4.1 → 4.5.0 ([upstream notes](https://github.com/uber/h3/releases/tag/v4.5.0))
- Add `reverseDirectedEdge` — returns a directed edge with origin and destination swapped (FFI + stub; throws `UnsupportedError` on web pending h3-js 4.5)
- `gridPathCells` is now bidirectional: `gridPathCells(a, b)` reversed equals `gridPathCells(b, a)` (H3 v4.5.0 behavior change)
- `cellsToLinkedMultiPolygon` / `cellsToMultiPolygon` now surface `E_CELL_INVALID`, `E_RES_MISMATCH`, and `E_DOMAIN` for invalid input, mixed resolutions, and duplicate cells (previously undefined output)
- Internal: refactored indexing (now uses `Vec3d`) and CoordIJK (now inlineable) from upstream — transparent to callers
- Regenerate FFI bindings against H3 v4.5.0 headers
- Refresh README badges and version references
- Expand pub.dev metadata: add `homepage`, `issue_tracker`, `documentation`, refined topics for better discoverability

## 1.0.5

- Upgrade vendored H3 C library from 4.4.1 → 4.5.0 ([upstream notes](https://github.com/uber/h3/releases/tag/v4.5.0))
- Add `reverseDirectedEdge` — returns a directed edge with origin and destination swapped (FFI + stub; throws `UnsupportedError` on web pending h3-js 4.5)
- `gridPathCells` is now bidirectional: `gridPathCells(a, b)` reversed equals `gridPathCells(b, a)` (H3 v4.5.0 behavior change)
- `cellsToLinkedMultiPolygon` / `cellsToMultiPolygon` now surface `E_CELL_INVALID`, `E_RES_MISMATCH`, and `E_DOMAIN` for invalid input, mixed resolutions, and duplicate cells (previously undefined output)
- Internal: refactored indexing (now uses `Vec3d`) and CoordIJK (now inlineable) from upstream — transparent to callers
- Regenerate FFI bindings against H3 v4.5.0 headers
- Refresh README badges and version references
- Expand pub.dev metadata: add `homepage`, `issue_tracker`, `documentation`, refined topics for better discoverability

## 1.0.4

- Switch h3-js CDN from jsDelivr to unpkg

## 1.0.3

- Update README with badges and structured platform support documentation

## 1.0.2

- Fix Windows build: add `BUILD_SHARED_LIBS` and `BUILDING_H3` defines for DLL symbol export
- Fix Windows build: skip `libm` linking (math is part of the C runtime on Windows)
- Remove deprecated `avoid_returning_null_for_future` lint rule
- Add CI/CD: automated testing on Linux, macOS, Windows, and Chrome
- Add automated publishing to pub.dev via GitHub Actions OIDC

## 1.0.1

- Web support via h3-js and `dart:js_interop`
- `H3Index` changed from int-backed to String-backed to avoid JS number precision loss
- Same public API on all platforms (conditional export: FFI on native, h3-js on web)
- `getIndexDigit` / `constructCell` use BigInt on web for 64-bit precision

## 1.0.0

- Initial release wrapping H3 v4.4.1
- Full H3 API: indexing, inspection, traversal, hierarchy, edges, vertices, measurements, regions, coordinates
- Native compilation via Build Hooks for Android, iOS, macOS, Linux, Windows
- Auto-generated FFI bindings via ffigen 20.x
- Async wrappers for heavy operations (polygonToCells, gridDisk, compact/uncompact)
