
import 'package:visual_discrimination_app/resources.dart';

double getAverageLatencyCorrect(List<ResultElement> _latencyList) {
    return Collection(_latencyList.where((elem) => elem.error == ErrorStatus.Correct).toList()
    .map((elem) => elem.seconds).toList())
    .average() ?? 0;
}

double getAverageLatencyIncorrect(List<ResultElement> _latencyList) {
    return Collection(_latencyList.where((elem) => elem.error == ErrorStatus.Incorrect).toList()
    .map((elem) => elem.seconds).toList())
    .average() ?? 0;
}
