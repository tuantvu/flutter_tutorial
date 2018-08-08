import 'package:flutter/material.dart';

class RouteObserverScreen extends StatefulWidget {
  @override
  RouteObserverScreenState createState() {
    return new RouteObserverScreenState();
  }
}

class RouteObserverScreenState extends State<RouteObserverScreen> with RouteAware {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            Text("Hi"),
            RaisedButton(
              child: Text("push"),
              onPressed: () {
                Navigator.of(context);
              },
            )
          ],
        ),
      ),
    );
  }

  @override
  void didPopNext() {
    //Called when the top route has been popped off, and the current route shows up.
  }

  @override
  void didPop() {
    //Called when the current route has been popped off.
  }

  @override
  void didPush() {
    //Called when the current route has been pushed.
  }

  @override
  void didPushNext() {
    //Called when a new route has been pushed, and the current route is no longer visible.
  }

}