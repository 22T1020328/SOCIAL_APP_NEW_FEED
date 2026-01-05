import 'package:flutter/cupertino.dart';

class ErrorPopup extends StatelessWidget {
  final String content;
  final String confirmText;
  final void Function()? onOk;
  final String title;

  const ErrorPopup({
    Key? key,
    required this.content,
    this.confirmText = "Ok",
    this.onOk,
    this.title = "Notification",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(title),
      ),
      content: Text(content),
      actions: <Widget>[
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            onOk?.call();
          },
          child: Text(confirmText),
        )
      ],
    );
  }
}

