import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/models/listing.dart';
import 'listing_repository.dart';

class LocalListingRepository implements ListingRepository {
  static const String _storageKey = 'mal_local_listings_v1';
  final SharedPreferences _prefs;

  LocalListingRepository(this._prefs);

  static Future<LocalListingRepository> create() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalListingRepository(prefs);
  }

  @override
  Future<List<Listing>> getAll() async {
    final rawJson = _prefs.getString(_storageKey);
    if (rawJson == null || rawJson.isEmpty) return [];

    try {
      final List<dynamic> list = jsonDecode(rawJson);
      return list.map((item) => Listing.fromMap(Map<String, dynamic>.from(item))).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<Listing?> getById(String id) async {
    final all = await getAll();
    try {
      return all.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Listing>> getByCategory(String categoryId) async {
    final all = await getAll();
    return all.where((l) => l.categoryId == categoryId).toList();
  }

  @override
  Future<List<Listing>> getByStatus(ListingStatus status) async {
    final all = await getAll();
    return all.where((l) => l.status == status).toList();
  }

  @override
  Future<List<Listing>> getByType(ListingType type) async {
    final all = await getAll();
    return all.where((l) => l.type == type).toList();
  }

  @override
  Future<Listing> save(Listing listing) async {
    final validation = listing.validate();
    if (!validation.isValid) {
      throw Exception('Validation failed: ${validation.errors.values.join(", ")}');
    }

    final all = await getAll();
    final index = all.indexWhere((l) => l.id == listing.id);

    if (index >= 0) {
      all[index] = listing;
    } else {
      all.add(listing);
    }

    await _persistAll(all);
    return listing;
  }

  @override
  Future<Listing> updateStatus(String id, ListingStatus newStatus) async {
    final listing = await getById(id);
    if (listing == null) {
      throw Exception('Listing with id $id not found');
    }

    final updated = listing.copyWith(
      status: newStatus,
      updatedAt: DateTime.now(),
    );

    return await save(updated);
  }

  @override
  Future<void> delete(String id) async {
    final all = await getAll();
    all.removeWhere((l) => l.id == id);
    await _persistAll(all);
  }

  @override
  Future<void> clearAll() async {
    await _prefs.remove(_storageKey);
  }

  @override
  Future<int> count() async {
    final all = await getAll();
    return all.length;
  }

  @override
  Future<void> seedIfEmpty(List<Listing> seedListings) async {
    final current = await getAll();
    if (current.isEmpty) {
      await _persistAll(seedListings);
    }
  }

  Future<void> _persistAll(List<Listing> listings) async {
    final mapList = listings.map((l) => l.toMap()).toList();
    await _prefs.setString(_storageKey, jsonEncode(mapList));
  }
}
