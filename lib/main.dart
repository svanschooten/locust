import 'package:flutter/material.dart';
import './models/user.dart';
import './pages/login.dart';
import 'package:firebase_database/firebase_database.dart';

void main() {
  FirebaseDatabase.instance.setPersistenceEnabled(true);
  FirebaseDatabase.instance.setPersistenceCacheSizeBytes(500000);
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Application(
      child: MaterialApp(
        title: "JS49a Home App",
        home: new LoginPage(),
      ),
    );
  }
}

class Application extends StatefulWidget {
  final Widget child;

  Application({this.child});

  @override
  State<StatefulWidget> createState() => new ApplicationState();

  static ApplicationState of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_LoginContext) as _LoginContext).data;
  }
}

class ApplicationState extends State<Application> {
  User _currentUser;
  User get currentUser => _currentUser;
  set currentUser (User user) {
    setState(() {
      _currentUser = user;
    });
  }

  String _digest;
  String get digest => _digest;
  set digest (String newDigest) {
    setState((){
      _digest = newDigest;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new _LoginContext(
      data: this,
      child: widget.child,
    );
  }
}

class _LoginContext extends InheritedWidget {
  final ApplicationState data;

  @override
  bool updateShouldNotify(_LoginContext oldWidget) {
    return true;
  }

  _LoginContext({Key key, this.data, Widget child}): super(key: key, child: child);
}
