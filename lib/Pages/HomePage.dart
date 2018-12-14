import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:visual_discrimination_app/Auth/AuthProvider.dart';
import 'package:visual_discrimination_app/Pages/AddPage.dart';
import 'package:visual_discrimination_app/Pages/EditPage.dart';

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
            child: Text(
              'Add Participant',
              style: TextStyle(
                fontSize: 17.0,
                color: Colors.white
              ),
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => 
                AddPage(
                  uid: uid,
                ),
              ),
            ),
          ),
          FlatButton(
            child: Text(
              'Logout',
              style: TextStyle(
                fontSize: 17.0, 
                color: Colors.white
              )
            ),
            onPressed: () => _signOut(context)
          ),
        ],
      ),
      body: Container(
        child: StreamBuilder(
          stream: Firestore.instance.collection('storage/$uid/participants').snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) return new Text('Loading...');

            return new ListView(
              children: snapshot.data.documents.map((document) {
                return new ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20.0, 
                    vertical: 10.0
                  ),
                  leading: Container(
                    padding: EdgeInsets.only(
                      right: 12.0
                    ),
                    decoration: new BoxDecoration(
                      border: new Border(
                        right: new BorderSide(
                          width: 1.0, 
                          color: Colors.white24
                        )
                      )
                    ),
                    child: Icon(Icons.person),
                  ),
                  title: new Text(document['participantTag'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  subtitle: new Text(document['descriptionTag']),
                  trailing: Container(
                    padding: EdgeInsets.only(
                      right: 12.0,
                    ),
                    decoration: new BoxDecoration(
                      border: new Border(
                        right: new BorderSide(
                          width: 1.0, 
                          color: Colors.white24
                        ),
                      ),
                    ),
                    child: GestureDetector(
                      child: Icon(
                        Icons.edit, 
                        size: 30.0,
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => 
                          EditPage(
                            uid: uid,
                            documentId: document.documentID,
                            trialCount: (document['trialNumbers'] as num).toDouble(),
                            difficultyValue: (document['difficultyLevel'] as num).toDouble(),
                            displaySeconds: (document['displayTime'] as num).toDouble(),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
            );
          },
        ),
      )
    );
  }
}