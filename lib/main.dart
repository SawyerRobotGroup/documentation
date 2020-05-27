import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sawyer Documentation',
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final page = useState(0);
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            destinations: [
              NavigationRailDestination(
                  icon: Icon(Icons.all_inclusive), label: Text('All'))
            ],
            selectedIndex: page.value,
          ),
          VerticalDivider(thickness: 1, width: 1),
          Expanded(child: WikiPage(page.value))
        ],
      ),
    );
  }
}

class WikiPage extends StatelessWidget {
  final int pageId;
  WikiPage(this.pageId);

  @override
  Widget build(BuildContext context) {
    return Center();
  }
}

final pages = {0: 'index.md'};
