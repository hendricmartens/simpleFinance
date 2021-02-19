import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_finance/constants/route_constants.dart';
import 'package:simple_finance/constants/ui_constants.dart';
import 'package:simple_finance/provider/active_page.dart';

class BottomNavBar extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  BottomNavBar(this.navigatorKey);

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  @override
  Widget build(BuildContext context) {
    ActivePage preferences = Provider.of<ActivePage>(context);
    Size size = MediaQuery.of(context).size;
    return Container(
      color: Colors.white,
      height: nav_bar_height,
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: size.width,
              height: nav_bar_height,
              child: Stack(
                children: [
                  CustomPaint(
                    size: Size(size.width, nav_bar_height),
                    painter: BottomNavBarPainter(backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor),
                  ),
                  Center(
                    heightFactor: 0.6,
                    child: FloatingActionButton(
                      onPressed: () {
                        if (preferences.index != 1) {
                          widget.navigatorKey.currentState
                              .pushNamed(route_transaction);
                        }
                      },
                      backgroundColor: Theme.of(context).accentColor,
                      child: Icon(
                        add_icon,
                        size: Theme.of(context).iconTheme.size,
                        color: preferences.index == 1
                            ? Theme.of(context).accentColor
                            : Theme.of(context).bottomNavigationBarTheme.backgroundColor,
                      ),
                      elevation: 2,
                    ),
                  ),
                  Container(
                    width: size.width,
                    height: nav_bar_height,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                            icon: Icon(
                              home_icon,
                              size: Theme.of(context).iconTheme.size,
                              color: preferences.index == 0
                                  ? Theme.of(context).bottomNavigationBarTheme.selectedItemColor
                                  : Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
                            ),
                            onPressed: () {
                              if (preferences.index != 0) {
                                widget.navigatorKey.currentState
                                    .pushNamed(route_home);
                              }
                            }),
                        Container(
                          width: size.width * 0.2,
                        ),
                        IconButton(
                            onPressed: () {
                              if (preferences.index != 2) {
                                widget.navigatorKey.currentState
                                    .pushNamed(route_settings);
                              }
                            },
                            icon: Icon(
                              settings_icon,
                              size: Theme.of(context).iconTheme.size,
                              color: preferences.index == 2
                                  ? Theme.of(context).bottomNavigationBarTheme.selectedItemColor
                                  : Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
                            ))
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class BottomNavBarPainter extends CustomPainter {

  final Color backgroundColor;

  BottomNavBarPainter({this.backgroundColor = Colors.white});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    Path path = Path()..moveTo(0, 0);
    path.quadraticBezierTo(size.width * 0.2, 0, size.width * 0.35, 0);
    path.quadraticBezierTo(size.width * 0.4, 0, size.width * 0.4, 20);
    path.arcToPoint(Offset(size.width * 0.6, 20),
        radius: Radius.circular(10), clockwise: false);
    path.quadraticBezierTo(size.width * 0.6, 0, size.width * 0.65, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawShadow(path, Colors.black, 30, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
