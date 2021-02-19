import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_finance/constants/db_constants.dart';
import 'package:simple_finance/constants/route_constants.dart';
import 'package:simple_finance/constants/ui_constants.dart';
import 'package:simple_finance/languages/app_localizations_delegate.dart';
import 'package:simple_finance/model/account.dart';
import 'package:simple_finance/model/category.dart';
import 'package:simple_finance/model/transaction.dart';
import 'package:simple_finance/provider/active_page.dart';
import 'package:simple_finance/provider/preferences.dart';
import 'package:simple_finance/screens/intro.dart';
import 'package:simple_finance/screens/navigator.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(AccountAdapter());
  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(CategoryAdapter());

  await Hive.openBox<Account>(BOX_ACCOUNT);
  await Hive.openBox<Transaction>(BOX_TRANSACTION);
  await Hive.openBox<Category>(BOX_CATEGORY);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ActivePage()),
        ChangeNotifierProvider(
          create: (context) => Preferences(window.locale),
        )
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void dispose() async {
    Hive.close();
    super.dispose();
  }

  Widget build(BuildContext context) {
    var usrPrefs = Provider.of<Preferences>(context);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return MaterialApp(
      theme: primaryTheme,
      localizationsDelegates: [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [Locale('en', ''), Locale('de', ''), Locale('es', '')],
      locale: Locale(usrPrefs.language, ''),
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale?.languageCode == locale?.languageCode &&
              supportedLocale?.countryCode == locale?.countryCode) {
            return supportedLocale;
          }
        }
        return supportedLocales?.first;
      },
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
          future: SharedPreferences.getInstance(),
          builder: (context, data) {
            if (data.hasData) {
              SharedPreferences instance = data.data;
              bool didLaunchBefore = instance.getBool(sp_launch_before);
              if (didLaunchBefore != null && didLaunchBefore) {
                Provider.of<ActivePage>(context, listen: false).index = 0;
                return NavigatorScreen();
              } else {
                return IntroScreen();
              }
            } else {
              return Container(color: Theme.of(context).backgroundColor);
            }
          }),
      routes: <String, WidgetBuilder>{
        route_start_app: (BuildContext context) => NavigatorScreen(),
        route_first_account: (BuildContext context) => IntroCreateAccount()
      },
    );
  }
}
