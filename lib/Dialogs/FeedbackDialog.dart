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

/*
 * Show encouragement
 */
void showFeedback(BuildContext context, bool accurate) {
  Navigator.of(context).push(new MaterialPageRoute<Null>(
    builder: (BuildContext context) {
      return SmileRotation(
        accurate: accurate,
      );
    },
    fullscreenDialog: true)
  );
}

class SmileRotation extends StatefulWidget {
  final bool accurate;

  SmileRotation({
    @required this.accurate 
  });

  @override
  SmileRotationState createState() => SmileRotationState();
}

class SmileRotationState extends State<SmileRotation> with SingleTickerProviderStateMixin {
  AnimationController animationController;
  Animation<double> animation;

  @override
  void initState() {
    super.initState();
    animationController = new AnimationController(
      vsync: this,
      duration: new Duration(seconds: 3),
    );

    animation = Tween<double>(begin: 50, end: 150).animate(animationController)            
    ..addListener(() {            
      setState(() {            
      
      });
    })
    ..addStatusListener((status) {
      if (status == AnimationStatus.completed) {            
        Navigator.of(context).pop();
      }
    });

    animationController.forward();
  }

  @override
  void dispose() {
    super.dispose();
    animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      alignment: Alignment.center,
      color: widget.accurate ? Colors.white : Colors.black,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        height: 300 * (animation.value / 100.0),
        width: 300 * (animation.value / 100.0),
        child: Opacity(
          child: Image.asset('assets/smiley-147407.png', 
            fit: BoxFit.fitWidth,
          ),
          opacity: widget.accurate ? 1.0 : 0.0,
        ),
      )
    );
  }
}
