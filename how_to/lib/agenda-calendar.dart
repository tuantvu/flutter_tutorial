import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quiver/core.dart';

typedef Widget AppointmentBuilder(Appointment appointment, double height);
typedef void OnSelectBookable(Appointment appointment);
typedef Widget TimeLabelBuilder(DateTime hour);

class AgendaCalendar extends StatelessWidget {
  AgendaCalendar({
    this.startHour = 6,
    this.endHour = 18,
    @required this.date,
    this.minuteIncrement = 60,
    this.agendaWidth = 108.0,
    this.agendaHeight = 64.0,
    this.timeLabelBuilder,
    @required this.appointmentBuilder,
    this.appointments,
  }):
    assert (date != null),
    assert (startHour >= 0),
    assert (endHour <= 24),
    assert (appointmentBuilder != null);

  final double agendaWidth;
  final double agendaHeight;
  final DateTime date;
  final int startHour;
  final int endHour;
  final int minuteIncrement;
  final TimeLabelBuilder timeLabelBuilder;
  final AppointmentBuilder appointmentBuilder;
  final List<Appointment> appointments;

  @override
  Widget build(BuildContext context) {
    DateTime startTime = DateTime(date.year, date.month, date.day, startHour);
    DateTime endTime = DateTime(date.year, date.month, date.day, endHour);
    debugPrint("startTime: $startTime, endTime: $endTime");

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              height: 48.0,
              decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
//              child: FlatButton(onPressed: () => debugPrint("Button"), child: Text("BUTTON")),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: new List<Widget>.generate(100, (i) => SizedBox(
                  width: 64.0,
                  child: FlatButton(
                    child: Text("$i"),
                    onPressed: () => debugPrint("$i"),
                  ),
                )),
              )
            ),
            Expanded(
              child: agenda(startTime, endTime)
            ),
          ],
        ),
      ),
    );
  }

  Widget agenda(DateTime startTime, DateTime endTime) {
    return ListView(
      children: <Widget>[Row(
        children: <Widget>[
          DecoratedBox(
            decoration: BoxDecoration(border: Border(right: BorderSide(color: Colors.grey))),
            child: Column(
              children: timeLabel(startTime, endTime),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
             children: agendaColumn(startTime, endTime),
            ),
          )
        ],
      ),]
    );
  }

  List<Widget> timeLabel(DateTime startTime, DateTime endTime) {
    var hourList = new List<DateTime>.generate(endHour - startHour, (i) => startTime.add(Duration(hours: i))).toList();
    return hourList.map((hour) => Container(
      width: agendaWidth,
      height: agendaHeight,
      child: timeLabelBuilder == null ?
        Text(DateFormat.jm().format(hour), textAlign: TextAlign.center,) :
        timeLabelBuilder(hour),
    )).toList();
  }

  List<Widget> agendaColumn(DateTime startTime, DateTime endTime) {
    return agendaList(startTime, endTime).map((appt) {
      var height = agendaHeight / 60 * appt.endTime.difference(appt.startTime).inMinutes;
      return Container(
        width: double.infinity,
        height: height,
        child: appointmentBuilder(appt, height),
      );
    }).toList();
  }

  List<Appointment> agendaList(DateTime startTime, DateTime endTime) {
    var results = <Appointment>[];
    var currentStartTime = startTime;

    debugPrint("start $startTime, end $endTime");
    debugPrint("appts: $appointments");
    if (appointments != null && appointments.isNotEmpty) {
      debugPrint("unsorted: $appointments");
      appointments.sort((a, b) => a.startTime.difference(b.startTime).inMinutes);
      debugPrint("sorted: $appointments");
      appointments.forEach((appointment) {
//        debugPrint("diff minutes: ${endTime.difference(currentStartTime).inMinutes} for appt: $appointment");
        if (appointment.startTime.difference(currentStartTime).inMinutes > 0) {
          //Add bookable section
          results.add(Appointment(startTime: currentStartTime, endTime: appointment.startTime, isBookable: true));
          //Add appointment
          results.add(appointment);
          currentStartTime = appointment.endTime;
        }
      });
    }
//    debugPrint("diff minutes: ${endTime.difference(currentStartTime).inMinutes} at the end");
    if (endTime.difference(currentStartTime).inMinutes > 0) {
//      debugPrint("start $startTime, end $endTime");
      results.add(Appointment(startTime: currentStartTime, endTime: endTime, isBookable: true));
    }
    debugPrint("resulting appts $results");
    return results;
  }
}

class Appointment {
  Appointment({@required this.startTime, @required this.endTime, this.isBookable = false}):
    assert (startTime != null),
    assert (endTime != null);
  final DateTime startTime;
  final DateTime endTime;
  bool isBookable;


  @override
  bool operator ==(other) {
    return other is Appointment &&
      other.startTime == startTime &&
      other.endTime == endTime &&
      other.isBookable == isBookable;
  }


  @override
  int get hashCode {
    return hash3(startTime.hashCode, endTime.hashCode, isBookable.hashCode);
  }

  @override
  String toString() {
    return 'Appointment{startTime: $startTime, endTime: $endTime, isBookable: $isBookable}';
  }


}