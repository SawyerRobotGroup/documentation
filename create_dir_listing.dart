import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

String get projectLoc => path.join(
    Platform.environment['HOME'], 'sawyer_ws/src/documentation/docs/');
const String ext = '.md';
void main() async {
  final files = await Directory(projectLoc)
      .list(recursive: true)
      .where((entity) => entity.path.contains(ext))
      .map((e) => e.path.split(projectLoc)[1])
      .toList();
  final listing = json.encode(files);
  final f = File(path.join(projectLoc, 'index.json'));
  if (!f.existsSync()) {
    f.create();
  }
  f.writeAsStringSync(listing);
}
