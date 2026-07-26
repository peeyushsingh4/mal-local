import '../models/listing.dart';
import '../models/category.dart';
import 'local_ai_service.dart';

class DeterministicAiService implements LocalAiService {
  @override
  Future<ListingSuggestion> suggestListingDetails(String rawInput) async {
    final cleanInput = rawInput.trim();
    if (cleanInput.isEmpty) {
      return ListingSuggestion(
        title: '',
        categoryId: 'other',
        description: '',
        confidence: 'deterministic-fallback',
      );
    }

    final lower = cleanInput.toLowerCase();
    String categoryId = 'other';

    // Category Keyword Map
    final categoryKeywords = <String, List<String>>{
      'food': ['tiffin', 'food', 'pickle', 'lunch', 'dinner', 'cake', 'cook', 'biryani', 'snack', 'paratha', 'chai'],
      'services': ['plumber', 'electrician', 'repair', 'ac', 'maid', 'driver', 'carpenter', 'painter', 'service'],
      'goods': ['table', 'chair', 'book', 'books', 'phone', 'laptop', 'sofa', 'tv', 'electronics', 'furniture', 'sell'],
      'lending': ['lend', 'borrow', 'tent', 'ladder', 'drill', 'camera', 'gear', 'tripod', 'tool'],
      'requests': ['need', 'looking for', 'wanted', 'required', 'urgent', 'walk', 'dog walker'],
      'skills': ['tutor', 'yoga', 'guitar', 'class', 'lessons', 'teach', 'coaching', 'math', 'physics', 'coding'],
    };

    for (final entry in categoryKeywords.entries) {
      if (entry.value.any((k) => lower.contains(k))) {
        categoryId = entry.key;
        break;
      }
    }

    // Capitalize first letter for title
    final title = cleanInput.length > 50
        ? '${cleanInput.substring(0, 47)}...'
        : cleanInput[0].toUpperCase() + cleanInput.substring(1);

    // Generate clean template description
    String generatedDescription = '';

    switch (categoryId) {
      case 'food':
        generatedDescription = '$title — freshly prepared in Bandra West. Made with quality home ingredients. Feel free to reach out to place an order or inquire about availability.';
        break;
      case 'services':
        generatedDescription = 'Offering $title in the Bandra West area. Experienced, reliable, and prompt. Contact to discuss schedule and requirements.';
        break;
      case 'goods':
        generatedDescription = '$title available in Bandra West. In good working condition and fairly priced. Pickup can be arranged locally.';
        break;
      case 'lending':
        generatedDescription = 'Available to lend: $title. Free to borrow for Bandra West neighbors for a reasonable period. Please return in good condition.';
        break;
      case 'requests':
        generatedDescription = 'Looking for $title in Bandra West. If you can help or know someone who can, please reach out!';
        break;
      case 'skills':
        generatedDescription = '$title available in Bandra West. Suitable for beginners or intermediate learners. Contact to discuss class timing and details.';
        break;
      default:
        generatedDescription = '$title available locally in Bandra West. Contact to discuss details.';
    }

    return ListingSuggestion(
      title: title,
      categoryId: categoryId,
      description: generatedDescription,
      confidence: 'deterministic-fallback',
    );
  }

  @override
  Future<List<Listing>> searchListings(String query, List<Listing> corpus) async {
    final cleanQ = query.trim().toLowerCase();
    if (cleanQ.isEmpty) return corpus;

    // Split search terms
    final terms = cleanQ.split(RegExp(r'\s+'));

    final results = corpus.where((listing) {
      final title = listing.title.toLowerCase();
      final desc = listing.description.toLowerCase();
      final area = listing.area.toLowerCase();
      final cat = ListingCategory.getById(listing.categoryId).name.toLowerCase();

      // Check if all terms match title, desc, area, or category
      return terms.every((term) =>
          title.contains(term) ||
          desc.contains(term) ||
          area.contains(term) ||
          cat.contains(term));
    }).toList();

    return results;
  }

  @override
  Future<SafetyFlag> checkListingSafety(Listing draft) async {
    final issues = <String>[];

    // Check 1: Exact address check (House/Flat/Room numbers + Building/Street)
    final addressRegex = RegExp(r'\b(flat|apt|apartment|room|bldg|building|house)\s*#?\s*\d+\b', caseSensitive: false);
    if (addressRegex.hasMatch(draft.description) || addressRegex.hasMatch(draft.area)) {
      issues.add('Contains exact house or building address (use coarse area like Pali Hill)');
    }

    // Check 2: Phone number embedded in title or description (should use Contact Preference)
    final phoneRegex = RegExp(r'(\+?\d{1,4}[-.\s]?)?\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}');
    if (phoneRegex.hasMatch(draft.title) || phoneRegex.hasMatch(draft.description)) {
      issues.add('Contains a phone number in text (use Contact Preference selector for privacy)');
    }

    // Check 3: Sensitive PII keywords
    final piiRegex = RegExp(r'\b(aadhaar|pan card|passport|credit card|pincode|otp)\b', caseSensitive: false);
    if (piiRegex.hasMatch(draft.description)) {
      issues.add('Contains sensitive personal identification info (PII)');
    }

    final isRisky = issues.isNotEmpty;
    return SafetyFlag(
      isRisky: isRisky,
      warningMessage: isRisky
          ? 'Privacy Warning: Please review detected sensitive issues before posting.'
          : null,
      detectedIssues: issues,
    );
  }
}
