import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:visual_discrimination_app/Auth/AuthProvider.dart';

class HomePage extends StatelessWidget {
  HomePage({
    this.onSignedOut, 
    this.uid
  });

  final VoidCallback onSignedOut;
  final String uid;

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
          child: StreamBuilder(
            stream: Firestore.instance.collection('storage/$uid/data').snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) return new Text('Loading...');

              return new ListView(
                children: snapshot.data.documents.map((document) {
                  return new ListTile(
                    title: new Text(document['title']),
                    subtitle: new Text(document['type']),
                  );
                }).toList(),
              );
            },
          ),
        ));
  }
}