import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:date_utils/date_utils.dart';

typedef List<Color> TickListCallBack(DateTime day);
typedef void OnDateSelectedCallBack(DateTime selectedDate);

class CalendarGrid extends StatelessWidget {
  CalendarGrid({@required this.month,
    this.width = WIDTH_MAX,
    this.borderSize = 1.0,
    this.borderColor = Colors.black12,
    this.gridLineSize = 1.0,
    this.gridLineColor = Colors.transparent,
    this.titleHeight = 48.0,
    this.titleGap = 1.0,
    this.titleGapColor = Colors.transparent,
    this.weekdayHeight = 30.0,
    this.weekdayGap = 1.0,
    this.weekdayGapColor = Colors.transparent,
    this.tickSize = 4.0,
    this.tickGap = 2.0,
    this.dayTextSizeFactor = 1.0,
    this.onSelected,
    this.ticksForDate,
    double viewportFraction = 0.9,
  }) {
    pageController = PageController(viewportFraction: viewportFraction);
  }

  static const WIDTH_MIN = 250.0;
  static const WIDTH_MAX = 100000000.0;

  final DateTime month;
  final double width;
  final double borderSize;
  final Color borderColor;
  final double gridLineSize;
  final Color gridLineColor;
  final double titleHeight;
  final double titleGap;
  final Color titleGapColor;
  final double weekdayHeight;
  final double weekdayGap;
  final Color weekdayGapColor;
  final double tickSize;
  final double tickGap;
  final double dayTextSizeFactor;

  //Callbacks
  final OnDateSelectedCallBack onSelected;
  final TickListCallBack ticksForDate;

  var pageController;

  @override
  Widget build(BuildContext context) {
    var calculatedWidth = width;
    var maxWidth = MediaQuery.of(context).size.width;
    if (width > maxWidth) {
      calculatedWidth = maxWidth;
    }

    return PageView.builder(
      controller: pageController,
      itemBuilder: (context, index) => Align(
//      alignment: Alignment.topLeft,
        child: Container(
          width: pageController.viewportFraction * calculatedWidth,
          height: pageController.viewportFraction * calculatedWidth * 0.856
              + weekdayHeight + weekdayGap + titleHeight + titleGap,
          decoration: BoxDecoration(
            border: Border.all(width: borderSize, color: borderColor),
          ),
          child: Column(
            children: <Widget>[
              monthHeader(index),
              SizedBox(
                height: titleGap,
                width: double.infinity,
                child: DecoratedBox(decoration: BoxDecoration(color: titleGapColor)),
              ),
              dayOfWeekHeader(),
              SizedBox(
                height: weekdayGap,
                width: double.infinity,
                child: DecoratedBox(decoration: BoxDecoration(color: weekdayGapColor)),
              ),
              calendarGrid(index),
            ],
          ),
        ),
      ),
    );
  }

  Container monthHeader(int index) {
    return Container(
      height: titleHeight,
      color: Colors.purple,
      child: Row(
        children: <Widget>[
          RotatedBox(
            child: Material(
              color: Colors.transparent,
              child: IconButton(
                icon: Icon(Icons.play_arrow, color: Colors.white,),
                onPressed: () {
                  debugPrint("page ${pageController.page}");
                  pageController.previousPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.decelerate);
                },
              ),
            ),
            quarterTurns: 2,),
          Expanded(
            child: Text(getMonthYearString(index),
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
              textScaleFactor: 1.1,
            ),
          ),
          Material(
            color: Colors.transparent,
            child: IconButton(
              icon: Icon(Icons.play_arrow, color: Colors.white,),
              onPressed: () {
                pageController.nextPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.decelerate);
              },
            ),
          ),
        ],
      ),
    );
  }

  DateTime getDateByIndex(int index) {
    int addMonth = index % 12;
    int addYear = index ~/ 12;
    return DateTime(month.year + addYear, month.month + addMonth);
  }

  String getMonthYearString(int index) {
    var newDate = getDateByIndex(index);
    debugPrint("index: $index, date $newDate");
    return "${DateFormat.MMMM().format(newDate)} ${DateFormat.y().format(newDate)}";
  }

  Container dayOfWeekHeader() {
    return Container(
      height: weekdayHeight,
      color: Colors.blue,
      child: GridView.count(
        crossAxisSpacing: 1.0,
        mainAxisSpacing: 1.0,
        padding: EdgeInsets.all(0.0),
        shrinkWrap: true,
        crossAxisCount: 7,
        children: <Widget>[
          weekday("Sun"),
          weekday("Mon"),
          weekday("Tue"),
          weekday("Wed"),
          weekday("Thu"),
          weekday("Fri"),
          weekday("Sat"),
        ],
      ),
    );
  }

  Expanded calendarGrid(int index) {
    return Expanded(
      child: Container(
        color: gridLineColor,
        child: GridView.count(
          physics: NeverScrollableScrollPhysics(),
          crossAxisSpacing: gridLineSize,
          mainAxisSpacing: gridLineSize,
          padding: EdgeInsets.all(0.0),
          crossAxisCount: 7,
          children: getDays(index),
        ),
      ),
    );
  }

  Widget weekday(String dayName) {
    return Container(
      padding: const EdgeInsets.only(top: 8.0),
      color: Colors.white,
      child: Text(dayName,
        textAlign: TextAlign.center,
        textScaleFactor: 0.9,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  List<Widget> getDays(int index) {
    //Calculate what day of the week to start
    //weekday is on scale of 1 - 7, Monday - Sunday
    var dateMonth = getDateByIndex(index);
    var firstDayOfMonth = Utils.firstDayOfMonth(dateMonth);
    var lastDayOfMonth = Utils.lastDayOfMonth(dateMonth);
    var lastDayOfPreviousMonth = Utils.lastDayOfMonth(getDateByIndex(index -1));

    //Modulo 7 would make 7 return 0, which is where Sunday is in the week header index
    var indexOfFirstDay = firstDayOfMonth.weekday % DateTime.daysPerWeek;

    return new List<Widget>.generate(42, (i) {
      var dayIndex = i - indexOfFirstDay + 1;
      var date = DateTime(dateMonth.year, dateMonth.month, dayIndex);

      if (dayIndex <= 0 || dayIndex > lastDayOfMonth.day) {
        return gridItem(date: date,
            lastDayOfMonth: lastDayOfMonth,
            lastDayOfPreviousMonth: lastDayOfPreviousMonth,
            bgColor: Colors.grey,
            tickWidgets: tickWidgets(date, showGreyTicks: true),
        );
      } else {
        return gridItem(
            date: date,
            lastDayOfMonth: lastDayOfMonth,
            lastDayOfPreviousMonth: lastDayOfPreviousMonth,
            onPressed: () => onSelected(DateTime(dateMonth.year, dateMonth.month, dayIndex)),
            tickWidgets: tickWidgets(date, showGreyTicks: false),
        );
      }
    });
  }

  List<Widget> tickWidgets(DateTime date, {bool showGreyTicks}) {
    //Create tickColors
    var tickColors =  <Color>[Colors.transparent];
    if (ticksForDate != null && ticksForDate(date) != null) {
      tickColors = ticksForDate(date);
      if (showGreyTicks) {
        tickColors = tickColors.map((_) => Colors.black26).toList();
      }
    }
    return tickColors.map((color) => drawCircle(color)).toList();
  }

  Widget gridItem({@required DateTime date,
        @required DateTime lastDayOfPreviousMonth,
        @required DateTime lastDayOfMonth,
        Color bgColor = Colors.white,
        VoidCallback onPressed,
        List<Widget> tickWidgets,
        }) {

    //Set dayNumber depending on if before or after month
    var dayNumber = date.day;
    if (date.day > lastDayOfMonth.day) {
      debugPrint("date after $date");
      dayNumber = date.day - lastDayOfMonth.day;
    } else if (date.day <= 0) {
      debugPrint("date before $date");
      dayNumber = lastDayOfPreviousMonth.day + date.day;
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: bgColor,
      ),
      child: FlatButton(
        padding: EdgeInsets.all(0.0),
        onPressed: onPressed,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("$dayNumber",
              textScaleFactor: dayTextSizeFactor,
            ),
            SizedBox(
              height: tickGap,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: tickWidgets,
            )
          ],
        ),
      ),
    );
  }

  Widget drawCircle(Color theColor) {
    return new Container(
      margin: EdgeInsets.symmetric(horizontal: 1.0), //between circles
      decoration: new BoxDecoration(
          shape: BoxShape.circle,
          color: theColor
      ),
      width: tickSize,
      height: tickSize,
    );
  }
}