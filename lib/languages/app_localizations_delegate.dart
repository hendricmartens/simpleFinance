import 'package:flutter/material.dart';
import 'package:simple_finance/languages/language.dart';
import 'package:simple_finance/languages/language_de.dart';
import 'package:simple_finance/languages/language_en.dart';
import 'package:simple_finance/languages/language_es.dart';

class AppLocalizationsDelegate extends LocalizationsDelegate<Language> {

  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'de', 'es'].contains(locale.languageCode);

  @override
  Future<Language> load(Locale locale) => _load(locale);

  static Future<Language> _load(Locale locale) async {
    switch (locale.languageCode) {
      case 'en':
        return LanguageEn();
      case 'de':
        return LanguageDe();
      case 'es':
        return LanguageEs();
      default:
        return LanguageEn();
    }
  }

  @override
  bool shouldReload(LocalizationsDelegate<Language> old) => false;

}