export class DeterministicFallback {
  /**
   * Generate a listing description suggestion from title + category.
   * Uses template-based generation with category-specific patterns.
   * @param {string} title - The listing title
   * @param {string} category - The category id (services, goods, lending, food, requests, skills)
   * @returns {{ description: string, confidence: string }}
   */
  suggestDescription(title, category) {
    const defaultTemplates = [
      `Available in Bandra West: ${title}. Feel free to reach out for more details!`,
      `Offering ${title} locally in Bandra West. Message me if you are interested or have any questions.`,
      `Check out ${title} in the Bandra West area. Get in touch to learn more.`
    ];

    const templates = {
      services: [
        `Offering ${title} in the Bandra West area. Reliable and experienced. Reach out to discuss availability, rates, and any specific requirements you may have.`,
        `Professional ${title} available in Bandra West. Dedicated to providing quality service tailored to your needs. Contact me to get started.`,
        `Local ${title} services in Bandra West. Fast, friendly, and efficient. Send a message to inquire about scheduling and pricing.`,
        `Need help with ${title}? I'm based in Bandra West and ready to assist. Drop a message to discuss how I can help you.`
      ],
      goods: [
        `${title} available in Bandra West. In good condition and fairly priced. Happy to share photos or answer questions. Pickup can be arranged locally.`,
        `Selling ${title} in the Bandra West neighborhood. Well-maintained and ready for a new owner. DM for details or to arrange a viewing.`,
        `Great deal on ${title} right here in Bandra West. First come, first served! Reach out if you'd like to check it out in person.`,
        `${title} for sale locally in Bandra West. Grab it before it's gone! Feel free to message with any questions.`
      ],
      lending: [
        `Available to lend: ${title}. Located in Bandra West. Free to borrow for a reasonable period. Please take good care and return in the same condition.`,
        `Happy to lend out my ${title} to neighbors in Bandra West. Just return it when you're done! Message me to arrange pickup.`,
        `Need a ${title} for a short while? I have one available to lend in Bandra West. Let's share resources! Reach out to coordinate.`,
        `Lending my ${title} in Bandra West. Perfect if you only need it temporarily. Treat it well and we're all good.`
      ],
      food: [
        `${title} — freshly prepared in Bandra West. Made with quality ingredients and care. Perfect for those looking for homemade options in the neighborhood.`,
        `Delicious homemade ${title} available in Bandra West. Cooked with love and fresh ingredients. Message to place an order or check availability.`,
        `Craving ${title}? Get it fresh in Bandra West! Authentic, tasty, and made to order. Reach out for menu and delivery/pickup details.`,
        `Treat yourself to some lovely ${title} made right here in Bandra West. Wholesome and flavorful. Contact me to get yours!`
      ],
      requests: [
        `Looking for ${title} in the Bandra West area. If you can help or know someone who can, please reach out. Flexible on timing and happy to discuss details.`,
        `Seeking ${title} around Bandra West. Willing to pay a fair price or trade services. Please message me if you have any leads!`,
        `In need of ${title} locally in Bandra West. Hoping a neighbor can help out. Get in touch if you have what I'm looking for.`,
        `Requesting ${title} in Bandra West. If you offer this or have it available, I'd love to hear from you. Let's connect.`
      ],
      skills: [
        `${title} available in Bandra West. Whether you're a beginner or looking to improve, this is a great opportunity to learn. Get in touch to discuss schedule and approach.`,
        `Offering guidance in ${title} right here in Bandra West. Patient and experienced. Let's unlock your potential together! Message for details.`,
        `Learn ${title} locally in Bandra West. Tailored sessions to suit your pace and goals. Reach out to start your learning journey.`,
        `Sharing my expertise in ${title} with the Bandra West community. Fun, engaging, and practical. Contact me to book a session.`
      ]
    };

    const categoryTemplates = templates[category?.toLowerCase()] || defaultTemplates;
    const randomIndex = Math.floor(Math.random() * categoryTemplates.length);
    const description = categoryTemplates[randomIndex];

    return { description, confidence: 'template' };
  }

  /**
   * Suggest relevant tags/keywords for a listing.
   * @param {string} title
   * @param {string} category
   * @returns {string[]}
   */
  suggestTags(title, category) {
    const stopWords = new Set(['in', 'the', 'and', 'for', 'a', 'an', 'of', 'to', 'with', 'on', 'at']);
    const words = title.toLowerCase().split(/[\s,.-]+/).filter(w => w.length > 2 && !stopWords.has(w));
    
    const tags = new Set(words);
    tags.add('bandra-west');
    tags.add('mumbai');
    
    if (category) {
      tags.add(category.toLowerCase());
      
      // Add a few relevant keywords based on category
      switch(category.toLowerCase()) {
        case 'services': tags.add('service'); tags.add('local-service'); break;
        case 'goods': tags.add('item'); tags.add('second-hand'); break;
        case 'lending': tags.add('borrow'); tags.add('share'); break;
        case 'food': tags.add('homemade'); tags.add('fresh'); break;
        case 'requests': tags.add('wanted'); tags.add('looking-for'); break;
        case 'skills': tags.add('learn'); tags.add('teach'); break;
      }
    }
    
    return Array.from(tags).slice(0, 5); // Return top 5 tags
  }

  isAvailable() {
    return true; // Always available
  }
}
