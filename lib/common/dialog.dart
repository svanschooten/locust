import 'package:flutter/material.dart';

class DialogFactory {
  static void createDeleteDialog(Function showDialog, BuildContext context, Function fn) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Are you sure?"),
          content: new Text("This will not be retrievable after deletion."),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            new FlatButton(
              child: new Text("Delete", style: TextStyle(color: Colors.white),),
              color: Colors.red,
              onPressed: (){
                fn();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  static void createTextEditDialog(Function showDialog, BuildContext context, String text, Function fn, [String hintText]) {
    TextEditingController _controller = new TextEditingController(text: text);
    showDialog(builder: (BuildContext context) {
      return new AlertDialog(
        content: new TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: hintText != null ? hintText : "",
          ),
          autofocus: true,
        ),
        actions: [
          new FlatButton(
            child: new Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          new FlatButton(
            child: new Text("Save", style: TextStyle(color: Colors.white),),
            color: Colors.blue,
            onPressed: (){
              fn(_controller.text);
              Navigator.pop(context);
            },
          ),
        ],
      );
    }, context: context);
  }
}