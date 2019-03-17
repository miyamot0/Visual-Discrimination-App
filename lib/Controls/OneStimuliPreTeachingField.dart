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

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:audioplayers/audio_cache.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:visual_discrimination_app/Dialogs/ErrorDialog.dart';
import 'package:visual_discrimination_app/Dialogs/FeedbackDialog.dart';
import 'package:visual_discrimination_app/Models/TrialElement.dart';

class OneStimuliPreTeachingField extends StatefulWidget {
  final String uid;
  final String documentId;
  final int trialNumber;

  const OneStimuliPreTeachingField(
  {
    Key key,
    @required this.uid,
    @required this.documentId,
    @required this.trialNumber,
  }) : super(key: key);

  @override
  OneStimuliPreTeachingFieldState createState() => OneStimuliPreTeachingFieldState();
}

class OneStimuliPreTeachingFieldState extends State<OneStimuliPreTeachingField> with SingleTickerProviderStateMixin {
  /* Layout ref's */
  MediaQueryData mediaData;
  static const double padding = 50.0;
  static double iconWidth = 0;

  /* Audio ref's */
  static const audioPath = "short-success-sound-glockenspiel-treasure-video-game.mp3";
  static AudioCache player = new AudioCache();

  List<TrialElement> trialList = [];

  double opacityReferent  = 1.0,
         opacitySelection = 0.0;

  AnimationController animController;

  /* Response ref's */
  int currentTrial = 1,
      s1c1 = 0,
      s1c2 = 0,
      s2c1 = 0,
      s2c2 = 0;

  void onSelected(bool output) async {

    if (trialList[currentTrial - 1].currentColor == Colors.blue) {
      if (trialList[currentTrial - 1].isOnLeftSide) 
        s1c1 = (output) ? s1c1 + 1 : s1c1;
      else
        s1c2 = (output) ? s1c2 + 1 : s1c2;
    } else {
      if (trialList[currentTrial - 1].isOnLeftSide) 
        s2c1 = (output) ? s2c1 + 1 : s2c1;
      else
        s2c2 = (output) ? s2c2 + 1 : s2c2;
    }

    currentTrial = currentTrial + 1;

    if (output) 
      player.play(audioPath);

    setState(() {
      opacityReferent = 0.0;
      opacitySelection = 0.0; 
    });

    showFeedback(context, output);

    if (currentTrial > widget.trialNumber) {
      await Future.delayed(Duration(seconds: 3)).then((asdf) async {
        try {
          CollectionReference dbSessions = Firestore.instance.collection('storage/${widget.uid}/participants/${widget.documentId}/practice1stim');

          Firestore.instance.runTransaction((Transaction tx) async {

            var nCorrect = s1c1 + s1c2 + s2c1 + s2c2;

            var replyObj = {
              'correctAnswers' : nCorrect,
              'wrongAnswers' : widget.trialNumber - nCorrect,
              's1c1' : s1c1,
              's1c2' : s1c2,
              's2c1' : s2c1,
              's2c2' : s2c2,
              'trialCount' : widget.trialNumber,
              'sessionDate' : DateTime.now().toString(),
            };

            await dbSessions.add(replyObj); 
          });
        } on PlatformException catch (e) {
          await showAlert(context, e.message);
        } finally {
          Navigator.pop(context);
        }
      });
    } else {
      Future.delayed(const Duration(milliseconds: 2000), () {
        setState(() {
          opacityReferent = 1.0;
          opacitySelection = 0.0; 
        });
      });
    }
  }

  /* Note: In here, if presentation length is zero a response is necessary to trigger the trial */

  @override
  void initState()
  {
    super.initState();
    opacityReferent = 1.0;
    opacitySelection = 0.0;

    trialList.addAll(List.filled(widget.trialNumber ~/ 4, TrialElement(currentColor: Colors.blue,   isOnLeftSide: true)));
    trialList.addAll(List.filled(widget.trialNumber ~/ 4, TrialElement(currentColor: Colors.blue,   isOnLeftSide: false)));
    trialList.addAll(List.filled(widget.trialNumber ~/ 4, TrialElement(currentColor: Colors.yellow, isOnLeftSide: true)));
    trialList.addAll(List.filled(widget.trialNumber ~/ 4, TrialElement(currentColor: Colors.yellow, isOnLeftSide: false)));

    trialList.shuffle();
  }

  @override
  Widget build(BuildContext context) {

    if (mediaData == null) {
      mediaData = MediaQuery.of(context);
      iconWidth = mediaData.size.height / 4.0;
    }

    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: (currentTrial > widget.trialNumber) ? Center(child: const CircularProgressIndicator(backgroundColor: Colors.black,)) : Stack(        
          children: <Widget>[
            Positioned(
              child: Text("Practice Trial #$currentTrial of ${widget.trialNumber}",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              left: padding,
              top: padding,
            ),
            Positioned(
              child: Opacity(
                child: GestureDetector(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                        width: 1.0,
                      ),
                      color: trialList[currentTrial - 1].currentColor,
                    ),
                  ),
                  onTap: () {
                    if (opacityReferent == 1) {
                        setState(() {
                          opacityReferent = 0;
                          opacitySelection = 1;
                        });
                    }
                  },
                ),
                opacity: opacityReferent,
              ),
              left: (mediaData.size.width / 2) - (iconWidth / 2),
              top:  (mediaData.size.height / 4) - (iconWidth / 2),
              width: iconWidth,
              height: iconWidth,
            ),
            Positioned(
              child: GestureDetector(
                child: Opacity(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                        width: 1.0,
                      ),
                      color: trialList[currentTrial - 1].currentColor,
                    ),
                  ),
                  opacity: opacitySelection,
                ),
                onTap: () {
                  if (opacitySelection == 0) {
                    return;
                  }

                  onSelected(true);
                },
              ),
              left: trialList[currentTrial - 1].isOnLeftSide ? padding : (mediaData.size.width) - padding - iconWidth,
              bottom: padding,
              width: iconWidth,
              height: iconWidth,
            ),
          ],
        ),
      ),
    );
  }
}