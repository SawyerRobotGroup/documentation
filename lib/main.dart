import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod/riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
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

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Sawyer Documentation',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.red,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: HomePage(),
      ),
    );
  }
}

class HomePage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final editing = useProvider(editingProvider);
    final pages = useProvider(docs).rootPages;
    return Scaffold(
      body: pages.length < 2
          ? Center(child: CircularProgressIndicator())
          : NavigationInset(pages),
      floatingActionButton: !kIsWeb
          ? Builder(
              builder: (context) {
                return editing.editing
                    ? FloatingActionButton(
                        child: Icon(Icons.save),
                        onPressed: () => editing.save(),
                      )
                    : FloatingActionButton(
                        child: Icon(Icons.edit),
                        onPressed: () => editing.editing = true);
              },
            )
          : null,
    );
  }
}

class NavigationInset extends HookWidget {
  final Map<String, Doc> pages;
  final Doc parent;
  NavigationInset(this.pages, {this.parent}) : super(key: ObjectKey(parent));

  @override
  Widget build(BuildContext context) {
    final page = useState(0);
    final pagesState = useProvider(docs);
    final editing = useProvider(editingProvider);
    final destinations = pages.keys
        .map((p) => WikiDestination(pages[p].name, pages[p]))
        .toList();
    if (destinations.any((p) => p.destination == 'Home')) {
      final home = destinations.firstWhere((p) => p.destination == 'Home');
      destinations.removeWhere((p) => p.destination == 'Home');
      destinations.insert(0, home);
    }
    if (parent != null) {
      destinations.insert(0, WikiDestination('Home', parent));
    }
    if (destinations.length == 1) {
      destinations.add(WikiDestination('', null));
    }
    if (editing.editing) {
      destinations.add(WikiDestination('Add', null, true));
    }
    final selectedDestination = destinations[page.value];
    final selectedPage = selectedDestination.page ?? pages.values.toList()[0];
    return Row(
      children: [
        NavigationRail(
          labelType: NavigationRailLabelType.all,
          destinations: destinations,
          selectedIndex: page.value,
          onDestinationSelected: (index) async {
            if (editing.editing && index == destinations.length - 1) {
              await pagesState.createPage(parent);
            }
            page.value = index;
          },
        ),
        VerticalDivider(thickness: 1, width: 1),
        Expanded(child: NavigatedPage(selectedPage, parent: parent))
      ],
    );
  }
}

class WikiDestination extends NavigationRailDestination {
  final String destination;
  final Doc page;
  final bool isAdd;
  WikiDestination(this.destination, this.page, [this.isAdd = false])
      : super(
            icon: isAdd ? Icon(Icons.add) : SizedBox.shrink(),
            label: isAdd ? SizedBox.shrink() : Text(destination));
}

class NavigatedPage extends HookWidget {
  final Doc page;
  final Doc parent;
  NavigatedPage(this.page, {this.parent}) : super(key: ObjectKey(page));

  @override
  Widget build(BuildContext context) {
    final pages = useProvider(docs);
    final children =
        page.children.asMap().map((_, p) => MapEntry(p, pages.pages[p]));
    if (page.children.isEmpty || parent == page) {
      return WikiPage(page);
    } else {
      return NavigationInset(children, parent: page);
    }
  }
}

class WikiPage extends HookWidget {
  final Doc page;
  WikiPage(this.page) : super(key: ObjectKey(page));

  @override
  Widget build(BuildContext context) {
    final editing = useProvider(editingProvider);
    final pages = useProvider(docs);
    final _titleController = useTextEditingController(text: page.name);
    final _controller = useTextEditingController(text: page.content);
    editing.save =
        () => _save(pages, _titleController, _controller, context, editing);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: editing.editing
            ? Column(
                children: [
                  TextField(
                      controller: _titleController, maxLines: 1, minLines: 1),
                  Expanded(
                    child: TextField(
                        controller: _controller,
                        expands: true,
                        maxLines: null,
                        minLines: null),
                  ),
                ],
              )
            : MarkdownBody(
                data: '# ${_titleController.text}\n---\n' +
                    (_controller.text.isNullOrEmpty
                        ? '## This Page is Empty'
                        : _controller.text)),
      ),
    );
  }

  void _save(
      Documents pages,
      TextEditingController titleController,
      TextEditingController controller,
      BuildContext context,
      EditingState editing) async {
    await pages.savePage(editing, page, titleController.text, controller.text);
    // For this example we save our document to a temporary file.
    Scaffold.of(context).showSnackBar(SnackBar(content: Text("Saved.")));
    editing.editing = false;
  }
}
