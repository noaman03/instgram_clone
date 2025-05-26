import 'package:flutter/material.dart';

class ExeptionMessage {
  String message;
  ExeptionMessage(this.message);
}

// ignore: unused_element
void _showErrorSnackbar(BuildContext context, ExeptionMessage error) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(error.message),
      backgroundColor:
          Colors.red, // Optional: Make the snackbar red for error indication
      duration: const Duration(seconds: 3),
      action: SnackBarAction(
        label: 'Dismiss',
        textColor: Colors.white,
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    ),
  );
}
