import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddPage extends StatefulWidget {
  final String uid;

  AddPage({
    this.uid,
  });

  @override
  AddPageState createState() => AddPageState();
}

class FieldValidator {
  static String validate(String value) {
    return value.isEmpty ? 'Email can\'t be empty' : null;
  }
}

class AddPageState extends State<AddPage> {
  double difficultyValue = 1.0;
  double trialCount = 5.0;
  double displaySeconds = 1;

  final key = new GlobalKey<ScaffoldState>();

  final nameController = TextEditingController();
  final descController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    descController.dispose();

    super.dispose();
  }

  submitNewDocument() async {

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
    } catch (e) {
      showToastFailed();
    }
  }

  showToastFailed() {
    key.currentState.removeCurrentSnackBar(reason: SnackBarClosedReason.dismiss);
    key.currentState.showSnackBar(
      SnackBar(
        content: new Text(
          "Saving Failed!"
        ),
        duration: Duration(
          seconds: 1
        ),
      ),
    );
  }

  @override
  Widget build (BuildContext ctxt) {
    return new Scaffold(
      key: key,
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
                min: 1.0,
                max: 10.0,
                divisions: 9,
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