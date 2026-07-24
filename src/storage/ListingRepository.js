import { IndexedDbAdapter } from './IndexedDbAdapter.js';
import { Listing } from '../models/Listing.js';

export class ListingRepository {
  constructor(adapter = new IndexedDbAdapter()) {
    this.adapter = adapter;
    this.storeName = 'listings';
    this._ready = this.adapter.open().catch(err => {
      console.error('Failed to open IndexedDB via ListingRepository:', err);
    });
  }

  async _ensureReady() {
    await this._ready;
  }

  async getAll() {
    await this._ensureReady();
    const rawListings = await this.adapter.getAll(this.storeName);
    return rawListings.map(Listing.fromJSON);
  }

  async getById(id) {
    await this._ensureReady();
    const rawListing = await this.adapter.getById(this.storeName, id);
    return rawListing ? Listing.fromJSON(rawListing) : null;
  }

  async getByNeighborhood(neighborhoodId) {
    const all = await this.getAll();
    return all.filter(l => l.neighborhoodId === neighborhoodId);
  }

  async getByCategory(category) {
    const all = await this.getAll();
    return all.filter(l => l.category === category);
  }

  async getByStatus(status) {
    const all = await this.getAll();
    return all.filter(l => l.status === status);
  }

  async save(listing) {
    await this._ensureReady();
    const validation = listing.validate();
    if (!validation.valid) {
      throw new Error(`Validation failed: ${validation.errors.join(', ')}`);
    }
    
    await this.adapter.put(this.storeName, listing.toJSON());
    return listing;
  }

  async update(id, changes) {
    await this._ensureReady();
    const listing = await this.getById(id);
    if (!listing) {
      throw new Error(`Listing with id ${id} not found.`);
    }

    // Apply changes
    Object.assign(listing, changes);
    listing.updatedAt = new Date().toISOString();
    
    return await this.save(listing);
  }

  async delete(id) {
    await this._ensureReady();
    await this.adapter.delete(this.storeName, id);
  }

  async deleteAll() {
    await this._ensureReady();
    await this.adapter.clear(this.storeName);
  }

  async count() {
    await this._ensureReady();
    return await this.adapter.count(this.storeName);
  }

  async seed(listings) {
    await this._ensureReady();
    const currentCount = await this.count();
    if (currentCount === 0) {
      console.log('Seeding initial listings data...');
      for (const listing of listings) {
        await this.save(listing);
      }
      console.log(`Seeded ${listings.length} listings.`);
    }
  }
}

export const listingRepository = new ListingRepository();
