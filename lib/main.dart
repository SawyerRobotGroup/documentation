import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod/riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartx/dartx.dart';
import 'package:zefyr/zefyr.dart';
import 'package:quill_delta/quill_delta.dart';

final docs = FutureProvider((_) async {
  final manifest = await rootBundle.loadString('AssetManifest.json');
  final docs = Documents(manifest);
  await docs.initialized.future;
  return docs;
});

class Documents {
  Map<String, Doc> _pages = {};
  Map<String, Doc> _rootPages = {};
  final String manifest;
  final initialized = Completer<bool>();
  Documents(this.manifest) {
    init();
  }
  void init() async {
    final Map<String, dynamic> manifestMap = json.decode(manifest);
    await Future.wait(manifestMap.keys
        .where((String key) => key.contains('.md'))
        .map((k) => k.substring(5))
        .sortedBy((k) => k.length)
        .map((k) => addDoc(k)));
    initialized.complete();
  }

  Future<void> addDoc(String path) async {
    final hasParent = path.contains('/');
    final parent =
        hasParent ? path.substring(0, path.lastIndexOf('/')) + '.md' : null;
    final name = hasParent ? path.substring(path.lastIndexOf('/') + 1) : path;
    final formattedName = name.replaceAll('.md', '').capitalize();
    _pages[path] = Doc(
        path, formattedName, [], await rootBundle.loadString('docs/' + path));
    if (hasParent) {
      if (_pages[parent] == null) {
        print('Problem with parent $parent');
      }
      _pages[parent].children.add(path);
    } else {
      _rootPages[path] = _pages[path];
    }
  }

  Map<String, Doc> get pages => _pages;
  Map<String, Doc> get rootPages => _rootPages;
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
    final pages = useProvider(docs)
        .maybeWhen(data: (d) => d.rootPages, orElse: () => <String, Doc>{});
    return Scaffold(
        body: pages.length < 2
            ? Center(child: CircularProgressIndicator())
            : NavigationInset(pages));
  }
}

class NavigationInset extends HookWidget {
  final Map<String, Doc> pages;
  final Doc parent;
  NavigationInset(this.pages, {this.parent});

  @override
  Widget build(BuildContext context) {
    final page = useState(0);
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
    final selectedDestination = destinations[page.value];
    final selectedPage = selectedDestination.page ?? pages.values.toList()[0];
    return Row(
      children: [
        NavigationRail(
          labelType: NavigationRailLabelType.all,
          destinations: destinations,
          selectedIndex: page.value,
          onDestinationSelected: (index) => page.value = index,
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
  WikiDestination(this.destination, this.page)
      : super(icon: SizedBox.shrink(), label: Text(destination));
}

class NavigatedPage extends HookWidget {
  final Doc page;
  final Doc parent;
  NavigatedPage(this.page, {this.parent});

  @override
  Widget build(BuildContext context) {
    final pages = useProvider(docs).maybeWhen(
        data: (d) =>
            page.children.asMap().map((_, p) => MapEntry(p, d.pages[p])),
        orElse: () => <String, Doc>{});
    if (page.children.isEmpty || parent == page) {
      return WikiPage(page);
    } else {
      return NavigationInset(pages, parent: page);
    }
  }
}

class WikiPage extends StatelessWidget {
  final Doc page;
  WikiPage(this.page);

  @override
  Widget build(BuildContext context) {
    final document =
        useMemoized(() => NotusDocument.fromJson(json.decode(page.content)));
    final zefyrController = useMemoized(() => ZefyrController(document));
    final focusNode = useFocusNode();
    final editing = useState(false);

    return Scaffold(
      body: ZefyrScaffold(
        child: editing.value
            ? ZefyrEditor(controller: zefyrController, focusNode: focusNode)
            : ZefyrView(document: document),
      ),
      floatingActionButton: Builder(
        builder: (context) {
          return editing.value
              ? FloatingActionButton(
                  child: Icon(Icons.save),
                  onPressed: () => _save(zefyrController, context, editing),
                )
              : FloatingActionButton(
                  child: Icon(Icons.edit),
                  onPressed: () => editing.value = true);
        },
      ),
    );
  }

  void _save(
      ZefyrController controller, BuildContext context, ValueNotifier editing) {
    final contents = jsonEncode(controller.document);

    // For this example we save our document to a temporary file.
    final file = File(Directory.systemTemp.path + "/quick_start.json");
    // And show a snack bar on success.
    file.writeAsString(contents).then((_) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text("Saved.")));
    });
    editing.value = false;
  }
}
