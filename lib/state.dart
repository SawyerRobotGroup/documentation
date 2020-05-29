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
  ProviderReference ref;
  EditingState(this.ref);

  bool _editing = false;
  bool get editing => _editing;
  set editing(bool value) {
    _editing = value;
    notifyListeners();
  }

  void Function() _save;
  void Function() get save => _save;
  set save(void Function() s) {
    _save = () {
      s();
      notifyListeners();
    };
  }

  void Function() _delete;
  void Function() get delete => _delete;
  set delete(void Function() d) {
    _delete = () {
      d();
      notifyListeners();
    };
  }
}

class Documents extends ChangeNotifier {
  Map<String, Doc> _pages = {};
  Map<String, Doc> _rootPages = {};
  final initialized = Completer<bool>();
  final url = kReleaseMode
      ? 'https://byu_sawyer_docs.codemagic.app/docs/'
      : 'http://localhost:8080/docs/';

  String requestedPage;
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
    final hasParent = page.path.contains('/');
    final parent =
        hasParent ? page.path.substring(0, page.path.lastIndexOf('/')) : null;
    final localPath =
        hasParent ? path.join(parent, newTitleFileName) : newTitleFileName;
    if (title != page.name) {
      await _removePage(page.path, newTitleFileName);
      requestedPage = localPath.split(ext)[0];
      print('Going to $requestedPage');
    }
    await _addPage(Doc(localPath, title, page.children, contents));
    await updateDirectoryListing();
    notifyListeners();
  }

  Future<void> createPage(Doc parent) async {
    var localPath = parent == null
        ? 'new_page.md'
        : path.join(parent.path.split(ext)[0], 'new_page.md');
    // And show a snack bar on success.
    await _addPage(Doc(localPath, 'New Page', [], ''));
    await updateDirectoryListing();
    notifyListeners();
  }

  Future<bool> deletePage(EditingState editing, Doc page) async {
    if (page.children.length > 0) {
      return false;
    } else {
      await _removePage(page.path);
      await updateDirectoryListing();
      notifyListeners();
      return true;
    }
  }

  Future<void> updateDirectoryListing() async {
    if (kIsWeb) {
      return;
    }
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

  Future<void> _removePage(String p, [String rename]) async {
    // Remove the file from disk
    final f = File(path.join(projectLoc, p));
    await f.delete();
    // Move the children (if renaming)
    final children = Directory(path.join(projectLoc, p).split(ext)[0]);
    if (await children.exists()) {
      assert(rename != null);
      await children.rename(path.join(projectLoc, rename.split(ext)[0]));
    }
    // Remove from local maps
    if (!p.contains('/')) {
      rootPages.remove(p);
    }
    pages.remove(p);
    // Remove from parent
    final hasParent = p.contains('/');
    if (hasParent) {
      final parent = p.substring(0, p.lastIndexOf('/'));
      print('Children: ${pages[parent + ext].children}');
      pages[parent + ext].children.remove(p);
    }
  }

  Future<void> _addPage(Doc doc) async {
    final p = doc.path;
    // Adds it to both the maps
    pages[p] = doc;
    if (!p.contains('/')) {
      rootPages[p] = pages[p];
    }
    // Adds it to the parent if there is one
    final hasParent = p.contains('/');
    if (hasParent) {
      final parent = p.substring(0, p.lastIndexOf('/'));
      pages[parent + ext].children.add(p);
      print('Children: ${pages[parent + ext].children}');
    }
    // Writes the file
    final file = File(path.join(
        Platform.environment['HOME'], 'sawyer_ws/src/documentation/docs/', p));
    if (!await file.exists()) {
      await file.create();
    }
    await file.writeAsString(doc.content);
  }

  void showPage(String str) {
    if (pages.keys.any((element) => element.split(ext)[0] == str) ||
        str == null) {
      requestedPage = str;
      notifyListeners();
    }
  }
}

class Doc {
  final String path;
  final String name;
  final List<String> children;
  final String content;

  Doc(this.path, this.name, this.children, this.content);
}
