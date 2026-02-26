import 'errors.dart';

const degsToRads = 0.0174532925199432957692369076848861271111;
const radsToDeg = 57.29577951308232087679815481410517033240547;

/// Throws [H3Exception] if [err] is non-zero.
void checkH3Error(int err) {
  if (err != 0) throw H3Exception.fromCode(err);
}
