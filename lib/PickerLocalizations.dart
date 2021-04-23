import 'package:flutter/material.dart';

abstract class PickerLocalizationsBase {
  final Locale? locale;
  const PickerLocalizationsBase(this.locale);
  Object? getItem(String key);
  String? get cancelText => getItem('cancelText') as String;
  String? get confirmText => getItem('confirmText') as String;
  List? get ampm => getItem('ampm') as List;
  List? get months => getItem('months') as List;
  List? get monthsLong => getItem('monthsLong') as List;
}

/// localizations
class PickerLocalizations extends PickerLocalizationsBase {
  static PickerLocalizations _static = PickerLocalizations(null);
  const PickerLocalizations(Locale? locale) : super(locale);

  @override
  Object? getItem(String key) {
    Map? localData;
    if (locale != null) {
      localData = localizedValues[locale!.languageCode];
    }
    if (localData == null) return localizedValues['en']![key];
    return localData[key];
  }

  static PickerLocalizations of(BuildContext context) {
    return Localizations.of<PickerLocalizations>(context, PickerLocalizations) ?? _static;
  }

  /// Language Support
  static const List<String> languages = ['en', 'ja', 'zh', 'ko', 'it', 'ar', 'fr', 'es', 'tr'];

  /// Language Values
  static const Map<String, Map<String, Object>> localizedValues = {
    'en': {
      'cancelText': 'Cancel',
      'confirmText': 'Confirm',
      'ampm': ['AM', 'PM'],
    },
    'ja': {
      'cancelText': 'キャンセル',
      'confirmText': '完了',
      'ampm': ['午前', '午後'],
    },
    'zh': {
      'cancelText': '取消',
      'confirmText': '确定',
      'ampm': ['上午', '下午'],
    },
    'ko': {
      'cancelText': '취소',
      'confirmText': '확인',
      'ampm': ['오전', '오후'],
    },
    'it': {
      'cancelText': 'Annulla',
      'confirmText': 'Conferma',
      'ampm': ['AM', 'PM'],
    },
    'ar': {
      'cancelText': 'إلغاء الأمر',
      'confirmText': 'تأكيد',
      'ampm': ['صباحاً', 'مساءً'],
    },
    'fr': {
      'cancelText': 'Annuler',
      'confirmText': 'Confirmer',
      'ampm': ['Matin', 'Après-midi'],
    },
    'es': {
      'cancelText': 'Cancelar',
      'confirmText': 'Confirmar',
      'ampm': ['AM', 'PM'],
    },
    'tr': {
      'cancelText': 'İptal',
      'confirmText': 'Onay',
      'ampm': ['ÖÖ', 'ÖS'],
      'months': [
        'Oca',
        'Şub',
        'Mar',
        'Nis',
        'May',
        'Haz',
        'Tem',
        'Ağu',
        'Eyl',
        'Eki',
        'Kas',
        'Ara'
      ],
      'monthsLong': [
        'Ocak',
        'Şubat',
        'Mart',
        'Nisan',
        'Mayıs',
        'Haziran',
        'Temmuz',
        'Ağustos',
        'Eylül',
        'Ekim',
        'Kasım',
        'Aralık'
      ]
    },
  };
}
