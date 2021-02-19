import 'package:flutter/material.dart';

abstract class Language {
  static Language of(BuildContext context) {
    return Localizations.of<Language>(context, Language);
  }

  String get transactions;

  String get balance;

  String get all_accounts;

  String get total;

  String get account;

  String get purpose;

  String get today;

  String get yesterday;

  String get settings;

  String get accounts;

  String get groups;

  String get general;

  String get delete_all;

  String get new_account;

  String get group;

  String get no_group;

  String get name;

  String get new_group;

  String get use;

  String get currency;

  String get language;

  String get security;

  String get no_groups;

  String get no_accounts;

  String get no_transactions;

  String get new_transaction_no_account;

  String get amount_empty_msg;

  String get amount_zero_msg;

  String get yes;

  String get no;

  String get are_you_sure;

  String get delete_account;

  String get delete_category;

  String get edit_account;

  String get name_empty;

  String get acc_name_exists;

  String get edit_group;

  String get group_name_exists;

  String get graph;

  String get line_graph;

  String get more_coming_soon;

  String get coming_soon;

  String get theme;

  String get feedback;

  String get delete_transaction;

  String get convert_currencies1;

  String get convert_currencies2;

  String get currency_converted;

  String get conversion_failed;

  String get decimal_option;

  String get initial_deposit;

  String get welcome;

  String get start_now;

  String get create_your_first_acc;

  String get synchronization;

  String get column_graph;
}
