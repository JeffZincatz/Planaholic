import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:planaholic/elements/BadgeShareTotalDialog.dart';
import 'package:planaholic/services/DbService.dart';

/// Abstraction for the topmost row (total activities) badges
class TotalActivitiesBadges extends StatefulWidget {

  final List<int> no = [1, 5, 15, 30, 60, 100];

  final List<String> text = [
    "Get started",
    "Fast Five",
    "15/15!",
    "On a roll!",
    "Unstoppable",
    "Sky is the limit!"
  ];

  @override
  _TotalActivitiesBadgesState createState() => _TotalActivitiesBadgesState();
}

class _TotalActivitiesBadgesState extends State<TotalActivitiesBadges> {

  DbService _db = new DbService();

  @override
  Widget build(BuildContext context) {

    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Total activities",
          textAlign: TextAlign.left,
        ),
        SizedBox(height: 8.0,),
        SizedBox(
          height: screenHeight / 9,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: NeverScrollableScrollPhysics(),
            itemCount: widget.no.length,
            itemBuilder: (context, index) {
              return FutureBuilder(
                future: _db.countCompletedEventByCategory("total"),
                builder: (context, snapshot) {
                  return !snapshot.hasData
                      ? Container()
                      : snapshot.data >= widget.no[index]
                        ? Container(
                          height: screenHeight / 9,
                          width: screenWidth / 6,
                          decoration: BoxDecoration(
                            border: Border.all(),
                          ),
                          child: TextButton(
                            onPressed: () {
                              // Navigator.push(context,
                              //   MaterialPageRoute(builder: (context) => BadgeShareTotal(no: widget.no[index], desc: widget.text[index],)));
                              showDialog(
                                  context: context,
                                  builder: (context) => BadgeShareTotalDialog(
                                    no: widget.no[index],
                                    desc: widget.text[index],
                                  ));
                            },
                            child: Column(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Image.asset(
                                    "assets/badges/${widget.no[index]}.png",
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Center(
                                    child: Text(
                                      widget.text[index],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 9,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Stack(
                        children: [
                          Container(
                            height: screenHeight / 9,
                            width: screenWidth / 6,
                            decoration: BoxDecoration(
                              border: Border.all(),
                            ),
                            child: Column(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Image.asset(
                                    "assets/badges/${widget.no[index]}.png",
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Center(
                                    child: Text(
                                      widget.text[index],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: screenHeight / 9,
                            width: screenWidth / 6,
                            color: Colors.grey.withOpacity(0.9),
                            child: Align(
                              alignment: Alignment.center,
                              child: Column(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: IconButton(
                                      icon: Icon(Icons.lock),
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: Text("Badge locked", textAlign: TextAlign.center,),
                                                scrollable: true,
                                                content: Text(
                                                  "Complete ${widget.no[index]} activities",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              );
                                            }
                                        );
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: LinearPercentIndicator(
                                      percent: snapshot.data / widget.no[index],
                                      backgroundColor: Colors.black,
                                      progressColor: Colors.blueGrey,
                                    ),
                                  )
                                ],
                              )
                            ),
                          ),
                        ],
                      );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
