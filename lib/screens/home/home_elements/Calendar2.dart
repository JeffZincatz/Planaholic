import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:provider/provider.dart';
import 'package:planaholic/models/Event.dart';
import 'package:planaholic/models/EventDataSource.dart';
import 'package:planaholic/screens/home/home_elements/TaskWidget.dart';

class Calendar2 extends StatefulWidget {

  final Function updateCurrentDate;

  Calendar2({this.updateCurrentDate});

  @override
  _Calendar2State createState() => _Calendar2State();
}

class _Calendar2State extends State<Calendar2> {

  @override
  Widget build(BuildContext context) {

    List<Event> events = Provider.of<List<Event>>(context) ?? [];

    return SfCalendar(
      dataSource: EventDataSource(events),
      headerStyle: CalendarHeaderStyle(
        textAlign: TextAlign.center,
        textStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 17,
        ),
      ),
      view: CalendarView.month,
      initialSelectedDate: DateTime.now(),
      onTap: (CalendarTapDetails details) {
        widget.updateCurrentDate(details.date);
      },
      onLongPress: (CalendarLongPressDetails detail) {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return TaskWidget(date: detail.date, events: events);
          },
        );
      },
    );
  }
}
