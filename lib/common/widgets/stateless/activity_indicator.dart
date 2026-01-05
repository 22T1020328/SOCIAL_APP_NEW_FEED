import 'package:flutter/cupertino.dart';

class ActivityIndicator extends StatelessWidget {
  const ActivityIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
           Padding(
            padding:  EdgeInsets.only(right: 8.0),
            child: CupertinoActivityIndicator(),
          ),
          Text(
            "Loading...",
          ),
        ],
      ),
    );
  }
}

