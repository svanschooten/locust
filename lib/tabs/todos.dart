import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import '../common/page.dart';
import '../common/dialog.dart';
import '../models/todo.dart';
import 'package:uuid/uuid.dart';

final Page todosPage = new Page(
  "Todos",
  Icons.check_box,
    new _TodoPage()
);

class _TodoPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState () => new _TodoPageState();
}

class _TodoPageState extends State<_TodoPage> {
  final Map<String, Todo> _todos = new Map();
  final DatabaseReference database =
      FirebaseDatabase.instance.reference().child("todos");
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
    _justAdded = null;
    return Scaffold(
      appBar: AppBar(
        title: new Text("Todos"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: addTodo,
          ),
          IconButton(
              icon: Icon(Icons.clear_all), onPressed: _clearFinishedTodos)
        ],
      ),
      body: _buildListView(),
    );
  }

  Widget _buildListView() {
    return FirebaseAnimatedList(
      query: database.orderByChild("created_at"),
      sort: (DataSnapshot dataSnapshot1, DataSnapshot dataSnapshot2) {
        Todo compareObject1 = Todo.fromSnapshot(dataSnapshot1);
        Todo compareObject2 = Todo.fromSnapshot(dataSnapshot2);
        int compare1 = (compareObject1 == null ? compareObject1.createdAt : null);
        int compare2 = (compareObject2 == null ? compareObject2.createdAt : null);
        if (compare1 == null || compare2 == null) return -1;
        return compare2.compareTo(compare1);
      },
      itemBuilder: (BuildContext context, DataSnapshot snapshot,
          Animation<double> animation, int idx) {
        Todo todo = Todo.fromSnapshot(snapshot);
        if (todo.id == _justAdded) {
          _justAdded = null;
          _sessionTimer?.cancel();
          _sessionTimer = new Timer(Duration(milliseconds: 100), () => editTodoText(todo, true));
        }
        return _buildRow(todo);
      },
    );
  }

  Widget _buildRow(Todo todo) {
    _todos[todo.id] = todo;
    return CheckboxListTile(
      title: new Text(todo.text),
      value: todo.done,
      secondary: new IconButton(
          icon: new Icon(Icons.edit), onPressed: () => editTodoText(todo)),
      onChanged: (bool value) {
        _setDone(todo, value);
      },
    );
  }

  void editTodoText(Todo todo, [bool newItem = false]) async {
    DialogFactory.createTextEditDialog(showDialog, context, newItem ? "" : todo.text, (text) {
      _setText(todo, text);
    }, "New todo");
  }

  void _setDone(Todo todo, bool done) {
    ApplicationState applicationState = Application.of(context);
    todo.updatedBy = applicationState.currentUser.id;
    todo.updatedAt = DateTime.now().millisecondsSinceEpoch;
    todo.done = done;
    database.child(todo.id).set(todo.toJson());
  }

  void _setText(Todo todo, String text) {
    ApplicationState applicationState = Application.of(context);
    todo.updatedBy = applicationState.currentUser.id;
    todo.updatedAt = DateTime.now().millisecondsSinceEpoch;
    todo.text = text;
    database.child(todo.id).set(todo.toJson());
  }

  void addTodo() {
    ApplicationState applicationState = Application.of(context);
    String id = uuid.v4();
    _justAdded = id;
    database.child(id).set(new Todo(id, "New Todo", false,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      createdBy: applicationState.currentUser.id,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      updatedBy: applicationState.currentUser.id,
    ).toJson());
  }

  void _clearFinishedTodos() {
    List<Todo> toRemove = new List<Todo>();
    _todos.forEach((id, todo) {
      if (todo.done) toRemove.add(todo);
    });

    toRemove.forEach((todo) {
      _todos.remove(todo.id);
      database.child(todo.id).remove();
    });
  }
}
