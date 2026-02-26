import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:hooks/hooks.dart';
import 'package:logging/logging.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

const _h3VersionMajor = '4';
const _h3VersionMinor = '4';
const _h3VersionPatch = '1';

void main(List<String> args) async {
  await build(args, (input, output) async {
    if (!input.config.buildCodeAssets) return;

    hierarchicalLoggingEnabled = true;
    final logger = Logger('h3_build')
      ..level = Level.ALL
      ..onRecord.listen((record) => print(record.message));

    final packageRoot = input.packageRoot.toFilePath();

    // Step 1: Generate h3api.h from template
    final generatedDir = Directory.fromUri(
      input.outputDirectoryShared.resolve('generated/'),
    );
    await generatedDir.create(recursive: true);

    final template = await File(
      '${packageRoot}src/h3lib/include/h3api.h.in',
    ).readAsString();

    final h3apiContent = template
        .replaceAll('@H3_VERSION_MAJOR@', _h3VersionMajor)
        .replaceAll('@H3_VERSION_MINOR@', _h3VersionMinor)
        .replaceAll('@H3_VERSION_PATCH@', _h3VersionPatch);

    await File('${generatedDir.path}/h3api.h').writeAsString(h3apiContent);

    // Track template for rebuild on change
    output.dependencies.add(
      Uri.file('${packageRoot}src/h3lib/include/h3api.h.in'),
    );

    // Step 2: Enumerate all .c source files
    final sourceGlob = Glob('src/h3lib/lib/*.c');
    final sources =
        sourceGlob
            .listSync(root: packageRoot)
            .whereType<File>()
            .map((f) => f.path.substring(packageRoot.length))
            .toList()
          ..sort();

    // Step 3: Compile with CBuilder
    final builder = CBuilder.library(
      name: 'h3',
      assetName: 'src/generated/h3_bindings.g.dart',
      sources: sources,
      includes: ['src/h3lib/include', generatedDir.path],
      defines: {
        'H3_VERSION_MAJOR': _h3VersionMajor,
        'H3_VERSION_MINOR': _h3VersionMinor,
        'H3_VERSION_PATCH': _h3VersionPatch,
      },
      std: 'c11',
      language: Language.c,
      optimizationLevel: OptimizationLevel.o3,
      libraries: ['m'],
    );

    await builder.run(input: input, output: output, logger: logger);
  });
}
