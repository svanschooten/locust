
import 'package:firebase_database/firebase_database.dart';

class Note {
  String id;
  String text;
  String title;
  String createdBy;
  int createdAt;
  String updatedBy;
  int updatedAt;

  Note(String id, String title, String text, {String createdBy, int createdAt, String updatedBy, int updatedAt}) {
    this.id = id;
    this.text = text;
    this.title = title;
    this.createdBy = createdBy;
    this.createdAt = createdAt;
    this.updatedBy = updatedBy;
    this.updatedAt = updatedAt;
  }

  static Note fromSnapshot(DataSnapshot snapshot) {
    try {
      return new Note(
          snapshot.value['id'],
          snapshot.value['title'],
          snapshot.value['text'],
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
      "title": title,
      "text": text,
      "created_by": createdBy,
      "created_at": createdAt,
      "updated_by": updatedBy,
      "updated_at": updatedAt
    };
  }
}