import 'package:flutter/material.dart';
import 'package:flutter_social_content_share/flutter_social_content_share.dart';
import 'package:social_share/social_share.dart';

class BadgeShareTotal extends StatefulWidget {
  final int no;
  final String desc;

  BadgeShareTotal({this.no, this.desc});

  @override
  _BadgeShareTotalState createState() => _BadgeShareTotalState();
}

class _BadgeShareTotalState extends State<BadgeShareTotal> {

  String activityOrActivities() {
    return widget.no > 1
        ? "activities"
        : "activity";
  }

  @override
  Widget build(BuildContext context) {

    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text("Great Job"),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: SizedBox(
              width: screenWidth,
              child: Card(
                margin: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Image.asset(
                        'assets/badges/${widget.no}.png',
                        scale: 1/5,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Badge Obtained!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${widget.desc}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(height: 3,),
                          Text(
                            "I have done ${widget.no} ${activityOrActivities()}",
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Card(
              child: Column(
                children: [
                  Text(
                    "Share It!",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextButton(
                          child: Image.asset("assets/social_media/twitter_logo.png"),
                          onPressed: () {
                            SocialShare.shareTwitter(
                                "Badge obtained: ${widget.desc} \n"
                                    "I have done ${widget.no} ${activityOrActivities()} via PlanNUS",
                                hashtags: ["PlanNUS", "BogoPlan", "GamifiedPlanner"],
                                url:"https://github.com/bernarduskrishna/PlanNUS-1");
                          },
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: TextButton(
                          child: Image.asset("assets/social_media/facebook_logo.png"),
                          onPressed: () {
                            FlutterSocialContentShare.share(
                                type: ShareType.facebookWithoutImage,
                                url: "https://github.com/bernarduskrishna/PlanNUS-1",
                                quote: "Badge obtained: ${widget.desc} \n"
                                    "I have done ${widget.no} ${activityOrActivities()} via PlanNUS \n"
                                    "#PlanNUS #BogoPlan #GamifiedPlanner");
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}