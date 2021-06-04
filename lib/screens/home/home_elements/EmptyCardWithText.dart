import 'package:flutter/material.dart';

class EmptyCardWithText extends StatelessWidget {
  final String text;

  EmptyCardWithText({this.text});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {},
      child: Center(child: Text(text)),
    );
  }
}