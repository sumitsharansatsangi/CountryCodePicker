import 'package:collection/collection.dart' show IterableExtension;
import 'package:diacritic/diacritic.dart';
import 'package:flutter/cupertino.dart';

import 'country_codes.dart';
import 'country_localizations.dart';

mixin ToAlias {}

/// Country element. This is the element that contains all the information
class CountryCode {
  /// the name of the country
  String? name;

  /// the flag of the country
  final String? flagUri;

  /// the country code (IT,AF..)
  final String? code;

  /// the dial code (+39,+93..)
  final String? dialCode;

  CountryCode({this.name, this.flagUri, this.code, this.dialCode});

  @Deprecated('Use `fromCountryCode` instead.')
  factory CountryCode.fromCode(String isoCode) {
    return CountryCode.fromCountryCode(isoCode);
  }

  factory CountryCode.fromCountryCode(String countryCode) {
    final Map<String, String>? jsonCode = codes.firstWhereOrNull(
      (code) => code['code'] == countryCode,
    );
    return CountryCode.fromJson(jsonCode!);
  }

  static CountryCode? tryFromCountryCode(String countryCode) {
    try {
      return CountryCode.fromCountryCode(countryCode);
    } catch (e) {
      debugPrint('Failed to recognize country from countryCode: $countryCode');
      return null;
    }
  }

  factory CountryCode.fromDialCode(String dialCode) {
    final Map<String, String>? jsonCode = codes.firstWhereOrNull(
      (code) => code['dial_code'] == dialCode,
    );
    return CountryCode.fromJson(jsonCode!);
  }

  static CountryCode? tryFromDialCode(String dialCode) {
    try {
      return CountryCode.fromDialCode(dialCode);
    } catch (e) {
      debugPrint('Failed to recognize country from dialCode: $dialCode');
      return null;
    }
  }

  static String generateFlagEmojiUnicode(String countryCode) {
    final base = 127397;

    return countryCode.codeUnits
        .map((e) => String.fromCharCode(base + e))
        .toList()
        .reduce((value, element) => value + element)
        .toString();
  }

  CountryCode localize(BuildContext context) {
    final nam = CountryLocalizations.of(context)?.translate(code) ?? name;
    return this..name = nam == null ? name : removeDiacritics(nam);
  }

  factory CountryCode.fromJson(Map<String, dynamic> json) {
    final base = 127397;
    return CountryCode(
      name: removeDiacritics(json['name']),
      code: json['code'],
      dialCode: json['dial_code'],
      flagUri: json['code']
          .toLowerCase()
          .codeUnits
          .map((e) => String.fromCharCode((base + e).toInt()))
          .toList()
          .reduce((value, element) => value + element)
          .toString(),
      // 'flags/${json['code'].toLowerCase()}.png'
    );
  }

  @override
  String toString() => "$dialCode";

  String toLongString() => "$dialCode ${toCountryStringOnly()}";

  String toCountryStringOnly() {
    return '$_cleanName';
  }

  String? get _cleanName {
    return name?.replaceAll(RegExp(r'[[\]]'), '').split(',').first;
  }
}
