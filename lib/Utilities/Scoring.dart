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

/* Accuracy measures */

/// Get total number correct responses
double getNumberCorrect(List<ResultElement> _latencyList) {
    return _latencyList.where((elem) => elem.error == ErrorStatus.Correct).length.toDouble();
}

/// Get total number incorrect responses
double getNumberIncorrect(List<ResultElement> _latencyList) {
    return _latencyList.where((elem) => elem.error == ErrorStatus.Incorrect).length.toDouble();
}

/* Positional measures */

/// Get total number correct responses on left
double getLeftCorrect(List<ResultElement> _latencyList) {
    return _latencyList.where((elem) => elem.error == ErrorStatus.Correct && elem.comparison == ComparisonStimuli.ComparisonOne)
                       .length
                       .toDouble();
}

/// Get total number incorrect responses on left
double getLeftIncorrect(List<ResultElement> _latencyList) {
    return _latencyList.where((elem) => elem.error == ErrorStatus.Incorrect && elem.comparison == ComparisonStimuli.ComparisonOne)
                       .length
                       .toDouble();
}

/// Get total number correct responses on right
double getRightCorrect(List<ResultElement> _latencyList) {
    return _latencyList.where((elem) => elem.error == ErrorStatus.Correct && elem.comparison == ComparisonStimuli.ComparisonTwo)
                       .length
                       .toDouble();
}

/// Get total number incorrect responses on left
double getRightIncorrect(List<ResultElement> _latencyList) {
    return _latencyList.where((elem) => elem.error == ErrorStatus.Incorrect && elem.comparison == ComparisonStimuli.ComparisonTwo)
                       .length
                       .toDouble();
}

/* Latency measures */

/// Get average latency for correct responses
double getAverageLatencyCorrect(List<ResultElement> _latencyList) {
    if (_latencyList.where((elem) => elem.error == ErrorStatus.Correct).length < 1) {
      return 0;
    }

    return Collection(_latencyList.where((elem) => elem.error == ErrorStatus.Correct).toList()
    .map((elem) => elem.seconds).toList())
    .average() / 1000 ?? 0;
}

/// Get average latency for incorrect responses
double getAverageLatencyIncorrect(List<ResultElement> _latencyList) {
    if (_latencyList.where((elem) => elem.error == ErrorStatus.Incorrect).length < 1) {
      return 0;
    }

    return Collection(_latencyList.where((elem) => elem.error == ErrorStatus.Incorrect).toList()
    .map((elem) => elem.seconds).toList())
    .average() / 1000 ?? 0;
}

/* Conditional Measures */

double getS1C1(List<ResultElement> _latencyList) {
  return _latencyList.where((elem) => elem.sample     == SampleStimuli.StimuliOne && 
                                      elem.comparison == ComparisonStimuli.ComparisonOne &&
                                      elem.error      == ErrorStatus.Correct)
                    .length
                    .toDouble();
}

double getS1C2(List<ResultElement> _latencyList) {
  return _latencyList.where((elem) => elem.sample     == SampleStimuli.StimuliOne && 
                                      elem.comparison == ComparisonStimuli.ComparisonTwo &&
                                      elem.error      == ErrorStatus.Correct)
                    .length
                    .toDouble();
}

double getS2C1(List<ResultElement> _latencyList) {
  return _latencyList.where((elem) => elem.sample     == SampleStimuli.StimuliTwo && 
                                      elem.comparison == ComparisonStimuli.ComparisonOne &&
                                      elem.error      == ErrorStatus.Correct)
                    .length
                    .toDouble();
}

double getS2C2(List<ResultElement> _latencyList) {
  return _latencyList.where((elem) => elem.sample     == SampleStimuli.StimuliTwo && 
                                      elem.comparison == ComparisonStimuli.ComparisonTwo &&
                                      elem.error      == ErrorStatus.Correct)
                    .length
                    .toDouble();
}

/* Conditional Errors */

double getS1C1e(List<ResultElement> _latencyList) {

  _latencyList.forEach((elem) {
    print("Sample: ${elem.sample} Compare ${elem.comparison} Err: ${elem.error}");
  });

  return _latencyList.where((elem) => elem.sample     == SampleStimuli.StimuliOne && 
                                      elem.comparison == ComparisonStimuli.ComparisonOne &&
                                      elem.error      == ErrorStatus.Incorrect)
                    .length
                    .toDouble();
}

double getS1C2e(List<ResultElement> _latencyList) {
  return _latencyList.where((elem) => elem.sample     == SampleStimuli.StimuliOne && 
                                      elem.comparison == ComparisonStimuli.ComparisonTwo &&
                                      elem.error      == ErrorStatus.Incorrect)
                    .length
                    .toDouble();
}

double getS2C1e(List<ResultElement> _latencyList) {
  return _latencyList.where((elem) => elem.sample     == SampleStimuli.StimuliTwo && 
                                      elem.comparison == ComparisonStimuli.ComparisonOne &&
                                      elem.error      == ErrorStatus.Incorrect)
                    .length
                    .toDouble();
}

double getS2C2e(List<ResultElement> _latencyList) {
  return _latencyList.where((elem) => elem.sample     == SampleStimuli.StimuliTwo && 
                                      elem.comparison == ComparisonStimuli.ComparisonTwo &&
                                      elem.error      == ErrorStatus.Incorrect)
                    .length
                    .toDouble();
}
