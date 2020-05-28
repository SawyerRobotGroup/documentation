import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dartx/dartx.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod/riverpod.dart';
import 'package:path/path.dart' as path;

final ChangeNotifierProvider<Documents> docs =
    ChangeNotifierProvider<Documents>((_) => Documents());

const String ext = '.md';
final editingProvider = ChangeNotifierProvider((ref) => EditingState(ref));

class EditingState extends ChangeNotifier {
  bool _editing = false;
  bool get editing => _editing;
  set editing(bool value) {
    _editing = value;
    notifyListeners();
  }

  void Function() _save;
  set save(void Function() s) {
    _save = () {
      s();
      notifyListeners();
    };
  }

  void Function() get save => _save;

  ProviderReference ref;
  EditingState(this.ref);
}

class Documents extends ChangeNotifier {
  Map<String, Doc> _pages = {};
  Map<String, Doc> _rootPages = {};
  final initialized = Completer<bool>();
  final url = kReleaseMode
      ? 'https://byu_sawyer_docs.codemagic.app/docs/'
      : 'http://localhost:8080/docs/';
  Documents() {
    init();
  }
  void init() async {
    final index = await getFile('index.json');
    final files = (json.decode(index) as List<dynamic>)
        .cast<String>()
        .sortedBy((k) => k.length);
    for (final file in files) {
      await addDoc(file);
    }

    initialized.complete();
    notifyListeners();
  }

  Future<String> getFile(String p) async {
    if (!kIsWeb) return await File(path.join(projectLoc, p)).readAsString();
    return (await http.get(url + p)).body;
  }

  Future<void> addDoc(String p) async {
    final hasParent = p.contains('/');
    final parent = hasParent ? p.substring(0, p.lastIndexOf('/')) + ext : null;
    final name = hasParent ? p.substring(p.lastIndexOf('/') + 1) : p;
    final formattedName = name
        .replaceAll(ext, '')
        .split('_')
        .map((s) => s.capitalize())
        .join(' ');
    _pages[p] = Doc(p, formattedName, [], await getFile(p));
    if (hasParent) {
      if (_pages[parent] == null) {
        print('Problem with parent $parent');
      }
      _pages[parent].children.add(p);
    } else {
      _rootPages[p] = _pages[p];
    }
  }

  Map<String, Doc> get pages => _pages;
  Map<String, Doc> get rootPages => _rootPages;
  String titleToFileName(String title) {
    return title.split(' ').map((s) => s.toLowerCase()).join('_') + ext;
  }

  String get projectLoc => path.join(
      Platform.environment['HOME'], 'sawyer_ws/src/documentation/docs/');

  Future<void> savePage(
      EditingState state, Doc page, String title, String contents) async {
    final newTitleFileName = titleToFileName(title);
    if (title != page.name) {
      final f = File(path.join(projectLoc, page.path));
      await f.delete();
      final children =
          Directory(path.join(projectLoc, page.path).split(ext)[0]);
      if (await children.exists()) {
        await children
            .rename(path.join(projectLoc, newTitleFileName.split(ext)[0]));
      }
      pages.remove(page.path);
    }
    final hasParent = page.path.contains('/');
    final parent =
        hasParent ? page.path.substring(0, page.path.lastIndexOf('/')) : null;
    final localPath =
        hasParent ? path.join(parent, newTitleFileName) : newTitleFileName;
    final newPath = path.join(projectLoc, localPath);
    pages[localPath] = Doc(localPath, title, page.children, contents);
    final file = File(newPath);
    // And show a snack bar on success.
    if (!await file.exists()) {
      await file.create();
    }
    await file.writeAsString(contents);
    notifyListeners();
  }

  Future<void> createPage(Doc parent) async {
    final localPath = path.join(parent.path.split(ext)[0], 'new_page.md');
    final file = File(path.join(Platform.environment['HOME'],
        'sawyer_ws/src/documentation/docs/', localPath));
    // And show a snack bar on success.
    await file.create();
    await file.writeAsString('');
    pages[localPath] = Doc(localPath, 'New Page', [], '');
    notifyListeners();
  }
}

class Doc {
  final String path;
  final String name;
  final List<String> children;
  final String content;

  Doc(this.path, this.name, this.children, this.content);
}
