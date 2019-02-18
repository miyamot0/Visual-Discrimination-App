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

class DisplayPage extends StatelessWidget {
  final String uid;
  final String documentId;

  DisplayPage({
    this.uid,
    this.documentId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Discriminability Training App'),
      ),
      body: new Center(
        child: StreamBuilder(
          stream: Firestore.instance.collection('storage/$uid/participants/$documentId/sessions').snapshots(),
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
              List<double> xData = [];
              List<String> xDataStr = [];
              List<double> yData = [];
              List<double> yData2= [];
              double session = 1.0;

              ChartData chartData = ChartData();
              LineChartOptions _lineChartOptions = new LineChartOptions();
              VerticalBarChartOptions _verticalBarChartOptions = new VerticalBarChartOptions();

              chartData = new ChartData();
              chartData.dataRowsLegends = [
                "Java",
                "Dart"];
              chartData.dataRows = [
                [9.0, 4.0,  3.0,  9.0, ],
                [7.0, 6.0,  7.0,  6.0, ],
              ];
              chartData.xLabels =  ["1", "2", "3", "4"];
              chartData.dataRowsColors = [
                Colors.blue,
                Colors.yellow,
              ];

              snapshot.data.documents.forEach((doc) {
                xData.add(session);
                xDataStr.add('$session');
                
                yData.add((doc.data["correctAnswers"] / doc.data["trialCount"]) * 100.0);
                yData2.add(doc.data["difficultyLevel"]);

                session += 1.0;
              });

              //_lineChartOptions.useUserProvidedYLabels = true; // use the labels below on Y axis

              /*
              // Has data to iterate over
              ChartData chartData = ChartData();
              chartData.dataRowsLegends = ["Accuracy", "Difficulty"];
              chartData.dataRows = [
                yData,
                yData2,
              ];
              chartData.xLabels = xDataStr;
              chartData.dataRowsColors = [
                Colors.blue,
                Colors.red,
              ];
              */

              LineChart lineChart = new LineChart(
                painter: new LineChartPainter(),
                container: new LineChartContainer(
                  chartData: chartData, 
                  chartOptions: LineChartOptions(),
                  xContainerLabelLayoutStrategy: DefaultIterativeLabelLayoutStrategy(
                    options: VerticalBarChartOptions(),
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

/*
class DisplayPage extends StatefulWidget {
  final String uid;
  final String documentId;

  DisplayPage({
    this.uid,
    this.documentId,
  });

  @override
  DisplayPageState createState() => new DisplayPageState();
}

class DisplayPageState extends State<DisplayPage> {
  LineChartOptions _lineChartOptions;
  ChartOptions _verticalBarChartOptions;
  LabelLayoutStrategy _xContainerLabelLayoutStrategy;
  ChartData _chartData;

  DisplayPageState() {
    defineOptionsAndData();
  }

  void defineOptionsAndData() {
    _lineChartOptions = new LineChartOptions();
    _verticalBarChartOptions = new VerticalBarChartOptions();
    _xContainerLabelLayoutStrategy = new DefaultIterativeLabelLayoutStrategy(
      options: _verticalBarChartOptions,
    );
    _chartData = new RandomChartData(
      useUserProvidedYLabels: _lineChartOptions.useUserProvidedYLabels
    );
  }

  @override
  Widget build(BuildContext context) {
    defineOptionsAndData();

    LineChart lineChart = new LineChart(
      painter: new LineChartPainter(),
      container: new LineChartContainer(
        chartData: _chartData, // @required
        chartOptions: _lineChartOptions, // @required
        xContainerLabelLayoutStrategy: _xContainerLabelLayoutStrategy, // @optional
      ),
    );

    return new Scaffold(
      appBar: new AppBar(
        title: new Text('TODO'),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
        ),
      ),
    );
  }
}
*/