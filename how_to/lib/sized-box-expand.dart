import 'package:flutter/material.dart';

class SizedBoxExpand extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new ListView(
        children: <Widget>[
          SizedBoxItem(),
          SizedBoxItem(),
          SizedBoxItem(),
          SizedBoxItem(),
        ],
      ),
    );
  }

}

class SizedBoxItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Stack(
      children: <Widget>[
        new ListTile(
          title: new Text('Bar'),
          subtitle: new Text('yipeee'),
          isThreeLine: true,
        ),
        new Container(
          decoration: BoxDecoration(color: Colors.blue),
          child: new Text("Hello"),
        )
      ],
    );
  }

}