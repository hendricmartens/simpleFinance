import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_finance/constants/route_constants.dart';
import 'package:simple_finance/provider/active_page.dart';
import 'package:simple_finance/screens/home.dart';
import 'package:simple_finance/screens/settings.dart';
import 'package:simple_finance/screens/create_transaction.dart';
import 'package:simple_finance/widgets/bottom_nav_bar.dart';
import 'package:provider/provider.dart';

class NavigatorScreen extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return SystemNavigator.pop();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: Navigator(
          key: navigatorKey,
          onGenerateRoute: (RouteSettings settings) {
            WidgetBuilder builder;
            ActivePage preferences =
                Provider.of<ActivePage>(context, listen: false);

            switch (settings.name) {
              case route_home:
                if (preferences.index != 0) preferences.changeIndex(0);
                builder = (BuildContext context) => HomeScreen(navigatorKey);
                break;
              case route_transaction:
                if (preferences.index != 1) preferences.changeIndex(1);
                builder = (BuildContext context) => TransactionScreen(
                    navigatorKey,
                    editTransaction: settings.arguments);
                break;
              case route_settings:
                if (preferences.index != 2) preferences.changeIndex(2);
                builder =
                    (BuildContext context) => SettingsScreen(navigatorKey);
                break;
              default:
                throw Exception('Invalid route: ${settings.name}');
            }

            return MaterialPageRoute(
              builder: builder,
              settings: settings,
            );
          },
        ),
        bottomNavigationBar: BottomNavBar(navigatorKey),
      ),
    );
  }
}
