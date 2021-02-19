import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

const double default_padding = 20;

const EdgeInsets default_page_margin = EdgeInsets.symmetric(
    horizontal: default_padding / 3, vertical: default_padding / 1.5);
const EdgeInsets default_list_item_margin =
    EdgeInsets.symmetric(horizontal: 5, vertical: 10);
const EdgeInsets default_box_padding =
    EdgeInsets.symmetric(horizontal: 10, vertical: 10);
const Radius default_box_radius = Radius.circular(20);

const EdgeInsets headline_padding =
    EdgeInsets.only(left: 10, right: 0, bottom: 0, top: 10);
const double default_box_shadow_radius = 4.0;

const Offset default_box_shadow_offset = Offset(0.0, 1.0);

const double swiper_card_height = 0.54;
const double transaction_card_height = 0.125;
const double transaction_card_width = 0.35;

const int transaction_card_money_treshold = 100000;

const TextStyle money = TextStyle(
  fontSize: 20.0,
  fontWeight: FontWeight.bold,
);
const TextStyle graph_label = TextStyle(fontSize: 10.0);

const int graph_compact_treshold = 5000;

final DotSwiperPaginationBuilder swiperDot = DotSwiperPaginationBuilder(
    size: 7, color: Colors.grey, activeColor: primaryTheme.primaryColor);

const Color negative_color = Colors.red;
const Color positive_color = Colors.green;
final Color zeroColor = primaryTheme.primaryColor;

const Color default_shadow_color = Colors.grey;
const Color default_box_color = Colors.white;

const Color graph_color = Colors.blueAccent;
final LinearGradient graphGradient = LinearGradient(
  colors: [primaryTheme.backgroundColor, Colors.blueAccent[200], graph_color],
  stops: [0, 0.7, 1.0],
  begin: Alignment.bottomCenter,
  end: Alignment.topCenter,
);
const Color graph_negative = negative_color;
const Color graph_positive = positive_color;
const double marker_radius = 6.0;

const double nav_bar_height = 90;
const IconData home_icon = Icons.account_balance;
const IconData add_icon = Icons.add;
const IconData settings_icon = Icons.settings;

//create_transaction
const IconData close_icon = Icons.close;
const IconData back_icon = Icons.arrow_back_ios;
const IconData check_icon = Icons.check;

const double amount_field_size = 0.72;
final TextStyle amountField = TextStyle(
    fontSize: 50,
    fontWeight: FontWeight.bold,
    color: primaryTheme.primaryColor);
const double cursor_width = 2;
const double cursor_radius = 5;
const int suggestions = 2;
const double autocomplete_item_height = 0.07;

//settings
const double account_list_height = 0.12;
const double account_tile_width = 0.35;
const int account_balance_treshold = 1000000;
const EdgeInsets dialog_content_padding =
    EdgeInsets.symmetric(vertical: 20, horizontal: 18);
final TextStyle balanceField = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: primaryTheme.primaryColor);
const double balance_field_width = 0.5;

//general
const double graph_option_height = 0.22;
final DotSwiperPaginationBuilder graphOptionSwiperDots =
    DotSwiperPaginationBuilder(
        size: 5,
        activeSize: 8,
        color: Colors.grey,
        activeColor: primaryTheme.primaryColor);
const double image_height = 100;

//intro
const List<Color> intro_gradient_colors = [
  Colors.lightBlueAccent,
  Colors.deepPurpleAccent
];
const double intro_image_height = 0.3;
const EdgeInsets button_padding = EdgeInsets.all(20);

final ThemeData primaryTheme = ThemeData(
// Define the default brightness and colors.
  brightness: Brightness.light,
  primaryColor: Colors.black,
  accentColor: Colors.blueAccent,
  backgroundColor: Colors.white,
  dividerColor: Colors.grey,
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: Colors.black,
    unselectedItemColor: Colors.grey,
  ),
  appBarTheme: AppBarTheme(color: Colors.white, elevation: 1),

  iconTheme: IconThemeData(color: Colors.black, size: 30),

  cursorColor: Colors.black,
  fontFamily: 'Montserrat',

// Define the default TextTheme. Use this to specify the default
// text styling for headlines, titles, bodies of text, and more.
  textTheme: TextTheme(
    headline1: TextStyle(
        fontSize: 30.0, fontWeight: FontWeight.bold, color: Colors.black),
    headline2: TextStyle(
        fontSize: 25.0, fontWeight: FontWeight.bold, color: Colors.black),
    headline3: TextStyle(
        fontSize: 15.0, fontWeight: FontWeight.bold, color: Colors.black),
    headline4: TextStyle(fontSize: 20.0, color: Colors.black),
    headline5: TextStyle(
        fontSize: 20.0, color: Colors.black, fontWeight: FontWeight.bold),
    headline6: TextStyle(
        fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
    bodyText1: TextStyle(
        fontSize: 15.0, color: Colors.black, fontWeight: FontWeight.normal),
    bodyText2: TextStyle(fontSize: 12.0, color: Colors.black, height: 0.9),
    subtitle1: TextStyle(fontSize: 15.0, color: Colors.black26),
    subtitle2: TextStyle(
        fontSize: 11.0, color: Colors.black26, fontWeight: FontWeight.normal),
  ),
);

const String privacy_policy = "What kind of data?"
    "\nNo kind of personal data is saved."
    "\nThe only data that is saved, is data about the fictional groups, accounts and transactions created in the app itself by the user."
    "\n\nWhere is the data saved?\n"
    "All the data is saved locally, which is why no one has access to the data but the user itself."
    "\nThe application only uses the internet connection to pull the latest currency conversion rates in order to convert between currencies."
    "\n\nHow to delete the data?\n"
    "In order to delete the data, which is locally saved, the user just has to delete the app and its data.";
