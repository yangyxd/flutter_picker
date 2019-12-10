import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'PickerLocalizations.dart';

/// picker localizations
class PickerLocalizationsDelegate
    extends LocalizationsDelegate<PickerLocalizations> {
  const PickerLocalizationsDelegate();

  static const PickerLocalizationsDelegate delegate =
      const PickerLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => PickerLocalizations.languages.contains(locale.languageCode);

  @override
  Future<PickerLocalizations> load(Locale locale) {
    return SynchronousFuture<PickerLocalizations>(new PickerLocalizations(locale));
  }

  @override
  bool shouldReload(PickerLocalizationsDelegate old) => false;
}