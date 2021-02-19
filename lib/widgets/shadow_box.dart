import 'package:flutter/material.dart';
import 'package:simple_finance/constants/ui_constants.dart';

class ShadowBox extends StatelessWidget {
  final Color shadowColor;
  final double shadowRadius;
  final Color boxColor;
  final Radius boxRadius;
  final EdgeInsets padding;
  final Widget child;
  final Function onPressed;
  final Function onLongPress;

  ShadowBox(
      {this.shadowColor = Colors.grey,
      this.shadowRadius = default_box_shadow_radius,
      this.boxColor = default_box_color,
      this.boxRadius = default_box_radius,
      this.padding = default_box_padding, this.child, this.onPressed, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.all(boxRadius),
        child: FlatButton(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: EdgeInsets.all(0),
          onPressed: onPressed == null? null: onPressed,
          onLongPress: onLongPress == null? null : onLongPress,
          child: Container(
            padding: padding,
            margin: EdgeInsets.all(shadowRadius),
            decoration: BoxDecoration(
              color:boxColor,
              borderRadius: BorderRadius.all(boxRadius),
              boxShadow: [
                BoxShadow(
                  color:shadowColor,
                  offset: default_box_shadow_offset, //(x,y)
                  blurRadius:shadowRadius,
                ),
              ],
            ),
            child: child,
          ),
        ));
  }
}
