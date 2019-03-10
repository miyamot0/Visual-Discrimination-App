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

import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:audioplayers/audio_cache.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:visual_discrimination_app/Dialogs/ErrorDialog.dart';
import 'package:visual_discrimination_app/Dialogs/FeedbackDialog.dart';

enum TimeOutCode {
  Sample,
  Comparison
}

class TwoStimuliTrainingField extends StatefulWidget {
  final String uid;
  final String documentId;
  final double discriminabilityDifficulty;
  final int trialNumber;
  final double presentationLength;

  const TwoStimuliTrainingField(
  {
    Key key,
    @required this.uid,
    @required this.documentId,
    @required this.discriminabilityDifficulty,
    @required this.trialNumber,
    @required this.presentationLength,
  }) : super(key: key);

  @override
  TwoStimuliTrainingFieldState createState() => TwoStimuliTrainingFieldState();
}

class TwoStimuliTrainingFieldState extends State<TwoStimuliTrainingField> with SingleTickerProviderStateMixin {

  /* Layout ref's */
  MediaQueryData mediaData;
  static const double padding = 50.0;
  static double iconWidth = 0;

  /* Audio ref's */
  static const audioPath = "short-success-sound-glockenspiel-treasure-video-game.mp3";
  static AudioCache player = new AudioCache();

  /* Referent ref's */
  static final List<Color> possibleColors = [
    Color.fromRGBO(255, 193, 193, 1),
    Color.fromRGBO(178, 81,   81, 1),
  ];
  Color colorCorrect = possibleColors[Random().nextInt(possibleColors.length - 1)],
        colorFoil    = possibleColors[Random().nextInt(possibleColors.length - 1)],
        colorLerp;
  bool locationRandomizer = Random().nextInt(100) % 2 == 0;
  double opacityReferent  = 1.0,
         opacitySelection = 0.0;
  AnimationController animController;

  Timer timer;
  final timeOutPeriod = 30;

  TimeOutCode timeOutCode;

  int correct1 = 0, 
      correct2 = 0,
      incorrect1 = 0, 
      incorrect2 = 0,
      skippedTrials = 0;

  /* Response ref's */
  int currentTrial = 1;

  void onSelected(bool output, TimeOutCode code) async {
    currentTrial = currentTrial + 1;

    // Cancel timer
    timer.cancel();

    if (code != null) {
      skippedTrials = skippedTrials + 1;

      output = false;
    } else {
      if (output) {
        player.play(audioPath);
      }

      if (locationRandomizer) {
        // left side has correct resp
        correct1   = (output)  ? correct1 + 1 : correct1;
        incorrect1 = (!output) ? incorrect1 + 1 : incorrect1;
      } else {
        // right side has correct resp
        correct2   = (output)  ? correct2 + 1 : correct2;
        incorrect2 = (!output) ? incorrect2 + 1 : incorrect2;
      }
    }

    setState(() {
      opacityReferent = 0.0;
      opacitySelection = 0.0; 
    });

    showFeedback(context, output);

    if (currentTrial > widget.trialNumber) {

      await Future.delayed(Duration(seconds: 3))
      .then((asdf) async {
        try {
          CollectionReference dbSessions = Firestore.instance.collection('storage/${widget.uid}/participants/${widget.documentId}/sessions');

          Firestore.instance.runTransaction((Transaction tx) async {
            var replyObj = {
              'correctAnswers' : (correct1 + correct2), //nCorrect,
              'wrongAnswers'   : (incorrect1 + incorrect2), //nIncorrect,
              'correct1'       : correct1,
              'correct2'       : correct2,
              'incorrect1'     : incorrect1,
              'incorrect2'     : incorrect2,
              'skippedTrials'  : skippedTrials,
              'trialCount'     : widget.trialNumber,
              'difficultyLevel': widget.discriminabilityDifficulty,
              'displayTime'    : widget.presentationLength,
              'sessionDate'    : DateTime.now().toString(),
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
      colorCorrect = possibleColors[Random().nextInt(possibleColors.length)];
      colorFoil = possibleColors[Random().nextInt(possibleColors.length)];

      while (colorCorrect == colorFoil) {
        colorFoil = possibleColors[Random().nextInt(possibleColors.length)];
      }

      locationRandomizer = Random().nextInt(100) % 2 == 0;

      await Future.delayed(Duration(seconds: 6))
      .then((asdf) async {
        if (widget.presentationLength == 0) {
          setState(() {
            opacityReferent = 1.0;
            opacitySelection = 0.0;
          });
        } else {
          animController.forward(from: 0.0);
        }

        timer.cancel();

        timer = new Timer(new Duration(seconds: timeOutPeriod), () {
          onSelected(null, TimeOutCode.Sample);
        });
      });
    }
  }

  /* Note: In here, if presentation length is zero a response is necessary to trigger the trial */

  @override
  void initState()
  {
    super.initState();

    if (widget.presentationLength == 0) {
      opacityReferent = 1.0;
      opacitySelection = 0.0;
    } else {
      animController = new AnimationController(
        lowerBound: 0.0,
        upperBound: 1.0,
        duration: new Duration(milliseconds: (widget.presentationLength * 1000).toInt()),
        vsync: this,
      )
      ..addListener(() 
      {
        this.setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          animController.reverse();
        }
        else if (status == AnimationStatus.dismissed) {
            opacitySelection = 1.0;
            opacityReferent = 0.0;
        }
        else if (status == AnimationStatus.forward) {
          opacitySelection = 0.0;
          opacityReferent = 1.0;
        }
      });

      WidgetsBinding.instance.addPostFrameCallback((_)  => animController.forward());
    }

    timer = new Timer(new Duration(seconds: timeOutPeriod), () {
      onSelected(null, TimeOutCode.Sample);
    });
  }

  @override
  void dispose() {
    if (widget.presentationLength != 0) {
      animController.stop(canceled: true);
      animController.dispose();
    }

    if (timer.isActive) {
      timer.cancel();
      timer = null;
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    while (colorCorrect == colorFoil) {
      colorFoil = possibleColors[Random().nextInt(possibleColors.length)];
    }

    colorLerp = Color.lerp(colorCorrect, colorFoil, widget.discriminabilityDifficulty / 50.0);

    if (mediaData == null) {
      mediaData = MediaQuery.of(context);
      iconWidth = mediaData.size.height / 4.0;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: (currentTrial > widget.trialNumber) ? Center(child: const CircularProgressIndicator(backgroundColor: Colors.black,)) : Stack(        
        children: <Widget>[
          Positioned(
            child: Text("Trial #$currentTrial of ${widget.trialNumber}, Difficulty Level: ${widget.discriminabilityDifficulty}",
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
                    color: colorLerp,
                  ),
                ),
                onTap: () {
                   if (widget.presentationLength == 0 && opacityReferent == 1) {
                      setState(() {
                        opacityReferent = 0;
                        opacitySelection = 1;

                        timer.cancel();

                        timer = new Timer(new Duration(seconds: timeOutPeriod), () {
                          onSelected(null, TimeOutCode.Comparison);
                        });
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
                    color: colorCorrect,
                  ),
                ),
                opacity: opacitySelection,
              ),
              onTap: () {
                if (widget.presentationLength > 0) {
                  if (animController.isAnimating) return;
                } else if (widget.presentationLength == 0 && opacitySelection == 0) {
                  return;
                }

                onSelected(true, null);
              },
            ),
            left: locationRandomizer ? padding : (mediaData.size.width) - padding - iconWidth,
            bottom: padding,
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
                    color: colorFoil,
                  ),
                ),
                opacity: opacitySelection,
              ),
              onTap: () {
                if (widget.presentationLength > 0) {
                  if (animController.isAnimating) return;
                } else if (widget.presentationLength == 0 && opacitySelection == 0) {
                  return;
                }

                onSelected(false, null);
              },
            ),
            left: !locationRandomizer ? padding : (mediaData.size.width) - padding - iconWidth,
            bottom: padding,
            width: iconWidth,
            height: iconWidth,
          )
        ],
      ),
    );
  }
}