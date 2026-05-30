import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/storage/locale_storage.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'routing/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
      ],
      child: const BoursaApp(),
    ),
  );
}

class BoursaApp extends ConsumerWidget {
  const BoursaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = appRouter;
    final locale = ref.watch(localeProvider);
    final isAr = locale.languageCode == 'ar';

    return MaterialApp.router(
      title: 'Boursa',
      debugShowCheckedModeBanner: false,
      theme: isAr ? AppTheme.arabic() : AppTheme.light(),
      darkTheme: isAr ? AppTheme.arabic() : AppTheme.light(),
      themeMode: ThemeMode.light,
      locale: locale,
      supportedLocales: const [Locale('fr'), Locale('ar')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
