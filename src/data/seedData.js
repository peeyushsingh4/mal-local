import { Listing } from '../models/Listing.js';

export function getSeedListings() {
  return [
    new Listing({
      title: "Home-cooked Maharashtrian Tiffin",
      category: "food",
      type: "offer",
      description: "Authentic, home-cooked Maharashtrian meals delivered for lunch. Fresh, hygienic, and made with love. Options for veg and non-veg available.",
      area: "Hill Road",
      contactPreference: "whatsapp"
    }),
    new Listing({
      title: "Looking for Math Tutor for Class 10",
      category: "requests",
      type: "request",
      description: "Need an experienced tutor for Class 10 ICSE Mathematics. Prefer someone who can come home twice a week in the evenings.",
      area: "Pali Hill",
      contactPreference: "call"
    }),
    new Listing({
      title: "Lending: Camping Tent for weekend",
      category: "lending",
      type: "offer",
      description: "I have a 4-person Quechua camping tent that is rarely used. Happy to lend it to anyone going for a weekend trek or camp. Just return it clean!",
      area: "Carter Road",
      contactPreference: "chat"
    }),
    new Listing({
      title: "Electrician available - Pali Hill area",
      category: "services",
      type: "offer",
      description: "Experienced electrician available for any residential repairs, wiring, and appliance installation. Quick response and reasonable rates.",
      area: "Pali Hill",
      contactPreference: "call"
    }),
    new Listing({
      title: "Second-hand books - Fiction collection",
      category: "goods",
      type: "offer",
      description: "Clearing out my bookshelf. Have about 20 popular fiction novels (thrillers, romance, sci-fi). Giving them away for a very nominal price.",
      area: "Chapel Road",
      contactPreference: "chat"
    }),
    new Listing({
      title: "Need someone to walk my dog evenings",
      category: "requests",
      type: "request",
      description: "Looking for a dog lover to walk my friendly Golden Retriever for 45 minutes every evening. Paid arrangement.",
      area: "Carter Road",
      contactPreference: "whatsapp"
    }),
    new Listing({
      title: "Yoga classes at Carter Road park",
      category: "skills",
      type: "offer",
      description: "Morning yoga sessions for beginners and intermediates. Join a small group to improve flexibility, strength, and mindfulness outdoors.",
      area: "Carter Road",
      contactPreference: "in-person"
    }),
    new Listing({
      title: "Homemade pickles and chutneys",
      category: "food",
      type: "offer",
      description: "Delicious homemade mango, lemon, and mixed veg pickles. No preservatives used. Great accompaniment for your daily meals.",
      area: "Linking Road",
      contactPreference: "whatsapp"
    }),
    new Listing({
      title: "Looking for a reliable plumber",
      category: "requests",
      type: "request",
      description: "Need a plumber for some minor bathroom fixture repairs and leak fixes. If you know someone reliable or are one, please contact.",
      area: "Mount Mary",
      contactPreference: "call"
    }),
    new Listing({
      title: "Guitar lessons for beginners",
      category: "skills",
      type: "offer",
      description: "Learn to play acoustic guitar! I teach basics, chords, and strumming patterns. Can teach at your place or mine.",
      area: "Bandstand",
      contactPreference: "chat"
    })
  ];
}
