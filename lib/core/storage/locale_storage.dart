import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLocaleKey = 'app_locale';

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier(this._prefs) : super(_resolve(_prefs));

  final SharedPreferences _prefs;

  static Locale _resolve(SharedPreferences prefs) {
    final saved = prefs.getString(_kLocaleKey);
    if (saved == 'ar') return const Locale('ar');
    return const Locale('fr');
  }

  Future<void> setLocale(Locale locale) async {
    await _prefs.setString(_kLocaleKey, locale.languageCode);
    state = locale;
  }
}

final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Must override in main()');
});

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>(
  (ref) => LocaleNotifier(ref.watch(sharedPrefsProvider)),
);
