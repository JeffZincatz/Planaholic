import 'package:flutter/material.dart';
import 'package:plannus/elements/Loading.dart';
import 'package:plannus/elements/MyButtons.dart';
import 'package:plannus/util/PresetColors.dart';
import 'package:plannus/util/Validate.dart';
import 'package:plannus/services/AuthService.dart';

import 'ResetPasswordSuccessful.dart';

class ResetPassword extends StatefulWidget {
  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final _formKey = GlobalKey<FormState>();
  final _auth = AuthService();

  String email = "";
  String error = "";

  bool loading = false;

  Validate validator = new Validate();

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            appBar: AppBar(backgroundColor: PresetColors.blueAccent),
            backgroundColor: PresetColors.background,
            body: SafeArea(
              child: Center(
                child: FractionallySizedBox(
                  widthFactor: 0.8,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      Text(
                        "Worry not! We will send an email to reset your password.",
                        style: TextStyle(
                          fontSize: 36,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 30, horizontal: 8),
                        child: Form(
                          key: _formKey,
                          child: TextFormField(
                            decoration: InputDecoration(
                              icon: Icon(Icons.email),
                              hintText: 'Enter your email',
                              labelText: 'Email',
                            ),
                            onChanged: (value) {
                              setState(() => email = value);
                            },
                            validator: validator.validateEmail,
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          error,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      MyButtons.roundedBlue(
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            setState(() {
                              loading = true;
                            });
                            try {
                              await _auth.sendPasswordResetEmail(email: email);
                              Navigator.of(context).popUntil((route) => route.isFirst);
                              Navigator.push(context, MaterialPageRoute(builder: (context) => ResetPasswordSuccessful()));
                            } catch (err) {
                              setState(() {
                                loading = false;
                                error = err;
                              });
                            }
                          }
                        },
                        text: "Reset Password",
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}