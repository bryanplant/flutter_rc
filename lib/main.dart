import 'package:flutter/material.dart';
import 'control_page.dart';

void main() {
  runApp(new App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "Cat's Conundrum",
      home: new ControlPage()
    );
  }
}
