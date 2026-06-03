import 'package:flutter/material.dart';

class ErrorView extends StatelessWidget {
  final String message;

  const ErrorView({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(Icons.error_outline, color: Colors.red, size: 60),
        SizedBox(height: 20),
        Text(
          "Error al registrar",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
        ),
        SizedBox(height: 10),
        Text(
          message,
          style: TextStyle(color: Colors.red[200], fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}