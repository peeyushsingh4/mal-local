export class Listing {
  constructor({
    id = crypto.randomUUID(),
    title = '',
    category = '',
    type = 'offer',  // 'offer' or 'request'
    description = '',
    area = '',
    contactPreference = 'chat',  // 'chat', 'call', 'whatsapp', 'in-person'
    status = 'active',  // 'active', 'saved', 'contacted', 'closed'
    neighborhoodId = 'bandra-west',
    createdAt = new Date().toISOString(),
    updatedAt = new Date().toISOString(),
    aiGenerated = false,  // whether description was AI-assisted
  } = {}) {
    this.id = id;
    this.title = this._stripHtml(title);
    this.category = category;
    this.type = type;
    this.description = this._stripHtml(description);
    this.area = this._stripHtml(area);
    this.contactPreference = contactPreference;
    this.status = status;
    this.neighborhoodId = neighborhoodId;
    this.createdAt = createdAt;
    this.updatedAt = updatedAt;
    this.aiGenerated = aiGenerated;
  }

  _stripHtml(str) {
    if (typeof str !== 'string') return str;
    return str.replace(/<[^>]*>?/gm, '').trim();
  }

  validate() {
    const errors = [];
    
    // Title
    if (!this.title) {
      errors.push('Title is required');
    } else if (this.title.length < 3) {
      errors.push('Title must be at least 3 characters');
    } else if (this.title.length > 100) {
      errors.push('Title must be at most 100 characters');
    }

    // Category
    if (!this.category) {
      errors.push('Category is required');
    }

    // Description
    if (!this.description) {
      errors.push('Description is required');
    } else if (this.description.length < 10) {
      errors.push('Description must be at least 10 characters');
    } else if (this.description.length > 1000) {
      errors.push('Description must be at most 1000 characters');
    }

    // Area
    if (!this.area) {
      errors.push('Area is required');
    } else if (/\d+/.test(this.area) && /(block|flat|apartment|apt|house|bldg|building|road|street)/i.test(this.area)) {
       // Rough heuristic to reject exact addresses
       errors.push('Area should be a general neighborhood area, not an exact address');
    }

    return {
      valid: errors.length === 0,
      errors
    };
  }

  toJSON() {
    return {
      id: this.id,
      title: this.title,
      category: this.category,
      type: this.type,
      description: this.description,
      area: this.area,
      contactPreference: this.contactPreference,
      status: this.status,
      neighborhoodId: this.neighborhoodId,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
      aiGenerated: this.aiGenerated,
    };
  }

  static fromJSON(obj) {
    return new Listing(obj);
  }
}
