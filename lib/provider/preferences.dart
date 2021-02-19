import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_finance/constants/db_constants.dart';
import 'package:simple_finance/constants/model_constants.dart';
import 'package:intl/intl.dart';

class Preferences extends ChangeNotifier {
  SharedPreferences _sharedPreferences;
  Locale initialLocale;

  Preferences(Locale userLocale) {
    if (languages[userLocale.languageCode] == null) {
      userLocale = Locale(defaultLanguage, userLocale.countryCode);
    }

    if (currencies[NumberFormat.simpleCurrency(locale: userLocale.toString())
            .currencyName] ==
        null) {
      userLocale = Locale(locale.languageCode, defaultCountry);
    }
    initialLocale = userLocale;

    SharedPreferences.getInstance().then((instance) {
      _sharedPreferences = instance;

      language = userLocale.languageCode;

      if (_sharedPreferences.getString(sp_country) == null) {
        country = userLocale.countryCode;
      }

      if (_sharedPreferences.getString(sp_currency) == null) {
        currency = NumberFormat.simpleCurrency(locale: userLocale.toString())
            .currencyName;
      }

      if (_sharedPreferences.getInt(sp_decimal) == null) {
        decimal = defaultDecimal;
      }
    });
  }

  SharedPreferences get sharedPreferences => _sharedPreferences;

  String get language => _sharedPreferences == null
      ? initialLocale.languageCode
      : _sharedPreferences.getString(sp_language);

  String get country => _sharedPreferences == null
      ? initialLocale.countryCode
      : _sharedPreferences.getString(sp_country);

  Locale get locale => Locale(this.language, this.country);

  String get currency => _sharedPreferences == null
      ? NumberFormat.simpleCurrency(locale: locale.toString()).currencyName
      : _sharedPreferences.getString(sp_currency);

  String get currencySymbol => currencies[currency];

  int get decimal => _sharedPreferences == null
      ? defaultDecimal
      : _sharedPreferences.getInt(sp_decimal);

  set language(String language) {
    if (_sharedPreferences != null) {
      _sharedPreferences.setString(sp_language, language).then((success) {
        if (success) {
          notifyListeners();
        }
      });
    }
  }

  set country(String country) {
    if (_sharedPreferences != null) {
      _sharedPreferences.setString(sp_country, country).then((success) {
        if (success) {
          notifyListeners();
        }
      });
    }
  }

  set currency(String currency) {
    if (_sharedPreferences != null) {
      _sharedPreferences.setString(sp_currency, currency).then((success) {
        if (success) {
        }
      });
    }
  }

  set decimal(int decimal) {
    if (decimal >= min_decimal && decimal <= max_decimal) {
      if (_sharedPreferences != null) {
        _sharedPreferences.setInt(sp_decimal, decimal);
      }
    }
  }

  set didLaunchBefore(bool didLaunchBefore) {
    if (_sharedPreferences != null) {
      _sharedPreferences.setBool(sp_launch_before, didLaunchBefore);
      notifyListeners();
    }
  }
}
