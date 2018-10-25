import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../main.dart';
import '../common/util.dart';
import '../models/user.dart';
import './home.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  String _googleEmail;
  String _firebaseEmail;
  bool _loggingIn = false;
  String _error;
  final FirebaseAuth _fAuth = FirebaseAuth.instance;
  final GoogleSignIn _gSignIn = new GoogleSignIn(
    signInOption: SignInOption.standard,
    scopes: [
      "email",
      "profile",
      "openid",
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/userinfo.profile"
    ]
  );
  final DatabaseReference database = FirebaseDatabase.instance.reference().child("users");

  @override
  Widget build(BuildContext context) {
    Util.loadCurrentUserData().then((User user) {
      if (user != null && user.email != null) {
        _signIn();
      }
    });

    ApplicationState applicationState = Application.of(context);

    String message;
    if (applicationState.digest != null) {
      message = "Tried to log in with email digest:\n" + applicationState.digest;
    } else if (_firebaseEmail != null) {
      message = "Firebase authenticated account:\n" + _firebaseEmail;
    } else if (_googleEmail != null) {
      message = "Google authenticated account:\n" + _googleEmail;
    } else if (_loggingIn) {
      message = "Logging in!";
    }

    List<Widget> loginWidgets = [
      Text(
        "Please log in!",
        style: TextStyle(fontSize: 28.0, color: Colors.black38),
      ),
      Text(
        "Either your google account is not logged in\nor not coupled to a user.",
        maxLines: 5,
        style: TextStyle(fontSize: 12.0, color: Colors.black38),
      )
    ];

    if (_error != null) {
      loginWidgets.add(
        new Container (
          padding: const EdgeInsets.all(16.0),
          width: MediaQuery.of(context).size.width*0.8,
          child: new Column (
            children: <Widget>[
              Text(
                _error,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                maxLines: 9,
                style: TextStyle(fontSize: 12.0, color: Colors.redAccent),
              ),
            ],
          ),
        )
      );
    }

    if (message != null) {
      loginWidgets.add(
        Text(
          message,
          maxLines: 2,
          style: TextStyle(fontSize: 12.0, color: Colors.black38),
        ));
    }

    loginWidgets.add(RaisedButton(
      child: const Text(
        "Log in",
        style: TextStyle(color: Colors.white, fontSize: 24.0),
      ),
      onPressed: () async {
        await _gSignIn.signOut();
        await _fAuth.signOut();
        _signIn();
      },
      color: Colors.blue,
    ));

    return Container(
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: loginWidgets,
          )
        ],
      ),
    );
  }

  void _signIn() async {
    User user;
    String digest;
    ApplicationState applicationState = Application.of(context);
    GoogleSignInAccount googleSignInAccount;
    GoogleSignInAuthentication authentication;
    FirebaseUser _firebaseUser;
    if (_loggingIn) return;
    setState(() {
      _loggingIn = true;
      _error = null;
    });

    try {
      googleSignInAccount = await _gSignIn.signIn();
      authentication = await googleSignInAccount.authentication;

      print("google token: " + authentication.idToken);
      if (googleSignInAccount != null) {
        setState(() {
          _googleEmail = googleSignInAccount.email;
        });
      }

      _firebaseUser = await _fAuth.signInWithGoogle(
          idToken: authentication.idToken,
          accessToken: authentication.accessToken);

      print("firebase email: " + _firebaseUser.email);
      if (_firebaseUser != null) {
        setState(() {
          _firebaseEmail = _firebaseUser.email;
        });
      }

      digest = Util.digest(_firebaseUser.email);
      print("Logging in with digest: " + digest);
      applicationState.digest = digest;

      user = User.fromSnapshot(await database.child(digest).once());
      print("New user?");

      if (user == null && context != null) {
        print("New user!");
        database.child(digest).set(new User(googleSignInAccount.displayName, digest, googleSignInAccount.email, false).toJson());
      }

      if (user != null && user.active && context != null) {
        applicationState.currentUser = user;

        Util.storeCurrentUserData(user);
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) => new HomePage()),
                (route) => route == null);
      }
    } catch (e) {
      print(e);
      if (!this.mounted) return;
      setState((){
        _error = e.toString();
        _loggingIn = false;
      });
    }

    if (context == null || !this.mounted) return;
    setState(() {
      _loggingIn = false;
    });
    return;
  }
}
