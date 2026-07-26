/// Application Configuration for LocalHive
class AppConfig {
  static const String appName = 'LocalHive';

  /// Default starting neighborhood
  static const String defaultNeighborhoodName = 'Bandra West';
  static const String defaultCity = 'Mumbai';

  /// Popular predefined Mumbai & Indian localities for quick selection
  static const List<String> popularLocalities = [
    'Bandra West',
    'Juhu',
    'Andheri West',
    'Powai',
    'Colaba',
    'Dadar',
    'Hiranandani',
    'Santacruz West',
    'Khar West',
    'Lower Parel',
    'Worli',
    'Koramangala (Bengaluru)',
    'Indiranagar (Bengaluru)',
    'Connaught Place (Delhi)',
  ];

  /// Coarse sub-localities allowed for listings (Never exact street addresses)
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
    'Main Market Area'
  ];
}
