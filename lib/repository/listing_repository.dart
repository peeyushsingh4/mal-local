import '../domain/models/listing.dart';

abstract class ListingRepository {
  Future<List<Listing>> getAll();
  Future<Listing?> getById(String id);
  Future<List<Listing>> getByCategory(String categoryId);
  Future<List<Listing>> getByStatus(ListingStatus status);
  Future<List<Listing>> getByType(ListingType type);
  Future<Listing> save(Listing listing);
  Future<Listing> updateStatus(String id, ListingStatus newStatus);
  Future<void> delete(String id);
  Future<void> clearAll();
  Future<int> count();
  Future<void> seedIfEmpty(List<Listing> seedListings);
}
