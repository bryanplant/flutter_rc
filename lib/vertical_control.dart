import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  int signalTime;
  bool canSignal = true;

  static const bluetooth = const MethodChannel('com.bryanplant/bluetooth');

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

                    if (canSignal) {
                      String signal = power.toInt().toString();
                      bluetooth.invokeMethod("write", "<");

                      for(int i = 0; i < signal.length; i++) {
                        bluetooth.invokeMethod("write", signal[i]);
                      }

                      bluetooth.invokeMethod("write", ">");
                      canSignal = false;
                      signalTime = new DateTime.now().millisecondsSinceEpoch;
                    }
                    else {
                      if (new DateTime.now().millisecondsSinceEpoch -
                          signalTime > 100) {
                        canSignal = true;
                      }
                    }
                  },
                  onPointerUp: (PointerEvent event) {
                    setState(() {
                      offsetY = 0.0;
                      power = 0.0;
                    });

                    bluetooth.invokeMethod("write", "<");
                    bluetooth.invokeMethod("write", "0");
                    bluetooth.invokeMethod("write", ">");
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
