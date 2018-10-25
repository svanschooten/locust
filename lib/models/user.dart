
import 'package:firebase_database/firebase_database.dart';

class User {
  final String name;
  final String id;
  final String email;
  final bool active;

  User(this.id, this.name, this.email, this.active);

  static User fromSnapshot(DataSnapshot snapshot) {
    try {
      return new User(
          snapshot.value['id'],
          snapshot.value['name'],
          snapshot.value['email'],
          snapshot.value['active']
      );
    } catch (e) {
      return null;
    }
  }

  dynamic toJson() {
    return {
      "id": id,
      "name": name,
      "email": email,
      "active": active
    };
  }
}