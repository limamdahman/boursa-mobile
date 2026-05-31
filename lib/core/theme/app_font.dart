import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Police adaptée à la locale : Cairo en arabe, Source Sans 3 sinon.
/// Remplace les appels directs à GoogleFonts.sourceSans3(...) dans les widgets
/// pour que la typographie suive la langue active (comme le swap CSS du web).
TextStyle appFont(
  BuildContext context, {
  double? fontSize,
  FontWeight? fontWeight,
  Color? color,
  double? height,
  double? letterSpacing,
  TextDecoration? decoration,
  FontStyle? fontStyle,
}) {
  final isAr = Localizations.localeOf(context).languageCode == 'ar';
  final fn = isAr ? GoogleFonts.cairo : GoogleFonts.sourceSans3;
  return fn(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
    decoration: decoration,
    fontStyle: fontStyle,
  );
}
