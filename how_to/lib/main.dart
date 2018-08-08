import 'package:flutter/material.dart';
import 'package:how_to/bookable-agenda.dart';
import 'package:how_to/booking-calendar.dart';
import 'package:how_to/resizable-shapes.dart';

import 'get-ip.dart';
import 'read-file.dart';
import 'route-observer.dart';
import 'sized-box-expand.dart';
import 'swipe-left-right-dismissible.dart';

void main() => runApp(new MyApp());

// Register the RouteObserver as a navigation observer.
final RouteObserver<PageRoute> routeObserver = new RouteObserver<PageRoute>();

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'How To Flutter',
      navigatorObservers: [routeObserver],
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'How to Flutter'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var sliderValue = "1";

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new Text(widget.title),
      ),
      body: new Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            NavButton("Get IP Address", new GetIPScreen()),
            NavButton("Dismissible", new SwipeLeftRightDismissible()),
            NavButton("Read File", new ReadFileScreen()),
            NavButton("SizedBox expand in stack", new SizedBoxExpand()),
            NavButton("Route Observer", new RouteObserverScreen()),
            NavButton("Resizable Rectangle", new ResizableShapes()),
            NavButton("Booking Calendar", new BookingCalendar()),
            NavButton("Bookable Agenda", new BookableAgenda(
              onBooking: (appt) => debugPrint("onBooking $appt"),
            )),
          ],
        ),
      ),
    );
  }
}

class NavButton extends StatelessWidget {
  final String title;
  final Widget navToWidget;

  NavButton(this.title, this.navToWidget);
  
  @override
  Widget build(BuildContext context) {
    return new RaisedButton(
      child: new Text(title),
      onPressed: () => Navigator.push(context, new MaterialPageRoute(
          builder: (context) => navToWidget)),
    );
  }

}