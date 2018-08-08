import 'package:flutter/material.dart';
import 'package:how_to/calendar-grid.dart';

class BookingCalendar extends StatefulWidget {
  BookingCalendar({this.initialMonth, this.initialSelectedDate});

  final DateTime initialMonth;
  final DateTime initialSelectedDate;
  
  @override
  BookingCalendarState createState() {
    return new BookingCalendarState();
  }
}

class BookingCalendarState extends State<BookingCalendar> {
  double calendarWidth = 250.0;
  double calendarHeight = 250.0;
  double calendarBorderSize = 1.0;
  double textSizeFactor = 1.0;
  double tickSize = 4.0;
  double tickSpace = 2.0;
  double dayNameHeight = 30.0;
  double maxWidth;
  double dayNameGap = 1.0;
  double monthNameGap = 1.0;
  double monthHeight = 48.0;

  DateTime currentMonth;
  DateTime selectedDate;

  final pageController = PageController(viewportFraction: 0.9);

  @override
  void initState() {
    super.initState();
    currentMonth = widget.initialMonth ?? DateTime.now();
//    pageController.addListener(() {
//      pageController.attach(position)
//    });
  }

  @override
  Widget build(BuildContext context) {
    maxWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey,
        body: Column(
          children: <Widget>[
            Expanded(child: CalendarGrid(month: currentMonth,
              onSelected: (selectedDate) => debugPrint("$selectedDate"),
              ticksForDate: (date) => date.weekday == DateTime.sunday ? <Color>[Colors.red] : null,
            )),
            widthsize(),
            SizedBox(height: 8.0,),
            heightsize(),
            SizedBox(height: 8.0,),
            textsize(),
            SizedBox(height: 8.0,),
            ticksize(),
            SizedBox(height: 8.0,),
            daytickspacingsize(),
            SizedBox(height: 24.0,)
          ],
        )
    );
  }

  Row widthsize() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Slider(
          value: calendarWidth,
          min: 100.0,
          max: 640.0,
          onChanged: (double value) {
            if (value >= 250.0 && value <= maxWidth) {
              setState(() {
                calendarWidth = value;
              });
            }
          },
        ),
        Text("W: $calendarWidth"),
      ],
    );
  }

  Row heightsize() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Slider(
          value: calendarHeight,
          min: 100.0,
          max: 640.0,
          onChanged: (double value) {
            setState(() {
              calendarHeight = value;
            });
          },
        ),
        Text("H: $calendarHeight"),
      ],
    );
  }

  Row textsize() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Text("Text"),
        RaisedButton(
          onPressed: () => debugPrint("hi"),
          child: Text("Up"),
        ),
        RaisedButton(
          onPressed: () => debugPrint("hi"),
          child: Text("Down"),
        ),
      ],
    );
  }

  Row ticksize() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Text("Tick"),
        RaisedButton(
          onPressed: () => debugPrint("hi"),
          child: Text("Up"),
        ),
        RaisedButton(
          onPressed: () => debugPrint("hi"),
          child: Text("Down"),
        ),
      ],
    );
  }

  Row daytickspacingsize() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Text("Spac"),
        RaisedButton(
          onPressed: () => debugPrint("hi"),
          child: Text("Up"),
        ),
        RaisedButton(
          onPressed: () => debugPrint("hi"),
          child: Text("Down"),
        ),
      ],
    );
  }
}