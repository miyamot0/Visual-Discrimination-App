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
  List<ResultElement> latencyList = [];

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

  int skippedTrials   = 0;

  /* Response ref's */
  int currentTrial  = 1;

  void onSelected(bool output, TimeOutCode code) async {
    post = DateTime.now();

    // Cancel timer
    timer.cancel();

    if (code != null) {
      skippedTrials = skippedTrials + 1;

      output = false;
    } else if (output) {
      player.play(audioPath);
    }

    if (code == null) {
      latencyList.add(
        ResultElement(
          sample: trialList[currentTrial - 1].currentColor == color1 ? SampleStimuli.StimuliOne : SampleStimuli.StimuliTwo,
          comparison: trialList[currentTrial - 1].isOnLeftSide ? ComparisonStimuli.ComparisonOne : ComparisonStimuli.ComparisonTwo,
          error: output ? ErrorStatus.Correct : ErrorStatus.Incorrect,
          seconds: post.difference(pre).inMilliseconds,
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

            Map<String, Object> replyObj = {
              'correctAnswers'   : getNumberCorrect(latencyList),
              'wrongAnswers'     : getNumberIncorrect(latencyList),
              's1c1'             : getS1C1(latencyList),
              's1c2'             : getS1C2(latencyList),
              's2c1'             : getS2C1(latencyList),
              's2c2'             : getS2C2(latencyList),
              'corLeft'          : getLeftCorrect(latencyList),
              'corRght'          : getRightCorrect(latencyList),
              'errLeft'          : getLeftIncorrect(latencyList),
              'errRght'          : getRightIncorrect(latencyList),
              's1errL'           : getS1C1e(latencyList),
              's1errR'           : getS1C2e(latencyList),
              's2errL'           : getS2C1e(latencyList),
              's2errR'           : getS2C2e(latencyList),
              'skippedTrials'    : skippedTrials,
              'trialCount'       : widget.trialNumber,
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
          onSelected(false, TimeOutCode.Sample);
        });
      });
    } else {
      // Bump to end
      var currentTrialElement = trialList[currentTrial - 1];
      trialList.remove(currentTrialElement);
      trialList.add(currentTrialElement);

      // Good to proceed
      await Future.delayed(Duration(seconds: (output) ? (2 + widget.itiSeconds) : widget.itiSeconds)).then((asdf) async {
        setState(() {
          opacityReferent = 1.0;
          opacitySelection = 0.0; 
        });

        timer.cancel();

        timer = new Timer(new Duration(seconds: timeOutPeriod), () {
          onSelected(false, TimeOutCode.Sample);
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

    latencyList = [];

    timer = new Timer(new Duration(seconds: timeOutPeriod), () {
      onSelected(false, TimeOutCode.Sample);
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
                          onSelected(false, TimeOutCode.Comparison);
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

                  onSelected(true, null);
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

                  onSelected(false, null);
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