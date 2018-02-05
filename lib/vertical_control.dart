import 'package:flutter/material.dart';

class VerticalControl extends StatefulWidget {
  final double height;

  VerticalControl({this.height});

  @override
  VerticalControlState createState() =>
      new VerticalControlState(height: this.height);
}

class VerticalControlState extends State<VerticalControl> {
  double offsetY = 0.0;
  double startY;
  double maxOffset;
  double height;
  double power = 0.0;
  double iconSize = 75.0;

  VerticalControlState({this.height}) {
    maxOffset = height / 2 - iconSize / 1.5;
  }

  @override
  Widget build(BuildContext context) {
    return new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Container(
              color: offsetY <= 1 ? Colors.lightGreen[700] : Colors.red[600],
              height: height,
              child: new Listener(
                  onPointerDown: (PointerEvent event) {
                    setState(() {
                      startY = event.position.dy;
                    });
                  },
                  onPointerMove: (PointerEvent event) {
                    setState(() {
                      offsetY = event.position.dy - startY;
                      if (offsetY > maxOffset) offsetY = maxOffset;
                      if (offsetY < -maxOffset) offsetY = -maxOffset;
                      power = -(offsetY / maxOffset) * 100.0;
                    });
                  },
                  onPointerUp: (PointerEvent event) {
                    setState(() {
                      offsetY = 0.0;
                      power = 0.0;
                    });
                  },
                  child: new Container(
                      transform:
                          new Matrix4.translationValues(0.0, offsetY, 0.0),
                      child: new Icon(Icons.swap_vertical_circle,
                          color: Colors.black, size: iconSize)))),
          new Container(
              margin: new EdgeInsets.only(left: 10.0),
              padding: new EdgeInsets.all(10.0),
              color: Colors.white,
              child: new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    new Text("Power",
                        style: Theme
                            .of(context)
                            .textTheme
                            .button
                            .apply(color: Colors.black)),
                    new Text(power.truncate().toString() + "%",
                        style: Theme
                            .of(context)
                            .textTheme
                            .button
                            .apply(color: Colors.black))
                  ]))
        ]);
  }
}
