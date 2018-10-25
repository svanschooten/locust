
import 'package:firebase_database/firebase_database.dart';

class ShoppingItem {
  String id;
  String text;
  bool done;
  String createdBy;
  int createdAt;
  String updatedBy;
  int updatedAt;

  ShoppingItem(String id, String text, bool done, {String createdBy, int createdAt, String updatedBy, int updatedAt}) {
    this.id = id;
    this.text = text;
    this.done = done;
    this.createdBy = createdBy;
    this.createdAt = createdAt;
    this.updatedBy = updatedBy;
    this.updatedAt = updatedAt;
  }

  static ShoppingItem fromSnapshot(DataSnapshot snapshot) {
    try {
      return new ShoppingItem(
          snapshot.value['id'],
          snapshot.value['text'],
          snapshot.value['done'],
          createdBy: snapshot.value['created_by'],
          createdAt: snapshot.value['created_at'],
          updatedBy: snapshot.value['updated_by'],
          updatedAt: snapshot.value['updated_at']
      );
    } catch (e) {
      return null;
    }
  }

  dynamic toJson() {
    return {
      "id": id,
      "text": text,
      "done": done,
      "created_by": createdBy,
      "created_at": createdAt,
      "updated_by": updatedBy,
      "updated_at": updatedAt
    };
  }
}