import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

mixin DialogErrorMixin<T extends StatefulWidget> on State<T> {
  Future<T?> showErrorMessage(String content) {
    return showDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Text('Alert'),
        ),
        content: Text(content),
        actions: <Widget>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Ok'),
          )
        ],
      ),
    );
  }
}

