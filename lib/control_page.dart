import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'vertical_control.dart';
import 'horizonal_control.dart';
import 'app_bar.dart';

class ControlPage extends StatefulWidget {
  ControlPage({Key key}) : super(key: key);

  @override
  ControlPageState createState() => new ControlPageState();
}

class ControlPageState extends State<ControlPage> {
  Size screenSize;
  double appbarHeight;
  double marginSize;
  double vcWidth;
  double vcHeight;
  double hcWidth;
  double hcHeight;

  @override
  initState() {
    super.initState();
    appbarHeight = 50.0;
    marginSize = 5.0;
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    vcWidth = screenSize.width / 2 - 40.0;
    vcHeight = screenSize.height - appbarHeight - marginSize;
    hcWidth = screenSize.width - vcWidth - marginSize * 3;
    hcHeight = screenSize.height - appbarHeight - marginSize;

    //only build
    if (vcHeight > 0 && hcWidth > 0) {
      return new Material(
          child: new Column(children: <Widget>[
        new RCAppBar(title: "Cat's Conundrum RC", height: appbarHeight),
        new Container(
            color: Colors.black,
            child: new Row(children: <Widget>[
              new Container(
                  width: vcWidth,
                  height: vcHeight,
                  color: Colors.white,
                  margin:
                      new EdgeInsets.only(left: marginSize, bottom: marginSize),
                  child: new VerticalControl(height: vcHeight)),
              new Container(
                  width: hcWidth-marginSize,
                  height: hcHeight,
                  color: Colors.white,
                  margin: new EdgeInsets.only(
                      left: marginSize*2, right: marginSize, bottom: marginSize),
                  child: new HorizontalControl(width: hcWidth))
            ]))
      ]));
    }
    return new Container();
  }
}
