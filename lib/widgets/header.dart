import 'package:flutter/material.dart';
import 'package:simple_finance/constants/ui_constants.dart';

class Header extends StatelessWidget {
  final String headline;
  final Widget trailing;
  final EdgeInsets margin;

  Header({this.trailing, this.headline, this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:margin == null ? EdgeInsets.all(0) : margin,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            alignment: Alignment.bottomLeft,
            child: Text(
                headline,
                style: Theme.of(context).textTheme.headline1
            ),
          ),
          trailing != null ? trailing : Container()
        ],
      ),
    );
  }
}