import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:xcontext/tiny_xcontext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'state.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) => ProviderScope(
        child: MaterialApp(
          title: 'Sawyer Documentation',
          debugShowCheckedModeBanner: false,
          theme: ThemeData.dark().copyWith(
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          darkTheme: ThemeData.dark().copyWith(
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          themeMode: ThemeMode.dark,
          home: Builder(
            builder: (context) => MediaQuery(
              data: context.mq
                  .copyWith(textScaleFactor: context.mq.textScaleFactor * 1.25),
              child: const HomePage(),
            ),
          ),
        ),
      );
}

class HomePage extends HookWidget {
  const HomePage({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final editing = useProvider(editingProvider);
    final pages = useProvider(docs).rootPages;
    final pagesState = useProvider(docs);

    return Scaffold(
      body: pages.length < 2
          ? const Center(child: CircularProgressIndicator())
          : NavigationInset(pages, pagesState),
      floatingActionButton: !kIsWeb
          ? editing.editing
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FloatingActionButton(
                      onPressed: () => editing.delete(),
                      child: const Icon(Icons.delete),
                    ),
                    const SizedBox(height: 20),
                    FloatingActionButton(
                      onPressed: () => editing.save(),
                      child: const Icon(Icons.save),
                    ),
                  ],
                )
              : FloatingActionButton(
                  onPressed: () => editing.editing = true,
                  child: const Icon(Icons.edit),
                )
          : null,
    );
  }
}

String getKey(Doc parent, Doc child, Map<String, Doc> pages) => '''
${parent?.path}, ${child?.path}, 
${child?.children?.map((c) => getKey(child, pages[c], pages))?.join()}''';

class NavigationInset extends HookWidget {
  NavigationInset(this.pages, this.pagesState, {this.parent})
      : super(key: Key(getKey(parent, parent, pagesState.pages)));
  final Map<String, Doc> pages;
  final Doc parent;
  final Documents pagesState;

  @override
  Widget build(BuildContext context) {
    // print('Rebuilding $key');
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
      destinations.add(WikiDestination('Add', null, isAdd: true));
    }
    if (pagesState.requestedPage != null) {
      final newPage = pagesState.requestedPage;
      for (final d in destinations.asMap().entries) {
        if (d.value.isAdd || d.value.page == null) {
          continue;
        }
        final destPage = d.value.page.path.split(ext)[0];
        if (newPage == destPage) {
          scheduleMicrotask(() => pagesState.showPage(null));
          page.value = d.key;
          break;
        } else if (newPage != null && newPage.startsWith(destPage)) {
          page.value = d.key;
        }
      }
    }
    final selectedDestination = destinations[page.value];
    final selectedPage = selectedDestination.page ?? pages.values.toList()[0];
    return Row(
      children: [
        NavigationRail(
          unselectedLabelTextStyle:
              context.theme.textTheme.subtitle1.copyWith(color: Colors.white70),
          elevation: 20,
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
        const VerticalDivider(thickness: 4, width: 4),
        Expanded(child: NavigatedPage(selectedPage, pagesState, parent: parent))
      ],
    );
  }
}

class WikiDestination extends NavigationRailDestination {
  WikiDestination(this.destination, this.page, {this.isAdd = false})
      : super(
            icon: isAdd ? const Icon(Icons.add) : const SizedBox.shrink(),
            label: isAdd
                ? const SizedBox.shrink()
                : Text(destination.toUpperCase()));
  final String destination;
  final Doc page;
  final bool isAdd;
}

class NavigatedPage extends HookWidget {
  NavigatedPage(this.page, this.pagesState, {this.parent})
      : super(key: Key(getKey(parent, page, pagesState.pages)));
  final Doc page;
  final Doc parent;
  final Documents pagesState;

  @override
  Widget build(BuildContext context) {
    final children =
        page.children.asMap().map((_, p) => MapEntry(p, pagesState.pages[p]));
    if (page.children.isEmpty || (parent == page)) {
      return WikiPage(page);
    } else {
      return NavigationInset(children, pagesState, parent: page);
    }
  }
}

class WikiPage extends HookWidget {
  WikiPage(this.page) : super(key: ObjectKey(page));
  final Doc page;

  @override
  Widget build(BuildContext context) {
    final editing = useProvider(editingProvider);
    final pages = useProvider(docs);
    final _titleController = useTextEditingController(text: page.name);
    final _controller = useTextEditingController(text: page.content);
    editing.save =
        () => _save(pages, _titleController, _controller, context, editing);
    editing.delete = () => _delete(pages, page, context, editing);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: editing.editing
          ? Column(
              children: [
                TextField(
                    controller: _titleController,
                    minLines: 1,
                    style: Theme.of(context).textTheme.headline4),
                Expanded(
                  child: TextField(
                      controller: _controller,
                      expands: true,
                      maxLines: null,
                      style: Theme.of(context).textTheme.subtitle1),
                ),
              ],
            )
          : Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                child: MarkdownBody(
                  onTapLink: (str) async {
                    print('Navigate to $str');
                    if (str.contains('://') ||
                        str.contains('.org') ||
                        str.contains('.dev')) {
                      if (str.contains('http://')) {
                        str = str.replaceAll('http://', 'https://');
                      }
                      if (!str.contains('https://')) {
                        str = 'https://$str';
                      }
                      await canLaunch(str);
                      await launch(str);
                    } else {
                      pages.showPage(str.split(ext)[0]);
                    }
                  },
                  styleSheet: MarkdownStyleSheet(
                      blockSpacing: 15,
                      h1Align: WrapAlignment.center,
                      textScaleFactor: 1.25),
                  data: '''
# ${_titleController.text.toUpperCase()}
---
${_controller.text.isNullOrEmpty ? '## This Page is Empty' : _controller.text}
''',
                  shrinkWrap: false,
                ),
              ),
            ),
    );
  }

  Future<void> _save(
      Documents pages,
      TextEditingController titleController,
      TextEditingController controller,
      BuildContext context,
      EditingState editing) async {
    final scaffold = Scaffold.of(context);
    await pages.savePage(editing, page, titleController.text, controller.text);
    scaffold.showSnackBar(const SnackBar(content: Text('Saved')));
    editing.editing = false;
  }

  void _delete(
      Documents pages, Doc page, BuildContext context, EditingState editing) {
    final scaffold = Scaffold.of(context);
    scaffold.showSnackBar(
      SnackBar(
        duration: 5.seconds,
        content: Text('Are you sure you want to delete ${page.name}'),
        action: SnackBarAction(
          label: 'Yes',
          onPressed: () async {
            final success = await pages.deletePage(editing, page);
            scaffold.showSnackBar(
              SnackBar(
                duration: success ? 5.seconds : 8.seconds,
                content: Text(
                  success
                      ? 'Deleted'
                      : """
Can't delete a page that has children, first delete or move the children (moving has to be done manually)""",
                ),
              ),
            );
            editing.editing = false;
          },
        ),
      ),
    );
  }
}
