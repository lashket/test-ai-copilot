class Env {
  static const apiKey = String.fromEnvironment('CONVAI_API_KEY');
  static const baseUrl = String.fromEnvironment(
    'CONVAI_BASE_URL',
    defaultValue: 'https://convai-agents-staging.on.com',
  );
}
