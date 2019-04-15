import 'package:flutter/material.dart';

enum ErrorStatus {
  Correct,
  Incorrect,
}

enum SampleStimuli {
  StimuliOne,
  StimuliTwo,
}

enum ComparisonStimuli {
  ComparisonOne,
  ComparisonTwo,
}

class LatencyElement {
  ErrorStatus error;
  SampleStimuli sample;
  ComparisonStimuli comparison;
  int seconds;

  LatencyElement({
    @required this.error,
    @required this.sample,
    @required this.comparison,
    @required this.seconds,
  });
}