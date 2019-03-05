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

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_charts/flutter_charts.dart';

import 'dart:ui' as ui show Paint;
import 'package:flutter/material.dart' as material show Colors;

class DisplayPage extends StatelessWidget {
  final String uid;
  final String documentId;
  final String participant;
  final bool training;
  final int level;

  DisplayPage({
    this.uid,
    this.documentId,
    this.participant,
    @required this.training,
    this.level,
  });

  @override
  Widget build(BuildContext context) {
    final docAddress = (training) ? "practice${level}stim" : "sessions";

    return Scaffold(
      appBar: AppBar(
        title: Text('Participant: $participant'),
      ),
      body: new Center(
        child: StreamBuilder(
          stream: Firestore.instance.collection('storage/$uid/participants/$documentId/$docAddress').snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {

            if (!snapshot.hasData) {
              return Column(
                children: <Widget>[
                  Text('Loading...')
                ],
              );
            }
            else
            {
              List<String> xDataStr = [];
              List<double> yData = [];
              List<double> yData2= [];
              double session = 1.0;

              snapshot.data.documents.forEach((doc) {
                xDataStr.add('$session');
                
                yData.add((doc.data["correctAnswers"] / doc.data["trialCount"]) * 100.0);

                if (!training) {
                  yData2.add(doc.data["difficultyLevel"] * 2.0);
                }

                session += 1.0;
              });

              if (xDataStr.length > 20) {
                int length = xDataStr.length;
                int start  = length - 20;

                xDataStr   = xDataStr.skip(start).toList();
                yData      = yData.skip(start).toList();

                if (!training) {
                  yData2   = yData2.skip(start).toList();
                }
              }

              ChartData chartData = ChartData();
              chartData.dataRowsLegends = (training) ? 
              [ "Accuracy: $level stimuli" ] :
              [
                "Accuracy",
                "Difficulty"
              ];
              chartData.dataRows = (training) ?
              [ yData ] :
              [ yData, 
                yData2,
              ];
              chartData.xLabels = xDataStr;
              chartData.dataRowsColors = [
                Colors.blue,
                Colors.red,
              ];

              LineChartOptions chartOptions  = LineChartOptions();
              chartOptions.hotspotInnerPaint = ui.Paint()..color = material.Colors.white;
              chartOptions.hotspotOuterPaint = ui.Paint()..color = material.Colors.black;

              LineChart lineChart = LineChart(
                painter: LineChartPainter(),
                container: LineChartContainer(
                  chartData: chartData, 
                  chartOptions: chartOptions,
                  xContainerLabelLayoutStrategy: DefaultIterativeLabelLayoutStrategy(
                    options: LineChartOptions(),
                  ),
                ),
              );

              return Column(
                children: <Widget>[
                  new Text(''),
                  new Expanded(
                    child: new Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        new Text(''),
                        new Expanded(
                          child: lineChart, 
                        ),
                        new Text(''), 
                      ],
                    ),
                  ),
                  new Text(''),
                ],
              );
            }
          }
        ),
      ),
    );
  }
}