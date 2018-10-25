import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../common/page.dart';
import '../main.dart';
import '../common/util.dart';
import '../pages/login.dart';

final Page settingsPage = new Page(
    "Settings",
    Icons.settings,
    _SettingsPage()
);

class _SettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState () => new _SettingsPageState();
}

class _SettingsPageState extends State<_SettingsPage> {
  final FirebaseAuth _fAuth = FirebaseAuth.instance;
  final GoogleSignIn _gSignIn = new GoogleSignIn();

  @override
  Widget build(BuildContext context) {
    ApplicationState applicationState = Application.of(context);
    return Scaffold(
      appBar: AppBar(
        title: new Text("Settings"),
      ),
      body: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: new Text(
                "User: " + (applicationState.currentUser == null ? "Unknown" : applicationState.currentUser.name),
                maxLines: 2,
                style: TextStyle(fontSize: 24.0, color: Colors.black38),
              ),
              margin: EdgeInsets.only(top: 10.0, bottom: 5.0),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              child: new Text(
                "Email: " + (applicationState.currentUser == null ? "Unknown" : applicationState.currentUser.email),
                maxLines: 2,
                overflow: TextOverflow.fade,
                style: TextStyle(fontSize: 16.0, color: Colors.black26),
              ),
              margin: EdgeInsets.only(top: 10.0, bottom: 5.0),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              child: new Text(
                "ID: " + (applicationState.currentUser == null ? "Unknown" : applicationState.currentUser.id),
                maxLines: 2,
                overflow: TextOverflow.fade,
                style: TextStyle(fontSize: 16.0, color: Colors.black26),
              ),
              margin: EdgeInsets.only(top: 10.0, bottom: 5.0),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RaisedButton(
              child: const Text(
                "Logout",
                style: TextStyle(color: Colors.white, fontSize: 24.0),
              ),
              onPressed: () async {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    // return object of type Dialog
                    return new AlertDialog(
                      title: new Text("Log out?"),
                      actions: <Widget>[
                        new FlatButton(
                            child: new Text("Cancel"),
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            }),
                        new FlatButton(
                          child: new Text(
                            "Log out",
                            style: TextStyle(color: Colors.white),
                          ),
                          color: Colors.blue,
                          onPressed: () async {
                            await _gSignIn.signOut();
                            await _fAuth.signOut();
                            await Util.clearCurrentUserData();

                            ApplicationState applicationState = Application.of(context);
                            applicationState.digest = null;
                            applicationState.currentUser = null;

                            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => new LoginPage()), (route) => route == null);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              color: Colors.blue,
            )
          ],
        ),
      ]),
    );
  }

}
