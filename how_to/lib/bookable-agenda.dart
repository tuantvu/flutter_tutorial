import 'package:flutter/material.dart';
import 'package:how_to/agenda-calendar.dart';
import 'package:how_to/resizable-rectangle.dart';
import 'package:intl/intl.dart';

class BookableAgenda extends StatefulWidget {
  BookableAgenda({this.minuteIncrements = 30, @required this.onBooking}):
    assert (onBooking != null);
  final minuteIncrements;
  final onBooking;

  @override
  BookableAgendaState createState() {
    return new BookableAgendaState();
  }
}

class BookableAgendaState extends State<BookableAgenda> {
  bool leftBorderOn = false;
  bool rightBorderOn = false;
  bool topBorderOn = false;
  bool bottomBorderOn = false;
  Appointment chosenAppointment;
  List<int> chosenIncrements = <int>[];
  int chosenIncrement;
  int prevIncrement;
  Widget selectedAppointment;

  @override
  Widget build(BuildContext context) {
    var now = DateTime.now();
    var today = DateTime(now.year, now.month, now.day);

    return Stack(
      children: <Widget>[
        AgendaCalendar(
          date: DateTime.now(),
          startHour: 6,
          endHour: 18,
          agendaHeight: 120.0,
          appointmentBuilder: appointmentBuilder,
          appointments: <Appointment>[
            Appointment(startTime: today.add(Duration(hours: 11)), endTime: today.add(Duration(hours: 13))),
            Appointment(startTime: today.add(Duration(hours: 8)), endTime: today.add(Duration(hours: 9))),
            Appointment(startTime: today.add(Duration(hours: 14, minutes: 30)), endTime: today.add(Duration(hours: 15, minutes: 30))),
          ],
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: chosenIncrements.isNotEmpty ? bookButton() : null,
        )
      ],
    );
  }
  
  Widget bookButton() {
    var appointmentToBook = Appointment(
      isBookable: true,
      startTime: getAppointmentTime(chosenAppointment, chosenIncrements.first),
      endTime: getAppointmentTime(chosenAppointment, chosenIncrements.last)
          .add(Duration(minutes: widget.minuteIncrements))
    );
    var startTime = DateFormat.jm().format(appointmentToBook.startTime);
    var endTime = DateFormat.jm().format(appointmentToBook.endTime);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: RaisedButton(
          child: Text("Book $startTime - $endTime"),
          onPressed: () => widget.onBooking(appointmentToBook),
        ),
      ),
    );
  }

  Widget appointmentBuilder(Appointment appointment, double height) {
    var startString = DateFormat.jm().format(appointment.startTime);
    var endString = DateFormat.jm().format(appointment.endTime);
    var increments = appointment.endTime.difference(appointment.startTime).inMinutes / widget.minuteIncrements;
    var incrementHeight = height / increments;
//    debugPrint("increments: $increments, incrementHeight: $incrementHeight");
//    debugPrint("chosen: $chosenAppointment, appt: $appointment");
    if (!appointment.isBookable) {
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).disabledColor,
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        child: Center(child: Text("Unavailable",
          style: TextStyle(color: Theme.of(context).textTheme.caption.color),
        )),
      );
    } else {
      return Stack(
        children: <Widget>[
//          Container(
//            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0),
//                color: Theme.of(context).primaryColorLight
//            ),
//            child: Center(
//              child: Text(chosenAppointment == appointment ? "" :
//                  "$startString - $endString",
//                textAlign: TextAlign.center,
//                style: TextStyle(color: Theme.of(context).primaryColorDark),
//              ),
//            ),
//          ),
          Column(
            children: new List<Widget>.generate(increments.toInt(), (i) => SizedBox(
                height: incrementHeight,
                width: double.infinity,
                child: FlatButton(
                  color: isIncrementChosen(appointment, i) ? Colors.lightGreen :
                      isIncrementChoosable(appointment, i) ? Theme.of(context).primaryColorLight :
                      Colors.grey,
                  onPressed: isIncrementChoosable(appointment, i) || isIncrementChosen(appointment, i)  ? () {
                    setState(() {
                      chosenAppointment = appointment;
                      toggleChosenIncrement(i);
                      chosenIncrement = i;
                      selectedAppointment = appointmentSelector(appointment, height);
                      debugPrint("chose increment $i");
                    });
                  } : null,
                  child: getAppointmentText(appointment, i),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(color: Colors.black38)
                  ),

                ),
              )
            ),
          ),
//          chosenAppointment == appointment ?
//            selectedAppointment : Container()
//          selectedAppointment ?? Container(),
        ],
      );
    }
  }

  bool isIncrementChoosable(Appointment appt, int inc) {
    return chosenIncrements.isEmpty ||
        (chosenAppointment == appt && (
          chosenIncrements.contains(inc - 1) ||
            chosenIncrements.contains(inc + 1)
        ));
  }

  bool isIncrementChosen(Appointment appt, int inc) {
    return chosenAppointment == appt &&
        chosenIncrements.contains(inc);
  }

  void toggleChosenIncrement(int inc) {
    int index = chosenIncrements.indexOf(inc);
    if (index > 0) {
      chosenIncrements.removeRange(index, chosenIncrements.length);
    } else if (index == 0) {
      chosenIncrements.removeAt(index);
    } else {
      chosenIncrements.add(inc);
      chosenIncrements.sort();
    }
  }
  
  DateTime getAppointmentTime(Appointment appt, int inc) {
    return appt.startTime.add(Duration(minutes: inc * widget.minuteIncrements));
  }

  Widget getAppointmentText(Appointment appt, int inc) {
    var apptTime = getAppointmentTime(appt, inc);
    var timeString = DateFormat.jm().format(apptTime);
    var result = "";
    if (isIncrementChosen(appt, inc)) {
      result = "Booking $timeString";
    } else {
      if (chosenIncrements.isNotEmpty && isIncrementChoosable(appt, inc)) {
        result = "Add $timeString";
      } else {
        result = "Book $timeString";
      }
    }
    return Text(result);
  }

  Widget appointmentSelector(Appointment appointment, double height) {
    var totalMinutes = appointment.endTime.difference(appointment.startTime).inMinutes;
    var heightPerMinute = height / totalMinutes;
    var incrementHeight = heightPerMinute * widget.minuteIncrements;
    return Align(
      child: Container(
        child: ResizableRectangle(
          showDebug: false,
          touchRadius: 24.0,
          top: chosenIncrement * incrementHeight,
          initialHeight: incrementHeight,
          minHeight: incrementHeight,
          snapIncrement: incrementHeight,
          snapFactor: 0.5,
          child: appointmentSelectorChild(),
          onDragStart: onDragStart,
          onDragEnd: onDragEnd,
        ),
      ),
    );
  }

  Widget appointmentSelectorChild() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColorDark,
        border: Border(
          top: BorderSide(
            color: topBorderOn ? Colors.yellow : Colors.black54,
            width: topBorderOn ? 4.0 : 1.0,
          ),
          bottom: BorderSide(
            color: bottomBorderOn ? Colors.yellow : Colors.black54,
            width: bottomBorderOn ? 4.0 : 1.0,
          ),
          left: BorderSide(
            color: leftBorderOn ? Colors.yellow : Colors.black54,
            width: leftBorderOn ? 4.0 : 1.0,
          ),
          right: BorderSide(
            color: rightBorderOn ? Colors.yellow : Colors.black54,
            width: rightBorderOn ? 4.0 : 1.0,
          ),
        )
      ),
      child: Center(
        child: Text("ehh", style: TextStyle(color: Theme.of(context).primaryColorLight),),
      ),
    );
  }

  void onDragStart(direction, delta) {
    setState(() {
      if (direction == AxisDirection.up) {
        topBorderOn = true;
      } else if (direction == AxisDirection.down) {
        bottomBorderOn = true;
      } else if (direction == AxisDirection.left) {
        leftBorderOn = true;
      } else if (direction == AxisDirection.right) {
        rightBorderOn = true;
      }
    });
  }

  void onDragEnd(direction, delta) {
    setState(() {
      topBorderOn = bottomBorderOn = leftBorderOn = rightBorderOn = false;
    });
  }

}