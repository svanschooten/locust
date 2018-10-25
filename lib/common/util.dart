import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

final String currentUserNameTag = "CURRENT_USER_NAME";
final String currentUserIdTag = "CURRENT_USER_ID";
final String currentUserEmailTag = "CURRENT_USER_EMAIL";

class Util {
  static T getFromIndex<T>(Map<String, T> map, int index) {
    return map[map.keys.toList(growable: false)[index]];
  }


  static Future<User> loadCurrentUserData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    try {
      String currentUserId = sharedPreferences.getString(currentUserIdTag);
      String currentUserName = sharedPreferences.getString(currentUserNameTag);
      String currentUserEmail = sharedPreferences.getString(currentUserEmailTag);
      return new User(currentUserId, currentUserName, currentUserEmail, true);
    } catch (e) {
      return null;
    }
  }

  static Future<void> storeCurrentUserData(User user) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(currentUserIdTag, user.id);
    sharedPreferences.setString(currentUserNameTag, user.name);
    sharedPreferences.setString(currentUserEmailTag, user.email);
  }

  static Future<void> clearCurrentUserData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.remove(currentUserIdTag);
    sharedPreferences.remove(currentUserNameTag);
    sharedPreferences.remove(currentUserEmailTag);
  }

  static String digest(String text) {
    List<int> bytes = utf8.encode(text);
    return sha1.convert(bytes).toString();
  }
}