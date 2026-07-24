export class IndexedDbAdapter {
  constructor(dbName = 'mal-local', version = 1) {
    this.dbName = dbName;
    this.version = version;
    this.db = null;
  }

  async open() {
    return new Promise((resolve, reject) => {
      // For SSR/Node environments where indexedDB is not available
      if (typeof indexedDB === 'undefined') {
        return reject(new Error('indexedDB is not available in this environment'));
      }

      const request = indexedDB.open(this.dbName, this.version);

      request.onerror = (event) => {
        console.error('IndexedDB open error:', event.target.error);
        reject(event.target.error);
      };

      request.onsuccess = (event) => {
        this.db = event.target.result;
        resolve(this.db);
      };

      request.onupgradeneeded = (event) => {
        const db = event.target.result;
        if (!db.objectStoreNames.contains('listings')) {
          db.createObjectStore('listings', { keyPath: 'id' });
        }
      };
    });
  }

  _getStore(storeName, mode = 'readonly') {
    if (!this.db) {
      throw new Error('Database not initialized. Call open() first.');
    }
    const transaction = this.db.transaction([storeName], mode);
    return transaction.objectStore(storeName);
  }

  async getAll(storeName) {
    return new Promise((resolve, reject) => {
      try {
        const store = this._getStore(storeName, 'readonly');
        const request = store.getAll();

        request.onsuccess = () => resolve(request.result);
        request.onerror = () => {
          console.error(`getAll error in ${storeName}:`, request.error);
          reject(request.error);
        };
      } catch (err) {
        console.error(`Error in getAll(${storeName}):`, err);
        resolve([]); // Graceful fallback
      }
    });
  }

  async getById(storeName, id) {
    return new Promise((resolve, reject) => {
      try {
        const store = this._getStore(storeName, 'readonly');
        const request = store.get(id);

        request.onsuccess = () => resolve(request.result || null);
        request.onerror = () => {
          console.error(`getById error in ${storeName} for id ${id}:`, request.error);
          reject(request.error);
        };
      } catch (err) {
        console.error(`Error in getById(${storeName}, ${id}):`, err);
        resolve(null);
      }
    });
  }

  async put(storeName, record) {
    return new Promise((resolve, reject) => {
      try {
        const store = this._getStore(storeName, 'readwrite');
        const request = store.put(record);

        request.onsuccess = () => resolve(record);
        request.onerror = () => {
          console.error(`put error in ${storeName}:`, request.error);
          reject(request.error);
        };
      } catch (err) {
        console.error(`Error in put(${storeName}):`, err);
        reject(err);
      }
    });
  }

  async delete(storeName, id) {
    return new Promise((resolve, reject) => {
      try {
        const store = this._getStore(storeName, 'readwrite');
        const request = store.delete(id);

        request.onsuccess = () => resolve(true);
        request.onerror = () => {
          console.error(`delete error in ${storeName} for id ${id}:`, request.error);
          reject(request.error);
        };
      } catch (err) {
        console.error(`Error in delete(${storeName}, ${id}):`, err);
        reject(err);
      }
    });
  }

  async clear(storeName) {
    return new Promise((resolve, reject) => {
      try {
        const store = this._getStore(storeName, 'readwrite');
        const request = store.clear();

        request.onsuccess = () => resolve(true);
        request.onerror = () => {
          console.error(`clear error in ${storeName}:`, request.error);
          reject(request.error);
        };
      } catch (err) {
        console.error(`Error in clear(${storeName}):`, err);
        reject(err);
      }
    });
  }

  async count(storeName) {
    return new Promise((resolve, reject) => {
      try {
        const store = this._getStore(storeName, 'readonly');
        const request = store.count();

        request.onsuccess = () => resolve(request.result);
        request.onerror = () => {
          console.error(`count error in ${storeName}:`, request.error);
          reject(request.error);
        };
      } catch (err) {
        console.error(`Error in count(${storeName}):`, err);
        resolve(0);
      }
    });
  }
}
