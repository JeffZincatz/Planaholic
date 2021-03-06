import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:planaholic/elements/MySnackBar.dart';
import 'package:planaholic/elements/ProfilePic.dart';
import 'package:planaholic/elements/PieCharOverview.dart';
import 'package:planaholic/elements/BarChartWeekly.dart';
import 'package:planaholic/services/DbService.dart';
import 'package:planaholic/util/PresetColors.dart';
import 'package:planaholic/util/TimeUtil.dart';
import 'package:planaholic/elements/RadarChartAttribute.dart';

/// User profile page
class Profile extends StatefulWidget {
  const Profile({Key key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  DbService _db = new DbService();

  // edit username button
  bool isEditing = false;
  String username = "";
  String newName = "";

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    // update weekly fields
    Function updateWeekly = () async {
      bool isUpdated = await DbService().updateWeekly();
      if (isUpdated) {
        setState(() {});
      }
    };
    updateWeekly();

    // deduct for inactivity
    Function checkInactivity = () async {
      Map lastCheckTime = await _db.getLastCheckTime();
      DateTime now = DateTime.now();
      int counter = 0;
      lastCheckTime.forEach((key, value) async {
        // first check for 4 other attributes
        if (key != "Resolve" &&
            TimeUtil.isAtLeastThreeDaysApart(now, value.toDate())) {
          // print("\n\n----Profile----\n"+
          //     "Function: checkInactivity\n" +
          //     "lastCheckTime.forEach, key: " + key +
          //     "\n\n");
          await _db.reduceAttributeTo80Percent(key);
          setState(() {});
          _db.refreshLastCheckTime(key);
          counter++;
        }
      });
      // reduce Resolve if all 4 has been deducted
      if (counter >= 4) {
        await _db.reduceAttributeTo80Percent("Resolve");
        setState(() {});
        _db.refreshLastCheckTime("Resolve");
      }
    };
    checkInactivity();

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          // un-focus text form field when tapped outside
          FocusScope.of(context).unfocus();
        },
        child: ListView(shrinkWrap: true, children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Column(
              children: [
                Text(
                  "My Profile",
                  style: TextStyle(
                    fontSize: screenHeight * 0.036,
                  ),
                ),
                FutureBuilder(
                    future: _db.getUserProfilePic(),
                    builder: (context, snapshot) {
                      return snapshot.hasData
                          ? Padding(
                              padding: EdgeInsets.all(screenHeight * 0.02),
                              child: Stack(children: [
                                ProfilePic(
                                  image: snapshot.data,
                                  radius: 60,
                                ),
                                Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      height: 40,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            width: 4,
                                            color: PresetColors.background,
                                          ),
                                          color: PresetColors.blue),
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          showModalBottomSheet(
                                            context: context,
                                            builder: ((builder) => bottomSheet()),
                                          );
                                        },
                                      ),
                                    )),
                              ]),
                            )
                          : Icon(
                              Icons.person,
                              size: 135,
                            );
                    }),
                FutureBuilder(
                  future: _db.getUserLevel(),
                  builder: (context, snapshot) {
                    String lvl =
                        snapshot.hasData ? snapshot.data.toString() : " ";
                    return Text(
                      "Level " + lvl,
                      style: TextStyle(
                        fontSize: screenHeight * 0.036,
                      ),
                    );
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: isEditing ? 0 : screenWidth * 0.11,
                    ),
                    isEditing
                        ? Container(
                            height: screenHeight * 0.07,
                            width: screenWidth * 0.65,
                            child: TextFormField(
                              key: ValueKey("nameField"),
                              initialValue: username,
                              style: TextStyle(
                                fontSize: screenHeight * 0.036,
                              ),
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                border: isEditing
                                    ? UnderlineInputBorder()
                                    : InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onChanged: (String value) {
                                setState(() {
                                  newName = value;
                                });
                              },
                            ),
                          )
                        : FutureBuilder(
                            future: _db.getUsername(),
                            builder: (context, snapshot) {
                              username =
                                  snapshot.hasData ? snapshot.data : username;
                              return Container(
                                width: screenWidth * 0.6,
                                child: Text(
                                  username,
                                  style: TextStyle(
                                      fontSize: screenHeight * 0.045,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }),
                    isEditing
                        ? Row(
                            children: [
                              IconButton(
                                key: ValueKey("finalised"),
                                icon: Icon(Icons.check),
                                onPressed: () async {
                                  await _db.updateUsername(newName);
                                  setState(() {
                                    isEditing = false;
                                  });
                                  MySnackBar.show(context,
                                      Text("Username updated successfully."));
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    isEditing = false;
                                    newName = "";
                                  });
                                },
                              ),
                            ],
                          )
                        : IconButton(
                            key: ValueKey("changeNameIcon"),
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              setState(() {
                                isEditing = true;
                              });
                            },
                          ),
                  ],
                ),
                FutureBuilder(
                  future: _db.getEmail(),
                  builder: (context, snapshot) {
                    return snapshot.hasData
                        ? Text(
                            snapshot.data,
                            style: TextStyle(
                              fontFamily: "monospace",
                              fontSize: screenHeight * 0.024,
                              decoration: TextDecoration.underline,
                            ),
                          )
                        : Text("");
                  },
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FutureBuilder(
                        future: _db.getUserCurrentExp(),
                        builder: (context, snapshot) {
                          String currExp =
                              snapshot.hasData ? snapshot.data.toString() : "";
                          return Text("Current EXP: " + currExp);
                        },
                      ),
                      FutureBuilder(
                        future: _db.getUserNextExp(),
                        builder: (context, snapshot) {
                          String nextExp =
                              snapshot.hasData ? snapshot.data.toString() : "";
                          return Text("EXP to next lvl: " + nextExp);
                        },
                      ),
                    ],
                  ),
                ),
                FutureBuilder(
                  future: (() async {
                    return {
                      "current": await _db.getUserCurrentExp(),
                      "next": await _db.getUserNextExp(),
                    };
                  })(),
                  builder: (context, snapshot) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.grey[400],
                          valueColor: AlwaysStoppedAnimation(PresetColors.blue),
                          value: snapshot.hasData
                              ? snapshot.data["current"] *
                                  1.0 /
                                  snapshot.data["next"]
                              : 0,
                          minHeight: 15,
                        ),
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 20, 12, 0),
                  child: SizedBox(
                    width: screenWidth * 0.8,
                    child: Column(
                      // column of all stats
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Container(
                            height: 200,
                            width: screenWidth * 0.7,
                            child: BarChartWeekly(),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 30.0),
                          child: Text(
                            "Attributes",
                            style: TextStyle(color: Colors.black, fontSize: 18),
                          ),
                        ),
                        Container(
                          height: screenWidth * 0.8,
                          child: RadarChartAttribute(),
                        ),
                        FutureBuilder(
                          future: _db.getUserAttributes(),
                          builder: (context, snapshot) {
                            Map data = snapshot.hasData
                                ? snapshot.data
                                : {
                                    "Vitality": 50,
                                    "Spirit": 50,
                                    "Charm": 50,
                                    "Resolve": 50,
                                    "Intelligence": 50,
                                  };
                            return Table(
                              defaultVerticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              children: [
                                TableRow(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 0),
                                      child: Text(
                                        "Intelligence:",
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Text(
                                      (data["Intelligence"] / 10)
                                          .round()
                                          .toString(),
                                      textAlign: TextAlign.center,
                                    )
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 0),
                                      child: Text(
                                        "Vitality:",
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Text(
                                      (data["Vitality"] / 10).round().toString(),
                                      textAlign: TextAlign.center,
                                    )
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 0),
                                      child: Text(
                                        "Spirit:",
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Text(
                                      (data["Spirit"] / 10).round().toString(),
                                      textAlign: TextAlign.center,
                                    )
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 0),
                                      child: Text(
                                        "Charm:",
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Text(
                                      (data["Charm"] / 10).round().toString(),
                                      textAlign: TextAlign.center,
                                    )
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 0),
                                      child: Text(
                                        "Resolve:",
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Text(
                                      (data["Resolve"] / 10).round().toString(),
                                      textAlign: TextAlign.center,
                                    )
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: Text(
                            "All Past Activities",
                            style: TextStyle(color: PresetColors.blackAccent, fontSize: 18),
                          ),
                        ),
                        Center(
                          widthFactor: 0.7,
                          child: PieChartOverview(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Hid sign out button on Profile page
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          //   child: MyButtons.roundedRed(
          //     key: ValueKey("sign-out-button"),
          //     text: "Sign Out",
          //     onPressed: () async {
          //       await _auth.signOut();
          //       Navigator.of(context).popUntil((route) => route.isFirst);
          //     },
          //   ),
          // ),
        ]),
      ),
    );
  }

  /// Create bottom sheet for upload profile picture
  Widget bottomSheet() {
    return Container(
      height: 100.0,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      child: Column(
        children: <Widget>[
          Text(
            "Choose Profile photo",
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: <
              Widget>[
            TextButton(
              child: Row(
                children: [
                  Icon(Icons.camera),
                  Text(
                    "Camera",
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
              onPressed: () async {
                PickedFile pickedImage = await pickPhoto(ImageSource.camera);
                File croppedImage = await cropPhoto(pickedImage);
                _db.uploadProfilePic(croppedImage).then((_) {
                  setState(() {});
                  Navigator.pop(context);
                  MySnackBar.show(
                      context, Text("Profile picture updated successfully."));
                });
              },
            ),
            TextButton(
              child: Row(
                children: [
                  Icon(Icons.image),
                  Text(
                    "Gallery",
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
              onPressed: () async {
                PickedFile pickedImage = await pickPhoto(ImageSource.gallery);
                File croppedImage = await cropPhoto(pickedImage);
                _db.uploadProfilePic(croppedImage).then((_) {
                  setState(() {});
                  Navigator.pop(context);
                  MySnackBar.show(
                      context, Text("Profile picture updated successfully."));
                });
              },
            ),
          ])
        ],
      ),
    );
  }

  /// Pick a photo file from an ImageSource [source]
  Future<PickedFile> pickPhoto(ImageSource source) async {
    final PickedFile pickedFile = await ImagePicker().getImage(
      source: source,
    );

    return pickedFile;
  }

  /// Crop a [pickedImage] to a new file
  Future<File> cropPhoto(PickedFile pickedImage) async {
    return ImageCropper.cropImage(
      sourcePath: pickedImage.path,
      maxHeight: 200,
      maxWidth: 200,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      aspectRatioPresets: [CropAspectRatioPreset.square],
      androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Crop image',
          toolbarColor: PresetColors.blueAccent,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true),
    );
  }
}
