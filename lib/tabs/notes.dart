import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import '../common/page.dart';
import 'package:uuid/uuid.dart';
import '../common/dialog.dart';
import '../models/note.dart';

final Page notesPage = new Page(
  "Notes",
  Icons.edit,
  _NotesPage()
);

class _NotesPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new NotesPageState();
  }
}

class NotesPageState extends State<_NotesPage> {
  final DatabaseReference database =
      FirebaseDatabase.instance.reference().child("notes");
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
        title: new Text("Notes"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addNote,
          ),
        ],
      ),
      body: _buildListView(),
    );
  }

  Widget _buildListView() {
    return FirebaseAnimatedList(
      query: database.orderByChild("created_at"),
      sort: (DataSnapshot dataSnapshot1, DataSnapshot dataSnapshot2) {
        Note compareObject1 = Note.fromSnapshot(dataSnapshot1);
        Note compareObject2 = Note.fromSnapshot(dataSnapshot2);
        int compare1 = (compareObject1 == null ? compareObject1.createdAt : null);
        int compare2 = (compareObject2 == null ? compareObject2.createdAt : null);
        if (compare1 == null || compare2 == null) return -1;
        return compare2.compareTo(compare1);
      },
      itemBuilder: (BuildContext context, DataSnapshot snapshot,
          Animation<double> animation, int idx) {
        Note note = Note.fromSnapshot(snapshot);
        if (note.id == _justAdded) {
          _justAdded = null;
          _sessionTimer?.cancel();
          _sessionTimer = new Timer(Duration(milliseconds: 100), () => editNote(note, true));
        }
        return _buildRow(note);
      },
    );
  }

  Widget _buildRow(Note note) {
    return Container(
      margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          new Container(
            padding: EdgeInsets.only(left: 10.0),
            color: Colors.blue,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                new Text(
                  note.title,
                  style: TextStyle(color: Colors.white),
                ),
                Row(
                  children: [
                    new IconButton(
                        icon: new Icon(Icons.edit),
                        onPressed: () => editNote(note),
                        color: Colors.white),
                    new IconButton(
                        icon: new Icon(Icons.delete),
                        onPressed: () => _removeNote(note),
                        color: Colors.white),
                  ],
                ),
              ],
            ),
          ),
          new Container(
            padding:
                EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
            child: new Text(
              note.text,
              maxLines: null,
            ),
          )
        ],
      ),
    );
  }

  void editNote(Note note, [bool newItem = false]) async {
    TextEditingController _textController =
        new TextEditingController(text: newItem ? "" : note.text);
    TextEditingController _titleController =
        new TextEditingController(text: newItem ? "" : note.title);
    await showDialog(
        builder: (BuildContext context) {
          return new AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                new TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: "New note title",
                  ),
                  autofocus: true,
                ),
                new Divider(),
                new TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    hintText: "New note body",
                  ),
                  maxLines: null,
                ),
              ],
            ),
            actions: [
              new FlatButton(
                child: new Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              ),
              new FlatButton(
                child: new Text(
                  "Save",
                  style: TextStyle(color: Colors.white),
                ),
                color: Colors.blue,
                onPressed: () {
                  _updateNote(
                      note, _titleController.text, _textController.text);
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
        context: context);
  }

  void _updateNote(Note note, String title, String text) {
    ApplicationState applicationState = Application.of(context);
    note.updatedBy = applicationState.currentUser.id;
    note.updatedAt = DateTime.now().millisecondsSinceEpoch;
    note.title = title;
    note.text = text;
    database.child(note.id).set(note.toJson());
  }

  void _addNote() {
    ApplicationState applicationState = Application.of(context);
    String id = uuid.v4();
    _justAdded = id;
    database.child(id).set(new Note(id, "New note title", "New note body",
      createdAt: DateTime.now().millisecondsSinceEpoch,
      createdBy: applicationState.currentUser.name,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      updatedBy: applicationState.currentUser.id,
    ).toJson());
  }

  void _removeNote(Note note) {
    DialogFactory.createDeleteDialog(showDialog, context, () {
      database.child(note.id).remove();
    });
  }
}
