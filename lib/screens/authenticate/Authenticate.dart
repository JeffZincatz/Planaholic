import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:planaholic/util/PresetColors.dart';

/// Authentication front page
class Authenticate extends StatefulWidget {
  const Authenticate({Key key}) : super(key: key);

  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: PresetColors.background,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/notebook_logo.png",
                    width: screenWidth * 0.15,
                  ),
                  Image.asset(
                    "assets/images/Planaholic logo.png",
                    width: screenWidth * 0.7,
                  ),
                ],
              ),
            ),
            Column(
              children: [
                TextButton.icon(
                  key: ValueKey("sign-in-button"),
                  onPressed: (){Navigator.pushNamed(context, '/signin');},
                  icon: Icon(
                    Icons.login_rounded,
                    color: Colors.white,
                  ),
                  label: Text(
                    "Sign In",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: PresetColors.blueAccent,
                    minimumSize: Size(200, 50),
                    padding: EdgeInsets.all(5),
                  ),
                ),
                SizedBox(height: 30,),
                TextButton.icon(
                  key: ValueKey("sign-up-button"),
                  onPressed: (){Navigator.pushNamed(context, '/signup');},
                  icon: Icon(
                    Icons.account_box,
                    color: PresetColors.blueAccent,
                  ),
                  label: Text(
                    "Sign Up",
                    style: TextStyle(
                        color: PresetColors.blueAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 20
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    minimumSize: Size(200, 50),
                    padding: EdgeInsets.all(5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
