import 'package:flutter/material.dart';

class ShowDialogbox {
  static warningDialogueBox(context, String message) {
    return showDialog(

        context: context,
        builder: (BuildContext context)
    {
      return AlertDialog(

        title: const Text("Warning"),
        content: Text(message),
        actions: [
          TextButton(child: const Text("Ok"),
            onPressed: () {
              Navigator.of(context).pop();
            },)
        ],
      );
    }
    );}
}