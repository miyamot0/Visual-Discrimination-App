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

import 'package:visual_discrimination_app/resources.dart';

class EditPage extends StatefulWidget {
  final String uid;
  final String documentId;
  final String participantTag;
  final String descriptionTag;
  final double difficultyValue;
  final double trialCount;
  final double displaySeconds;
  final double itiSeconds;

  EditPage({
    this.uid,
    this.documentId,
    this.participantTag,
    this.descriptionTag,
    this.difficultyValue,
    this.trialCount,
    this.displaySeconds,
    this.itiSeconds,
  });

  @override
  EditPageState createState() => EditPageState(
    difficultyValue,
    trialCount,
    displaySeconds,
    descriptionTag,
    itiSeconds
  );
}

class EditPageState extends State<EditPage> {
  double difficultyValue;
  double trialCount;
  double displaySeconds;
  double itiSeconds;
  String descTag;

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
    this.itiSeconds,
  );

  void updateStateRemotely() async {
    try {
      await Firestore.instance.collection('storage/${widget.uid}/participants').document(widget.documentId).setData(
        {
          'trialNumbers' : trialCount,
          'difficultyLevel' : difficultyValue,
          'displayTime' : displaySeconds,
          'descriptionTag' : textEditController.text,
          'itiTime' : itiSeconds,
        },
        merge: true,
      );
    } on PlatformException catch (e) {
      await showAlert(context, e.message);
    }
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
                min: 4.0,
                max: 48.0,
                divisions: 11,
                label: 'Run $trialCount Trials',
                onChanged: (double value) {
                  setState(() {
                    trialCount = num.parse(value.toStringAsFixed(2));

                    updateStateRemotely();
                  });
                },
              ),
              Text(
                "Select ITI Length",
                style: textStyle,
              ),
              Slider(
                value: itiSeconds,
                min: 0.0,
                max: 5.0,
                divisions: 5,
                label: 'ITI = $itiSeconds Seconds',
                onChanged: (double value) {
                  setState(() {
                    itiSeconds = num.parse(value.toStringAsFixed(2));

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
                min: 0.0,
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