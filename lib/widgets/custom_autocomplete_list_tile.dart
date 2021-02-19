import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:simple_finance/constants/db_constants.dart';
import 'package:simple_finance/constants/ui_constants.dart';
import 'package:simple_finance/model/account.dart';
import 'package:simple_finance/model/transaction.dart';
import 'package:simple_finance/provider/preferences.dart';
import 'package:simple_finance/utils.dart';
import 'package:intl/intl.dart';

class AutocompleteListTile extends StatelessWidget {
  final Transaction transaction;

  AutocompleteListTile({this.transaction});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var usrPrefs = Provider.of<Preferences>(context, listen: false);
    return Container(
        height: size.height * autocomplete_item_height,
        margin: EdgeInsets.only(
            left: default_padding / 1.5,
            right: default_padding / 1.5,
            top: default_padding / 2),
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  transaction.purpose,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                Text(
                  Hive.box<Account>(BOX_ACCOUNT)
                      .get(transaction.accountId)
                      .name,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.subtitle2,
                ),
                Text(
                  DateFormat('dd MMM yy', usrPrefs.language)
                      .format(transaction.timestamp),
                  style: Theme.of(context).textTheme.subtitle2,
                ),
              ]),
              Text(
                Utils.formatMoney(
                    transaction.amount, usrPrefs.language, usrPrefs.decimal,
                    compactTreshold: transaction_card_money_treshold,
                    currency: usrPrefs.currency),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: money.fontSize,
                    fontWeight: money.fontWeight,
                    color: transaction.amount < 0
                        ? negative_color
                        : positive_color),
              )
            ]),
          ],
        ));
  }
}
