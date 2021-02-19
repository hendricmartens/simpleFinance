import 'package:flutter/material.dart';
import 'package:simple_finance/languages/language.dart';

class PopupDialog extends StatelessWidget {
  final String question;
  final Function() onYes;
  final Function() onNo;

  PopupDialog({this.question, this.onNo, this.onYes});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(
          child: Center(
              child: Text(
                question,
                textAlign: TextAlign.center,style: Theme.of(context).textTheme.headline4
              ))),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FlatButton(
            child: Text(Language.of(context).yes,),
            onPressed: () {
              onYes();
              Navigator.pop(context);
            },
          ),
          FlatButton(
              child: Text(Language.of(context).no),
              onPressed: () {
                onNo();
                Navigator.pop(context);
              })
        ],
      ),
    );
  }
}
