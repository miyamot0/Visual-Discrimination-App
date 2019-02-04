import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditPage extends StatefulWidget {
  final String uid;
  final String documentId;
  final String participantTag;
  final String descriptionTag;
  final double difficultyValue;
  final double trialCount;
  final double displaySeconds;

  EditPage({
    this.uid,
    this.documentId,
    this.participantTag,
    this.descriptionTag,
    this.difficultyValue,
    this.trialCount,
    this.displaySeconds,
  });

  @override
  EditPageState createState() => EditPageState(
    difficultyValue,
    trialCount,
    displaySeconds,
    descriptionTag,
  );
}

class EditPageState extends State<EditPage> {
  double difficultyValue;
  double trialCount;
  double displaySeconds;
  String descTag;

  final key = new GlobalKey<ScaffoldState>();
  final textEditController = TextEditingController();
  final textStyle = TextStyle(
    fontFamily: "Roboto",
    fontSize: 20.0,
  );

  EditPageState(
    this.difficultyValue,
    this.trialCount,
    this.displaySeconds,
    this.descTag,
  );

  updateStateRemotely() async {
    try {
      await Firestore.instance.collection('storage/${widget.uid}/participants').document(widget.documentId).setData(
        {
          'trialNumbers' : trialCount,
          'difficultyLevel' : difficultyValue,
          'displayTime' : displaySeconds,
          'descriptionTag' : textEditController.text,
        },
        merge: true,
      );
      //.then(showToastSuccess);
    } catch (e) {
      showToastFailed(null);
    }
  }

  // Stubbed for now
  showToastSuccess(state) {
    key.currentState.removeCurrentSnackBar(reason: SnackBarClosedReason.dismiss);
    key.currentState.showSnackBar(
      SnackBar(
        content: new Text(
          "Uploaded to server"
        ),
        duration: Duration(
          seconds: 1
        ),
      ),
    );
  }

  showToastFailed(state) {
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
  void initState() {
    super.initState();
    textEditController.text = descTag;
    textEditController.addListener(updateStateRemotely);
  }

  @override
  void dispose() {
    textEditController.dispose();

    super.dispose();
  }

  @override
  Widget build (BuildContext ctxt) {
    return new Scaffold(
      key: key,
      appBar: new AppBar(
        title: new Text(
          "Participant: ${widget.participantTag}"
        ),
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
                  bottom: 50.0,
                ),
                child: Text(
                  "To begin the visual discrimination task, select the number of trials desired and the level of difficulty. The levels of difficulty represent the distance from equal difference between each of the stimuli (i.e., equal similarity)",
                  style: textStyle,
                ),
              ),
              Text(
                "Select Number of Trials",
                style: textStyle,
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

                    updateStateRemotely();
                  });
                },
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: 10.0,
                ),
                child: Text(
                  "Select Level of Difficulty",
                  style: textStyle,
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

                    updateStateRemotely();
                  });
                },
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: 10.0,
                ),
                child: Text(
                  "Select Display Times",
                  style: textStyle,
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

                    updateStateRemotely();
                  });
                },
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      "Participant Comments",
                      style: textStyle,
                    ),
                    TextField(
                      controller: textEditController,
                    )
                  ]
                ),
              )
            ],
          ),
        ),
      )
    );
  }
}