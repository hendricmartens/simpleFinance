import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:simple_finance/constants/db_constants.dart';
import 'package:simple_finance/constants/route_constants.dart';
import 'package:simple_finance/constants/ui_constants.dart';
import 'package:simple_finance/db.dart';
import 'package:simple_finance/languages/language.dart';
import 'package:simple_finance/model/account.dart';
import 'package:simple_finance/provider/preferences.dart';
import 'package:simple_finance/utils.dart';
import 'package:simple_finance/widgets/shadow_box.dart';

class IntroScreen extends StatefulWidget {
  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        body: FutureBuilder(
            future: precacheImage(
                AssetImage('resources/images/oie_transparent.png'), context),
            builder: (context, data) {
              if (data.connectionState != ConnectionState.done) {
                return Container(
                  color: Theme.of(context).backgroundColor,
                );
              }
              return Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: intro_gradient_colors)),
                child: Container(
                  margin: EdgeInsets.only(
                      left: default_padding * 1.5,
                      right: default_padding * 1.5,
                      bottom: default_padding * 2,
                      top: default_padding * 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Center(
                          child: Text(Language.of(context).welcome,
                              style: Theme.of(context).textTheme.headline6)),
                      Stack(
                        children: [
                          Image(
                            height: size.height * intro_image_height,
                            fit: BoxFit.fitWidth,
                            image: AssetImage(
                                'resources/images/oie_transparent.png'),
                          ),
                          Positioned(
                              bottom: default_padding / 3,
                              right: default_padding * 1.8,
                              child: Text(
                                "Designed by pch.vector / Freepik",
                                style: TextStyle(
                                    color: Colors.black26, fontSize: 8),
                              ))
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(default_box_radius),
                                color: Colors.white),
                            child: FlatButton(
                              padding: EdgeInsets.zero,
                              child: Container(
                                padding: button_padding,
                                child: Text(
                                  Language.of(context).start_now,
                                  style: Theme.of(context).textTheme.headline5,
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context)
                                    .pushNamed(route_first_account);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }));
  }
}

class IntroCreateAccount extends StatefulWidget {
  @override
  _IntroCreateAccountState createState() => _IntroCreateAccountState();
}

class _IntroCreateAccountState extends State<IntroCreateAccount> {
  String _name;
  double _balance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  FocusNode _balanceFocusNode = FocusNode();
  FocusNode _nameFocusNode = FocusNode();

  @override
  void initState() {
    var usrPrefs = Provider.of<Preferences>(context, listen: false);

    setState(() {
      _balance = 0.0;
      _amountController.text =
          Utils.formatMoney(_balance, usrPrefs.language, usrPrefs.decimal);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: intro_gradient_colors)),
      child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  (!_balanceFocusNode.hasFocus && !_nameFocusNode.hasFocus)
                      ? Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: default_padding * 1.5,
                              vertical: default_padding * 1.5),
                          child: Text(
                            Language.of(context).create_your_first_acc,
                            style: Theme.of(context).textTheme.headline6,
                          ),
                        )
                      : Container(),
                  Container(
                      margin: EdgeInsets.only(top: default_padding * 2),
                      child: Center(child: _buildFirstAccountForm(context)))
                ],
              ),
            ),
          )),
    );
  }

  Widget _buildFirstAccountForm(BuildContext context) {
    var usrPrefs = Provider.of<Preferences>(context, listen: false);
    return AlertDialog(
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(default_box_radius)),
      contentPadding: dialog_content_padding,
      content: SingleChildScrollView(
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                  margin: EdgeInsets.only(bottom: default_padding),
                  child: Text(
                    Language.of(context).new_account,
                    style: Theme.of(context).textTheme.headline2,
                  )),
            ],
          ),
          Form(
            key: _formKey,
            child: Column(
              children: [
                _buildLabel(Language.of(context).name,
                    margin: EdgeInsets.only(left: default_padding)),
                Container(
                  child: _buildNameField(),
                  margin: EdgeInsets.only(bottom: default_padding / 2),
                ),
                _buildLabel(Language.of(context).balance,
                    margin: EdgeInsets.only(left: default_padding)),
                Container(
                  child: _buildAmountField(),
                  margin: EdgeInsets.only(bottom: default_padding),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).accentColor),
                      child: IconButton(
                        icon: Icon(Icons.check,
                            color: Theme.of(context).backgroundColor),
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            _formKey.currentState.save();

                            DB.createAccount(
                                Account(name: _name, balance: _balance),
                                Language.of(context).initial_deposit);

                            usrPrefs.sharedPreferences
                                .setBool(sp_launch_before, true);
                            Navigator.of(context)
                                .pushReplacementNamed(route_start_app);
                          }
                        },
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildLabel(String text, {EdgeInsets margin}) {
    return Container(
        margin: margin == null ? EdgeInsets.all(0) : margin,
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: Theme.of(context).textTheme.subtitle1,
        ));
  }

  Widget _buildNameField() {
    return ShadowBox(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      shadowRadius: 2,
      child: TextFormField(
        controller: _nameController,
        focusNode: _nameFocusNode,
        decoration: InputDecoration(
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          border: InputBorder.none,
        ),
        style: Theme.of(context).textTheme.headline4,
        onTap: () {
          setState(() {});
        },
        onSaved: (value) {
          value = value.trim();
          if (value.isNotEmpty) {
            _name = value;
          }
        },
        validator: (value) {
          value = value.trim();
          if (value.isEmpty) {
            return Language.of(context).name_empty;
          }

          return null;
        },
      ),
    );
  }

  Widget _buildAmountField() {
    Size size = MediaQuery.of(context).size;
    var usrPrefs = Provider.of<Preferences>(context, listen: false);
    return ShadowBox(
      shadowRadius: 2,
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Row(
        children: [
          Text(
            usrPrefs.currencySymbol,
            style: balanceField,
          ),
          Container(
            margin: EdgeInsets.only(left: 5),
            width: size.width * balance_field_width,
            child: TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.numberWithOptions(signed: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                    RegExp(r"^\-?\d*\,?\.?\d{0,2}")),
              ],
              focusNode: _balanceFocusNode,
              onTap: () {
                if (!_balanceFocusNode.hasFocus) {
                  _amountController.text = _amountController.text.replaceAll(
                      Utils.getThousandFigure(usrPrefs.language), "");
                  if (_amountController.text.startsWith("0")) {
                    _amountController.text =
                        _amountController.text.replaceFirst("0", "");
                  }
                  if (_amountController.text
                      .contains(Utils.getDecimalFigure(usrPrefs.language))) {
                    _amountController.selection = TextSelection.collapsed(
                        offset: _amountController.text.indexOf(
                            Utils.getDecimalFigure(usrPrefs.language)));
                  }
                }
              },
              onEditingComplete: () {
                _amountController.text = Utils.formatMoney(
                    _balance, usrPrefs.language, usrPrefs.decimal);
                if (_balance == 0.0) {
                  _amountController.text =
                      _amountController.text.replaceAll("-", "");
                }

                FocusScope.of(context).unfocus();
              },
              onChanged: (value) {
                double amount = 0.0;
                if (value.isNotEmpty) {
                  amount = Utils.parseMoney(value, usrPrefs.language);
                }

                setState(() {
                  _balance = amount;
                });
              },
              validator: (value) {
                if (value.isEmpty) {
                  return Language.of(context).amount_empty_msg;
                }

                return null;
              },
              style: TextStyle(
                fontWeight: balanceField.fontWeight,
                fontSize: balanceField.fontSize,
                color: _balance < 0
                    ? negative_color
                    : (_balance > 0 ? positive_color : zeroColor),
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
