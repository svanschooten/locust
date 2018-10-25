import 'package:flutter/material.dart';
import '../common/page.dart';
import '../tabs/notes.dart';
import '../tabs/settings.dart';
import '../tabs/shopping.dart';
import '../tabs/todos.dart';

class HomePage extends StatelessWidget {
  final List<Page> _pages = [
    shoppingPage,
    todosPage,
    notesPage,
    settingsPage,
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _pages.length,
      child: new Scaffold(
        body: new Builder(builder: (BuildContext context) {
          return TabBarView(
            children: _pages.map((Page page) => page.content).toList(),
          );
        }),
        backgroundColor: Colors.blue,
        bottomNavigationBar: TabBar(
          tabs: _pages.map((Page page) => page.tab).toList(),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.black38,
          indicatorSize: TabBarIndicatorSize.label,
          indicatorPadding: EdgeInsets.all(5.0),
          indicatorColor: Colors.white,

        ),
      ),
    );
  }
}
