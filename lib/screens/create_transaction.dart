import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:simple_finance/constants/db_constants.dart';
import 'package:simple_finance/constants/route_constants.dart';
import 'package:simple_finance/constants/ui_constants.dart';
import 'package:simple_finance/db.dart';
import 'package:simple_finance/languages/language.dart';
import 'package:simple_finance/model/account.dart';
import 'package:simple_finance/model/transaction.dart';
import 'package:simple_finance/provider/preferences.dart';
import 'package:simple_finance/utils.dart';
import 'package:intl/intl.dart';
import 'package:simple_finance/widgets/custom_autocomplete_list_tile.dart';
import 'package:simple_finance/widgets/shadow_box.dart';

class TransactionScreen extends StatefulWidget {
  final Transaction editTransaction;
  final GlobalKey<NavigatorState> navigatorKey;

  TransactionScreen(this.navigatorKey, {this.editTransaction});

  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              widget.editTransaction != null ? close_icon : back_icon,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: () {
              widget.navigatorKey.currentState.pushNamed(route_home);
            },
          ),
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: Theme.of(context).backgroundColor,
          actions: [
            Hive.box<Account>(BOX_ACCOUNT).isNotEmpty
                ? Container(
                    margin: EdgeInsets.only(right: default_padding / 4),
                    child: IconButton(
                      icon: Icon(
                        check_icon,
                        color: Theme.of(context).iconTheme.color,
                        size: Theme.of(context).iconTheme.size,
                      ),
                      onPressed: () {
                        _saveForm();
                      },
                    ),
                  )
                : Container()
          ],
        ),
        body: SafeArea(
          child: Container(
              margin: EdgeInsets.only(
                left: default_padding * 2,
                right: default_padding * 2,
              ),
              child: Hive.box<Account>(BOX_ACCOUNT).isEmpty
                  ? Center(
                      child: Text(
                        Language.of(context).new_transaction_no_account,
                        textAlign: TextAlign.center,
                      ),
                    )
                  : buildTransactionForm(context)),
        ),
      ),
    );
  }

  double _amount;
  int _accountId;
  String _purpose;
  DateTime _timestamp;

  List<Account> _accounts;
  List<Transaction> _transactions;

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();
  final FocusNode _purposeFocusNode = FocusNode();

  @override
  void initState() {
    if (Hive.box<Account>(BOX_ACCOUNT).isNotEmpty) {
      var usrPrefs = Provider.of<Preferences>(context, listen: false);
      setState(() {
        _amount = 0.0;
        _accounts = Utils.sortAccountsByName(
            Hive.box<Account>(BOX_ACCOUNT).values.toList());
        _transactions = Hive.box<Transaction>(BOX_TRANSACTION).values.toList();
        if (_transactions.isNotEmpty) {
          _accountId = _transactions.last.accountId;
        } else {
          _accountId = _accounts.first.key;
        }
        _timestamp = DateTime.now();
        _amountFocusNode.addListener(() {
          if (!_amountFocusNode.hasFocus) {
            _amountController.text =
                Utils.formatMoney(_amount, usrPrefs.language, usrPrefs.decimal);
            if (_amount == 0.0) {
              _amountController.text =
                  _amountController.text.replaceAll("-", "");
            }
          }
        });
      });
      if (widget.editTransaction != null) {
        setState(() {
          _amount = widget.editTransaction.amount;
          if (widget.editTransaction.accountId != null) {
            _accountId = widget.editTransaction.accountId;
          }
          _purpose = widget.editTransaction.purpose
              .replaceAll("\n", "")
              .replaceAll("-", "");
          _timestamp = widget.editTransaction.timestamp;

          _purposeController.text = _purpose;
        });
      }
      _amountController.text =
          Utils.formatMoney(_amount, usrPrefs.language, usrPrefs.decimal);
      super.initState();
    }
  }

  void _saveForm() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      Transaction transaction = Transaction(
          amount: _amount,
          accountId: _accountId,
          purpose: _purpose,
          timestamp: _timestamp);

      if (widget.editTransaction == null) {
        DB.transfer(transaction);
      } else {
        DB.updateTransaction(widget.editTransaction.key, transaction);
      }
      widget.navigatorKey.currentState.pushNamed(route_home);
    }
  }

  Widget buildTransactionForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: (_purposeFocusNode.hasFocus || _amountFocusNode.hasFocus)
                  ? 0
                  : default_padding * 3,
            ),
            Container(
              child: _buildAmountField(),
              margin: EdgeInsets.only(bottom: default_padding / 2),
            ),
            Container(
                child: _buildPurposeField(),
                margin: EdgeInsets.only(bottom: default_padding / 2)),
            Container(
                child: _buildAccountField(),
                margin: EdgeInsets.only(bottom: default_padding / 2)),
            _buildDateField(),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountField() {
    var usrPrefs = Provider.of<Preferences>(context, listen: false);
    Size size = MediaQuery.of(context).size;
    return Row(
      children: [
        Container(
          width: size.width * amount_field_size,
          margin: EdgeInsets.only(left: 5),
          child: TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.numberWithOptions(signed: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r"^\-?\d*\.?\,?\d{0,2}"))
            ],
            focusNode: _amountFocusNode,
            onTap: () {
              if (!_amountFocusNode.hasFocus) {
                _amountController.text = _amountController.text
                    .replaceAll(Utils.getThousandFigure(usrPrefs.language), "");
                if (_amountController.text.startsWith("0")) {
                  _amountController.text =
                      _amountController.text.replaceFirst("0", "");
                }
                if (_amountController.text
                    .contains(Utils.getDecimalFigure(usrPrefs.language))) {
                  _amountController.selection = TextSelection.collapsed(
                      offset: _amountController.text
                          .indexOf(Utils.getDecimalFigure(usrPrefs.language)));
                }
              }
              setState(() {});
            },
            onEditingComplete: () {
              _amountController.text = Utils.formatMoney(
                  _amount, usrPrefs.language, usrPrefs.decimal);
              if (_amount == 0.0) {
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
                _amount = amount;
              });
            },
            validator: (value) {
              if (value.isEmpty) {
                return Language.of(context).amount_empty_msg;
              } else {
                if (_amount == 0) {
                  return Language.of(context).amount_zero_msg;
                }
              }
              return null;
            },
            style: TextStyle(
              fontWeight: amountField.fontWeight,
              fontSize: amountField.fontSize,
              color: _amount < 0
                  ? negative_color
                  : (_amount > 0 ? positive_color : zeroColor),
            ),
            decoration: InputDecoration(
              prefix: Container(
                margin: EdgeInsets.only(right: default_padding / 4),
                child: Text(
                  usrPrefs.currencySymbol,
                  style: TextStyle(
                      fontSize: amountField.fontSize,
                      fontWeight: FontWeight.normal,
                      color: Theme.of(context).primaryColor),
                ),
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPurposeField() {
    var usrPrefs = Provider.of<Preferences>(context, listen: false);
    Size size = MediaQuery.of(context).size;
    return ShadowBox(
      shadowRadius: 3,
      padding: EdgeInsets.symmetric(
          horizontal: default_padding, vertical: default_padding / 2),
      child: TypeAheadFormField(
        textFieldConfiguration: TextFieldConfiguration(
            focusNode: _purposeFocusNode,
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.multiline,
            controller: _purposeController,
            style: Theme.of(context).textTheme.headline4,
            decoration: InputDecoration(
              hintText: Language.of(context).purpose,
              hintStyle: TextStyle(
                  fontSize: Theme.of(context).textTheme.headline4.fontSize),
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              border: InputBorder.none,
            ),
            onEditingComplete: () {
              setState(() {});
              FocusScope.of(context).unfocus();
            },
            onTap: () {
              setState(() {});
            }),
        hideOnEmpty: true,
        hideOnLoading: true,
        getImmediateSuggestions: false,
        suggestionsCallback: (pattern) {
          return Utils.getSuggestions(_transactions, pattern);
        },
        itemBuilder: (context, Transaction suggestion) {
          return AutocompleteListTile(transaction: suggestion);
        },
        suggestionsBoxVerticalOffset: 0,
        suggestionsBoxDecoration: SuggestionsBoxDecoration(
            borderRadius: BorderRadius.all(default_box_radius),
            constraints: BoxConstraints(
              maxHeight: size.height * autocomplete_item_height * 2 +
                  default_padding * 1.5,
            )),
        transitionBuilder: (context, suggestionsBox, controller) {
          return suggestionsBox;
        },
        onSuggestionSelected: (Transaction suggestion) {
          _purposeController.text = suggestion.purpose;
          _amountController.text = Utils.formatMoney(
              suggestion.amount, usrPrefs.language, usrPrefs.decimal);

          setState(() {
            _amount = suggestion.amount;
            _accountId = suggestion.accountId;
          });
        },
        onSaved: (value) => this._purpose = value,
      ),
    );
  }

  Widget _buildAccountField() {
    return ShadowBox(
      shadowRadius: 3,
      padding: EdgeInsets.only(
          left: default_padding,
          right: default_padding,
          bottom: default_padding / 3,
          top: 0),
      child: DropdownButtonFormField(
        value: _accountId,
        isExpanded: true,
        isDense: true,
        items: _accounts.map((Account account) {
          return DropdownMenuItem(
            value: account.key,
            child: Container(
                child: Text(
              account.name,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.headline4,
            )),
          );
        }).toList(),
        onChanged: (value) {
          _accountId = value;
        },
        decoration: InputDecoration(
          labelText: Language.of(context).account,
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return Container(
        alignment: Alignment.center,
        child: ShadowBox(
          child: Text(_timestamp.isAfter(DateTime(DateTime.now().year,
                  DateTime.now().month, DateTime.now().day))
              ? Language.of(context).today
              : (_timestamp.isAfter(DateTime(DateTime.now().year,
                          DateTime.now().month, DateTime.now().day)
                      .subtract(Duration(days: 1)))
                  ? Language.of(context).yesterday
                  : DateFormat('dd MMM yy').format(_timestamp))),
          onPressed: () {
            _selectDate();
          },
        ));
  }

  Future<void> _selectDate() async {
    var usrPrefs = Provider.of<Preferences>(context, listen: false);
    final DateTime picked = await showDatePicker(
        locale: usrPrefs.locale,
        context: context,
        initialDate: _timestamp,
        firstDate: new DateTime(1970, 8),
        lastDate: DateTime.now());
    if (picked != null)
      setState(() {
        _timestamp = picked;
      });
  }
}
