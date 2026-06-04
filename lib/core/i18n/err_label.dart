import 'package:flutter/widgets.dart';

String errLabel(BuildContext context, Object e) {
  final isAr = Localizations.localeOf(context).languageCode == 'ar';
  return isAr ? 'خطأ: $e' : 'Erreur: $e';
}
