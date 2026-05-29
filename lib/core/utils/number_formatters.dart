/// Formatage local Mauritanie : séparateur de milliers = espace fine.
///
/// Exemples :
/// - `formatPrice(1250000)` → "1 250 000"
/// - `formatKm(85000)` → "85 000"
class NumberFormatters {
  NumberFormatters._();

  static String _thousands(num value) {
    final s = value.toInt().toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  static String formatPrice(num value) => _thousands(value);
  static String formatKm(num value) => _thousands(value);
}
