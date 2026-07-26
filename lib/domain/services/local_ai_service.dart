import '../models/listing.dart';

class ListingSuggestion {
  final String title;
  final String categoryId;
  final String description;
  final String confidence; // e.g. "gemma-local" or "deterministic-fallback"

  ListingSuggestion({
    required this.title,
    required this.categoryId,
    required this.description,
    required this.confidence,
  });
}

class SafetyFlag {
  final bool isRisky;
  final String? warningMessage;
  final List<String> detectedIssues;

  SafetyFlag({
    required this.isRisky,
    this.warningMessage,
    this.detectedIssues = const [],
  });
}

abstract class LocalAiService {
  Future<ListingSuggestion> suggestListingDetails(String rawInput);
  Future<List<Listing>> searchListings(String query, List<Listing> corpus);
  Future<SafetyFlag> checkListingSafety(Listing draft);
}
