import 'package:flutter/material.dart';
import 'package:visual_discrimination_app/Auth/AuthProvider.dart';

class HomePage extends StatelessWidget {
  HomePage({this.onSignedOut});
  final VoidCallback onSignedOut;

  void _signOut(BuildContext context) async {
    try {
      var auth = AuthProvider.of(context).auth;
      await auth.signOut();
      onSignedOut();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Welcome'),
          actions: <Widget>[
            FlatButton(
                child: Text('Logout',
                    style: TextStyle(fontSize: 17.0, color: Colors.white)),
                onPressed: () => _signOut(context))
          ],
        ),
        body: Container(
          child: Center(
              child: Text('Welcome', style: TextStyle(fontSize: 32.0))),
        ));
  }
}