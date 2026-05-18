class AppConfig {
  const AppConfig._();

  static const String appName = 'Boursa';

  /// Pour Android émulateur, 127.0.0.1 du conteneur === 10.0.2.2.
  /// Pour iOS simulator, 127.0.0.1 fonctionne.
  /// Pour device physique : remplacer par l'IP locale du PC dev (ex: 192.168.1.x).
  static const String apiBaseUrl = String.fromEnvironment(
    'BOURSA_API_URL',
    defaultValue: 'http://localhost:8000/api/v1',
  );

  static const Duration apiTimeout = Duration(seconds: 15);
}
