import 'package:flutter/material.dart';

void KShowSnackBar(BuildContext context, String message, [int durationInSec = 2]) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: Duration(
          seconds: durationInSec)
    ),
  );
}
