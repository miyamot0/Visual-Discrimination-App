/* 
    The MIT License

    Copyright September 1, 2018 Shawn Gilroy/Louisiana State University

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.

    ---------------------------------------------------------------------

    This code also incorporates work from "coding-with-flutter-login-demo" under
    the following license:

    Copyright (c) 2018 Andrea Bizzotto [bizz84@gmail.com](mailto:bizz84@gmail.com)

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.
*/

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:visual_discrimination_app/Auth/AuthProvider.dart';
import 'package:visual_discrimination_app/Dialogs/ErrorDialog.dart';
import 'package:visual_discrimination_app/Dialogs/StatusDialog.dart';
import 'package:visual_discrimination_app/Pages/AddPage.dart';
import 'package:visual_discrimination_app/Pages/DisplayPage.dart';
import 'package:visual_discrimination_app/Pages/EditPage.dart';
import 'package:visual_discrimination_app/Pages/PracticePage.dart';
import 'package:visual_discrimination_app/Pages/TrialPage.dart';

class HomePage extends StatelessWidget {
  HomePage({
    this.onSignedOut, 
    this.uid,
  });

  final VoidCallback onSignedOut;
  final String uid;
  final trainingSessionCount = 24;

  /*
   * Sign out user
   */
  void signOut(BuildContext context) async {
    try {
      var auth = AuthProvider.of(context).auth;
      await auth.signOut();
      onSignedOut();
    } on PlatformException catch (e) {
      await showAlert(context, e.message);
    }
  }

  /*
   * Show options for editing/displaying 
   */
  void showOptionDialog<T>({ BuildContext context, Widget child }) {
    showDialog<T>(
      context: context,
      builder: (BuildContext context) => child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Discriminability Training App'),
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
            onPressed: () => signOut(context)
          ),
        ],
      ),
      body: Container(
        child: StreamBuilder(
          stream: Firestore.instance.collection('storage/$uid/participants').snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) return const CircularProgressIndicator();

            return new ListView(
              children: snapshot.data.documents.map((document) {
                return new ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20.0, 
                    vertical: 10.0
                  ),
                  leading: GestureDetector(
                    child: Icon(
                      Icons.play_arrow,
                      size: 30.0,
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => 
                        TrialPage(
                          uid: uid,
                          documentId: document.documentID,
                          difficultyLevel: (document['difficultyLevel'] as num).toDouble(),
                          trialCount: (document['trialNumbers'] as num).toDouble().round(),
                          presentationLength: (document['displayTime'] as num).toDouble(),
                          iti: (document['itiTime'] as num).toInt(),
                        ),
                      ),
                    ),
                  ),
                  title: new Text(document['participantTag'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
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
                          color: Colors.white24,
                        ),
                      ),
                    ),
                    child: GestureDetector(
                      child: Icon(
                        Icons.edit, 
                        size: 30.0,
                      ),
                      onTap: () {
                        showOptionDialog<String>(
                          context: context,
                          child: SimpleDialog(
                            title: const Text('Display/Edit'),
                            children: <Widget>[
                              StatusDialogItem(
                                icon: Icons.show_chart,
                                text: 'Show Data',
                                onPressed: () { 
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => 
                                      DisplayPage(
                                        uid: uid,
                                        documentId: document.documentID,
                                        participant: document.data['participantTag'].toString(),
                                        training: false,
                                      ),
                                    ),
                                  )
                                  .then((result) => Navigator.pop(context)
                                  );
                                }
                              ),
                              StatusDialogItem(
                                icon: Icons.mode_edit,
                                text: 'Edit Session',
                                onPressed: () { 
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => 
                                      EditPage(
                                        uid: uid,
                                        documentId: document.documentID,
                                        trialCount: (document['trialNumbers'] as num).toDouble(),
                                        difficultyValue: (document['difficultyLevel'] as num).toDouble(),
                                        displaySeconds: (document['displayTime'] as num).toDouble(),
                                        participantTag: document['participantTag'].toString(),
                                        descriptionTag: document['descriptionTag'].toString(),
                                        itiSeconds: (document['itiTime'] as num).toDouble(),
                                      ),
                                    ),
                                  )
                                  .then((result) => Navigator.pop(context)
                                  );
                                }
                              ),
                              StatusDialogItem(
                                icon: Icons.info,
                                text: 'Practice (1s/1c)',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => 
                                      PracticePage(
                                        uid: uid,
                                        documentId: document.documentID,
                                        trialCount: trainingSessionCount,
                                        comparisons: 1,
                                        iti: (document['itiTime'] as num).toInt(),
                                      ),
                                    ),
                                  )
                                  .then((result) => Navigator.pop(context)
                                  );
                                },
                              ),
                              StatusDialogItem(
                                icon: Icons.show_chart,
                                text: 'Display Practice (1s/1c)',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => 
                                      DisplayPage(
                                        uid: uid,
                                        documentId: document.documentID,
                                        participant: document.data['participantTag'].toString(),
                                        training: true,
                                        level: 1,
                                      ),
                                    ),
                                  )
                                  .then((result) => Navigator.pop(context)
                                  );
                                },
                              ),
                              StatusDialogItem(
                                icon: Icons.info,
                                text: 'Practice (1s/2c)',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => 
                                      PracticePage(
                                        uid: uid,
                                        documentId: document.documentID,
                                        trialCount: trainingSessionCount,
                                        comparisons: 2,
                                        iti: (document['itiTime'] as num).toInt(),
                                      ),
                                    ),
                                  )
                                  .then((result) => Navigator.pop(context)
                                  );
                                },
                              ),
                              StatusDialogItem(
                                icon: Icons.show_chart,
                                text: 'Display Practice (1s/2c)',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => 
                                      DisplayPage(
                                        uid: uid,
                                        documentId: document.documentID,
                                        participant: document.data['participantTag'].toString(),
                                        training: true,
                                        level: 2,
                                      ),
                                    ),
                                  )
                                  .then((result) => Navigator.pop(context)
                                  );
                                },
                              ),
                            ]
                          )
                        );
                      }
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