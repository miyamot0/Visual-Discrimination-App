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
*/

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:visual_discrimination_app/Dialogs/ErrorDialog.dart';

class AddPage extends StatefulWidget {
  final String uid;

  AddPage({
    this.uid,
  });

  @override
  AddPageState createState() => AddPageState();
}

class AddPageState extends State<AddPage> {
  double difficultyValue = 1.0;
  double trialCount = 5.0;
  double displaySeconds = 1;

  final nameController = TextEditingController();
  final descController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    descController.dispose();

    super.dispose();
  }

  /*
   * Submit a new record to FB 
   */
  void submitNewDocument() async {
    try {
      CollectionReference dbReplies = Firestore.instance.collection('storage/${widget.uid}/participants');

      Firestore.instance.runTransaction((Transaction tx) async {
        var replyObj = {
          'participantTag' : nameController.text,
          'descriptionTag' : descController.text,
          'trialNumbers' : trialCount,
          'difficultyLevel' : difficultyValue,
          'displayTime' : displaySeconds,
        };

        await dbReplies.add(replyObj); 
      }).then((val) {
        Navigator.pop(context, false);
      });
    } on PlatformException catch (e) {
      await showAlert(context, e.message);
    }
  }

  @override
  Widget build (BuildContext ctxt) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Discrimination Trial Task"),
      ),
      body: Align(
        alignment: Alignment.center,        
        child: Padding(
          padding: EdgeInsets.only(
            top: 10.0,
            left: 10.0,
            right: 10.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  bottom: 25.0,
                ),
                child: Text(
                  "To begin the visual discrimination task, select the number of trials desired and the level of difficulty. The levels of difficulty represent the distance from equal difference between each of the stimuli (i.e., equal similarity)"
                ),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Name'),
                controller: nameController,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                controller: descController,
              ),
              Padding(
                padding: EdgeInsets.only(
                  bottom: 25.0,
                  top: 25.0,
                ),
                child: Text(
                  "Select Number of Trials"
                ),
              ),
              Slider(
                value: trialCount,
                min: 4.0,
                max: 48.0,
                divisions: 11,
                label: 'Run $trialCount Trials',
                onChanged: (double value) {
                  setState(() {
                    trialCount = num.parse(value.toStringAsFixed(2));
                  });
                },
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: 10.0,
                ),
                child: Text(
                  "Select Level of Difficulty"
                ),
              ),
              Slider(
                value: difficultyValue,
                min: 0.0,
                max: 50.0,
                divisions: 50,
                label: '$difficultyValue % Similarity',
                onChanged: (double value) {
                  setState(() {
                    difficultyValue = num.parse(value.toStringAsFixed(2));
                  });
                },
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: 10.0,
                ),
                child: Text(
                  "Select Display Times"
                ),
              ),
              Slider(
                value: displaySeconds,
                min: 0.5,
                max: 10.0,              
                divisions: 95,
                label: 'Sample stimuli presented for $displaySeconds seconds',
                onChanged: (double value) {
                  setState(() {
                    displaySeconds = num.parse(value.toStringAsFixed(2));
                  });
                },
              ),
              RaisedButton(
                child: Text('Create a Participant',
                    style: TextStyle(fontSize: 20.0)),
                onPressed: submitNewDocument,
              ),
            ],
          ),
        ),
      )
    );
  }
}