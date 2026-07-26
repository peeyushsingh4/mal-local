/// Application Configuration for MAL Local
class AppConfig {
  static const String appName = 'MAL Local';
  static const String defaultNeighborhoodId = 'bandra-west';
  static const String defaultNeighborhoodName = 'Bandra West';
  static const String defaultCity = 'Mumbai';

  /// Coarse sub-localities allowed for listings (Never exact addresses)
  static const List<String> allowedSubLocalities = [
    'Pali Hill',
    'Carter Road',
    'Hill Road',
    'Linking Road',
    'Chapel Road',
    'Bandstand',
    'Mount Mary',
    'Turners Road',
    'Perry Road',
    'Bandra Station Area'
  ];
}
