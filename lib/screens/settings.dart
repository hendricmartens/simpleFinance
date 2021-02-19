import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:simple_finance/constants/db_constants.dart';
import 'package:simple_finance/constants/ui_constants.dart';
import 'package:simple_finance/db.dart';
import 'package:simple_finance/languages/language.dart';
import 'package:simple_finance/model/account.dart';
import 'package:simple_finance/model/category.dart';
import 'package:simple_finance/provider/preferences.dart';
import 'package:simple_finance/screens/general_settings.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:simple_finance/utils.dart';
import 'package:simple_finance/widgets/shadow_box.dart';
import 'package:simple_finance/widgets/header.dart';
import 'package:simple_finance/widgets/popup_dialog.dart';

class SettingsScreen extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  SettingsScreen(this.navigatorKey);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.symmetric(
              horizontal: default_padding / 1.5, vertical: default_padding),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Header(
                    margin: EdgeInsets.only(bottom: default_padding / 2),
                    headline: Language.of(context).settings,
                    trailing: PopupMenuButton(
                      icon: Icon(Icons.more_vert),
                      onSelected: (value) {
                        if (value == "delete_all") {
                          showDialog(
                              useRootNavigator: false,
                              context: context,
                              builder: (context) => PopupDialog(
                                  question: Language.of(context).are_you_sure,
                                  onYes: () {
                                    DB.deleteAll();
                                  },
                                  onNo: () {}));
                        }
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                        PopupMenuItem(
                          value: "delete_all",
                          child: Text(
                            Language.of(context).delete_all,
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                        ),
                      ],
                    )),
                Container(
                    margin: EdgeInsets.only(
                        top: default_padding, bottom: default_padding / 1.5),
                    child: AccountSettings()),
                Container(
                    margin: EdgeInsets.only(bottom: default_padding / 1.5),
                    child: CategorySettings()),
                ShadowBox(
                  padding: EdgeInsets.symmetric(
                      horizontal: default_padding, vertical: default_padding),
                  onPressed: () {
                    navigatorKey.currentState.push(MaterialPageRoute(
                        builder: (context) => GeneralSettings(navigatorKey)));
                  },
                  child: Row(
                    children: [
                      Text(
                        Language.of(context).general,
                        style: Theme.of(context).textTheme.headline1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AccountSettings extends StatefulWidget {
  @override
  _AccountSettingsState createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {
  var accountBox = Hive.box<Account>(BOX_ACCOUNT);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ShadowBox(
        padding: EdgeInsets.only(
            left: default_padding,
            right: default_padding,
            top: default_padding / 2,
            bottom: default_padding),
        child: Column(
          children: [
            Header(
              margin: EdgeInsets.only(bottom: default_padding / 2),
              headline: Language.of(context).accounts,
              trailing: IconButton(
                icon: Icon(
                  add_icon,
                  color: Theme.of(context).iconTheme.color,
                ),
                onPressed: () {
                  showDialog(
                      context: context,
                      useRootNavigator: false,
                      builder: (context) => EditAccountDialog());
                },
              ),
            ),
            ValueListenableBuilder(
                valueListenable: accountBox.listenable(),
                builder: (context, Box<Account> box, _) {
                  List<Account> accounts =
                      Utils.sortAccountsByDate(accountBox.values.toList())
                          .reversed
                          .toList();
                  return Container(
                      height: size.height * account_list_height,
                      child: accounts.isEmpty
                          ? Container(
                              child: Center(
                                child: Text(Language.of(context).no_accounts),
                              ),
                            )
                          : ListView.builder(
                              itemCount: accounts.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return _buildAccountTile(accounts[index]);
                              }));
                })
          ],
        ));
  }

  Widget _buildAccountTile(Account account) {
    var categoryBox = Hive.box<Category>(BOX_CATEGORY);
    var usrPrefs = Provider.of<Preferences>(context, listen: false);
    Size size = MediaQuery.of(context).size;

    return Container(
      margin: EdgeInsets.only(right: default_padding / 4),
      width: size.width * account_tile_width,
      child: ShadowBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              alignment: Alignment.topLeft,
              child: Text(account.name,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headline3),
            ),
            Container(
                margin: EdgeInsets.only(bottom: default_padding / 4),
                alignment: Alignment.topLeft,
                child: Text(
                    account.categoryId != null
                        ? categoryBox.get(account.categoryId).name
                        : " - ",
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.subtitle2)),
            Container(
              margin: EdgeInsets.only(bottom: default_padding / 4),
              alignment: Alignment.topLeft,
              child: Text(
                Utils.formatMoney(
                    account.balance, usrPrefs.language, usrPrefs.decimal,
                    compactTreshold: account_balance_treshold,
                    currency: usrPrefs.currency),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontWeight: money.fontWeight,
                    fontSize: Theme.of(context).textTheme.bodyText2.fontSize,
                    color: account.balance < 0
                        ? negative_color
                        : (account.balance > 0 ? positive_color : zeroColor)),
              ),
            ),
          ],
        ),
        onPressed: () {
          showDialog(
              context: context,
              useRootNavigator: false,
              builder: (context) => EditAccountDialog(
                    account: account,
                  ));
        },
        onLongPress: () {
          showDialog(
              useRootNavigator: false,
              context: context,
              builder: (context) => PopupDialog(
                  question: Language.of(context).delete_account,
                  onYes: () {
                    DB.deleteAccount(account.key);
                  },
                  onNo: () {}));
        },
      ),
    );
  }
}

class CategorySettings extends StatefulWidget {
  @override
  _CategorySettingsState createState() => _CategorySettingsState();
}

class _CategorySettingsState extends State<CategorySettings> {
  @override
  Widget build(BuildContext context) {
    var categoryBox = Hive.box<Category>(BOX_CATEGORY);
    Size size = MediaQuery.of(context).size;
    return ShadowBox(
        padding: EdgeInsets.only(
            left: default_padding,
            right: default_padding,
            top: default_padding / 2,
            bottom: default_padding),
        child: Column(
          children: [
            Header(
              headline: Language.of(context).groups,
              margin: EdgeInsets.only(bottom: default_padding / 2),
              trailing: IconButton(
                icon: Icon(
                  add_icon,
                  color: Theme.of(context).iconTheme.color,
                ),
                onPressed: () {
                  showDialog(
                      context: context,
                      useRootNavigator: false,
                      builder: (context) => EditCategoryDialog(
                            category: null,
                          ));
                },
              ),
            ),
            ValueListenableBuilder(
                valueListenable: categoryBox.listenable(),
                builder: (context, Box<Category> box, _) {
                  List<Category> categories =
                      Utils.sortCategoriesByDate(categoryBox.values.toList())
                          .reversed
                          .toList();
                  return Container(
                      height: size.height * account_list_height,
                      child: categories.isEmpty
                          ? Container(
                              child: Center(
                                child: Text(Language.of(context).no_groups),
                              ),
                            )
                          : ListView.builder(
                              itemCount: categories.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return _buildCategoryTile(categories[index]);
                              }));
                })
          ],
        ));
  }

  Widget _buildCategoryTile(Category category) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width * account_tile_width,
      margin: EdgeInsets.only(right: default_padding / 4),
      child: ShadowBox(
        child: Column(
          children: [
            Container(
              alignment: Alignment.topLeft,
              child: Text(
                category.name,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headline3,
              ),
            ),
            Container(
              alignment: Alignment.topLeft,
              margin: EdgeInsets.only(top: default_padding / 8),
              child: Text(
                category.use == null ? " - " : category.use,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.subtitle2,
              ),
            ),
          ],
        ),
        onPressed: () {
          showDialog(
              context: context,
              useRootNavigator: false,
              builder: (context) => EditCategoryDialog(
                    category: category,
                  ));
        },
        onLongPress: () {
          showDialog(
              useRootNavigator: false,
              context: context,
              builder: (context) => PopupDialog(
                  question: Language.of(context).delete_category,
                  onYes: () {
                    DB.deleteCategory(category.key);
                  },
                  onNo: () {}));
        },
      ),
    );
  }
}

class EditAccountDialog extends StatefulWidget {
  final Account account;

  EditAccountDialog({this.account});

  @override
  _EditAccountDialogState createState() => _EditAccountDialogState();
}

class _EditAccountDialogState extends State<EditAccountDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<Category> _categories;

  String _name;
  int _categoryId;
  double _balance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    var usrPrefs = Provider.of<Preferences>(context, listen: false);
    var transBox = Hive.box<Category>(BOX_CATEGORY);

    setState(() {
      _categories = Utils.sortCategoriesByName(transBox.values.toList());
      _categories.insert(0, Category(name: null));
      _categoryId = _categories[0].key;
      _balance = 0.0;
      _amountController.text =
          Utils.formatMoney(_balance, usrPrefs.language, usrPrefs.decimal);
    });

    if (widget.account != null) {
      setState(() {
        _name = widget.account.name;
        _categoryId = widget.account.categoryId;
        _nameController.text = _name;
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var transBox = Hive.box<Category>(BOX_CATEGORY);
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(default_box_radius)),
      contentPadding: dialog_content_padding,
      content: Container(
          child: SingleChildScrollView(
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                  child: Text(
                widget.account == null
                    ? Language.of(context).new_account
                    : Language.of(context).edit_account,
                style: Theme.of(context).textTheme.headline2,
              )),
              IconButton(
                icon: Icon(
                  close_icon,
                  color: Theme.of(context)
                      .bottomNavigationBarTheme
                      .unselectedItemColor,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          ),
          Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                    margin: EdgeInsets.only(left: default_padding),
                    child: _buildLabel(Language.of(context).name)),
                Container(
                    margin: EdgeInsets.only(bottom: default_padding / 2),
                    child: _buildNameField()),
                transBox.values.isNotEmpty
                    ? Container(
                        margin: EdgeInsets.only(left: default_padding),
                        child: _buildLabel(Language.of(context).group))
                    : Container(),
                transBox.values.isNotEmpty
                    ? Container(
                        margin: EdgeInsets.only(bottom: default_padding / 2),
                        child: _buildCategoriesDropdown())
                    : Container(),
                widget.account == null
                    ? Container(
                        margin: EdgeInsets.only(left: default_padding),
                        child: _buildLabel(Language.of(context).balance))
                    : Container(),
                widget.account == null ? _buildAmountField() : Container(),
                Container(
                  margin: EdgeInsets.only(top: default_padding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).accentColor),
                        child: IconButton(
                          icon: Icon(check_icon,
                              color: Theme.of(context).backgroundColor),
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              _formKey.currentState.save();

                              if (widget.account == null) {
                                DB.createAccount(
                                    Account(
                                        name: _name,
                                        balance: _balance,
                                        categoryId: _categoryId),
                                    Language.of(context).initial_deposit);
                              } else {
                                DB.updateAccount(
                                    widget.account.key,
                                    Account(
                                        name: _name,
                                        categoryId: _categoryId,
                                        icon: widget.account.icon));
                              }
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ]),
      )),
    );
  }

  Widget _buildLabel(String text) {
    return Container(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: Theme.of(context).textTheme.subtitle1,
        ));
  }

  Widget _buildNameField() {
    return ShadowBox(
      shadowRadius: 2,
      padding: EdgeInsets.symmetric(
          vertical: default_padding / 4, horizontal: default_padding / 2),
      child: TextFormField(
        controller: _nameController,
        decoration: InputDecoration(
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          border: InputBorder.none,
        ),
        style: Theme.of(context).textTheme.headline4,
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

          var key = -1;

          if (widget.account != null) {
            key = widget.account.key;
          }
          if (!DB.validateAccountName(value, key)) {
            return Language.of(context).acc_name_exists;
          }

          return null;
        },
      ),
    );
  }

  Widget _buildCategoriesDropdown() {
    return ShadowBox(
      shadowRadius: 2,
      padding: EdgeInsets.symmetric(
          vertical: default_padding / 4, horizontal: default_padding / 2),
      child: DropdownButtonFormField(
        value: _categoryId,
        items: _categories.map((Category category) {
          return DropdownMenuItem(
            value: category.key,
            child: Container(
              child: Text(
                category.name == null
                    ? Language.of(context).no_group
                    : category.name,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ),
          );
        }).toList(),
        validator: (value) {
          return null;
        },
        onChanged: (value) {
          this._categoryId = value;
        },
        onSaved: (value) {
          this._categoryId = value;
        },
        decoration: InputDecoration(
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildAmountField() {
    Size size = MediaQuery.of(context).size;
    var usrPrefs = Provider.of<Preferences>(context, listen: false);
    return ShadowBox(
      shadowRadius: 2,
      padding: EdgeInsets.symmetric(
          vertical: default_padding / 8, horizontal: default_padding / 2),
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
              focusNode: _focusNode,
              onTap: () {
                if (!_focusNode.hasFocus) {
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

class EditCategoryDialog extends StatefulWidget {
  final Category category;

  EditCategoryDialog({this.category});

  @override
  _EditCategoryDialogState createState() => _EditCategoryDialogState();
}

class _EditCategoryDialogState extends State<EditCategoryDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _name;
  String _use;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _useController = TextEditingController();

  @override
  void initState() {
    if (widget.category != null) {
      setState(() {
        _name = widget.category.name;
        _use = widget.category.use;
        _nameController.text = _name;
        _useController.text = _use;
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(default_box_radius)),
      contentPadding: dialog_content_padding,
      content: Container(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        child: Text(
                      widget.category == null
                          ? Language.of(context).new_group
                          : Language.of(context).edit_group,
                      style: Theme.of(context).textTheme.headline2,
                    )),
                    IconButton(
                      icon: Icon(
                        close_icon,
                        color: Theme.of(context)
                            .bottomNavigationBarTheme
                            .unselectedItemColor,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ),
                Container(
                    margin: EdgeInsets.only(left: default_padding),
                    child: _buildLabel(Language.of(context).name)),
                _buildNameField(),
                Container(
                    margin: EdgeInsets.only(
                        left: default_padding, top: default_padding / 2),
                    child: _buildLabel(Language.of(context).use)),
                Container(
                    margin: EdgeInsets.only(bottom: default_padding),
                    child: _buildUseField()),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).accentColor),
                      child: IconButton(
                        icon: Icon(check_icon,
                            color: Theme.of(context).backgroundColor),
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            _formKey.currentState.save();

                            if (widget.category == null) {
                              DB.createCategory(Category(
                                name: _name,
                                use: _use,
                              ));
                            } else {
                              DB.updateCategory(widget.category.key,
                                  Category(name: _name, use: _use));
                            }
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Container(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: Theme.of(context).textTheme.subtitle1,
        ));
  }

  Widget _buildNameField() {
    return ShadowBox(
      padding: EdgeInsets.symmetric(
          horizontal: default_padding / 2, vertical: default_padding / 4),
      shadowRadius: 2,
      child: TextFormField(
        controller: _nameController,
        decoration: InputDecoration(
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          border: InputBorder.none,
        ),
        style: Theme.of(context).textTheme.headline4,
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

          var key = -1;

          if (widget.category != null) {
            key = widget.category.key;
          }
          if (!DB.validateCategoryName(value, key)) {
            return Language.of(context).group_name_exists;
          }

          return null;
        },
      ),
    );
  }

  Widget _buildUseField() {
    return ShadowBox(
      padding: EdgeInsets.symmetric(
          horizontal: default_padding / 2, vertical: default_padding / 4),
      shadowRadius: 2,
      child: TextFormField(
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.done,
        maxLines: 3,
        controller: _useController,
        decoration: InputDecoration(
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          border: InputBorder.none,
        ),
        style: Theme.of(context).textTheme.bodyText1,
        onSaved: (value) {
          if (value.isNotEmpty) {
            _use = value;
          }
        },
      ),
    );
  }
}
