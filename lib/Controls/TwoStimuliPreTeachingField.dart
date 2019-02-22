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

class TwoStimuliPreTeachingField extends StatefulWidget {
  final String uid;
  final String documentId;
  final int trialNumber;

  const TwoStimuliPreTeachingField(
  {
    Key key,
    @required this.uid,
    @required this.documentId,
    @required this.trialNumber,
  }) : super(key: key);

  @override
  TwoStimuliPreTeachingFieldState createState() => TwoStimuliPreTeachingFieldState();
}

class TwoStimuliPreTeachingFieldState extends State<TwoStimuliPreTeachingField> with SingleTickerProviderStateMixin {

  /* Layout ref's */
  MediaQueryData mediaData;
  static const double padding = 50.0;
  static double iconWidth = 0;

  /* Audio ref's */
  static const audioPath = "short-success-sound-glockenspiel-treasure-video-game.mp3";
  static AudioCache player = new AudioCache();

  /* Referent ref's */
  static final List<Color> possibleColors = [
    Colors.blue, 
    Colors.yellow
  ];
  Color colorCorrect = possibleColors[Random().nextInt(possibleColors.length - 1)],
        colorFoil    = possibleColors[Random().nextInt(possibleColors.length - 1)],
        colorLerp;
  bool locationRandomizer = Random().nextInt(100) % 2 == 0;
  double opacityReferent  = 1.0,
         opacitySelection = 0.0;

  /* Response ref's */
  int currentTrial = 1,
      nCorrect = 0,
      nIncorrect = 0;

  void onSelected(bool output) async {
    currentTrial = currentTrial + 1;

    if (output) {
      nCorrect++;
      player.play(audioPath);
    } else {
      nIncorrect++;
    }

    showFeedback(context, output);

    if (currentTrial > widget.trialNumber) {

      setState(() {
        opacityReferent = 0.0;
        opacitySelection = 0.0; 
      });

      await Future.delayed(Duration(seconds: 3))
      .then((asdf) async {
        try {
          CollectionReference dbSessions = Firestore.instance.collection('storage/${widget.uid}/participants/${widget.documentId}/practice2stim');

          Firestore.instance.runTransaction((Transaction tx) async {
            var replyObj = {
              'correctAnswers' : nCorrect,
              'wrongAnswers' : nIncorrect,
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
      colorCorrect = possibleColors[Random().nextInt(possibleColors.length)];
      colorFoil = possibleColors[Random().nextInt(possibleColors.length)];

      while (colorCorrect == colorFoil) {
        colorFoil = possibleColors[Random().nextInt(possibleColors.length)];
      }

      locationRandomizer = Random().nextInt(100) % 2 == 0;

      setState(() {
        opacityReferent = 1.0;
        opacitySelection = 0.0; 
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
  }

  @override
  Widget build(BuildContext context) {

    while (colorCorrect == colorFoil) {
      colorFoil = possibleColors[Random().nextInt(possibleColors.length)];
    }

    colorLerp = colorCorrect;

    if (mediaData == null) {
      mediaData = MediaQuery.of(context);
      iconWidth = mediaData.size.height / 4.0;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: (currentTrial > widget.trialNumber) ? Center(child: const CircularProgressIndicator(backgroundColor: Colors.black,)) : Stack(        
        children: <Widget>[
          Positioned(
            child: Text("Trial #$currentTrial of ${widget.trialNumber}"),
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
                    color: colorCorrect,
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
                if (opacitySelection == 0) {
                  return;                  
                }
                onSelected(false);
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