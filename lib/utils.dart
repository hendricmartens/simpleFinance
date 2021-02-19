import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:simple_finance/constants/model_constants.dart';
import 'package:simple_finance/constants/ui_constants.dart';
import 'package:simple_finance/model/account.dart';
import 'package:simple_finance/model/category.dart';
import 'package:simple_finance/model/transaction.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class Utils {
  static List<Account> sortAccountsByDate(List<Account> accounts) {
    accounts.sort((a, b) => a.timestamp.isAfter(b.timestamp) ? -1 : 1);
    return accounts;
  }

  static List<Category> sortCategoriesByDate(List<Category> categories) {
    categories.sort((a, b) => a.timestamp.isAfter(b.timestamp) ? -1 : 1);
    return categories;
  }

  static List<Transaction> sortTransactionsByDate(
      List<Transaction> transactions) {
    transactions.sort((a, b) => a.timestamp.isAfter(b.timestamp) ? -1 : 1);
    return transactions;
  }

  static List<Account> sortAccountsByName(List<Account> accounts) {
    accounts.sort((a, b) => a.name.compareTo(b.name));
    return accounts;
  }

  static List<Category> sortCategoriesByName(List<Category> categories) {
    categories.sort((a, b) => a.name.compareTo(b.name));
    return categories;
  }

  static List<Transaction> filterTransactionsByAccount(
      List<Transaction> transactions, int accountId) {
    return transactions.fold<List<Transaction>>(List<Transaction>(),
        (list, Transaction transaction) {
      if (transaction.accountId == accountId) list.add(transaction);
      return list;
    });
  }

  static List<Account> filterAccountsByCategory(
      List<Account> accounts, int categoryId) {
    return accounts.fold<List<Account>>(List<Account>(),
        (list, Account account) {
      if (account.categoryId == categoryId) list.add(account);
      return list;
    });
  }

  static List<Transaction> filterTransactionsBetweenDates(
      List<Transaction> transactions, DateTime from, DateTime to) {
    return transactions.fold<List<Transaction>>(List<Transaction>(),
        (list, Transaction transaction) {
      bool isValid = true;
      if (from != null) {
        if (transaction.timestamp.isBefore(from)) {
          isValid = false;
        }
      }
      if (to != null) {
        if (transaction.timestamp.isAfter(to)) {
          isValid = false;
        }
      }
      if (isValid) list.add(transaction);

      return list;
    });
  }

  static List<Tuple<DateTime, double>> foldTransactionsToDay(
      List<Transaction> transactions, bool carrySum) {
    List<Tuple<DateTime, double>> list = List<Tuple<DateTime, double>>();
    transactions = sortTransactionsByDate(transactions).reversed.toList();

    if (transactions.isNotEmpty) {
      double sum = 0;

      DateTime start = transactions.first.timestamp;
      start = DateTime(start.year, start.month, start.day);
      int days = start.difference(DateTime.now()).inDays.abs();

      for (int i = 0; i <= days; i++) {
        DateTime day = start.add(Duration(days: i));
        var temp = transactions.where((element) =>
            element.timestamp.year == day.year &&
            element.timestamp.month == day.month &&
            element.timestamp.day == day.day);

        double dailySum = temp.fold(0, (previousValue, element) {
          return previousValue += element.amount;
        });

        sum += dailySum;

        list.add(Tuple(key: day, value: sum));
      }

    }
    return list;
  }

  static String getDecimalFigure(String language) {
    switch (language) {
      case "en":
        return ".";
      case "de":
        return ",";
      case "es":
        return ",";
      default:
        return ".";
    }
  }

  static String getThousandFigure(String language) {
    switch (language) {
      case "en":
        return ",";
      case "de":
        return ".";
      case "es":
        return ".";
      default:
        return ",";
    }
  }

  static int round(double value) {
    if (value.abs() >= 10000) {
      return 1000 * (value / 1000.0).round();
    } else if (value.abs() >= 100) {
      return 100 * (value / 100.0).round();
    } else {
      return 10 * (value / 10.0).round();
    }
  }

  static int scd(int first, int second) {
    for (int i = 3; i < min(first.abs(), second.abs()); i++) {
      if (first % i == 0 && second % i == 0) {
        return i;
      }
    }
  }

  static String formatMoney(double money, String language, int decimal,
      {int compactTreshold = -1, String currency}) {
    NumberFormat numberFormat;

    switch (decimal) {
      case 0:
        numberFormat = NumberFormat(number_format, language);
        break;
      case 1:
        numberFormat = NumberFormat(number_format + ".0", language);
        break;

      case 2:
        numberFormat = NumberFormat(number_format + ".00", language);
        break;
      default:
        numberFormat = NumberFormat("#,##0.00", language);
        break;
    }

    String formatted = numberFormat.format(money);

    if (compactTreshold != -1 && money.round().abs() >= compactTreshold) {
      formatted = NumberFormat.compact(locale: "en")
          .format(money)
          .replaceAll(".", getDecimalFigure(language));
    }

    return addCurrency(formatted, currency);
  }

  static String addCurrency(String money, String currency) {
    switch (currency) {
      case "USD":
        return currencies[currency] + " " + money;
      case "GBP":
        return currencies[currency] + " " + money;
      case "EUR":
        return money + " " + currencies[currency];
      default:
        if (currency != null && currencies[currency] != null) {
          return money + " " + currencies[currency];
        } else {
          return money;
        }
    }
  }

  static double parseMoney(String money, String language) {
    return NumberFormat("#,##0.00", language).parse(money);
  }

  static Future<double> getCurrencyRate(
      String fromCurrency, String toCurrency) async {
    String uri =
        "https://api.exchangeratesapi.io/latest?base=$fromCurrency&symbols=$toCurrency";
    var response = await http.get(Uri.encodeFull(uri));

    var responseBody = json.decode(response.body);

    return responseBody['rates'][toCurrency];
  }

  static Future<bool> isConnected() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
    return false;
  }

  static List<Transaction> getSuggestions(
      List<Transaction> transactions, String pattern) {
    List<Transaction> result = List<Transaction>();

    if (pattern.length >= suggestions) {
      transactions = sortTransactionsByDate(transactions);
      for (Transaction trans in transactions) {
        if (trans.purpose != null &&
            trans.purpose.isNotEmpty &&
            trans.purpose
                .toLowerCase()
                .trim()
                .startsWith(pattern.toLowerCase().trim())) {
          if (result.where((t) {
            return t.purpose == trans.purpose && t.accountId == trans.accountId;
          }).isEmpty) {
            result.add(trans);
          }
        }
      }
    }

    return result;
  }
}

class Tuple<K, V> {
  K key;
  V value;

  Tuple({
    this.key,
    this.value,
  });
}
