import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planaholic/elements/MySnackBar.dart';
import 'package:planaholic/models/Event.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:planaholic/services/DbNotifService.dart';
import 'package:planaholic/services/DbService.dart';
import 'package:planaholic/services/NotifService.dart';
import 'package:planaholic/util/PresetColors.dart';

/// Edit or delete an event page
class EditOrDelete extends StatefulWidget {
  final Event event;

  EditOrDelete({this.event});

  @override
  _EditOrDelete createState() => _EditOrDelete();
}

class _EditOrDelete extends State<EditOrDelete> {
  /// Get the icon of the [category]
  Widget makeIcon(String category) {
    return category == "Studies"
        ? Icon(Icons.book)
        : category == "Fitness"
            ? Icon(Icons.sports_baseball)
            : category == "Arts"
                ? Icon(Icons.music_note)
                : category == "Social"
                    ? Icon(Icons.phone_in_talk)
                    : Icon(Icons.thumb_up);
  }

  /// Check if the [currentDate] is today
  bool today(DateTime currentDate) {
    return (currentDate.year == DateTime.now().year &&
        currentDate.month == DateTime.now().month &&
        currentDate.day == DateTime.now().day);
  }

  String errorMessage = "";

  String description;
  String dropdownValue;
  String startTime;
  String endTime;
  int difficulty;
  String startDate;
  String endDate;

  /// Create the edit and delete actions icons
  List<Widget> buildEditingActions() {
    return [
      ElevatedButton.icon(
        onPressed: () async {
          // save data to firestore
          Event submitted = Event(
            completed: false,
            passed: false,
            category: dropdownValue,
            id: widget.event.id,
            description: description,
            startTime: DateTime(
                int.parse(startDate.substring(
                    startDate.lastIndexOf('/') + 1, startDate.length)),
                int.parse(startDate.substring(
                    startDate.indexOf('/') + 1, startDate.lastIndexOf('/'))),
                int.parse(startDate.substring(0, startDate.indexOf('/'))),
                int.parse(startTime.substring(0, 2)),
                int.parse(startTime.substring(3, 5))),
            endTime: DateTime(
                int.parse(endDate.substring(
                    endDate.lastIndexOf('/') + 1, endDate.length)),
                int.parse(endDate.substring(
                    endDate.indexOf('/') + 1, endDate.lastIndexOf('/'))),
                int.parse(endDate.substring(0, endDate.indexOf('/'))),
                int.parse(endTime.substring(0, 2)),
                int.parse(endTime.substring(3, 5))),
            difficulty: difficulty,
          );

          if (submitted.description == "") {
            // errorMessage = "Please add a description.";
            // setState(() {});
            MySnackBar.show(context, Text("Please add a description."));
          } else if (submitted.endTime.compareTo(submitted.startTime) <= 0) {
            // errorMessage = "End Time has to be after Start Time";
            // setState(() {});
            MySnackBar.show(
                context, Text("End Time has to be after Start Time."));
          } else {
            await DbService().editEvent(widget.event, submitted);
            DateTime startTimeDb = DateTime(
                int.parse(startDate.substring(
                    startDate.lastIndexOf('/') + 1, startDate.length)),
                int.parse(startDate.substring(
                    startDate.indexOf('/') + 1, startDate.lastIndexOf('/'))),
                int.parse(startDate.substring(0, startDate.indexOf('/'))),
                int.parse(startTime.substring(0, 2)),
                int.parse(startTime.substring(3, 5)));
            int before = await DbNotifService().getBefore();
            if (startTimeDb
                    .subtract(Duration(minutes: before))
                    .compareTo(DateTime.now()) >
                0) {
              try {
                int id = await DbNotifService().findIndex(widget.event.id);
                await NotifService.changeSchedule(id, submitted, before);
              } catch (e) {
                List<dynamic> lsInit = await DbNotifService().getAvailable();
                List<int> ls = lsInit.cast<int>();
                int notifId = ls[0];
                ls.removeAt(0);
                await DbNotifService().updateAvailable(ls);
                await DbNotifService().addToTaken(notifId, widget.event.id);
                await NotifService.notifyScheduled(submitted, notifId, before);
              }
            }
            MySnackBar.show(context, Text("Activity edited successfully."));
            Navigator.pop(context);
          }
        },
        icon: Icon(Icons.done),
        label: Text("EDIT"),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(PresetColors.blueAccent),
        ),
      ),
      ElevatedButton.icon(
        onPressed: () async {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return SimpleDialog(
                title: Text("Are you sure you want to delete?"),
                children: [
                  makeIcon(widget.event.category),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    widget.event.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Column(
                    children: [
                      Text(
                        widget.event.startTime.toString().substring(0, 10),
                      ),
                      Text(
                        "${DateFormat.Hms().format(widget.event.startTime).substring(0, 5)} - ${DateFormat.Hms().format(widget.event.endTime).substring(0, 5)}",
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                          icon: Icon(Icons.done),
                          onPressed: () async {
                            await DbService().delete(widget.event);
                            int notifId = await DbNotifService()
                                .findIndex(widget.event.id);
                            NotifService.deleteSchedule(notifId);
                            DbNotifService().removeFromTaken(widget.event.id);
                            List<dynamic> lsInit =
                                await DbNotifService().getAvailable();
                            List<int> ls = lsInit.cast<int>();
                            ls.add(notifId);
                            DbNotifService().updateAvailable(ls);
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                            MySnackBar.show(context,
                                Text("Activity successfully deleted."));
                          }),
                      SizedBox(width: 48),
                      IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            Navigator.pop(context);
                          }),
                    ],
                  ),
                ],
              );
            },
          );
        },
        icon: Icon(Icons.close),
        label: Text("DELETE"),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(PresetColors.blueAccent),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    description = description ?? widget.event.description;
    dropdownValue = dropdownValue ?? widget.event.category;
    startTime = startTime ??
        DateFormat.Hms().format(widget.event.startTime).substring(0, 5);
    endTime = endTime ??
        DateFormat.Hms().format(widget.event.endTime).substring(0, 5);
    difficulty = difficulty ?? widget.event.difficulty;
    startDate = startDate ??
        DateFormat.d().format(widget.event.startTime) +
            "/" +
            DateFormat.M().format(widget.event.startTime) +
            "/" +
            DateFormat.y().format(widget.event.startTime);
    endDate = endDate ??
        DateFormat.d().format(widget.event.endTime) +
            "/" +
            DateFormat.M().format(widget.event.endTime) +
            "/" +
            DateFormat.y().format(widget.event.endTime);

    return Scaffold(
      appBar: AppBar(
        actions: buildEditingActions(),
        title: Text("Edit or delete"),
        backgroundColor: PresetColors.blueAccent,
      ),
      body: GestureDetector(
        onTap: () {
          // un-focus text form field when tapped outside
          FocusScope.of(context).unfocus();
        },
        child: ListView(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth / 24, vertical: screenHeight / 30),
              child: Wrap(
                runSpacing: screenHeight / 30,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Category",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          return DropdownButton<String>(
                            isExpanded: true,
                            items: <String>[
                              "Studies",
                              "Fitness",
                              "Arts",
                              "Social",
                              "Others"
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                  value: value, child: Text(value));
                            }).toList(),
                            value: dropdownValue,
                            icon: Icon(Icons.arrow_downward),
                            onChanged: (String newValue) {
                              setState(() {
                                dropdownValue = newValue;
                              });
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Description",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Enter description',
                          labelText: 'Description',
                        ),
                        initialValue: description,
                        onChanged: (String desc) {
                          description = desc;
                        },
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Perceived Difficulty",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 13,
                            child: Slider(
                              value: difficulty.toDouble(),
                              // value: difficulty ?? 5,
                              activeColor: Colors.blue[difficulty * 100],
                              inactiveColor: Colors.blue[difficulty * 100],
                              min: 1,
                              max: 9,
                              divisions: 8,
                              onChanged: (val) =>
                                  setState(() => difficulty = val.round()),
                            ),
                          ),
                          // Expanded(flex: 1, child: Text(difficulty.toString())),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Start Date",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      StatefulBuilder(
                          builder: (BuildContext context, StateSetter setState) {
                        return SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              DatePicker.showDatePicker(context,
                                  currentTime: DateTime(
                                    int.parse(startDate.substring(
                                        startDate.lastIndexOf('/') + 1,
                                        startDate.length)),
                                    int.parse(startDate.substring(
                                        startDate.indexOf('/') + 1,
                                        startDate.lastIndexOf('/'))),
                                    int.parse(
                                        startDate.substring(0, startDate.indexOf('/'))),
                                  ), onConfirm: (val) {
                                startDate = DateFormat.d().format(val) +
                                    "/" +
                                    DateFormat.M().format(val) +
                                    "/" +
                                    DateFormat.y().format(val);
                                setState(() {});
                              });
                            },
                            child: Text(
                              startDate,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Start Time",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      StatefulBuilder(
                          builder: (BuildContext context, StateSetter setState) {
                        return SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              DatePicker.showTimePicker(context,
                                  currentTime: DateTime(
                                      2021,
                                      1,
                                      1,
                                      int.parse(startTime.substring(0, 2)),
                                      int.parse(startTime.substring(3, 5))),
                                  showSecondsColumn: false, onConfirm: (date) {
                                startTime =
                                    DateFormat.Hms().format(date).substring(0, 5);
                                setState(() {});
                              });
                            },
                            child: Text(
                              startTime,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "End Date",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      StatefulBuilder(
                          builder: (BuildContext context, StateSetter setState) {
                        return SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              DatePicker.showDatePicker(context,
                                  currentTime: DateTime(
                                    int.parse(endDate.substring(
                                        endDate.lastIndexOf('/') + 1, endDate.length)),
                                    int.parse(endDate.substring(
                                        endDate.indexOf('/') + 1,
                                        endDate.lastIndexOf('/'))),
                                    int.parse(
                                        endDate.substring(0, endDate.indexOf('/'))),
                                  ), onConfirm: (val) {
                                endDate = DateFormat.d().format(val) +
                                    "/" +
                                    DateFormat.M().format(val) +
                                    "/" +
                                    DateFormat.y().format(val);
                                setState(() {});
                              });
                            },
                            child: Text(
                              endDate,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "End Time",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          return SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {
                                DatePicker.showTimePicker(context,
                                    currentTime: DateTime(
                                        2021,
                                        1,
                                        1,
                                        int.parse(endTime.substring(0, 2)),
                                        int.parse(endTime.substring(3, 5))),
                                    showSecondsColumn: false, onConfirm: (date) {
                                  endTime =
                                      DateFormat.Hms().format(date).substring(0, 5);
                                  setState(() {});
                                });
                              },
                              child: Text(
                                endTime,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  // Not needed if MySnackBar works well
                  // Text(
                  //   errorMessage,
                  //   style: TextStyle(
                  //     color: Colors.red,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
