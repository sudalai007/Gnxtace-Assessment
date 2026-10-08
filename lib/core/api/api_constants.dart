class ApiConstants {
  static const String baseUrl = 'https://pixabay.com/api/';

  // Default Pixabay API key (public key for demo/assessment)
  // Pixabay provides free API keys for developers.
  static String apiKey = '57936436-a92f5040f61054c998ca93462';

  static const int defaultPerPage = 20;

  static const List<String> categories = [
    'all',
    'nature',
    'science',
    'education',
    'feelings',
    'health',
    'places',
    'industry',
    'computer',
    'food',
    'sports',
    'transportation',
    'travel',
    'buildings',
    'business',
    'music',
  ];
}
