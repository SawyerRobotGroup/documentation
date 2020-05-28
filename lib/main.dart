import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'state.dart';

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

String getKey(Doc parent, Map<String, Doc> pages) {
  return '${parent?.path}, ${pages.keys.join(',')}';
}

class NavigationInset extends HookWidget {
  final Map<String, Doc> pages;
  final Doc parent;
  NavigationInset(this.pages, {this.parent})
      : super(key: Key(getKey(parent, pages)));

  @override
  Widget build(BuildContext context) {
    final pagesState = useProvider(docs);
    final page = useState(0);
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
    useValueChanged(pagesState.requestedPage, (_, __) {
      final newPage = pagesState.requestedPage;
      for (final d in destinations.asMap().entries) {
        if (d.value.isAdd || d.value.page == null) {
          continue;
        }
        final destPage = d.value.page.path.split(ext)[0];
        if (newPage == destPage) {
          scheduleMicrotask(() => pagesState.showPage(null));
          page.value = d.key;
          print('Found It!');
          return;
        } else if (newPage != null && newPage.startsWith(destPage)) {
          page.value = d.key;
          print('Found a parent!');
          return;
        }
      }
    });
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
    return Padding(
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
              onTapLink: (str) async {
                print(str);
                if (str.contains('://')) {
                  await canLaunch(str);
                  launch(str);
                } else {
                  pages.showPage(str.split(ext)[0]);
                }
              },
              selectable: true,
              styleSheet: MarkdownStyleSheet(h1Align: WrapAlignment.center),
              data: '# ${_titleController.text}\n---\n' +
                  (_controller.text.isNullOrEmpty
                      ? '## This Page is Empty'
                      : _controller.text),
              shrinkWrap: false,
            ),
    );
  }

  void _save(
      Documents pages,
      TextEditingController titleController,
      TextEditingController controller,
      BuildContext context,
      EditingState editing) async {
    final scaffold = Scaffold.of(context);
    await pages.savePage(editing, page, titleController.text, controller.text);
    // For this example we save our document to a temporary file.
    scaffold.showSnackBar(SnackBar(content: Text("Saved")));
    editing.editing = false;
  }
}
