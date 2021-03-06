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

class TrialPage extends StatelessWidget {
  final String uid;
  final String documentId;
  final double difficultyLevel;
  final int trialCount;
  final double presentationLength;
  final int iti;

  TrialPage({
    @required this.uid,
    @required this.documentId,
    @required this.difficultyLevel, 
    @required this.trialCount, 
    @required this.presentationLength,
    @required this.iti,
  });

  @override
  Widget build (BuildContext ctxt) {
    return new Scaffold(
      body: TwoStimuliTrainingField(
        uid: uid,
        documentId: documentId,
        discriminabilityDifficulty: difficultyLevel,
        trialNumber: trialCount,
        presentationLength: presentationLength,
        itiSeconds: iti,
      ),
    );
  }
}