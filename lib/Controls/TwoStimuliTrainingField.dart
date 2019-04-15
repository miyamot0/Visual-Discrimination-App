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

class TwoStimuliTrainingField extends StatefulWidget {
  final String uid;
  final String documentId;
  final double discriminabilityDifficulty;
  final int trialNumber;
  final double presentationLength;
  final int itiSeconds;

  const TwoStimuliTrainingField(
  {
    Key key,
    @required this.uid,
    @required this.documentId,
    @required this.discriminabilityDifficulty,
    @required this.trialNumber,
    @required this.presentationLength,
    @required this.itiSeconds,
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

  List<TrialElement> trialList = [];
  List<LatencyElement> latencyList = [];

  Color color1 = Color.fromRGBO(255, 193, 193, 1),
        color2 = Color.fromRGBO(178, 81,   81, 1),
        colorCorrect,
        colorIncorrect,
        colorLerp;

  double opacityReferent  = 1.0,
         opacitySelection = 0.0;

  AnimationController animController;

  /* Time out */
  Timer timer;
  final timeOutPeriod = 30;
  final killSession = 6;

  TimeOutCode timeOutCode;
  DateTime pre, post;

  int skippedTrials   = 0,
      incorrectTrials = 0;

  /* Response ref's */
  int currentTrial  = 1,
      s1c1          = 0,
      s1c2          = 0,
      s2c1          = 0,
      s2c2          = 0,
      corLeft       = 0,
      corRght       = 0,
      errLeft       = 0,
      errRght       = 0,
      s1corL        = 0,
      s1corR        = 0,
      s1errL        = 0,
      s1errR        = 0,
      s2corL        = 0,
      s2corR        = 0,
      s2errL        = 0,
      s2errR        = 0;

  void onSelected(bool output, TimeOutCode code, bool isComparisonOnLeft) async {
    post = DateTime.now();

    // Cancel timer
    timer.cancel();

    incorrectTrials = (!output) ? incorrectTrials + 1 : incorrectTrials;

    if (code != null) {
      skippedTrials = skippedTrials + 1;

      output = false;
    } else if (output) {
      player.play(audioPath);
    }

    if (code == null) {
      if (trialList[currentTrial - 1].currentColor == color1) {
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

      corLeft =  output & trialList[currentTrial - 1].isOnLeftSide ?  corLeft + 1 : corLeft;
      errLeft = !output & trialList[currentTrial - 1].isOnLeftSide ?  errLeft + 1 : errLeft;
      corRght =  output & !trialList[currentTrial - 1].isOnLeftSide ? corRght + 1 : corRght;
      errRght = !output & !trialList[currentTrial - 1].isOnLeftSide ? errRght + 1 : errRght;

              //Correct      // Side            // Stimuli
      s1corR =  output & !isComparisonOnLeft & (trialList[currentTrial - 1].currentColor == color1) ? s1corR + 1 : s1corR;
      s1errR = !output & !isComparisonOnLeft & (trialList[currentTrial - 1].currentColor == color1) ? s1errR + 1 : s1errR;
      s1corL =  output &  isComparisonOnLeft & (trialList[currentTrial - 1].currentColor == color1) ? s1corL + 1 : s1corL;
      s1errL = !output &  isComparisonOnLeft & (trialList[currentTrial - 1].currentColor == color1) ? s1errL + 1 : s1errL;

      s2corR =  output & !isComparisonOnLeft & (trialList[currentTrial - 1].currentColor == color2) ? s2corR + 1 : s2corR;
      s2errR = !output & !isComparisonOnLeft & (trialList[currentTrial - 1].currentColor == color2) ? s2errR + 1 : s2errR;
      s2corL =  output &  isComparisonOnLeft & (trialList[currentTrial - 1].currentColor == color2) ? s2corL + 1 : s2corL;
      s2errL = !output &  isComparisonOnLeft & (trialList[currentTrial - 1].currentColor == color2) ? s2errL + 1 : s2errL;

      latencyList.add(
        LatencyElement(
          sample: (trialList[currentTrial - 1].currentColor == Colors.blue) ? SampleStimuli.StimuliOne : SampleStimuli.StimuliTwo,
          comparison: isComparisonOnLeft ? ComparisonStimuli.ComparisonOne : ComparisonStimuli.ComparisonTwo,
          error: output ? ErrorStatus.Correct : ErrorStatus.Incorrect,
          seconds: post.difference(pre).inSeconds,
        )
      );

      currentTrial = currentTrial + 1;
    }

    // blank out
    setState(() {
      opacityReferent = 0.0;
      opacitySelection = 0.0; 
    });

    showFeedback(context, output);

    if (currentTrial > widget.trialNumber || skippedTrials >= killSession) {

      await Future.delayed(Duration(seconds: 3)).then((asdf) async {
        try {
          CollectionReference dbSessions = Firestore.instance.collection('storage/${widget.uid}/participants/${widget.documentId}/sessions');

          Firestore.instance.runTransaction((Transaction tx) async {

            var nCorrect = s1c1 + s1c2 + s2c1 + s2c2;

            var replyObj = {
              'correctAnswers'   : nCorrect,
              'wrongAnswers'     : incorrectTrials,
              's1c1'             : s1c1,
              's1c2'             : s1c2,
              's2c1'             : s2c1,
              's2c2'             : s2c2,
              'corLeft'          : corLeft,
              'corRght'          : corRght,
              'errLeft'          : errLeft,
              'errRght'          : errRght,
              's1corL'           : s1corL,
              's1corR'           : s1corR,
              's1errL'           : s1errL,
              's1errR'           : s1errR,
              's2corL'           : s2corL,
              's2corR'           : s2corR,
              's2errL'           : s2errL,
              's2errR'           : s2errR,
              'trialCount'       : widget.trialNumber,
              'skippedTrials'    : skippedTrials,
              'difficultyLevel'  : widget.discriminabilityDifficulty,
              'displayTime'      : widget.presentationLength,
              'sessionDate'      : DateTime.now().toString(),
              'latencyCorrect'   : getAverageLatencyCorrect(latencyList),
              'latencyIncorrect' : getAverageLatencyIncorrect(latencyList),
            };

            await dbSessions.add(replyObj); 
          });
        } on PlatformException catch (e) {
          await showAlert(context, e.message);
        } finally {
          Navigator.pop(context);
        }
      });
    } else if (code == null) {
      await Future.delayed(Duration(seconds: 2 + widget.itiSeconds)).then((asdf) async {
        if (widget.presentationLength == 0) {
            setState(() {
              colorCorrect   = trialList[currentTrial - 1].currentColor;
              colorIncorrect = (trialList[currentTrial - 1].currentColor == color1) ? color2 : color1;

              opacityReferent = 1.0;
              opacitySelection = 0.0; 
            });
        } else {
          animController.forward(from: 0.0);
        }

        timer.cancel();

        timer = new Timer(new Duration(seconds: timeOutPeriod), () {
          onSelected(false, TimeOutCode.Sample, null);
        });
      });
    } else {
      // Bump to end
      var currentTrialElement = trialList[currentTrial - 1];
      trialList.add(currentTrialElement);
      trialList.removeAt(currentTrial - 1);

      // Good to proceed
      await Future.delayed(Duration(seconds: (output) ? (2 + widget.itiSeconds) : widget.itiSeconds)).then((asdf) async {
        setState(() {
          opacityReferent = 1.0;
          opacitySelection = 0.0; 
        });

        timer.cancel();

        timer = new Timer(new Duration(seconds: timeOutPeriod), () {
          onSelected(false, TimeOutCode.Sample, null);
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

    trialList.addAll(List.filled(widget.trialNumber ~/ 4, TrialElement(currentColor: color1, isOnLeftSide: true)));
    trialList.addAll(List.filled(widget.trialNumber ~/ 4, TrialElement(currentColor: color1, isOnLeftSide: false)));
    trialList.addAll(List.filled(widget.trialNumber ~/ 4, TrialElement(currentColor: color2, isOnLeftSide: true)));
    trialList.addAll(List.filled(widget.trialNumber ~/ 4, TrialElement(currentColor: color2, isOnLeftSide: false)));

    trialList.shuffle();

    timer = new Timer(new Duration(seconds: timeOutPeriod), () {
      onSelected(false, TimeOutCode.Sample, null);
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

    if (mediaData == null) {
      mediaData = MediaQuery.of(context);
      iconWidth = mediaData.size.height / 4.0;
    }

    // Hacky workaround
    if (currentTrial < widget.trialNumber) {
      colorCorrect   = trialList[currentTrial - 1].currentColor;
      colorIncorrect = (trialList[currentTrial - 1].currentColor == color1) ? color2 : color1;

      colorLerp = Color.lerp(colorCorrect, colorIncorrect, widget.discriminabilityDifficulty / 50.0);
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
                          onSelected(false, TimeOutCode.Comparison, null);
                        });

                        pre = DateTime.now();
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

                  onSelected(true, null, trialList[currentTrial - 1].isOnLeftSide);
                },
              ),
              left: trialList[currentTrial - 1].isOnLeftSide ? padding : (mediaData.size.width) - padding - iconWidth,
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
                      color: colorIncorrect,
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

                  onSelected(false, null, !trialList[currentTrial - 1].isOnLeftSide);
                },
              ),
              left: !trialList[currentTrial - 1].isOnLeftSide ? padding : (mediaData.size.width) - padding - iconWidth,
              bottom: padding,
              width: iconWidth,
              height: iconWidth,
            )
          ],
        ),
      ),
    );
  }
}