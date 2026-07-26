import '../../config/app_config.dart';

enum ListingType { offer, request }
enum ListingStatus { active, saved, contacted, closed }
enum ContactPreference { whatsapp, call, inAppNote }

class ValidationResult {
  final bool isValid;
  final Map<String, String> errors;

  ValidationResult({required this.isValid, required this.errors});
}

class Listing {
  final String id;
  final String title;
  final String categoryId;
  final ListingType type; // offer or request
  final String description;
  final String area; // coarse sub-locality (e.g., "Pali Hill")
  final ContactPreference contactPreference;
  final ListingStatus status;
  final String neighborhoodId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool aiGenerated;
  final int expiryDays; // Original Feature: Closing soon self-expiry tracking
  final String? imageUrl; // Visual image for the help / listing provided

  Listing({
    required this.id,
    required this.title,
    required this.categoryId,
    this.type = ListingType.offer,
    required this.description,
    required this.area,
    this.contactPreference = ContactPreference.whatsapp,
    this.status = ListingStatus.active,
    this.neighborhoodId = AppConfig.defaultNeighborhoodName,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.aiGenerated = false,
    this.expiryDays = 7,
    this.imageUrl,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Strip basic HTML tags from user input for safety
  static String sanitize(String input) {
    return input.replaceAll(RegExp(r'<[^>]*>?'), '').trim();
  }

  /// Check if closing soon (expires within 48 hours)
  bool get isClosingSoon {
    if (status == ListingStatus.closed) return false;
    final expiryDate = createdAt.add(Duration(days: expiryDays));
    final hoursRemaining = expiryDate.difference(DateTime.now()).inHours;
    return hoursRemaining <= 48 && hoursRemaining > 0;
  }

  /// Calculate days remaining before self-closing
  int get daysRemaining {
    final expiryDate = createdAt.add(Duration(days: expiryDays));
    final diff = expiryDate.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  /// Validate inputs before saving
  ValidationResult validate() {
    final errors = <String, String>{};

    final cleanTitle = sanitize(title);
    if (cleanTitle.isEmpty) {
      errors['title'] = 'Title is required';
    } else if (cleanTitle.length < 3) {
      errors['title'] = 'Title must be at least 3 characters';
    } else if (cleanTitle.length > 100) {
      errors['title'] = 'Title must be 100 characters or fewer';
    }

    if (categoryId.isEmpty) {
      errors['category'] = 'Category is required';
    }

    final cleanDesc = sanitize(description);
    if (cleanDesc.isEmpty) {
      errors['description'] = 'Description is required';
    } else if (cleanDesc.length < 10) {
      errors['description'] = 'Description must be at least 10 characters';
    } else if (cleanDesc.length > 1000) {
      errors['description'] = 'Description must be 1000 characters or fewer';
    }

    if (area.isEmpty) {
      errors['area'] = 'Neighborhood area is required';
    } else if (RegExp(r'\d+').hasMatch(area) &&
        RegExp(r'(flat|apt|apartment|room|bldg|building|street|road|st|lane)', caseSensitive: false).hasMatch(area)) {
      errors['area'] = 'Use a general sub-locality (e.g. Pali Hill), not an exact address';
    }

    return ValidationResult(isValid: errors.isEmpty, errors: errors);
  }

  Listing copyWith({
    String? id,
    String? title,
    String? categoryId,
    ListingType? type,
    String? description,
    String? area,
    ContactPreference? contactPreference,
    ListingStatus? status,
    String? neighborhoodId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? aiGenerated,
    int? expiryDays,
    String? imageUrl,
  }) {
    return Listing(
      id: id ?? this.id,
      title: title ?? this.title,
      categoryId: categoryId ?? this.categoryId,
      type: type ?? this.type,
      description: description ?? this.description,
      area: area ?? this.area,
      contactPreference: contactPreference ?? this.contactPreference,
      status: status ?? this.status,
      neighborhoodId: neighborhoodId ?? this.neighborhoodId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      aiGenerated: aiGenerated ?? this.aiGenerated,
      expiryDays: expiryDays ?? this.expiryDays,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'categoryId': categoryId,
      'type': type.name,
      'description': description,
      'area': area,
      'contactPreference': contactPreference.name,
      'status': status.name,
      'neighborhoodId': neighborhoodId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'aiGenerated': aiGenerated,
      'expiryDays': expiryDays,
      'imageUrl': imageUrl,
    };
  }

  factory Listing.fromMap(Map<String, dynamic> map) {
    return Listing(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      categoryId: map['categoryId'] ?? 'other',
      type: ListingType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ListingType.offer,
      ),
      description: map['description'] ?? '',
      area: map['area'] ?? 'Bandra West',
      contactPreference: ContactPreference.values.firstWhere(
        (e) => e.name == map['contactPreference'],
        orElse: () => ContactPreference.whatsapp,
      ),
      status: ListingStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ListingStatus.active,
      ),
      neighborhoodId: map['neighborhoodId'] ?? AppConfig.defaultNeighborhoodName,
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
      aiGenerated: map['aiGenerated'] ?? false,
      expiryDays: map['expiryDays'] ?? 7,
      imageUrl: map['imageUrl'],
    );
  }
}
