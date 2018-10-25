import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import '../common/page.dart';
import 'package:uuid/uuid.dart';
import '../common/dialog.dart';
import '../models/shopping_item.dart';

final Page shoppingPage = new Page(
  "Shopping",
  Icons.shopping_cart,
  _ShoppingPage()
);

class _ShoppingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _ShoppingPageState();
  }
}

class _ShoppingPageState extends State<_ShoppingPage> {

  final Map<String, ShoppingItem> _items = new Map();
  final DatabaseReference database = FirebaseDatabase.instance.reference().child("shopping");
  final Uuid uuid = new Uuid();
  String _justAdded;
  static Timer _sessionTimer;

  @override
  void initState() {
    super.initState();
    database.keepSynced(true);
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: new Text("Shopping"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addItem,
          ),
          IconButton(
              icon: Icon(Icons.clear_all),
              onPressed: _clearFinishedItems
          )
        ],
      ),
      body: _buildListView(),
    );
  }

  Widget _buildListView() {
    _justAdded = null;
    return FirebaseAnimatedList(
      query: database.orderByChild("created_at"),
      sort: (DataSnapshot dataSnapshot1, DataSnapshot dataSnapshot2) {
        ShoppingItem compareObject1 = ShoppingItem.fromSnapshot(dataSnapshot1);
        ShoppingItem compareObject2 = ShoppingItem.fromSnapshot(dataSnapshot2);
        int compare1 = (compareObject1 == null ? compareObject1.createdAt : null);
        int compare2 = (compareObject2 == null ? compareObject2.createdAt : null);
        if (compare1 == null || compare2 == null) return -1;
        return compare2.compareTo(compare1);
      },
      itemBuilder: (BuildContext context, DataSnapshot snapshot, Animation<double> animation, int idx) {
        ShoppingItem shoppingItem = ShoppingItem.fromSnapshot(snapshot);
        if (shoppingItem.id == _justAdded) {
          _justAdded = null;
          _sessionTimer?.cancel();
          _sessionTimer = new Timer(Duration(milliseconds: 100), () => editItemText(shoppingItem, true));
        }
        return _buildRow(shoppingItem);
      },
    );
  }

  Widget _buildRow(ShoppingItem item) {
    _items[item.id] = item;
    return CheckboxListTile(
      title: new Text(item.text),
      value: item.done,
      secondary: new IconButton(icon: new Icon(Icons.edit), onPressed: () => editItemText(item)),
      onChanged: (bool value) {
        _setDone(item, value);
      },
    );
  }

  void editItemText(ShoppingItem item, [bool newItem = false]) {
    DialogFactory.createTextEditDialog(showDialog, context, newItem ? "" : item.text, (text) {
      _setText(item, text);
    }, "New shopping item");
  }

  void _setDone(ShoppingItem item, bool done) {
    ApplicationState applicationState = Application.of(context);
    item.updatedBy = applicationState.currentUser.id;
    item.updatedAt = DateTime.now().millisecondsSinceEpoch;
    item.done = done;
    database.child(item.id).set(item.toJson());
  }

  void _setText(ShoppingItem item, String text) {
    ApplicationState applicationState = Application.of(context);
    item.updatedBy = applicationState.currentUser.id;
    item.updatedAt = DateTime.now().millisecondsSinceEpoch;
    item.text = text;
    database.child(item.id).set(item.toJson());
  }


  void _addItem() {
    ApplicationState applicationState = Application.of(context);
    String id = uuid.v4();
    _justAdded = id;
    database.child(id).set(new ShoppingItem(id, "New shopping item", false,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      createdBy: applicationState.currentUser.id,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      updatedBy: applicationState.currentUser.id,
    ).toJson());
  }

  void _clearFinishedItems() {
    List<ShoppingItem> toRemove = new List<ShoppingItem>();
    _items.forEach((id, item) {
      if (item.done) toRemove.add(item);
    });

    toRemove.forEach((item) {
      _items.remove(item.id);
      database.child(item.id).remove();
    });
  }
}