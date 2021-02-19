import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:provider/provider.dart';
import 'package:simple_finance/constants/model_constants.dart';
import 'package:simple_finance/constants/ui_constants.dart';
import 'package:simple_finance/db.dart';
import 'package:simple_finance/languages/language.dart';
import 'package:simple_finance/provider/preferences.dart';
import 'package:simple_finance/utils.dart';
import 'package:simple_finance/widgets/shadow_box.dart';
import 'package:simple_finance/widgets/popup_dialog.dart';

class GeneralSettings extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  GeneralSettings(this.navigatorKey);

  @override
  _GeneralSettingsState createState() => _GeneralSettingsState();
}

class _GeneralSettingsState extends State<GeneralSettings> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).appBarTheme.color,
          elevation: Theme.of(context).appBarTheme.elevation,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(
              back_icon,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: () {
              widget.navigatorKey.currentState.pop();
            },
          ),
        ),
        body: SafeArea(
          child: Container(
            margin: EdgeInsets.only(
                left: default_padding / 1.5,
                right: default_padding / 1.5,
                top: default_padding / 2),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                      margin: EdgeInsets.only(bottom: default_padding / 4),
                      child: CurrencyOption()),
                  Container(
                      margin: EdgeInsets.only(bottom: default_padding / 4),
                      child: DecimalOption()),
                  Container(
                      margin: EdgeInsets.only(bottom: default_padding / 4),
                      child: _buildGraphOption()),
                  Container(
                      margin: EdgeInsets.only(bottom: default_padding / 4),
                      child: _buildSynchronizationOption()),
                  Container(
                      margin: EdgeInsets.only(bottom: default_padding / 4),
                      child: _buildThemeOption()),
                  Container(
                      margin: EdgeInsets.only(bottom: default_padding / 4),
                      child: _buildSecurityOption()),
                  Container(
                      margin: EdgeInsets.only(bottom: default_padding / 4),
                      child: _buildAboutOption()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGraphOption() {
    Size size = MediaQuery.of(context).size;
    return ShadowBox(
        shadowRadius: 3,
        padding: EdgeInsets.symmetric(
            horizontal: default_padding, vertical: default_padding),
        child: Container(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: default_padding / 2),
                    child: Text(
                      Language.of(context).graph,
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  ),
                ],
              ),
            ),
            Container(
                height: size.height * graph_option_height,
                child: Swiper(
                  pagination: new SwiperPagination(
                    alignment: Alignment.bottomCenter,
                    builder: graphOptionSwiperDots,
                  ),
                  loop: false,
                  viewportFraction: 1,
                  scale: 0.9,
                  itemCount: 2,
                  itemBuilder: (context, index) {
                    return ShadowBox(
                        child: Container(
                            margin:
                                EdgeInsets.only(bottom: default_padding / 1.5),
                            child: index == 1
                                ? Container(
                                    child: Center(
                                      child: Text(Language.of(context)
                                          .more_coming_soon),
                                    ),
                                  )
                                : Container(
                                    child: Column(
                                      children: [
                                        Container(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                Language.of(context)
                                                    .column_graph,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText1,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Image(
                                            height: image_height,
                                            fit: BoxFit.fitWidth,
                                            image: AssetImage(
                                                'resources/images/column_graph.jpg')),
                                      ],
                                    ),
                                  )));
                  },
                ))
          ]),
        ));
  }

  Widget _buildSecurityOption() {
    return ShadowBox(
        shadowRadius: 3,
        padding: EdgeInsets.symmetric(
            horizontal: default_padding, vertical: default_padding / 2),
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Language.of(context).security,
                style: Theme.of(context).textTheme.headline5,
              ),
              Text(
                Language.of(context).coming_soon,
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ],
          ),
        ));
  }

  Widget _buildThemeOption() {
    return ShadowBox(
        shadowRadius: 3,
        padding: EdgeInsets.symmetric(
            horizontal: default_padding, vertical: default_padding / 2),
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Language.of(context).theme,
                style: Theme.of(context).textTheme.headline5,
              ),
              Text(
                Language.of(context).coming_soon,
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ],
          ),
        ));
  }

  Widget _buildFeedbackOption() {
    return ShadowBox(
        shadowRadius: 3,
        padding: EdgeInsets.symmetric(
            horizontal: default_padding, vertical: default_padding / 2),
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Language.of(context).feedback,
                style: Theme.of(context).textTheme.headline5,
              ),
              Text(
                Language.of(context).coming_soon,
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ],
          ),
        ));
  }

  Widget _buildSynchronizationOption() {
    return ShadowBox(
        shadowRadius: 3,
        padding: EdgeInsets.symmetric(
            horizontal: default_padding, vertical: default_padding / 2),
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Language.of(context).synchronization,
                style: Theme.of(context).textTheme.headline5,
              ),
              Text(
                Language.of(context).coming_soon,
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ],
          ),
        ));
  }

  Widget _buildAboutOption() {
    return GestureDetector(
      onTap: () {
        showDialog(
            context: context,
            useRootNavigator: false,
            builder: (context) => AlertDialog(
                  content: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              widget.navigatorKey.currentState
                                  .push(MaterialPageRoute(
                                      builder: (context) => SafeArea(
                                            child: LicensePage(
                                              applicationIcon: Image(
                                                  height: 100,
                                                  image: AssetImage(
                                                      'resources/images/icon.png')),
                                              applicationName:
                                                  "\nsimple finance",
                                            ),
                                          )));
                            },
                            child: Text("Licenses")),
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              showDialog(
                                  useRootNavigator: false,
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        content: SingleChildScrollView(
                                          child: Column(
                                            children: [
                                              Container(
                                                  margin: EdgeInsets.only(
                                                      bottom:
                                                          default_padding / 2),
                                                  child: Text(
                                                    "Privacy Policy",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline3,
                                                  )),
                                              Text(
                                                privacy_policy,
                                                textAlign: TextAlign.left,
                                              ),
                                              FlatButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: Center(
                                                      child: Text("Okay")))
                                            ],
                                          ),
                                        ),
                                      ));
                            },
                            child: Text("Policy"))
                      ],
                    ),
                  ),
                ));
      },
      child: ShadowBox(
          shadowRadius: 3,
          padding: EdgeInsets.symmetric(
              horizontal: default_padding, vertical: default_padding),
          child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "About",
                  style: Theme.of(context).textTheme.headline5,
                ),
              ],
            ),
          )),
    );
  }
}

class CurrencyOption extends StatefulWidget {
  @override
  _CurrencyOptionState createState() => _CurrencyOptionState();
}

class _CurrencyOptionState extends State<CurrencyOption> {
  @override
  Widget build(BuildContext context) {
    var usrPrefs = Provider.of<Preferences>(context);
    return ShadowBox(
        shadowRadius: 3,
        padding: EdgeInsets.symmetric(
            horizontal: default_padding, vertical: default_padding / 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: Text(
                Language.of(context).currency,
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
            Container(
              child: DropdownButtonHideUnderline(
                child: DropdownButton(
                    value: usrPrefs.currency,
                    items: currencies.keys.toList().map((String key) {
                      return DropdownMenuItem(
                        value: key,
                        child: Text(key,
                            style: Theme.of(context).textTheme.bodyText1),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      final oldValue = usrPrefs.currency;
                      if (newValue != oldValue) {
                        showDialog(
                            useRootNavigator: false,
                            context: context,
                            builder: (context) => PopupDialog(
                                question: Language.of(context)
                                        .convert_currencies1 +
                                    newValue +
                                    Language.of(context).convert_currencies2,
                                onYes: () {
                                  Utils.isConnected().then((connected) {
                                    if (connected) {
                                      DB
                                          .convertCurrency(oldValue, newValue)
                                          .then((value) {
                                        _showToast(
                                            context,
                                            oldValue +
                                                " " +
                                                Language.of(context)
                                                    .currency_converted +
                                                " " +
                                                newValue);
                                      });
                                    } else {
                                      _showToast(
                                          context,
                                          Language.of(context)
                                              .conversion_failed);
                                    }

                                    usrPrefs.currency = newValue;
                                    setState(() {});
                                  });
                                },
                                onNo: () {}));
                      }
                    }),
              ),
            ),
          ],
        ));
  }

  void _showToast(BuildContext context, String text) {
    final scaffold = Scaffold.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  }
}

class LanguageOption extends StatefulWidget {
  @override
  _LanguageOptionState createState() => _LanguageOptionState();
}

class _LanguageOptionState extends State<LanguageOption> {
  @override
  Widget build(BuildContext context) {
    var usrPrefs = Provider.of<Preferences>(context);
    return ShadowBox(
      shadowRadius: 3,
      padding: EdgeInsets.symmetric(
          horizontal: default_padding, vertical: default_padding / 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Text(
              Language.of(context).language,
              style: Theme.of(context).textTheme.headline5,
            ),
          ),
          Container(
            child: DropdownButtonHideUnderline(
                child: DropdownButton(
                    value: usrPrefs.language,
                    items: languages.keys.map((String key) {
                      return DropdownMenuItem(
                        value: key,
                        child: Text(languages[key],
                            style: Theme.of(context).textTheme.bodyText1),
                      );
                    }).toList(),
                    onChanged: (value) {
                      usrPrefs.language = value;
                      setState(() {});
                    })),
          )
        ],
      ),
    );
  }
}

class DecimalOption extends StatefulWidget {
  @override
  _DecimalOptionState createState() => _DecimalOptionState();
}

class _DecimalOptionState extends State<DecimalOption> {
  @override
  Widget build(BuildContext context) {
    var usrPrefs = Provider.of<Preferences>(context);
    return ShadowBox(
        shadowRadius: 3,
        padding: EdgeInsets.symmetric(
            horizontal: default_padding, vertical: default_padding / 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: Text(
                Language.of(context).decimal_option,
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
            Container(
              child: DropdownButtonHideUnderline(
                  child: DropdownButton(
                      value: usrPrefs.decimal,
                      items: [0, 1, 2].map((int decimal) {
                        return DropdownMenuItem(
                          value: decimal,
                          child: Text(decimal.toString(),
                              style: Theme.of(context).textTheme.bodyText1),
                        );
                      }).toList(),
                      onChanged: (value) {
                        usrPrefs.decimal = value;
                        setState(() {});
                      })),
            )
          ],
        ));
  }
}
